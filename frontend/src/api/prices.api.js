// prices.api.js — live prices endpoint.
import { api } from './client.js';

export const getLivePrices = ({ role, q } = {}) => {
  const qs = new URLSearchParams();
  if (role) qs.set('role', role);
  if (q) qs.set('q', q);
  const s = qs.toString();
  return api.get(`/api/prices${s ? `?${s}` : ''}`);
};
