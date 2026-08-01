-- ═══════════════════════════════════════════════════════════════════
-- AgroMart Migration 005 — Payments, transactions, wallet (PostgreSQL)
-- Tables: payment_methods, payments, transactions, audit_logs
-- Consolidates base schema + migration 006 (wallet trigger fix).
-- Depends on: 001(users), 004(orders). subscriptions FK deferred to 008.
--
-- FIXES folded in (from the code review):
--  * wallet update is atomic (wallet_balance + NEW.amount) — no lost-update race
--  * balance_before/after set in a BEFORE trigger (legal in PG; MySQL errored 1442)
--  * external (payment_method-backed) purchases don't touch wallet (migration 006 intent)
-- ═══════════════════════════════════════════════════════════════════
BEGIN;

CREATE TABLE payment_methods (
    method_id      INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id        INTEGER NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    method_type    VARCHAR(15) NOT NULL
                   CHECK (method_type IN ('bkash','nagad','rocket','bank_transfer','wallet')),
    account_number VARCHAR(50) NOT NULL,
    account_name   VARCHAR(100),
    bank_name      VARCHAR(100),
    is_default     BOOLEAN DEFAULT FALSE,
    is_verified    BOOLEAN DEFAULT FALSE,
    created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_payment_method UNIQUE (user_id, method_type, account_number)
);
CREATE TRIGGER payment_methods_set_updated_at BEFORE UPDATE ON payment_methods
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE payments (
    payment_id      INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    payment_reference VARCHAR(50) NOT NULL UNIQUE,
    order_id        INTEGER REFERENCES orders(order_id) ON DELETE SET NULL,
    subscription_id INTEGER,  -- FK to subscriptions added in 008 (deferred)
    user_id         INTEGER NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    gateway         VARCHAR(12) NOT NULL
                    CHECK (gateway IN ('sslcommerz','bkash','nagad','rocket','mock','cod')),
    gateway_transaction_id VARCHAR(100),
    gateway_session_key    VARCHAR(255),
    amount          NUMERIC(12,2) NOT NULL CHECK (amount >= 0),
    currency        CHAR(3) DEFAULT 'BDT',
    status          VARCHAR(12) NOT NULL DEFAULT 'initiated'
                    CHECK (status IN ('initiated','pending','success','failed','cancelled','refunded')),
    failure_reason  VARCHAR(255),
    raw_request     JSONB,
    raw_response    JSONB,
    ipn_payload     JSONB,
    initiated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    completed_at    TIMESTAMPTZ,
    refunded_at     TIMESTAMPTZ,
    refund_amount   NUMERIC(12,2) DEFAULT 0,
    refund_reason   VARCHAR(255)
);
CREATE INDEX idx_payments_order ON payments(order_id);
CREATE INDEX idx_payments_user  ON payments(user_id, status);

-- orders.payment_id FK now that payments exists
ALTER TABLE orders ADD CONSTRAINT orders_payment_fk
    FOREIGN KEY (payment_id) REFERENCES payments(payment_id) ON DELETE SET NULL;

CREATE TABLE transactions (
    transaction_id  INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id         INTEGER NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    transaction_type VARCHAR(20) NOT NULL
                    CHECK (transaction_type IN ('sale','purchase','loan_disbursement','loan_repayment',
                                                'commission','refund','withdrawal','deposit')),
    amount          NUMERIC(12,2) NOT NULL CHECK (amount >= 0),
    currency        CHAR(3) DEFAULT 'BDT',
    transaction_status VARCHAR(10) DEFAULT 'pending'
                    CHECK (transaction_status IN ('pending','completed','failed','cancelled')),
    payment_method_id INTEGER REFERENCES payment_methods(method_id) ON DELETE SET NULL,
    related_order_id INTEGER REFERENCES orders(order_id) ON DELETE SET NULL,
    related_loan_id INTEGER,  -- FK to loans added in 006 (deferred)
    reference_number VARCHAR(100) UNIQUE,
    description     VARCHAR(255),
    balance_before  NUMERIC(12,2),
    balance_after   NUMERIC(12,2),
    is_flagged      BOOLEAN DEFAULT FALSE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    completed_at    TIMESTAMPTZ
);
CREATE INDEX idx_transactions_user ON transactions(user_id, created_at DESC);

CREATE TABLE audit_logs (
    log_id          INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id         INTEGER REFERENCES users(user_id) ON DELETE SET NULL,
    action_type     VARCHAR(50) NOT NULL,
    table_name      VARCHAR(50) NOT NULL,
    record_id       INTEGER,
    old_values      JSONB,
    new_values      JSONB,
    ip_address      VARCHAR(45),
    user_agent      VARCHAR(255),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_audit_logs_user ON audit_logs(user_id, created_at DESC);
CREATE INDEX idx_audit_logs_record ON audit_logs(table_name, record_id);

-- ─── WALLET TRIGGERS (fixes folded in) ──────────────────────────────
-- BEFORE: stamp balance_before/after (legal in PG BEFORE trigger)
CREATE OR REPLACE FUNCTION tr_txn_before_insert() RETURNS TRIGGER AS $$
DECLARE cur NUMERIC(12,2);
BEGIN
    SELECT COALESCE(wallet_balance,0) INTO cur FROM users WHERE user_id = NEW.user_id;
    NEW.balance_before := cur;
    IF NEW.transaction_type IN ('sale','deposit','loan_disbursement','refund','commission') THEN
        NEW.balance_after := cur + NEW.amount;
    ELSE
        NEW.balance_after := GREATEST(0, cur - NEW.amount);
    END IF;
    RETURN NEW;
END; $$ LANGUAGE plpgsql;

CREATE TRIGGER txn_before_insert BEFORE INSERT ON transactions
    FOR EACH ROW EXECUTE FUNCTION tr_txn_before_insert();

-- AFTER: apply the wallet change atomically, only for completed, wallet-backed txns.
-- Migration 006 intent: a purchase paid via an external payment_method_id must NOT
-- debit the wallet (the money came from the gateway, not the wallet).
CREATE OR REPLACE FUNCTION tr_txn_after_insert() RETURNS TRIGGER AS $$
BEGIN
    IF NEW.transaction_status = 'completed' THEN
        IF NEW.transaction_type IN ('sale','deposit','loan_disbursement','refund','commission') THEN
            UPDATE users SET wallet_balance = wallet_balance + NEW.amount
                WHERE user_id = NEW.user_id;
        ELSIF NEW.transaction_type IN ('purchase','withdrawal','loan_repayment')
              AND NEW.payment_method_id IS NULL THEN
            -- only wallet-backed debits reduce the wallet
            UPDATE users SET wallet_balance = GREATEST(0, wallet_balance - NEW.amount)
                WHERE user_id = NEW.user_id;
        END IF;
    END IF;
    RETURN NEW;
END; $$ LANGUAGE plpgsql;

CREATE TRIGGER txn_after_insert AFTER INSERT ON transactions
    FOR EACH ROW EXECUTE FUNCTION tr_txn_after_insert();

COMMIT;
