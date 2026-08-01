-- ═══════════════════════════════════════════════════════════════════
-- AgroMart Migration 009 — Views (PostgreSQL)
-- Converts vw_active_crops_with_details, vw_farmer_performance.
-- FIX: uses SQL SECURITY INVOKER semantics (default in PG) — the MySQL
-- views were DEFINER=root, a privilege-escalation smell. In PG, views
-- run with the querying user's privileges by default. Good.
-- Depends on: all base tables (run LAST).
-- ═══════════════════════════════════════════════════════════════════
BEGIN;

CREATE OR REPLACE VIEW vw_active_crops_with_details AS
SELECT c.crop_id, c.farmer_id, c.category_id, c.crop_name, c.crop_variety,
       c.quantity, c.unit, c.price_per_unit, c.quality_grade, c.is_organic,
       c.harvest_date, c.available_from, c.available_until, c.description,
       c.images, c.status, c.views_count, c.listed_by_agent, c.agent_id,
       c.created_at, c.updated_at,
       u.full_name       AS farmer_name,
       u.phone           AS farmer_phone,
       u.profile_picture AS farmer_picture,
       d.district_name,
       d.division,
       cc.category_name
FROM crops c
JOIN users u            ON c.farmer_id = u.user_id
JOIN districts d        ON u.district_id = d.district_id
JOIN crop_categories cc ON c.category_id = cc.category_id
WHERE c.status = 'available';

CREATE OR REPLACE VIEW vw_farmer_performance AS
SELECT u.user_id AS farmer_id,
       u.full_name AS farmer_name,
       d.district_name,
       COUNT(DISTINCT c.crop_id)  AS total_crops_listed,
       COUNT(DISTINCT o.order_id) AS total_orders,
       COALESCE(SUM(CASE WHEN o.order_status = 'delivered' THEN o.total_amount END), 0) AS total_revenue,
       COALESCE(AVG(fr.overall_rating), 0) AS avg_rating
FROM users u
JOIN districts d   ON u.district_id = d.district_id
JOIN user_roles ur ON u.user_id = ur.user_id AND ur.role = 'farmer'
LEFT JOIN crops c          ON u.user_id = c.farmer_id
LEFT JOIN orders o         ON u.user_id = o.farmer_id
LEFT JOIN farmer_ratings fr ON u.user_id = fr.farmer_id
GROUP BY u.user_id, u.full_name, d.district_name;

COMMIT;
