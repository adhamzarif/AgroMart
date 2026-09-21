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

// GET /api/prices/history?crop=<name>&district_id=<id>&days=30
// Returns { rows: [{ price_date, wholesale_price, retail_price }, ...] }
// sorted by date ascending, ready for a line chart.
router.get('/history', async (req, res, next) => {
  try {
    const { crop, district_id, days = 30 } = req.query;
    if (!crop || !district_id) {
      return res.status(400).json({ error: 'crop and district_id required' });
    }
    const daysNum = Math.min(365, Math.max(1, Number(days)));

    const rows = await fetchAll(
      `SELECT price_date, wholesale_price, retail_price, unit
       FROM market_prices
       WHERE crop_name = $1
         AND district_id = $2
         AND price_date >= CURRENT_DATE - $3::int
       ORDER BY price_date ASC`,
      [crop, district_id, daysNum]
    );

    const districts = await fetchAll(
      `SELECT district_id, district_name FROM districts ORDER BY district_name`
    );

    res.json({
      crop,
      district_id: Number(district_id),
      days: daysNum,
      rows,
      districts,
      count: rows.length,
    });
  } catch (err) { next(err); }
});

// GET /api/prices/recommend?crop=<name>&local_district_id=<id>
// Returns a "sell now / wait / hold" recommendation with supporting data.
router.get('/recommend', async (req, res, next) => {
  try {
    const { crop, local_district_id } = req.query;
    if (!crop) return res.status(400).json({ error: 'crop query param required' });
    const localId = local_district_id ? Number(local_district_id) : null;

    // 1. Latest price per district for this crop (most-recent price_date each)
    const districtRows = await fetchAll(
      `SELECT DISTINCT ON (d.district_id)
              d.district_id, d.district_name,
              mp.wholesale_price, mp.retail_price, mp.unit, mp.price_date
       FROM market_prices mp
       JOIN districts d ON mp.district_id = d.district_id
       WHERE mp.crop_name = $1
       ORDER BY d.district_id, mp.price_date DESC`,
      [crop]
    );

    if (districtRows.length === 0) {
      return res.status(404).json({ error: 'No prices found for this crop' });
    }

    // sort desc by retail — priciest first (best sell markets)
    districtRows.sort((a, b) => Number(b.retail_price) - Number(a.retail_price));
    const unit = districtRows[0].unit || 'kg';

    const best = districtRows[0];
    const top3 = districtRows.slice(0, 3);

    // 2. Local district picture
    let local = null;
    if (localId) {
      local = districtRows.find((d) => d.district_id === localId);
    }
    if (!local) local = districtRows[districtRows.length - 1]; // fallback = cheapest

    const localPrice = Number(local.retail_price);
    const bestPrice  = Number(best.retail_price);
    const gainPct    = localPrice > 0
      ? +(((bestPrice - localPrice) / localPrice) * 100).toFixed(1)
      : 0;

    // 3. Trend: 30-day price history for the local district
    const history = await fetchAll(
      `SELECT price_date, retail_price
       FROM market_prices
       WHERE crop_name = $1 AND district_id = $2
         AND price_date >= CURRENT_DATE - 30
       ORDER BY price_date ASC`,
      [crop, local.district_id]
    );

    let avg30 = 0, vsAvgPct = 0, direction = 'flat';
    if (history.length > 0) {
      avg30 = +(history.reduce((s, r) => s + Number(r.retail_price), 0) / history.length).toFixed(2);
      vsAvgPct = +(((localPrice - avg30) / avg30) * 100).toFixed(1);

      // last-7 vs prior-7 to gauge direction
      const last7  = history.slice(-7).reduce((s, r) => s + Number(r.retail_price), 0) / Math.min(7, history.length);
      const prior7 = history.slice(-14, -7).reduce((s, r) => s + Number(r.retail_price), 0) / Math.max(1, Math.min(7, history.slice(-14, -7).length));
      const diff = last7 - prior7;
      direction = diff > 0.5 ? 'rising' : diff < -0.5 ? 'falling' : 'flat';
    }

    // Mini 7-day trend for the chart on the page
    const trend7 = history.slice(-7).map((r) => ({
      date: r.price_date,
      price: Number(r.retail_price),
    }));

    // 4. Verdict logic
    // sell_now: price above avg AND (best gain > 30% OR trend rising)
    // wait:     price below avg AND trend falling
    // hold:     everything else (mixed signals)
    let verdict = 'hold';
    let reason_key = 'sr_reason_hold';
    if (localPrice >= avg30 && (gainPct >= 30 || direction === 'rising')) {
      verdict = 'sell_now';
      reason_key = gainPct >= 30 ? 'sr_reason_sell_gain' : 'sr_reason_sell_rising';
    } else if (localPrice < avg30 && direction === 'falling') {
      verdict = 'wait';
      reason_key = 'sr_reason_wait';
    }

    // list of crops that have data
    const crops = await fetchAll(
      `SELECT DISTINCT crop_name FROM market_prices ORDER BY crop_name`
    );

    res.json({
      crop,
      unit,
      local: {
        district_id: local.district_id,
        district_name: local.district_name,
        retail_price: localPrice,
      },
      best: {
        district_id: best.district_id,
        district_name: best.district_name,
        retail_price: bestPrice,
        gain_pct: gainPct,
      },
      top_markets: top3.map((d) => ({
        district_id: d.district_id,
        district_name: d.district_name,
        retail_price: Number(d.retail_price),
        gain_pct: localPrice > 0 ? +(((Number(d.retail_price) - localPrice) / localPrice) * 100).toFixed(1) : 0,
      })),
      trend: {
        avg_30d: avg30,
        current: localPrice,
        vs_avg_pct: vsAvgPct,
        direction,
        history_7d: trend7,
      },
      verdict,
      reason_key,
      crops: crops.map((c) => c.crop_name),
    });
  } catch (err) { next(err); }
});
