// prices.routes.js — /api/prices/*
import { Router } from 'express';
import { listPrices } from '../controllers/prices.controller.js';

const router = Router();
router.get('/', listPrices);
export default router;
