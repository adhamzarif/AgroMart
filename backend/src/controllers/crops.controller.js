// crops.controller.js — marketplace crop endpoints.
import { listAvailableCrops, getCropById } from '../models/crop.model.js';

export async function listCrops(req, res, next) {
  try {
    const limit = Math.min(parseInt(req.query.limit ?? '12', 10) || 12, 50);
    const offset = Math.max(parseInt(req.query.offset ?? '0', 10) || 0, 0);
    const crops = await listAvailableCrops({
      distinct: req.query.distinct === '1',
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

// Add to backend/src/controllers/crops.controller.js (append the new handler + import).
import { createCrop } from '../models/crop.model.js';
import path from 'path';

// req.files comes from the upload middleware; store web-accessible paths.
export async function postCrop(req, res, next) {
  try {
    const b = req.body;
    // basic validation
    const errors = {};
    if (!b.cropName || b.cropName.trim().length < 2) errors.cropName = 'Crop name required';
    if (!b.categoryId) errors.categoryId = 'Category required';
    if (!(Number(b.quantity) > 0)) errors.quantity = 'Quantity must be positive';
    if (!(Number(b.pricePerUnit) > 0)) errors.pricePerUnit = 'Price must be positive';
    if (!['kg', 'ton', 'mon', 'piece'].includes(b.unit)) errors.unit = 'Invalid unit';
    if (Object.keys(errors).length) {
      return res.status(422).json({ error: 'Validation failed', fields: errors });
    }

    // map uploaded files to the URL the API serves them at
    const images = (req.files || []).map((f) => `/uploads/crops/${path.basename(f.path)}`);

    const crop = await createCrop({
      // farmerId: hardcoded demo farmer for now (auth wires this later — slice A2)
      farmerId: Number(b.farmerId) || 4,
      categoryId: Number(b.categoryId),
      cropName: b.cropName.trim(),
      cropVariety: b.cropVariety?.trim() || null,
      quantity: Number(b.quantity),
      unit: b.unit,
      pricePerUnit: Number(b.pricePerUnit),
      isOrganic: b.isOrganic === 'true' || b.isOrganic === true,
      description: b.description?.trim() || null,
      images,
    });

    res.status(201).json({ message: 'Crop listed', crop });
  } catch (err) {
    next(err);
  }
}
