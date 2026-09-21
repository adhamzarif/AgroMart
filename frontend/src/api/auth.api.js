// auth.api.js — auth endpoints. All calls use credentials:'include' so the
// session cookie is sent with every request.
const BASE = import.meta.env.VITE_API_URL || 'http://localhost:4000';

async function post(path, body) {
  const res = await fetch(`${BASE}${path}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    credentials: 'include',
    body: JSON.stringify(body),
  });
  const data = await res.json().catch(() => ({}));
  if (!res.ok) {
    const err = new Error(data.error || `HTTP ${res.status}`);
    err.fields = data.fields;
    throw err;
  }
  return data;
}

async function get(path) {
  const res = await fetch(`${BASE}${path}`, { credentials: 'include' });
  const data = await res.json().catch(() => ({}));
  if (!res.ok) throw new Error(data.error || `HTTP ${res.status}`);
  return data;
}

export const register = (data) => post('/api/auth/register', data);
export const login    = (data) => post('/api/auth/login', data);
export const logout   = ()     => post('/api/auth/logout', {});
export const me       = ()     => get('/api/auth/me');
