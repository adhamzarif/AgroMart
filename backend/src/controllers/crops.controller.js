// crops.controller.js — marketplace crop endpoints.
import { listAvailableCrops, getCropById } from '../models/crop.model.js';

export async function listCrops(req, res, next) {
  try {
    const limit = Math.min(parseInt(req.query.limit ?? '12', 10) || 12, 50);
    const offset = Math.max(parseInt(req.query.offset ?? '0', 10) || 0, 0);
    const crops = await listAvailableCrops({
      categoryId: req.query.category ? parseInt(req.query.category, 10) : undefined,
      districtId: req.query.district ? parseInt(req.query.district, 10) : undefined,
      search: req.query.q?.trim() || undefined,
      limit,
      offset,
    });
    res.json({ crops, count: crops.length, limit, offset });
  } catch (err) {
    next(err);
  }
}

export async function getCrop(req, res, next) {
  try {
    const crop = await getCropById(parseInt(req.params.id, 10));
    if (!crop) return res.status(404).json({ error: 'Crop not found' });
    res.json({ crop });
  } catch (err) {
    next(err);
  }
}
