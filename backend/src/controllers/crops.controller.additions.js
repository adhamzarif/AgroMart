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
