// auth.api.js — auth endpoints.
import { api } from './client.js';

export const register = (data) => api.post('/api/auth/register', data);