// prices.controller.js — live prices endpoint.
import { getLivePrices } from '../models/price.model.js';

export async function listPrices(req, res, next) {
  try {
    const role = req.query.role === 'farmer' ? 'farmer' : 'buyer';
    const search = req.query.q?.trim() || undefined;
    const prices = await getLivePrices({ role, search });
    res.json({ prices, count: prices.length, role });
  } catch (err) { next(err); }
}
