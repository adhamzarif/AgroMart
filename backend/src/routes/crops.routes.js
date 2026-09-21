// crops.routes.js — /api/crops/*
// GET routes are public; write routes require login + role.
import { Router } from 'express';
import {
  listCrops,
  getCrop,
  postCrop,
  patchCrop,
  deleteCrop,
} from '../controllers/crops.controller.js';
import { handleUpload } from '../middleware/upload.js';
import { requireAuth, requireRole } from '../middleware/auth.middleware.js';

const router = Router();

// Public reads
router.get('/', listCrops);
router.get('/:id', getCrop);

// Farmer + admin writes (login required; role-gated)
router.post('/', requireRole('farmer', 'admin'), handleUpload, postCrop);
router.patch('/:id', requireRole('farmer', 'admin'), patchCrop);
router.delete('/:id', requireRole('farmer', 'admin'), deleteCrop);

export default router;
