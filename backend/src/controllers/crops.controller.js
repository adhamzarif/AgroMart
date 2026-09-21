// crops.controller.js — marketplace crop endpoints.
import { listAvailableCrops, getCropById, getRelatedCrops } from '../models/crop.model.js';

export async function listCrops(req, res, next) {
  try {
    // Now fully server-side: search, category, district, price range,
    // organic/in-stock flags and sort are all applied in the DB query, and
    // `total` (independent of limit/offset) lets the frontend "Load More"
    // without re-fetching a large pool up front like before.
    const limit = Math.min(parseInt(req.query.limit ?? '12', 10) || 12, 100);
    const offset = Math.max(parseInt(req.query.offset ?? '0', 10) || 0, 0);

    const { crops, total } = await listAvailableCrops({
      distinct: req.query.distinct === '1',
      categoryId: req.query.category ? parseInt(req.query.category, 10) : undefined,
      district: req.query.district?.trim() || undefined,
      search: req.query.q?.trim() || undefined,
      minPrice: req.query.minPrice !== undefined ? Number(req.query.minPrice) : undefined,
      maxPrice: req.query.maxPrice !== undefined ? Number(req.query.maxPrice) : undefined,
      organicOnly: req.query.organic === 'true',
      inStockOnly: req.query.inStock === 'true',
      sortBy: req.query.sort || 'default',
      limit,
      offset,
    });

    res.json({ crops, total, limit, offset });
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

// "Related products" for the ProductDetails page — a few other available
// crops from the same category, excluding the crop being viewed.
export async function getRelated(req, res, next) {
  try {
    const cropId = parseInt(req.params.id, 10);
    const crop = await getCropById(cropId);
    if (!crop) return res.status(404).json({ error: 'Crop not found' });

    const limit = Math.min(parseInt(req.query.limit ?? '4', 10) || 4, 12);
    const crops = await getRelatedCrops(crop.category_id, cropId, limit);
    res.json({ crops });
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