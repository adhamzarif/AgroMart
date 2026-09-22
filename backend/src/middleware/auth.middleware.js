// auth.middleware.js — protect routes by session and role.
export function requireAuth(req, res, next) {
  if (!req.session?.user) return res.status(401).json({ error: 'Login required' });
  req.user = req.session.user;
  next();
}

export function requireRole(...allowed) {
  return (req, res, next) => {
    if (!req.session?.user) return res.status(401).json({ error: 'Login required' });
    const has = (req.session.user.roles || []).some((r) => allowed.includes(r));
    if (!has) return res.status(403).json({ error: 'Forbidden' });
    req.user = req.session.user;
    next();
  };
}
