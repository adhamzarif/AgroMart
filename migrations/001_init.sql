-- ═══════════════════════════════════════════════════════════════════
-- AgroMart Migration 001 — users + user_roles  (PostgreSQL)
-- Converted from the MySQL database.sql. Fixes applied vs. the old schema:
--   • account_status (not "status") — the column the PHP app kept mis-naming
--   • real BOOLEAN instead of TINYINT(1)
--   • GENERATED ... AS IDENTITY instead of AUTO_INCREMENT
--   • CHECK-based enums (easy to alter later) instead of MySQL ENUM
--   • UTF-8 is native — no collation mismatch possible (old bug gone)
-- ═══════════════════════════════════════════════════════════════════

BEGIN;

-- ── users ────────────────────────────────────────────────────────────
CREATE TABLE users (
    user_id          INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    full_name        VARCHAR(100) NOT NULL,
    phone            VARCHAR(15)  NOT NULL UNIQUE,
    email            VARCHAR(100) UNIQUE,
    password_hash    VARCHAR(255) NOT NULL,
    nid_number       VARCHAR(20),
    district_id      INTEGER,               -- FK added in a later migration (districts table)
    address          VARCHAR(255),
    profile_picture  VARCHAR(255),
    preferred_language VARCHAR(5) NOT NULL DEFAULT 'bn'
                       CHECK (preferred_language IN ('bn', 'en')),
    account_status   VARCHAR(20) NOT NULL DEFAULT 'active'
                       CHECK (account_status IN ('active','suspended','banned','inactive')),
    wallet_balance   NUMERIC(12,2) NOT NULL DEFAULT 0
                       CHECK (wallet_balance >= 0),
    phone_verified   BOOLEAN NOT NULL DEFAULT FALSE,
    email_verified   BOOLEAN NOT NULL DEFAULT FALSE,
    nid_verified     BOOLEAN NOT NULL DEFAULT FALSE,
    last_login       TIMESTAMPTZ,
    last_seen_at     TIMESTAMPTZ,
    created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_users_account_status ON users(account_status, created_at DESC);
CREATE INDEX idx_users_district       ON users(district_id, account_status);
CREATE INDEX idx_users_last_seen      ON users(last_seen_at DESC);

-- keep updated_at fresh on every UPDATE
CREATE OR REPLACE FUNCTION set_updated_at() RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER users_set_updated_at
  BEFORE UPDATE ON users
  FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ── user_roles ───────────────────────────────────────────────────────
-- A user can hold multiple roles (farmer + buyer = "dual").
CREATE TABLE user_roles (
    user_id     INTEGER NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    role        VARCHAR(10) NOT NULL
                CHECK (role IN ('farmer','buyer','agent','admin')),
    assigned_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    PRIMARY KEY (user_id, role)
);

CREATE INDEX idx_user_roles_role ON user_roles(role);

COMMIT;
