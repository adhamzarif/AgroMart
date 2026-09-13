// price.model.js — live market prices with trend + AgroMart comparison.
// Ports the "compare bazar rate vs AgroMart farmer listings + 7-day trend" logic.
import { fetchAll } from '../config/db.js';

/**
 * Return a row per crop with today's bazar rate, current best AgroMart price,
 * 7-day trend direction, and the first available crop_id for CTA linking.
 *
 * `role` shapes the sort: 'buyer' -> biggest savings first; 'farmer' -> biggest
 * price gap first (where farmers can charge more than the current best).
 */
export async function getLivePrices({ search, role = 'buyer' } = {}) {
  const params = [];
  const where = [];
  if (search) { params.push(`%${search}%`); where.push(`mp.crop_name ILIKE $${params.length}`); }
  const whereSql = where.length ? `WHERE ${where.join(' AND ')}` : '';

  // Uses two window sub-queries (today's bazar, 7-day-old bazar) so the trend
  // is real. AgroMart cheapest picked from available crops joined on name.
  const sql = `
    WITH today AS (
      SELECT DISTINCT ON (crop_name)
        crop_name, wholesale_price AS wp_now, retail_price AS rp_now, unit
      FROM market_prices
      WHERE price_date = CURRENT_DATE
      ORDER BY crop_name, price_id DESC
    ),
    week_ago AS (
      SELECT DISTINCT ON (crop_name)
        crop_name, retail_price AS rp_then
      FROM price_history
      WHERE price_date <= CURRENT_DATE - INTERVAL '6 days'
      ORDER BY crop_name, price_date DESC
    ),
    farm AS (
      SELECT crop_name,
             MIN(price_per_unit)  AS am_min,
             AVG(price_per_unit)  AS am_avg,
             MAX(price_per_unit)  AS am_max,
             COUNT(*)             AS am_count,
             (ARRAY_AGG(crop_id ORDER BY price_per_unit ASC))[1] AS best_crop_id,
             (ARRAY_AGG(category_id))[1] AS category_id
      FROM crops
      WHERE status = 'available'
      GROUP BY crop_name
    )
    SELECT
      t.crop_name,
      t.unit,
      t.rp_now         AS bazar_rate,
      t.wp_now         AS wholesale_rate,
      f.am_min         AS agromart_min,
      f.am_avg         AS agromart_avg,
      f.am_max         AS agromart_max,
      f.am_count       AS agromart_count,
      f.best_crop_id,
      (SELECT category_name_bn FROM crop_categories WHERE category_id = f.category_id) AS category_name,
      w.rp_then,
      CASE
        WHEN w.rp_then IS NULL OR t.rp_now IS NULL THEN 'stable'
        WHEN t.rp_now > w.rp_then * 1.03 THEN 'up'
        WHEN t.rp_now < w.rp_then * 0.97 THEN 'down'
        ELSE 'stable'
      END AS trend,
      CASE
        WHEN w.rp_then IS NULL OR t.rp_now IS NULL OR w.rp_then = 0 THEN 0
        ELSE ROUND(((t.rp_now - w.rp_then) / w.rp_then * 100)::numeric, 1)
      END AS trend_pct,
      -- image from the best AgroMart listing
      (SELECT images FROM crops WHERE crop_id = f.best_crop_id) AS images
    FROM today t
    LEFT JOIN farm f     ON f.crop_name = t.crop_name
    LEFT JOIN week_ago w ON w.crop_name = t.crop_name
    ${whereSql}
    ORDER BY
      CASE WHEN $${params.length + 1} = 'farmer'
           THEN COALESCE(t.rp_now - f.am_max, 0)  -- farmers: biggest room to charge more
           ELSE COALESCE(t.rp_now - f.am_min, 0)  -- buyers: biggest savings first
      END DESC NULLS LAST,
      t.crop_name`;
  params.push(role);
  return fetchAll(sql, params);
}
