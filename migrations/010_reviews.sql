-- ═══════════════════════════════════════════════════════════════════
-- AgroMart Migration 010 — Marketplace Reviews (PostgreSQL)
-- Table: crop_reviews
-- Depends on: 003 (crops).
--
-- NOTE ON reviewer_name (temporary, until login exists):
-- AgroMart still has no login/session (backend/src/middleware/auth.js is
-- empty), so there is no reliable logged-in user_id to attach a review to.
-- Rather than block Reviews entirely, reviewer_name is a free-text guest
-- name for now. Once login lands, add:
--   ALTER TABLE crop_reviews ADD COLUMN reviewer_id INTEGER
--     REFERENCES users(user_id) ON DELETE SET NULL;
-- and switch the app to send reviewer_id (from the session) instead of a
-- typed name, keeping reviewer_name only as a display-name fallback.
-- ═══════════════════════════════════════════════════════════════════

BEGIN;

CREATE TABLE crop_reviews (
    review_id      INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    crop_id        INTEGER NOT NULL REFERENCES crops(crop_id) ON DELETE CASCADE,
    reviewer_name  VARCHAR(100) NOT NULL,
    rating         SMALLINT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment        TEXT,
    created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_crop_reviews_crop ON crop_reviews(crop_id, created_at DESC);

COMMIT;