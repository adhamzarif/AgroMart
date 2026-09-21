// crop.model.js — crop data access for the marketplace.
// Ports the "list available crops with farmer + category + district" query
// (was: CropModel.php listing methods / vw_active_crops_with_details).
import { fetchAll, fetchOne, pool } from '../config/db.js';

/**
 * List available crops for the marketplace, with full server-side
 * filtering, sorting and pagination.
 *
 * `search` — a comma-separated list of already-expanded search terms
 * (Bangla + English synonyms — see frontend/src/i18n/cropSynonyms.js's
 * expandSearchTerms()). We match crop_name ILIKE ANY(terms) so bilingual
 * search still works without the DB needing to know about synonyms.
 *
 * `district` — matched against d.district_name (not a district_id) since
 * the districts table only has a handful of seeded rows shared with other
 * modules; every crop's farmer district still comes from that table, so
 * name-matching here is exact and simple.
 *
 * `distinct` — when true, collapses multiple listings with the same
 * crop_name down to one (DISTINCT ON), newest first. NOTE: `total` is
 * computed from the window function before DISTINCT ON is applied, so with
 * distinct=true the reported total may be slightly higher than the number
 * of rows actually returned across pages — acceptable for now, flagged here
 * in case it needs exact correction later.
 *
 * Returns { crops, total } — `total` is the COUNT of all rows matching the
 * filters (via a window function), independent of limit/offset, so the
 * frontend can page/"Load More" without re-fetching everything.
 *
 * Two separate ratings are joined in:
 *  - review_count / avg_rating         → this crop's own reviews (crop_reviews table, migrations/010_reviews.sql)
 *  - farmer_review_count / farmer_avg_rating → the farmer's overall rating (farmer_ratings table)
 * They're intentionally named differently so ProductCard/ProductDetails can show both without clashing.
 */
