// stock.js — shared "in stock / low stock / out of stock" logic.
// Based purely on crops.quantity (there is no separate stock-status column
// in the schema — see migrations/003_marketplace.sql). Adjust
// LOW_STOCK_THRESHOLD if the team wants a different cutoff.
export const LOW_STOCK_THRESHOLD = 10;

/** @returns {'out' | 'low' | 'in'} */
export function getStockStatus(quantity) {
  const qty = Number(quantity ?? 0);
  if (qty <= 0) return 'out';
  if (qty < LOW_STOCK_THRESHOLD) return 'low';
  return 'in';
}