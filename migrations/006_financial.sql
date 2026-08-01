-- ═══════════════════════════════════════════════════════════════════
-- AgroMart Migration 006 — Financial (PostgreSQL)
-- Tables: farmer_ratings, loans, loan_repayments, expenses
-- Depends on: 001(users), 003(crops), 004(orders), 007(agents for loan.agent_id deferred)
-- ═══════════════════════════════════════════════════════════════════
BEGIN;

CREATE TABLE farmer_ratings (
    rating_id       INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    farmer_id       INTEGER NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    buyer_id        INTEGER NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    order_id        INTEGER NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    overall_rating  NUMERIC(2,1) NOT NULL CHECK (overall_rating BETWEEN 1 AND 5),
    quality_rating  NUMERIC(2,1) NOT NULL CHECK (quality_rating BETWEEN 1 AND 5),
    delivery_rating NUMERIC(2,1) NOT NULL CHECK (delivery_rating BETWEEN 1 AND 5),
    communication_rating NUMERIC(2,1) NOT NULL CHECK (communication_rating BETWEEN 1 AND 5),
    review_title    VARCHAR(100),
    review_text     TEXT,
    review_images   JSONB,
    would_recommend BOOLEAN DEFAULT TRUE,
    is_verified_purchase BOOLEAN DEFAULT TRUE,
    helpful_count   INTEGER DEFAULT 0,
    farmer_response TEXT,
    responded_at    TIMESTAMPTZ,
    is_flagged      BOOLEAN DEFAULT FALSE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_rating_per_order UNIQUE (order_id, buyer_id)
);
CREATE INDEX idx_ratings_farmer ON farmer_ratings(farmer_id);

CREATE TABLE loans (
    loan_id         INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    farmer_id       INTEGER NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    loan_amount     NUMERIC(12,2) NOT NULL CHECK (loan_amount > 0),
    interest_rate   NUMERIC(5,2) DEFAULT 5.00,
    loan_purpose    VARCHAR(255) NOT NULL,
    tenure_months   INTEGER NOT NULL CHECK (tenure_months > 0),
    monthly_installment NUMERIC(10,2) NOT NULL,
    total_payable   NUMERIC(12,2) NOT NULL,
    amount_paid     NUMERIC(12,2) DEFAULT 0,
    remaining_balance NUMERIC(12,2) NOT NULL,
    credit_score_at_application INTEGER,
    application_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    approval_date   TIMESTAMPTZ,
    disbursement_date TIMESTAMPTZ,
    next_payment_date DATE,
    status          VARCHAR(12) DEFAULT 'pending'
                    CHECK (status IN ('pending','approved','rejected','disbursed','active','completed','defaulted')),
    approved_by     INTEGER REFERENCES users(user_id) ON DELETE SET NULL,
    rejection_reason VARCHAR(255),
    assisted_by_agent BOOLEAN DEFAULT FALSE,
    agent_id        INTEGER,  -- FK to agents added in 007 (deferred)
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_loans_farmer ON loans(farmer_id, status);
CREATE TRIGGER loans_set_updated_at BEFORE UPDATE ON loans
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- transactions.related_loan_id FK now that loans exists
ALTER TABLE transactions ADD CONSTRAINT transactions_loan_fk
    FOREIGN KEY (related_loan_id) REFERENCES loans(loan_id) ON DELETE SET NULL;

CREATE TABLE loan_repayments (
    repayment_id    INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    loan_id         INTEGER NOT NULL REFERENCES loans(loan_id) ON DELETE CASCADE,
    payment_amount  NUMERIC(10,2) NOT NULL CHECK (payment_amount > 0),
    payment_date    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    payment_method  VARCHAR(15) DEFAULT 'auto_deduction'
                    CHECK (payment_method IN ('auto_deduction','manual','cash','mobile_banking')),
    transaction_reference VARCHAR(100),
    late_fee        NUMERIC(8,2) DEFAULT 0,
    is_early_payment BOOLEAN DEFAULT FALSE,
    remaining_after_payment NUMERIC(12,2) NOT NULL,
    recorded_by     INTEGER REFERENCES users(user_id) ON DELETE SET NULL,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_loan_repayments_loan ON loan_repayments(loan_id, payment_date DESC);

CREATE TABLE expenses (
    expense_id      INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    farmer_id       INTEGER NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    crop_id         INTEGER REFERENCES crops(crop_id) ON DELETE SET NULL,
    expense_category VARCHAR(12) NOT NULL
                    CHECK (expense_category IN ('seeds','fertilizer','pesticide','labor',
                                                'irrigation','equipment','transport','other')),
    expense_amount  NUMERIC(10,2) NOT NULL CHECK (expense_amount >= 0),
    expense_description VARCHAR(255),
    expense_date    DATE NOT NULL,
    receipt_url     VARCHAR(255),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_expenses_farmer ON expenses(farmer_id, expense_date DESC);

COMMIT;
