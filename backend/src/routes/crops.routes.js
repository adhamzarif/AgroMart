// crops.routes.js — /api/crops/*
import { Router } from 'express';
import { listCrops, getCrop } from '../controllers/crops.controller.js';

const router = Router();

router.get('/', listCrops);      // GET /api/crops?category=&district=&q=&limit=&offset=
router.get('/:id', getCrop);     // GET /api/crops/123

export default router;
