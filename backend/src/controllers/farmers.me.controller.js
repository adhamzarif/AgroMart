// farmers.me.controller.js — endpoints for the logged-in farmer.
// Mounted as /api/farmers/me/*
import { pool } from '../config/db.js';

export async function getMyCrops(req, res, next) {
  try {
    const farmerId = req.user.userId;
    const { rows } = await pool.query(
      `SELECT c.crop_id, c.crop_name, c.crop_variety, c.quantity, c.unit,
              c.price_per_unit, c.status, c.is_organic, c.created_at,
              c.images
       FROM crops c
       WHERE c.farmer_id = $1
       ORDER BY c.created_at DESC`,
      [farmerId]
    );
    res.json({ crops: rows, count: rows.length });
  } catch (err) { next(err); }
}

export async function getMyStats(req, res, next) {
  try {
    const farmerId = req.user.userId;
    const { rows } = await pool.query(
      `SELECT
         COUNT(*)::int AS total_crops,
         COUNT(*) FILTER (WHERE status='available')::int AS available_crops,
         COUNT(*) FILTER (WHERE status='sold')::int AS sold_crops,
         COALESCE(SUM(quantity * price_per_unit) FILTER (WHERE status='available'), 0)::float AS total_value
       FROM crops WHERE farmer_id=$1`,
      [farmerId]
    );
    res.json({ stats: rows[0] });
  } catch (err) { next(err); }
}
