-- ═══════════════════════════════════════════════════════════════════
-- AgroFin Migration 004: Trust Layer Tables
-- ═══════════════════════════════════════════════════════════════════
-- Adds three tables and one column for Update Chunk 3:
--   1. otp_codes        — OTP send/verify with rate limiting + expiry
--   2. payments         — payment gateway transactions
--   3. orders.payment_gateway columns
-- ═══════════════════════════════════════════════════════════════════

USE agrofin;

-- ─── 1. OTP CODES ──────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS otp_codes (
    otp_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    phone VARCHAR(15) NOT NULL,
    code_hash VARCHAR(255) NOT NULL,        -- bcrypt hash; never store raw OTP
    purpose ENUM('register','login','reset_password','verify_phone','two_factor') NOT NULL,
    expires_at TIMESTAMP NOT NULL,
    attempts TINYINT UNSIGNED NOT NULL DEFAULT 0,
    max_attempts TINYINT UNSIGNED NOT NULL DEFAULT 5,
    verified_at TIMESTAMP NULL,
    request_ip VARCHAR(45),
    sent_via ENUM('sms','log','email') NOT NULL DEFAULT 'log',
    provider_response TEXT,                 -- JSON payload from SMS provider
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_phone_purpose (phone, purpose, created_at),
    INDEX idx_expires (expires_at),
    INDEX idx_unverified (phone, verified_at, expires_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ─── 2. PAYMENTS LEDGER ────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS payments (
    payment_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    payment_reference VARCHAR(50) NOT NULL UNIQUE,
    order_id INT UNSIGNED,                  -- nullable: standalone payments possible
    subscription_id INT UNSIGNED,           -- nullable: subscription auto-charges
    user_id INT UNSIGNED NOT NULL,
    gateway ENUM('sslcommerz','bkash','nagad','rocket','mock','cod') NOT NULL,
    gateway_transaction_id VARCHAR(100),    -- the provider's TXN ID
    gateway_session_key VARCHAR(255),       -- provider session/checkout token
    amount DECIMAL(12,2) NOT NULL,
    currency CHAR(3) DEFAULT 'BDT',
    status ENUM('initiated','pending','success','failed','cancelled','refunded') NOT NULL DEFAULT 'initiated',
    failure_reason VARCHAR(255),
    raw_request JSON,                       -- what we sent
    raw_response JSON,                      -- what came back (last)
    ipn_payload JSON,                       -- webhook payload (verified)
    initiated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP NULL,
    refunded_at TIMESTAMP NULL,
    refund_amount DECIMAL(12,2) DEFAULT 0,
    refund_reason VARCHAR(255),
    INDEX idx_order (order_id),
    INDEX idx_subscription (subscription_id),
    INDEX idx_user (user_id),
    INDEX idx_gateway_txn (gateway, gateway_transaction_id),
    INDEX idx_status_date (status, initiated_at),
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE SET NULL,
    FOREIGN KEY (subscription_id) REFERENCES subscriptions(subscription_id) ON DELETE SET NULL,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ─── 3. ORDERS payment-gateway columns ─────────────────────────────
-- Add columns only if they don't already exist (idempotent)
DROP PROCEDURE IF EXISTS migration_004_orders;
DELIMITER $$
CREATE PROCEDURE migration_004_orders()
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA = 'agrofin' AND TABLE_NAME = 'orders'
          AND COLUMN_NAME = 'payment_gateway'
    ) THEN
        ALTER TABLE orders
            ADD COLUMN payment_gateway VARCHAR(30) AFTER payment_method,
            ADD COLUMN payment_id INT UNSIGNED NULL AFTER payment_gateway,
            ADD INDEX idx_payment (payment_id);
    END IF;
END$$
DELIMITER ;
CALL migration_004_orders();
DROP PROCEDURE migration_004_orders;

-- Update the orders.order_status ENUM to include 'pending_payment'
-- (only if not already there — we use a column-modification approach)
DROP PROCEDURE IF EXISTS migration_004_status;
DELIMITER $$
CREATE PROCEDURE migration_004_status()
BEGIN
    DECLARE current_def TEXT;
    SELECT COLUMN_TYPE INTO current_def
    FROM INFORMATION_SCHEMA.COLUMNS
    WHERE TABLE_SCHEMA = 'agrofin' AND TABLE_NAME = 'orders' AND COLUMN_NAME = 'order_status';

    IF current_def NOT LIKE '%pending_payment%' THEN
        ALTER TABLE orders MODIFY COLUMN order_status
            ENUM('pending_payment','pending','confirmed','processing','packed','shipped','delivered','cancelled','refunded')
            DEFAULT 'pending';
    END IF;
END$$
DELIMITER ;
CALL migration_004_status();
DROP PROCEDURE migration_004_status;

-- ─── 4. Phone verification flag ────────────────────────────────────
-- Add otp_verified_at to users (separate from phone_verified — gives audit trail)
DROP PROCEDURE IF EXISTS migration_004_users;
DELIMITER $$
CREATE PROCEDURE migration_004_users()
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA = 'agrofin' AND TABLE_NAME = 'users'
          AND COLUMN_NAME = 'otp_verified_at'
    ) THEN
        ALTER TABLE users
            ADD COLUMN otp_verified_at TIMESTAMP NULL AFTER phone_verified;
    END IF;
END$$
DELIMITER ;
CALL migration_004_users();
DROP PROCEDURE migration_004_users;

SELECT 'Migration 004 complete. otp_codes + payments tables ready.' AS msg;
