-- ═══════════════════════════════════════════════════════════════════
-- AgroFin Migration 001: Performance Indexes
-- ═══════════════════════════════════════════════════════════════════
-- Run this AFTER your initial database.sql import.
-- Targets specific hot queries identified during profiling.
-- Total disk overhead: ~5-15 MB on a typical dataset.
-- INSERT/UPDATE penalty: <2ms per row across these tables.
--
-- NOTE: this migration only adds indexes that don't already exist.
-- The original database.sql ships with some indexes already; we add
-- the missing ones here. If an index name collides, drop and re-run.
-- ═══════════════════════════════════════════════════════════════════

USE agrofin;

-- ─── CROPS ──────────────────────────────────────────────────────────
-- Marketplace browse filtered by status + price sort
CREATE INDEX idx_crops_avail_price ON crops(status, price_per_unit);
-- Newest crops first on the homepage
CREATE INDEX idx_crops_created     ON crops(created_at DESC);
-- "Show only organic" filter
CREATE INDEX idx_crops_organic     ON crops(is_organic, status);

-- ─── NOTIFICATIONS ──────────────────────────────────────────────────
-- The header bell icon counts unread per user — runs on every page view
CREATE INDEX idx_notif_user_read   ON notifications(user_id, is_read, created_at DESC);
-- Filter inbox by category
CREATE INDEX idx_notif_user_type   ON notifications(user_id, notification_type);

-- ─── MESSAGES ───────────────────────────────────────────────────────
-- Inbox view shows unread first
CREATE INDEX idx_msg_unread        ON messages(receiver_id, is_read, created_at DESC);

-- ─── LOANS ──────────────────────────────────────────────────────────
-- Used by the cron job in Step 7 to find loans needing payment reminders
CREATE INDEX idx_loans_next_payment ON loans(next_payment_date);

-- ─── EXPENSES ───────────────────────────────────────────────────────
-- P&L report groups by category in a date range
CREATE INDEX idx_expenses_cat_date ON expenses(expense_category, expense_date);

-- ─── INVENTORY LOGS ─────────────────────────────────────────────────
-- Crop detail page shows the stock-movement timeline
CREATE INDEX idx_inventory_crop    ON inventory_logs(crop_id, logged_at DESC);

-- ─── USERS ──────────────────────────────────────────────────────────
-- Admin filter by status + sort by date
CREATE INDEX idx_users_status_date ON users(account_status, created_at DESC);
-- Filter users by district
CREATE INDEX idx_users_district    ON users(district_id, account_status);
-- "Inactive users" report
CREATE INDEX idx_users_last_login  ON users(last_login DESC);

-- ─── TICKETS ────────────────────────────────────────────────────────
-- Agent queue sorted by priority + age
CREATE INDEX idx_tickets_status_pri ON farmer_support_tickets(status, priority, created_at DESC);
-- An agent's own queue
CREATE INDEX idx_tickets_assigned   ON farmer_support_tickets(assigned_agent_id, status);

-- ─── AUDIT LOGS ─────────────────────────────────────────────────────
-- Admin filters by date range
CREATE INDEX idx_audit_date        ON audit_logs(created_at DESC);
-- Filter audit log by action type
CREATE INDEX idx_audit_action_date ON audit_logs(action_type, created_at DESC);

-- ─── ASSISTANT QUERIES ──────────────────────────────────────────────
-- User's own chat history
CREATE INDEX idx_assistant_user_date ON assistant_queries(user_id, created_at DESC);

-- ─── WEATHER ALERTS ─────────────────────────────────────────────────
-- The JSON_CONTAINS lookup is the inner query; the outer query filters by is_active
CREATE INDEX idx_weather_active    ON weather_alerts(is_active, created_at DESC);

-- ─── FAVORITES ──────────────────────────────────────────────────────
-- Find all users favoriting a specific crop or farmer
CREATE INDEX idx_favorites_crop    ON favorites(crop_id, created_at DESC);
CREATE INDEX idx_favorites_farmer  ON favorites(farmer_id, created_at DESC);

-- ─── SUBSCRIPTIONS ──────────────────────────────────────────────────
-- Used by the cron job in Step 8 to find subscriptions due for delivery
CREATE INDEX idx_sub_next          ON subscriptions(next_delivery_date, status);
-- A buyer's own active subscriptions
CREATE INDEX idx_sub_buyer         ON subscriptions(buyer_id, status);

-- ─── DELIVERIES ─────────────────────────────────────────────────────
-- Admin filters by delivery status
CREATE INDEX idx_deliveries_status ON deliveries(delivery_status, created_at DESC);

-- ─── AGENT ACTIVITIES ───────────────────────────────────────────────
-- Filter agent earnings page by activity type
CREATE INDEX idx_agent_act_type    ON agent_activities(agent_id, activity_type, activity_date DESC);

SELECT 'Migration 001 complete. Run SHOW INDEX FROM <table> to verify.' AS msg;
