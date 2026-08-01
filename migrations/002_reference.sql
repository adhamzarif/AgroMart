-- ═══════════════════════════════════════════════════════════════════
-- AgroMart Migration 002 — Reference tables (PostgreSQL)
-- Converted from MySQL mysql_schema_reference.sql.
-- Consolidates: base schema + migration 003 (last_seen_at) + 005 (district coords).
-- Depends on: 001_init.sql (users, user_roles already exist there).
--
-- NOTE: 001_init.sql already created `users` and `user_roles`. This file
-- creates the tables they reference (districts) and adds the FK afterward,
-- plus the other reference tables. If you prefer, fold districts into 001;
-- kept separate here to match the migration numbering in the runbook.
-- ═══════════════════════════════════════════════════════════════════

BEGIN;

-- ─── districts (referenced by users.district_id) ────────────────────
CREATE TABLE districts (
    district_id   INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    district_name VARCHAR(50) NOT NULL UNIQUE,
    division      VARCHAR(20) NOT NULL
                  CHECK (division IN ('Dhaka','Chittagong','Rajshahi','Khulna',
                                      'Barishal','Sylhet','Rangpur','Mymensingh')),
    latitude      NUMERIC(9,6),
    longitude     NUMERIC(9,6),
    created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_districts_division ON districts(division);

-- users.district_id FK — users came from 001, add the FK now that districts exists.
-- (users.district_id was created NULL-able in 001; if it was NOT NULL there,
--  make sure districts is seeded before inserting users.)
ALTER TABLE users
    ADD CONSTRAINT users_district_fk
    FOREIGN KEY (district_id) REFERENCES districts(district_id);

-- ─── system_settings ────────────────────────────────────────────────
CREATE TABLE system_settings (
    setting_id          INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    setting_key         VARCHAR(100) NOT NULL UNIQUE,
    setting_value       TEXT NOT NULL,
    setting_type        VARCHAR(10) DEFAULT 'string'
                        CHECK (setting_type IN ('string','number','boolean','json')),
    setting_category    VARCHAR(50) NOT NULL,
    setting_description VARCHAR(255),
    is_editable         BOOLEAN DEFAULT TRUE,
    updated_by          INTEGER REFERENCES users(user_id) ON DELETE SET NULL,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE TRIGGER system_settings_set_updated_at BEFORE UPDATE ON system_settings
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ─── crop_categories (self-referencing parent) ──────────────────────
CREATE TABLE crop_categories (
    category_id        INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    category_name      VARCHAR(50) NOT NULL UNIQUE,
    category_name_bn   VARCHAR(50) NOT NULL UNIQUE,
    parent_category_id INTEGER REFERENCES crop_categories(category_id) ON DELETE SET NULL,
    description        TEXT,
    icon               VARCHAR(100),
    created_at         TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_crop_categories_parent ON crop_categories(parent_category_id);

COMMIT;
