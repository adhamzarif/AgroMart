// reviews.controller.js — Marketplace crop reviews/ratings endpoints.
// Mounted under /api/crops/:id/reviews (see crops.routes.js) so a review is
// always scoped to a specific crop.
import { listReviewsForCrop, getRatingSummary, createReview } from '../models/review.model.js';
import { getCropById } from '../models/crop.model.js';

export async function getReviews(req, res, next) {
  try {
    const cropId = parseInt(req.params.id, 10);
    if (!Number.isInteger(cropId)) return res.status(400).json({ error: 'Invalid crop id' });

    const [reviews, summary] = await Promise.all([
      listReviewsForCrop(cropId),
      getRatingSummary(cropId),
    ]);

    res.json({ reviews, review_count: summary.review_count, avg_rating: Number(summary.avg_rating) });
  } catch (err) {
    next(err);
  }
}

export async function postReview(req, res, next) {
  try {
    const cropId = parseInt(req.params.id, 10);
    if (!Number.isInteger(cropId)) return res.status(400).json({ error: 'Invalid crop id' });

    const { reviewerName, rating, comment } = req.body;

    const errors = {};
    if (!reviewerName || !String(reviewerName).trim()) errors.reviewerName = 'Name is required';
    const ratingNum = Number(rating);
    if (!Number.isInteger(ratingNum) || ratingNum < 1 || ratingNum > 5) {
      errors.rating = 'Rating must be an integer from 1 to 5';
    }
    if (Object.keys(errors).length) {
      return res.status(422).json({ error: 'Validation failed', fields: errors });
    }

    const crop = await getCropById(cropId);
    if (!crop) return res.status(404).json({ error: 'Crop not found' });

    const review = await createReview({
      cropId,
      reviewerName: String(reviewerName).trim().slice(0, 100),
      rating: ratingNum,
      comment: comment ? String(comment).trim().slice(0, 1000) : null,
    });

    res.status(201).json({ review });
  } catch (err) {
    next(err);
  }
}