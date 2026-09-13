// stats.routes.js — public overview stats for the landing/how-it-works pages.
// GET /api/stats/overview -> { farmers, buyers, agents, crops, orders, districts }
import { Router } from 'express';
import { fetchOne } from '../config/db.js';

const router = Router();

router.get('/overview', async (_req, res, next) => {
  try {
    const row = await fetchOne(`
      SELECT
        (SELECT COUNT(*) FROM user_roles WHERE role='farmer')::int AS farmers,
        (SELECT COUNT(*) FROM user_roles WHERE role='buyer')::int  AS buyers,
        (SELECT COUNT(*) FROM user_roles WHERE role='agent')::int  AS agents,
        (SELECT COUNT(*) FROM crops WHERE status='available')::int AS crops,
        (SELECT COUNT(*) FROM orders)::int                          AS orders,
        (SELECT COUNT(*) FROM districts)::int                       AS districts
    `);
    res.json({ stats: row });
  } catch (err) { next(err); }
});

export default router;
