// alerts.routes.js — CRUD + trigger check for price_alerts.
import { Router } from 'express';
import { fetchAll, fetchOne } from '../config/db.js';

const router = Router();

// DEMO_USER_ID: until Login is built, all alerts belong to user_id=1.
const DEMO_USER_ID = 1;

// Attach a `triggered` flag + current market price + district_name to each alert.
async function enrichAlerts(rows) {
  if (rows.length === 0) return [];
  return Promise.all(rows.map(async (a) => {
    // fetch the most-recent price for the crop (and district, if pinned)
    let priceRow;
    if (a.district_id) {
      priceRow = await fetchOne(
        `SELECT retail_price, price_date FROM market_prices
         WHERE crop_name = $1 AND district_id = $2
         ORDER BY price_date DESC LIMIT 1`,
        [a.crop_name, a.district_id]
      );
    } else {
      // no district = look for best-case match across all districts
      // "above" alert cares about the max; "below" cares about the min
      priceRow = await fetchOne(
        a.direction === 'above'
          ? `SELECT MAX(retail_price)::numeric(10,2) AS retail_price, MAX(price_date) AS price_date
             FROM market_prices WHERE crop_name = $1 AND price_date = (SELECT MAX(price_date) FROM market_prices WHERE crop_name = $1)`
          : `SELECT MIN(retail_price)::numeric(10,2) AS retail_price, MAX(price_date) AS price_date
             FROM market_prices WHERE crop_name = $1 AND price_date = (SELECT MAX(price_date) FROM market_prices WHERE crop_name = $1)`,
        [a.crop_name]
      );
    }

    const currentPrice = priceRow ? Number(priceRow.retail_price) : null;
    let triggered = false;
    if (currentPrice !== null && a.is_active) {
      triggered = a.direction === 'above'
        ? currentPrice >= Number(a.target_price)
        : currentPrice <= Number(a.target_price);
    }

    let district_name = null;
    if (a.district_id) {
      const d = await fetchOne(`SELECT district_name FROM districts WHERE district_id = $1`, [a.district_id]);
      district_name = d ? d.district_name : null;
    }

    return {
      ...a,
      current_price: currentPrice,
      price_date: priceRow ? priceRow.price_date : null,
      district_name,
      triggered,
    };
  }));
}

// GET /api/alerts — list demo user's alerts (with trigger status)
router.get('/', async (_req, res, next) => {
  try {
    const rows = await fetchAll(
      `SELECT alert_id, crop_name, district_id, direction, target_price,
              is_active, last_triggered, trigger_count, created_at
       FROM price_alerts
       WHERE user_id = $1
       ORDER BY is_active DESC, created_at DESC`,
      [DEMO_USER_ID]
    );
    const enriched = await enrichAlerts(rows);
    res.json({ alerts: enriched, count: enriched.length });
  } catch (err) { next(err); }
});

// POST /api/alerts — create
router.post('/', async (req, res, next) => {
  try {
    const { crop_name, district_id, direction, target_price } = req.body || {};
    if (!crop_name)   return res.status(400).json({ error: 'crop_name required' });
    if (!direction || !['above','below'].includes(direction))
      return res.status(400).json({ error: 'direction must be above or below' });
    if (!target_price || Number(target_price) <= 0)
      return res.status(400).json({ error: 'target_price must be > 0' });

    const row = await fetchOne(
      `INSERT INTO price_alerts (user_id, crop_name, district_id, direction, target_price)
       VALUES ($1, $2, $3, $4, $5)
       RETURNING alert_id`,
      [DEMO_USER_ID, crop_name, district_id || null, direction, target_price]
    );
    res.status(201).json({ alert_id: row.alert_id });
  } catch (err) { next(err); }
});

// PATCH /api/alerts/:id — toggle active
router.patch('/:id', async (req, res, next) => {
  try {
    const { id } = req.params;
    const { is_active } = req.body || {};
    if (typeof is_active !== 'boolean')
      return res.status(400).json({ error: 'is_active boolean required' });

    const row = await fetchOne(
      `UPDATE price_alerts SET is_active = $1
       WHERE alert_id = $2 AND user_id = $3
       RETURNING alert_id, is_active`,
      [is_active, id, DEMO_USER_ID]
    );
    if (!row) return res.status(404).json({ error: 'Alert not found' });
    res.json(row);
  } catch (err) { next(err); }
});

// DELETE /api/alerts/:id
router.delete('/:id', async (req, res, next) => {
  try {
    const { id } = req.params;
    const row = await fetchOne(
      `DELETE FROM price_alerts WHERE alert_id = $1 AND user_id = $2 RETURNING alert_id`,
      [id, DEMO_USER_ID]
    );
    if (!row) return res.status(404).json({ error: 'Alert not found' });
    res.json({ deleted: row.alert_id });
  } catch (err) { next(err); }
});

export default router;
