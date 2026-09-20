// useCart.js — Marketplace shopping cart.
//
// IMPORTANT — this is frontend-only storage, not a real checkout system:
// AgroMart's backend already has an `orders` table (migrations/004_transactions.sql,
// columns: buyer_id, farmer_id, crop_id, payment_status, delivery_address, ...),
// but it's designed for one crop per order and there is still no login/session
// (backend/src/middleware/auth.js is empty, /api/auth only has POST /register
// so far). Without a logged-in buyer_id, we can't create a real order yet.
//
// So, for now, the cart is kept in this browser's localStorage only:
//  - it persists across page reloads on THIS device/browser
//  - it is NOT synced to the database and is NOT shared across devices
//  - there is no real checkout/payment step — Cart.jsx just shows a
//    "checkout will be available once login is ready" notice
//  - it will be lost if the user clears site data
//
// When login + a real /api/orders (or /api/cart) endpoint land, swap the
// body of these functions for API calls — the shape (an array of
// { crop_id, quantity, ...snapshot fields }) can stay the same, so Cart.jsx
// and any component using this hook won't need to change much.
import { useCallback, useEffect, useMemo, useState } from 'react';

const STORAGE_KEY = 'agromart_cart_items';

function readStoredItems() {
  try {
    const raw = window.localStorage.getItem(STORAGE_KEY);
    const parsed = raw ? JSON.parse(raw) : [];
    return Array.isArray(parsed) ? parsed : [];
  } catch {
    // localStorage unavailable (privacy mode) or corrupted value — start empty.
    return [];
  }
}

// We snapshot a few display fields (name, price, unit, image, available
// quantity) at add-to-cart time. Prices/stock can change on the server
// afterwards; Cart.jsx re-clamps quantity against `maxQuantity` but doesn't
// silently rewrite price, so this is clearly "cart as of when you added it"
// rather than a live-synced view — good enough for a no-login demo cart.
export function useCart() {
  const [items, setItems] = useState(() => readStoredItems());

  useEffect(() => {
    try {
      window.localStorage.setItem(STORAGE_KEY, JSON.stringify(items));
    } catch {
      // ignore write failures (e.g. storage full / disabled)
    }
  }, [items]);

  const getQuantity = useCallback(
    (cropId) => items.find((it) => String(it.crop_id) === String(cropId))?.quantity ?? 0,
    [items]
  );

  const isInCart = useCallback(
    (cropId) => items.some((it) => String(it.crop_id) === String(cropId)),
    [items]
  );

  // Adds `qty` more of a crop to the cart (default 1). Clamps to the crop's
  // available stock if `crop.quantity` is known. `crop` should be the full
  // crop object from the API (or a demo crop) — we only keep a snapshot of
  // the fields the cart UI needs.
  const addItem = useCallback((crop, qty = 1) => {
    const id = String(crop.crop_id);
    const available = Number(crop.quantity ?? Infinity);

    setItems((prev) => {
      const existing = prev.find((it) => String(it.crop_id) === id);
      if (existing) {
        const nextQty = Math.min(existing.quantity + qty, available);
        return prev.map((it) =>
          String(it.crop_id) === id ? { ...it, quantity: nextQty, maxQuantity: available } : it
        );
      }

      const img = Array.isArray(crop.images) ? crop.images[0] : crop.images;
      return [
        ...prev,
        {
          crop_id: crop.crop_id,
          crop_name: crop.crop_name ?? crop.name ?? '',
          price_per_unit: Number(crop.price_per_unit ?? crop.price ?? 0),
          unit: crop.unit ?? '',
          image: img ?? null,
          maxQuantity: available,
          quantity: Math.min(Math.max(qty, 1), available),
          is_demo: !!crop.is_demo,
        },
      ];
    });
  }, []);

  const removeItem = useCallback((cropId) => {
    const id = String(cropId);
    setItems((prev) => prev.filter((it) => String(it.crop_id) !== id));
  }, []);

  const setQuantity = useCallback((cropId, qty) => {
    const id = String(cropId);
    setItems((prev) =>
      prev.map((it) => {
        if (String(it.crop_id) !== id) return it;
        const max = Number.isFinite(it.maxQuantity) ? it.maxQuantity : Infinity;
        const clamped = Math.min(Math.max(qty, 1), max);
        return { ...it, quantity: clamped };
      })
    );
  }, []);

  const clearCart = useCallback(() => setItems([]), []);

  const totalCount = useMemo(() => items.reduce((sum, it) => sum + it.quantity, 0), [items]);

  const subtotal = useMemo(
    () => items.reduce((sum, it) => sum + it.quantity * Number(it.price_per_unit || 0), 0),
    [items]
  );

  return {
    items,
    totalCount,
    subtotal,
    isInCart,
    getQuantity,
    addItem,
    removeItem,
    setQuantity,
    clearCart,
  };
}