-- ═══════════════════════════════════════════════════════════════════
-- AgroMart Migration 000 — Prelude (PostgreSQL)
-- Shared objects that later migrations depend on.
-- RUN THIS FIRST, before 001_init.sql.
-- ═══════════════════════════════════════════════════════════════════
BEGIN;

-- Shared trigger function: keeps updated_at fresh on any UPDATE.
-- Every table with an updated_at column attaches a trigger to this.
CREATE OR REPLACE FUNCTION set_updated_at() RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

COMMIT;
