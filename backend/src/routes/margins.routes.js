// margins.routes.js — GET /api/margins/calculate?crop=<name>&quantity=<n>
// Returns the earnings comparison for a farmer under traditional vs AgroMart.
import { Router } from 'express';
import { fetchAll, fetchOne } from '../config/db.js';

const router = Router();

router.get('/calculate', async (req, res, next) => {
  try {
    const { crop, quantity = 100 } = req.query;
    if (!crop) return res.status(400).json({ error: 'crop query param required' });
    const qty = Math.max(1, Number(quantity));

    // 1. latest retail price for the crop (average across districts)
    const priceRow = await fetchOne(
      `SELECT AVG(retail_price)::numeric(10,2) AS retail_price,
              MAX(unit) AS unit
       FROM market_prices
       WHERE crop_name = $1
         AND price_date = (SELECT MAX(price_date) FROM market_prices WHERE crop_name = $1)`,
      [crop]
    );

    if (!priceRow || !priceRow.retail_price) {
      return res.status(404).json({ error: 'No prices found for this crop' });
    }

    const retailPrice = Number(priceRow.retail_price);
    const unit = priceRow.unit || 'kg';
    const totalRevenue = retailPrice * qty;

    // 2. margin breakdown by system
    const margins = await fetchAll(
      `SELECT system, role, share_pct
       FROM supply_chain_margins
       WHERE crop_name = $1
       ORDER BY system, share_pct DESC`,
      [crop]
    );

    const traditional = margins
      .filter((m) => m.system === 'traditional')
      .map((m) => ({
        role: m.role,
        share_pct: Number(m.share_pct),
        amount: +(totalRevenue * m.share_pct / 100).toFixed(2),
      }));

    const agromart = margins
      .filter((m) => m.system === 'agromart')
      .map((m) => ({
        role: m.role,
        share_pct: Number(m.share_pct),
        amount: +(totalRevenue * m.share_pct / 100).toFixed(2),
      }));

    const traditionalFarmer = traditional.find((r) => r.role === 'farmer')?.amount || 0;
    const agromartFarmer    = agromart.find((r) => r.role === 'farmer')?.amount || 0;
    const gain              = +(agromartFarmer - traditionalFarmer).toFixed(2);
    const gainPct           = traditionalFarmer > 0
                                ? +(gain / traditionalFarmer * 100).toFixed(1)
                                : 0;

    // list of crops that have margin data
    const crops = await fetchAll(
      `SELECT DISTINCT crop_name FROM supply_chain_margins ORDER BY crop_name`
    );

    res.json({
      crop,
      quantity: qty,
      unit,
      retail_price: retailPrice,
      total_revenue: +totalRevenue.toFixed(2),
      traditional,
      agromart,
      traditional_farmer_earnings: traditionalFarmer,
      agromart_farmer_earnings:    agromartFarmer,
      gain,
      gain_pct: gainPct,
      crops: crops.map((c) => c.crop_name),
    });
  } catch (err) { next(err); }
});

export default router;
