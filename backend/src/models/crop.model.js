// FEATURED_DEDUPE_PATCHED
// crop.model.js — crop data access for the marketplace.
// Ports the "list available crops with farmer + category + district" query
// (was: CropModel.php listing methods / vw_active_crops_with_details).
import { fetchAll, fetchOne } from '../config/db.js';

/**
 * List available crops for the marketplace, newest first.
 * Supports optional filters: category_id, district_id, search (crop name), and pagination.
 */
export async function listAvailableCrops({ categoryId, districtId, search, limit = 12, offset = 0, distinct = false } = {}) {
  const where = [`c.status = 'available'`];
  const params = [];
  let i = 1;

  if (categoryId) { where.push(`c.category_id = $${i++}`); params.push(categoryId); }
  if (districtId) { where.push(`u.district_id = $${i++}`); params.push(districtId); }
  if (search)     { where.push(`c.crop_name ILIKE $${i++}`); params.push(`%${search}%`); }

  // limit + offset are the last two params
  const limitIdx = i++;
  const offsetIdx = i++;
  params.push(limit, offset);

  const sql = `
    SELECT ${distinct ? 'DISTINCT ON (c.crop_name) ' : ''}c.crop_id, c.crop_name, c.quantity, c.unit, c.price_per_unit,
           c.is_organic, c.images, c.created_at,
           cc.category_name,
           u.full_name  AS farmer_name,
           d.district_name,
           (c.created_at > NOW() - INTERVAL '7 days') AS is_new
    FROM crops c
    JOIN users u            ON c.farmer_id = u.user_id
    JOIN crop_categories cc ON c.category_id = cc.category_id
    LEFT JOIN districts d    ON u.district_id = d.district_id
    WHERE ${where.join(' AND ')}
    ORDER BY ${distinct ? 'c.crop_name, ' : ''}c.created_at DESC
    LIMIT $${limitIdx} OFFSET $${offsetIdx}`;

  return fetchAll(sql, params);
}

/** Single crop with full detail (for the detail page). */
export function getCropById(cropId) {
  return fetchOne(
    `SELECT c.*, cc.category_name, u.full_name AS farmer_name, u.phone AS farmer_phone,
            d.district_name
     FROM crops c
     JOIN users u            ON c.farmer_id = u.user_id
     JOIN crop_categories cc ON c.category_id = cc.category_id
     LEFT JOIN districts d    ON u.district_id = d.district_id
     WHERE c.crop_id = $1`,
    [cropId]
  );
}

// Add this to backend/src/models/crop.model.js (append — don't replace the file).
// createCrop — insert a new crop listing with optional image paths.

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
