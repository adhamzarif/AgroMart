// farmers.routes.js — farmer profile + reviews for the Trust & Ratings feature.
import { Router } from 'express';
import { fetchAll, fetchOne } from '../config/db.js';

const router = Router();

// GET /api/farmers/:id — farmer profile + rating summary
router.get('/:id', async (req, res, next) => {
  try {
    const { id } = req.params;

    const farmer = await fetchOne(
      `SELECT u.user_id, u.full_name, u.phone, u.address, u.profile_picture,
              u.created_at, d.district_name
       FROM users u
       LEFT JOIN districts d ON u.district_id = d.district_id
       WHERE u.user_id = $1`,
      [id]
    );

    if (!farmer) return res.status(404).json({ error: 'Farmer not found' });

    const summary = await fetchOne(
      `SELECT
         COUNT(*)::int AS review_count,
         ROUND(AVG(overall_rating)::numeric, 1) AS avg_overall,
         ROUND(AVG(quality_rating)::numeric, 1) AS avg_quality,
         ROUND(AVG(delivery_rating)::numeric, 1) AS avg_delivery,
         ROUND(AVG(communication_rating)::numeric, 1) AS avg_communication,
         SUM(CASE WHEN would_recommend THEN 1 ELSE 0 END)::int AS recommend_count
       FROM farmer_ratings
       WHERE farmer_id = $1`,
      [id]
    );

    const cropCount = await fetchOne(
      `SELECT COUNT(*)::int AS active_crops FROM crops WHERE farmer_id = $1 AND status = 'available'`,
      [id]
    );

    const orderCount = await fetchOne(
      `SELECT COUNT(*)::int AS completed_orders FROM orders WHERE farmer_id = $1 AND order_status = 'delivered'`,
      [id]
    );

    res.json({
      ...farmer,
      ...summary,
      active_crops: cropCount.active_crops,
      completed_orders: orderCount.completed_orders,
    });
  } catch (err) { next(err); }
});

// GET /api/farmers/:id/reviews — paginated review list
router.get('/:id/reviews', async (req, res, next) => {
  try {
    const { id } = req.params;
    const limit  = Math.min(50, Math.max(1, Number(req.query.limit || 20)));
    const offset = Math.max(0, Number(req.query.offset || 0));

    const rows = await fetchAll(
      `SELECT r.rating_id, r.overall_rating, r.quality_rating, r.delivery_rating,
              r.communication_rating, r.review_title, r.review_text,
              r.would_recommend, r.is_verified_purchase, r.helpful_count,
              r.created_at,
              u.full_name AS buyer_name,
              d.district_name AS buyer_district
       FROM farmer_ratings r
       JOIN users u ON r.buyer_id = u.user_id
       LEFT JOIN districts d ON u.district_id = d.district_id
       WHERE r.farmer_id = $1 AND r.is_flagged = false
       ORDER BY r.created_at DESC
       LIMIT $2 OFFSET $3`,
      [id, limit, offset]
    );

    res.json({ reviews: rows, count: rows.length });
  } catch (err) { next(err); }
});

// GET /api/farmers/:id/crops — active crops from this farmer
router.get('/:id/crops', async (req, res, next) => {
  try {
    const { id } = req.params;
    const rows = await fetchAll(
      `SELECT c.crop_id, c.crop_name, c.crop_name_en, c.price_per_unit, c.unit,
              c.quantity, c.images, cc.category_name
       FROM crops c
       JOIN crop_categories cc ON c.category_id = cc.category_id
       WHERE c.farmer_id = $1 AND c.status = 'available'
       ORDER BY c.created_at DESC`,
      [id]
    );
    res.json({ crops: rows });
  } catch (err) { next(err); }
});

export default router;
