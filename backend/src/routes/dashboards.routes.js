// dashboards.routes.js — auth-protected dashboard endpoints.
import { Router } from 'express';
import { requireAuth, requireRole } from '../middleware/auth.middleware.js';
import { getMyCrops, getMyStats } from '../controllers/farmers.me.controller.js';
import { getStats as adminStats, listUsers, listCropsAdmin } from '../controllers/admin.controller.js';

const router = Router();

// Farmer dashboard — logged-in farmer's own data
router.get('/farmers/me/crops', requireRole('farmer', 'admin'), getMyCrops);
router.get('/farmers/me/stats', requireRole('farmer', 'admin'), getMyStats);

// Admin dashboard — admin only
router.get('/admin/stats', requireRole('admin'), adminStats);
router.get('/admin/users', requireRole('admin'), listUsers);
router.get('/admin/crops', requireRole('admin'), listCropsAdmin);

export default router;
