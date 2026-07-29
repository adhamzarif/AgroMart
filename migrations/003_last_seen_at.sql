-- ═══════════════════════════════════════════════════════════════════
-- AgroFin Migration 003: last_seen_at User Activity Tracking
-- ═══════════════════════════════════════════════════════════════════
-- Adds a column updated on every authenticated request, giving admins
-- visibility into which users are actively using the platform.
--
-- Note: the column may already exist in newer database.sql files —
-- this migration uses a stored procedure to check first, so it's
-- safely idempotent.
-- ═══════════════════════════════════════════════════════════════════

USE agrofin;

DROP PROCEDURE IF EXISTS migration_003;

DELIMITER $$
CREATE PROCEDURE migration_003()
BEGIN
    -- Add the column only if it doesn't already exist
    IF NOT EXISTS (
        SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA = 'agrofin'
          AND TABLE_NAME = 'users'
          AND COLUMN_NAME = 'last_seen_at'
    ) THEN
        ALTER TABLE users ADD COLUMN last_seen_at TIMESTAMP NULL DEFAULT NULL AFTER last_login;
    END IF;

    -- Add the index only if it doesn't already exist
    IF NOT EXISTS (
        SELECT 1 FROM INFORMATION_SCHEMA.STATISTICS
        WHERE TABLE_SCHEMA = 'agrofin'
          AND TABLE_NAME = 'users'
          AND INDEX_NAME = 'idx_users_last_seen'
    ) THEN
        CREATE INDEX idx_users_last_seen ON users(last_seen_at DESC);
    END IF;

    -- Backfill from last_login for existing users
    UPDATE users SET last_seen_at = last_login
    WHERE last_seen_at IS NULL AND last_login IS NOT NULL;
END$$
DELIMITER ;

CALL migration_003();
DROP PROCEDURE migration_003;

SELECT 'Migration 003 complete. last_seen_at column ready.' AS msg;
