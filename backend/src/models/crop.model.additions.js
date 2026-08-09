// Add this to backend/src/models/crop.model.js (append — don't replace the file).
// createCrop — insert a new crop listing with optional image paths.
import { fetchOne } from '../config/db.js';

export async function createCrop(data) {
  const {
    farmerId, categoryId, cropName, cropVariety = null,
    quantity, unit, pricePerUnit, isOrganic = false,
    description = null, images = [],
  } = data;

  return fetchOne(
    `INSERT INTO crops
       (farmer_id, category_id, crop_name, crop_variety, quantity, unit,
        price_per_unit, is_organic, description, images, available_from, status)
     VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,CURRENT_DATE,'available')
     RETURNING crop_id, crop_name, price_per_unit, unit, images, status`,
    [farmerId, categoryId, cropName, cropVariety, quantity, unit,
     pricePerUnit, isOrganic, description, JSON.stringify(images)]
  );
}
