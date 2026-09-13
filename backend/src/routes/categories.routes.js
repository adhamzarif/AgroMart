// categories.routes.js — GET /api/categories (for the crop form dropdown)
import { Router } from 'express';
import { fetchAll } from '../config/db.js';

const router = Router();
router.get('/', async (_req, res, next) => {
  try {
    const categories = await fetchAll(
      'SELECT category_id, category_name, category_name_bn FROM crop_categories ORDER BY category_name'
    );
    res.json({ categories });
  } catch (err) { next(err); }
});
export default router;
