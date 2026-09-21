// delivery.routes.js — delivery estimate calculator.
// Distances between the 9 districts are approximate (km),
// computed from a hardcoded matrix (no DB table required).
import { Router } from 'express';
import { fetchAll, fetchOne } from '../config/db.js';

const router = Router();

// Rough district-to-district distances in km.
// Symmetric — dist(A,B) = dist(B,A). Self = 0.
// district_id → district_id → km
const DISTANCE_KM = {
  1: { 1:0,   2:250, 3:270, 4:270, 5:250, 6:160, 7:315, 8:120, 9:350 }, // Dhaka
  2: { 1:250, 2:0,   3:510, 4:490, 5:340, 6:270, 7:565, 8:370, 9:120 }, // Chittagong
  3: { 1:270, 2:510, 3:0,   4:200, 5:520, 6:410, 7:180, 8:220, 9:620 }, // Rajshahi
  4: { 1:270, 2:490, 3:200, 4:0,   5:520, 6:170, 7:350, 8:320, 9:600 }, // Khulna
  5: { 1:250, 2:340, 3:520, 4:520, 5:0,   6:420, 7:500, 8:260, 9:420 }, // Sylhet
  6: { 1:160, 2:270, 3:410, 4:170, 5:420, 6:0,   7:475, 8:280, 9:390 }, // Barishal
  7: { 1:315, 2:565, 3:180, 4:350, 5:500, 6:475, 7:0,   8:230, 9:670 }, // Rangpur
  8: { 1:120, 2:370, 3:220, 4:320, 5:260, 6:280, 7:230, 8:0,   9:475 }, // Mymensingh
  9: { 1:350, 2:120, 3:620, 4:600, 5:420, 6:390, 7:670, 8:475, 9:0   }, // Rangamati
};

// AgroExpress pricing model:
// base pickup fee + per-km + per-kg fee. Weight above 100kg gets a small discount.
function estimate(distanceKm, weightKg) {
  const base = 80;                          // pickup fee
  const perKm = 3.5;                        // ৳ per km
  const perKg = 1.2;                        // ৳ per kg
  const discount = weightKg >= 100 ? 0.9 : 1.0;
  const cost = Math.round((base + perKm * distanceKm + perKg * weightKg) * discount);

  // ETA: 40 km/h + 2 hours prep
  const etaHours = Math.max(4, Math.round(distanceKm / 40) + 2);

  return { cost, etaHours };
}

// GET /api/delivery/estimate?from=<id>&to=<id>&weight=<kg>
router.get('/estimate', async (req, res, next) => {
  try {
    const from = Number(req.query.from);
    const to   = Number(req.query.to);
    const weight = Math.max(1, Number(req.query.weight || 10));

    if (!from || !to) {
      return res.status(400).json({ error: 'from and to district ids required' });
    }
    const distance = DISTANCE_KM[from]?.[to];
    if (distance === undefined) {
      return res.status(400).json({ error: 'unknown district id' });
    }

    const { cost, etaHours } = estimate(distance, weight);

    // Look up district names to return alongside
    const [fromRow, toRow] = await Promise.all([
      fetchOne(`SELECT district_id, district_name FROM districts WHERE district_id = $1`, [from]),
      fetchOne(`SELECT district_id, district_name FROM districts WHERE district_id = $1`, [to]),
    ]);

    // Available carriers (only AgroExpress currently)
    const carriers = [
      {
        code: 'agroexpress',
        name: 'AgroExpress',
        tagline_key: 'de_carrier1_tagline',
        icon: '🚚',
        cost,
        eta_hours: etaHours,
        features: ['insured', 'tracking', 'cold_storage'],
      },
    ];

    // Full list of districts for dropdowns
    const districts = await fetchAll(
      `SELECT district_id, district_name FROM districts ORDER BY district_id`
    );

    // ETA date = now + etaHours
    const etaDate = new Date(Date.now() + etaHours * 3600 * 1000);

    res.json({
      from: fromRow,
      to: toRow,
      distance_km: distance,
      weight_kg: weight,
      carriers,
      eta_date: etaDate.toISOString(),
      districts,
    });
  } catch (err) { next(err); }
});

export default router;
