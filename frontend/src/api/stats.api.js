// stats.api.js — public stats endpoints.
import { api } from './client.js';

export const getOverviewStats = () => api.get('/api/stats/overview');
