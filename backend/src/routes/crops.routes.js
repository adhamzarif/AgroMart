import { handleUpload } from '../middleware/upload.js';
// crops.routes.js — /api/crops/*
import { Router } from 'express';
import { listCrops, getCrop, postCrop } from '../controllers/crops.controller.js';

const router = Router();

router.get('/', listCrops);
router.post('/', handleUpload, postCrop);      // GET /api/crops?category=&district=&q=&limit=&offset=
router.get('/:id', getCrop);     // GET /api/crops/123

export default router;
