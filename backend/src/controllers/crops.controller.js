// crops.controller.js — marketplace crop endpoints.
// Layers 3 (auth) and 4 (ownership) apply here.
// - listCrops / getCrop: PUBLIC (anyone can browse)
// - postCrop / patchCrop / deleteCrop: farmer or admin only (wired via requireRole in routes)
// - Ownership: farmers can only touch their own crops; admins bypass ownership.
import path from 'path';
import {
  listAvailableCrops,
  getCropById,
  createCrop,
  updateCrop,
  deleteCropById,
} from '../models/crop.model.js';

const UNITS = ['kg', 'ton', 'mon', 'piece'];

// ─── LIST (public) ───────────────────────────────────────────────
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
  } catch (err) { next(err); }
}

// ─── GET ONE (public) ────────────────────────────────────────────
export async function getCrop(req, res, next) {
  try {
    const crop = await getCropById(parseInt(req.params.id, 10));
    if (!crop) return res.status(404).json({ error: 'Crop not found' });
    res.json({ crop });
  } catch (err) { next(err); }
}

// ─── CREATE (farmer + admin) ─────────────────────────────────────
// SECURITY: farmerId ALWAYS comes from req.user.userId (session).
// Any farmerId in the request body is IGNORED — never trust the client.
export async function postCrop(req, res, next) {
  try {
    const b = req.body;
    const errors = {};
    if (!b.cropName || b.cropName.trim().length < 2) errors.cropName = 'Crop name required';
    if (!b.categoryId) errors.categoryId = 'Category required';
    if (!(Number(b.quantity) > 0)) errors.quantity = 'Quantity must be positive';
    if (!(Number(b.pricePerUnit) > 0)) errors.pricePerUnit = 'Price must be positive';
    if (!UNITS.includes(b.unit)) errors.unit = 'Invalid unit';
    if (Object.keys(errors).length) {
      return res.status(422).json({ error: 'Validation failed', fields: errors });
    }

    const images = (req.files || []).map((f) => `/uploads/crops/${path.basename(f.path)}`);

    const crop = await createCrop({
      farmerId: req.user.userId,      // ← from session, not from client body
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
  } catch (err) { next(err); }
}

// ─── UPDATE (farmer owner + admin) ───────────────────────────────
export async function patchCrop(req, res, next) {
  try {
    const cropId = parseInt(req.params.id, 10);
    const existing = await getCropById(cropId);
    if (!existing) return res.status(404).json({ error: 'Crop not found' });

    // Ownership check: admin bypasses, farmer must own the crop
    const isAdmin = req.user.roles?.includes('admin');
    const isOwner = existing.farmer_id === req.user.userId;
    if (!isAdmin && !isOwner) return res.status(403).json({ error: 'Not your crop' });

    // Whitelist fields — don't let a client change farmer_id or crop_id
    const b = req.body;
    const patch = {};
    if (b.cropName !== undefined) patch.cropName = String(b.cropName).trim();
    if (b.categoryId !== undefined) patch.categoryId = Number(b.categoryId);
    if (b.quantity !== undefined) patch.quantity = Number(b.quantity);
    if (b.unit !== undefined) {
      if (!UNITS.includes(b.unit)) return res.status(422).json({ error: 'Invalid unit' });
      patch.unit = b.unit;
    }
    if (b.pricePerUnit !== undefined) patch.pricePerUnit = Number(b.pricePerUnit);
    if (b.description !== undefined) patch.description = String(b.description).trim() || null;
    if (b.isOrganic !== undefined) patch.isOrganic = b.isOrganic === true || b.isOrganic === 'true';
    if (b.status !== undefined) {
      if (!['available', 'sold', 'expired'].includes(b.status)) {
        return res.status(422).json({ error: 'Invalid status' });
      }
      patch.status = b.status;
    }

    if (Object.keys(patch).length === 0) {
      return res.status(400).json({ error: 'No fields to update' });
    }

    const crop = await updateCrop(cropId, patch);
    res.json({ message: 'Crop updated', crop });
  } catch (err) { next(err); }
}

// ─── DELETE (farmer owner + admin) ───────────────────────────────
export async function deleteCrop(req, res, next) {
  try {
    const cropId = parseInt(req.params.id, 10);
    const existing = await getCropById(cropId);
    if (!existing) return res.status(404).json({ error: 'Crop not found' });

    const isAdmin = req.user.roles?.includes('admin');
    const isOwner = existing.farmer_id === req.user.userId;
    if (!isAdmin && !isOwner) return res.status(403).json({ error: 'Not your crop' });

    await deleteCropById(cropId);
    res.json({ message: 'Crop deleted', cropId });
  } catch (err) { next(err); }
}