export async function listAvailableCrops({
  categoryId,
  district,
  search,
  minPrice,
  maxPrice,
  organicOnly,
  inStockOnly,
  sortBy = 'default',
  distinct = false,
  limit = 12,
  offset = 0,
} = {}) {
  const where = [`c.status = 'available'`];
  const params = [];
  let i = 1;

  if (categoryId) {
    where.push(`c.category_id = $${i++}`);
    params.push(categoryId);
  }
  if (district) {
    where.push(`d.district_name ILIKE $${i++}`);
    params.push(district);
  }
  if (search) {
    const terms = search.split(',').map((s) => s.trim()).filter(Boolean);
    if (terms.length) {
      where.push(`c.crop_name ILIKE ANY($${i++})`);
      params.push(terms.map((t) => `%${t}%`));
    }
  }
  if (minPrice != null && minPrice !== '') {
    where.push(`c.price_per_unit >= $${i++}`);
    params.push(minPrice);
  }
  if (maxPrice != null && maxPrice !== '') {
    where.push(`c.price_per_unit <= $${i++}`);
    params.push(maxPrice);
  }
  if (organicOnly) {
    where.push(`c.is_organic = TRUE`);
  }
  if (inStockOnly) {
    where.push(`c.quantity > 0`);
  }

  // Whitelist sort options — never interpolate the raw sortBy value into SQL.
  const ORDER_BY = {
    'price-low': 'c.price_per_unit ASC',
    'price-high': 'c.price_per_unit DESC',
    name: 'c.crop_name ASC',
    default: 'c.created_at DESC',
  };
  const orderClause = ORDER_BY[sortBy] || ORDER_BY.default;
  // DISTINCT ON requires its leading ORDER BY expression(s) to match the
  // DISTINCT ON columns, so crop_name must lead when distinct=true.
  const finalOrderClause = distinct ? `c.crop_name, ${orderClause}` : orderClause;

  const limitIdx = i++;
  const offsetIdx = i++;
  params.push(limit, offset);

  const sql = `
    SELECT ${distinct ? 'DISTINCT ON (c.crop_name) ' : ''}c.crop_id, c.category_id, c.crop_name, c.quantity, c.unit, c.price_per_unit,
           c.is_organic, c.images, c.created_at, c.description,
           cc.category_name,
           u.full_name  AS farmer_name,
           d.district_name,
           (c.created_at > NOW() - INTERVAL '7 days') AS is_new,
           COALESCE(r.review_count, 0)  AS review_count,
           r.avg_rating                 AS avg_rating,
           COALESCE(fr.review_count, 0) AS farmer_review_count,
           fr.avg_rating                AS farmer_avg_rating,
           COUNT(*) OVER()               AS total_count
    FROM crops c
    JOIN users u            ON c.farmer_id = u.user_id
    JOIN crop_categories cc ON c.category_id = cc.category_id
    LEFT JOIN districts d    ON u.district_id = d.district_id
    LEFT JOIN (
      SELECT crop_id, COUNT(*)::int AS review_count,
             ROUND(AVG(rating)::numeric, 1) AS avg_rating
      FROM crop_reviews
      GROUP BY crop_id
    ) r ON r.crop_id = c.crop_id
    LEFT JOIN (
      SELECT farmer_id,
             ROUND(AVG(overall_rating)::numeric, 1) AS avg_rating,
             COUNT(*)::int AS review_count
      FROM farmer_ratings
      WHERE is_flagged = false
      GROUP BY farmer_id
    ) fr ON u.user_id = fr.farmer_id
    WHERE ${where.join(' AND ')}
    ORDER BY ${finalOrderClause}
    LIMIT $${limitIdx} OFFSET $${offsetIdx}`;

  const rows = await fetchAll(sql, params);
  const total = rows[0]?.total_count ? Number(rows[0].total_count) : 0;
  // Strip the window-function column before handing rows back to the controller.
  const crops = rows.map(({ total_count, ...rest }) => rest);
  return { crops, total };
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

/** A few other available crops from the same category, for "Related Products". */
export function getRelatedCrops(categoryId, excludeCropId, limit = 4) {
  return fetchAll(
    `SELECT c.crop_id, c.crop_name, c.price_per_unit, c.unit, c.quantity,
            c.is_organic, c.images, c.category_id,
            cc.category_name, u.full_name AS farmer_name, d.district_name
     FROM crops c
     JOIN users u            ON c.farmer_id = u.user_id
     JOIN crop_categories cc ON c.category_id = cc.category_id
     LEFT JOIN districts d    ON u.district_id = d.district_id
     WHERE c.status = 'available' AND c.category_id = $1 AND c.crop_id <> $2
     ORDER BY c.created_at DESC
     LIMIT $3`,
    [categoryId, excludeCropId, limit]
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
// Additions to backend/src/models/crop.model.js
// (Append these to the existing file — do not replace.)

// Update whitelisted fields on a crop. `patch` keys are camelCase; SQL columns snake_case.
export async function updateCrop(cropId, patch) {
  const map = {
    cropName: 'crop_name',
    cropVariety: 'crop_variety',
    categoryId: 'category_id',
    quantity: 'quantity',
    unit: 'unit',
    pricePerUnit: 'price_per_unit',
    description: 'description',
    isOrganic: 'is_organic',
    status: 'status',
  };
  const setParts = [];
  const values = [];
  let n = 1;
  for (const [key, val] of Object.entries(patch)) {
    if (!(key in map)) continue;
    setParts.push(`${map[key]} = $${n++}`);
    values.push(val);
  }
  if (setParts.length === 0) return getCropById(cropId);
  values.push(cropId);
  const { rows } = await pool.query(
    `UPDATE crops SET ${setParts.join(', ')}, updated_at = NOW()
       WHERE crop_id = $${n} RETURNING *`,
    values
  );
  return rows[0];
}

export async function deleteCropById(cropId) {
  await pool.query('DELETE FROM crops WHERE crop_id = $1', [cropId]);
  return true;
}
