// review.model.js — data access for crop_reviews (migrations/010_reviews.sql).
//
// reviewer_name is a free-text guest name, not tied to a user_id, because
// there is still no login/session in this app (see the migration file's
// header comment for the plan to add reviewer_id once auth exists).
import { fetchAll, fetchOne } from '../config/db.js';

export function listReviewsForCrop(cropId, { limit = 20, offset = 0 } = {}) {
  return fetchAll(
    `SELECT review_id, reviewer_name, rating, comment, created_at
     FROM crop_reviews
     WHERE crop_id = $1
     ORDER BY created_at DESC
     LIMIT $2 OFFSET $3`,
    [cropId, limit, offset]
  );
}

/** { review_count, avg_rating } for a crop — avg_rating is 0 when there are no reviews yet. */
export async function getRatingSummary(cropId) {
  const row = await fetchOne(
    `SELECT COUNT(*)::int AS review_count,
            COALESCE(ROUND(AVG(rating)::numeric, 1), 0) AS avg_rating
     FROM crop_reviews
     WHERE crop_id = $1`,
    [cropId]
  );
  return row ?? { review_count: 0, avg_rating: 0 };
}

export function createReview({ cropId, reviewerName, rating, comment }) {
  return fetchOne(
    `INSERT INTO crop_reviews (crop_id, reviewer_name, rating, comment)
     VALUES ($1, $2, $3, $4)
     RETURNING review_id, reviewer_name, rating, comment, created_at`,
    [cropId, reviewerName, rating, comment || null]
  );
}