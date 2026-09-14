// priceCompare.routes.js — GET /api/prices/compare?crop=<name>
import { Router } from 'express';
import { fetchAll } from '../config/db.js';

const router = Router();

// GET /api/prices/compare?crop=লাউ
// Returns each district's current wholesale + retail price for the given crop,
// most-recent price_date per district, sorted by retail price ascending.
router.get('/compare', async (req, res, next) => {
  try {
    const { crop } = req.query;
    if (!crop) return res.status(400).json({ error: 'crop query param required' });

    const rows = await fetchAll(
      `SELECT DISTINCT ON (d.district_id)
              d.district_id,
              d.district_name,
              mp.wholesale_price,
              mp.retail_price,
              mp.unit,
              mp.price_date
       FROM market_prices mp
       JOIN districts d ON mp.district_id = d.district_id
       WHERE mp.crop_name = $1
       ORDER BY d.district_id, mp.price_date DESC`,
      [crop]
    );

    // now sort by retail_price ascending, cheapest first
    rows.sort((a, b) => Number(a.retail_price) - Number(b.retail_price));

    // list of distinct crops for the dropdown
    const crops = await fetchAll(
      `SELECT DISTINCT crop_name FROM market_prices ORDER BY crop_name`
    );

    res.json({
      crop,
      rows,
      crops: crops.map((c) => c.crop_name),
      count: rows.length,
    });
  } catch (err) { next(err); }
});

// GET /api/prices/crops — quick list of crops we have prices for
router.get('/crops', async (_req, res, next) => {
  try {
    const rows = await fetchAll(
      `SELECT DISTINCT crop_name FROM market_prices ORDER BY crop_name`
    );
    res.json({ crops: rows.map((r) => r.crop_name) });
  } catch (err) { next(err); }
});

export default router;
