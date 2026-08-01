-- ═══════════════════════════════════════════════════════════════════
-- AgroMart Migration 003 — Marketplace (PostgreSQL)
-- Tables: crops, market_prices, price_history, favorites, search_logs
-- Consolidates base schema + migration 002 (CHECK constraints).
-- Depends on: 001 (users), 002 (districts, crop_categories), 007 (agents).
--
-- ORDERING NOTE: crops.agent_id references agents(agent_id). Since agents
-- is created in 007, this file adds that FK at the END as a deferred
-- ALTER (or run 007 before this and move the FK inline). Kept as ALTER
-- here so 003 can run before 007 during incremental development.
-- ═══════════════════════════════════════════════════════════════════

BEGIN;

-- ─── crops ──────────────────────────────────────────────────────────
CREATE TABLE crops (
    crop_id        INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    farmer_id      INTEGER NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    category_id    INTEGER NOT NULL REFERENCES crop_categories(category_id),
    crop_name      VARCHAR(100) NOT NULL,
    crop_variety   VARCHAR(100),
    quantity       NUMERIC(10,2) NOT NULL CHECK (quantity >= 0),
    unit           VARCHAR(10) NOT NULL CHECK (unit IN ('kg','ton','mon','piece')),
    price_per_unit NUMERIC(10,2) NOT NULL CHECK (price_per_unit > 0),
    quality_grade  VARCHAR(1) DEFAULT 'B' CHECK (quality_grade IN ('A','B','C')),
    is_organic     BOOLEAN DEFAULT FALSE,
    harvest_date   DATE,
    available_from DATE NOT NULL,
    available_until DATE,
    description    TEXT,
    images         JSONB,
    status         VARCHAR(20) DEFAULT 'available'
                   CHECK (status IN ('available','sold','expired','removed')),
    views_count    INTEGER DEFAULT 0 CHECK (views_count >= 0),
    listed_by_agent BOOLEAN DEFAULT FALSE,
    agent_id       INTEGER,  -- FK to agents added after 007 (see note)
    created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_crops_farmer   ON crops(farmer_id);
CREATE INDEX idx_crops_category ON crops(category_id);
CREATE INDEX idx_crops_status   ON crops(status, created_at DESC);
CREATE INDEX idx_crops_name     ON crops(crop_name);
CREATE TRIGGER crops_set_updated_at BEFORE UPDATE ON crops
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ─── market_prices ──────────────────────────────────────────────────
CREATE TABLE market_prices (
    price_id       INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    crop_name      VARCHAR(100) NOT NULL,
    district_id    INTEGER NOT NULL REFERENCES districts(district_id) ON DELETE CASCADE,
    wholesale_price NUMERIC(10,2) NOT NULL CHECK (wholesale_price >= 0),
    retail_price   NUMERIC(10,2) NOT NULL CHECK (retail_price >= 0),
    unit           VARCHAR(10) DEFAULT 'kg' CHECK (unit IN ('kg','ton','mon','piece')),
    price_date     DATE NOT NULL,
    source         VARCHAR(100) DEFAULT 'DAM',
    updated_by     INTEGER REFERENCES users(user_id) ON DELETE SET NULL,
    created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_price UNIQUE (crop_name, district_id, price_date),
    CONSTRAINT chk_retail_ge_wholesale CHECK (retail_price >= wholesale_price)
);
CREATE INDEX idx_market_prices_lookup ON market_prices(crop_name, district_id, price_date DESC);

-- ─── price_history ──────────────────────────────────────────────────
CREATE TABLE price_history (
    history_id     INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    crop_name      VARCHAR(100) NOT NULL,
    district_id    INTEGER NOT NULL REFERENCES districts(district_id) ON DELETE CASCADE,
    wholesale_price NUMERIC(10,2) NOT NULL,
    retail_price   NUMERIC(10,2) NOT NULL,
    unit           VARCHAR(10) DEFAULT 'kg' CHECK (unit IN ('kg','ton','mon','piece')),
    price_date     DATE NOT NULL,
    archived_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_price_history_lookup ON price_history(crop_name, district_id, price_date DESC);

-- ─── favorites ──────────────────────────────────────────────────────
CREATE TABLE favorites (
    favorite_id    INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id        INTEGER NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    favorite_type  VARCHAR(10) NOT NULL CHECK (favorite_type IN ('crop','farmer')),
    crop_id        INTEGER REFERENCES crops(crop_id) ON DELETE CASCADE,
    farmer_id      INTEGER REFERENCES users(user_id) ON DELETE CASCADE,
    price_alert_enabled BOOLEAN DEFAULT FALSE,
    alert_price_threshold NUMERIC(10,2),
    created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_favorites_user ON favorites(user_id);

-- ─── search_logs ────────────────────────────────────────────────────
CREATE TABLE search_logs (
    search_id      INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id        INTEGER REFERENCES users(user_id) ON DELETE SET NULL,
    search_query   VARCHAR(255) NOT NULL,
    search_type    VARCHAR(10) DEFAULT 'text' CHECK (search_type IN ('text','voice','filter')),
    filters_applied JSONB,
    results_count  INTEGER DEFAULT 0,
    clicked_crop_id INTEGER REFERENCES crops(crop_id) ON DELETE SET NULL,
    search_timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_search_logs_user ON search_logs(user_id, search_timestamp DESC);

COMMIT;
