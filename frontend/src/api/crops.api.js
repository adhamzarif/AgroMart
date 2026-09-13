// crops.api.js — marketplace endpoints.
import { api } from './client.js';

export const getCrops = (params = {}) => {
  const qs = new URLSearchParams(
    Object.entries(params).filter(([, v]) => v != null && v !== '')
  ).toString();
  return api.get(`/api/crops${qs ? `?${qs}` : ''}`);
};

export const getCrop = (id) => api.get(`/api/crops/${id}`);

// Add these to frontend/src/api/crops.api.js
// createCrop sends multipart/form-data (for the image files), so it does NOT
// use the JSON client — it calls fetch directly with the FormData body.

const BASE = import.meta.env.VITE_API_URL || 'http://localhost:4000';

export async function createCrop(formData) {
  const res = await fetch(`${BASE}/api/crops`, {
    method: 'POST',
    credentials: 'include',
    body: formData, // do NOT set Content-Type; the browser sets the multipart boundary
  });
  const data = await res.json().catch(() => ({}));
  if (!res.ok) {
    const err = new Error(data.error || `HTTP ${res.status}`);
    err.fields = data.fields;
    throw err;
  }
  return data;
}

export const getCategories = () =>
  fetch(`${BASE}/api/categories`, { credentials: 'include' }).then((r) => r.json());
