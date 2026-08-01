// crops.api.js — marketplace endpoints.
import { api } from './client.js';

export const getCrops = (params = {}) => {
  const qs = new URLSearchParams(
    Object.entries(params).filter(([, v]) => v != null && v !== '')
  ).toString();
  return api.get(`/api/crops${qs ? `?${qs}` : ''}`);
};

export const getCrop = (id) => api.get(`/api/crops/${id}`);
