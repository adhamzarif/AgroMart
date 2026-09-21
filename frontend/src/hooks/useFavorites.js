// useFavorites.js — Marketplace favorites/wishlist.
//
// IMPORTANT — this is frontend-only storage, not a real account feature:
// AgroMart's backend already has a `favorites` table (migrations/003_marketplace.sql,
// columns: user_id, favorite_type, crop_id, ...), but there is no login/session
// yet (backend/src/middleware/auth.js is empty, and /api/auth only has
// POST /register so far — no /login, no logged-in user available on the
// frontend). Favorites can't be tied to a real user_id yet.
//
// So, for now, favorites are kept in this browser's localStorage only:
//  - they persist across page reloads on THIS device/browser
//  - they are NOT synced to the database and are NOT shared across devices
//  - they will be lost if the user clears site data
//
// When login lands, swap the body of toggleFavorite()/isFavorite() for calls
// to a favorites.api.js that hits POST/DELETE /api/favorites — the shape
// (a Set of crop_id) can stay the same, so components using this hook won't
// need to change.
import { useCallback, useEffect, useState } from 'react';

const STORAGE_KEY = 'agromart_favorite_crop_ids';

function readStoredIds() {
  try {
    const raw = window.localStorage.getItem(STORAGE_KEY);
    const parsed = raw ? JSON.parse(raw) : [];
    return new Set(Array.isArray(parsed) ? parsed.map(String) : []);
  } catch {
    // localStorage unavailable (privacy mode) or corrupted value — start empty.
    return new Set();
  }
}

export function useFavorites() {
  const [favoriteIds, setFavoriteIds] = useState(() => readStoredIds());

  useEffect(() => {
    try {
      window.localStorage.setItem(
        STORAGE_KEY,
        JSON.stringify(Array.from(favoriteIds))
      );
    } catch {
      // ignore write failures (e.g. storage full / disabled)
    }
  }, [favoriteIds]);

  const isFavorite = useCallback(
    (cropId) => favoriteIds.has(String(cropId)),
    [favoriteIds]
  );

  const toggleFavorite = useCallback((cropId) => {
    const id = String(cropId);
    setFavoriteIds((prev) => {
      const next = new Set(prev);
      if (next.has(id)) next.delete(id);
      else next.add(id);
      return next;
    });
  }, []);

  return { favoriteIds, isFavorite, toggleFavorite };
}