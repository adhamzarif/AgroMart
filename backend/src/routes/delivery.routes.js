// delivery.routes.js — delivery estimate calculator.
// Realistic pricing:
//   Same district      → ৳80 base + ৳0.50/kg, same-day
//   Cross district std → ৳150 base + ৳1.0/kg, 2-3 days
//   Cross district exp → ৳300 base + ৳2.0/kg, next-day
//   Weight >50 kg adds +30%, >200 kg +60%, >500 kg → contact for quote.
import { Router } from "express";
import { fetchAll, fetchOne } from "../config/db.js";

const router = Router();

// district_id → district_id → km
const DISTANCE_KM = {
  1: { 1:0,   2:250, 3:270, 4:270, 5:250, 6:160, 7:315, 8:120, 9:350 },
  2: { 1:250, 2:0,   3:510, 4:490, 5:340, 6:270, 7:565, 8:370, 9:120 },
  3: { 1:270, 2:510, 3:0,   4:200, 5:520, 6:410, 7:180, 8:220, 9:620 },
  4: { 1:270, 2:490, 3:200, 4:0,   5:520, 6:170, 7:350, 8:320, 9:600 },
  5: { 1:250, 2:340, 3:520, 4:520, 5:0,   6:420, 7:500, 8:260, 9:420 },
  6: { 1:160, 2:270, 3:410, 4:170, 5:420, 6:0,   7:475, 8:280, 9:390 },
  7: { 1:315, 2:565, 3:180, 4:350, 5:500, 6:475, 7:0,   8:230, 9:670 },
  8: { 1:120, 2:370, 3:220, 4:320, 5:260, 6:280, 7:230, 8:0,   9:475 },
  9: { 1:350, 2:120, 3:620, 4:600, 5:420, 6:390, 7:670, 8:475, 9:0   },
};

function weightMultiplier(weightKg) {
  if (weightKg > 500) return null;  // requires custom quote
  if (weightKg > 200) return 1.60;
  if (weightKg > 50)  return 1.30;
  return 1.0;
}

function estimateForTier(tier, weightKg) {
  const bases = {
    same_district: { base: 80,  perKg: 2.0, days_min: 0, days_max: 1 },
    standard:      { base: 150, perKg: 3.5, days_min: 2, days_max: 3 },
    express:       { base: 300, perKg: 5.0, days_min: 1, days_max: 1 },
  };
  const b = bases[tier];
  const mult = weightMultiplier(weightKg);
  if (mult === null) return null; // too heavy for auto quote

  const cost = Math.round((b.base + b.perKg * weightKg) * mult);
  return { cost, days_min: b.days_min, days_max: b.days_max };
}

router.get("/estimate", async (req, res, next) => {
  try {
    const from = Number(req.query.from);
    const to   = Number(req.query.to);
    const weight = Math.max(1, Number(req.query.weight || 10));

    if (!from || !to) {
      return res.status(400).json({ error: "from and to district ids required" });
    }
    const distance = DISTANCE_KM[from]?.[to];
    if (distance === undefined) {
      return res.status(400).json({ error: "unknown district id" });
    }

    const sameDistrict = from === to;
    const overweight = weight > 500;

    const [fromRow, toRow] = await Promise.all([
      fetchOne(`SELECT district_id, district_name FROM districts WHERE district_id = $1`, [from]),
      fetchOne(`SELECT district_id, district_name FROM districts WHERE district_id = $1`, [to]),
    ]);

    let carriers = [];
    if (overweight) {
      // 500+ kg → contact for custom quote
      carriers = [];
    } else if (sameDistrict) {
      const est = estimateForTier("same_district", weight);
      carriers.push({
        code: "agroexpress_same",
        name: "AgroExpress",
        tagline_key: "de_tag_same_district",
        icon: "🚚",
        tier: "same_district",
        ...est,
        features: ["insured", "tracking"],
      });
    } else {
      const std = estimateForTier("standard", weight);
      const exp = estimateForTier("express", weight);
      carriers.push({
        code: "agroexpress_std",
        name: "AgroExpress",
        tagline_key: "de_tag_standard",
        icon: "🚚",
        tier: "standard",
        ...std,
        features: ["insured", "tracking", "cold_storage"],
      });
      carriers.push({
        code: "agroexpress_exp",
        name: "AgroExpress Express",
        tagline_key: "de_tag_express",
        icon: "⚡",
        tier: "express",
        ...exp,
        features: ["insured", "tracking", "cold_storage", "priority"],
      });
    }

    const districts = await fetchAll(
      `SELECT district_id, district_name FROM districts ORDER BY district_id`
    );

    res.json({
      from: fromRow,
      to: toRow,
      distance_km: distance,
      weight_kg: weight,
      same_district: sameDistrict,
      overweight,
      carriers,
      districts,
    });
  } catch (err) { next(err); }
});

export default router;
