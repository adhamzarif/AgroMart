// AuthContext.jsx — global auth state. Hydrates via /api/auth/me on mount.
import { createContext, useContext, useEffect, useState } from 'react';
import { login as apiLogin, logout as apiLogout, me as apiMe } from '../api/auth.api.js';

const AuthCtx = createContext({
  user: null,
  loading: true,
  login: async () => {},
  logout: async () => {},
});

export function AuthProvider({ children }) {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    let alive = true;
    apiMe()
      .then((res) => { if (alive) setUser(res.user); })
      .catch(() => {})
      .finally(() => { if (alive) setLoading(false); });
    return () => { alive = false; };
  }, []);

  const login = async (credentials) => {
    const res = await apiLogin(credentials);
    setUser(res.user);
    return res.user;
  };

  const logout = async () => {
    try { await apiLogout(); } catch {}
    setUser(null);
  };

  return (
    <AuthCtx.Provider value={{ user, loading, login, logout }}>
      {children}
    </AuthCtx.Provider>
  );
}

export const useAuth = () => useContext(AuthCtx);
