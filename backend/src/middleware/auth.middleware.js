// auth.middleware.js — protect routes by session and role.
// Not used yet by Round 1 endpoints but Round 2 (dashboards) will need these.

/** 401 if not logged in. Attaches req.user for downstream handlers. */
export function requireAuth(req, res, next) {
  if (!req.session?.user) {
    return res.status(401).json({ error: 'Login required' });
  }
  req.user = req.session.user;
  next();
}

/** 403 if the user doesn't have any of the allowed roles. */
export function requireRole(...allowed) {
  return (req, res, next) => {
    if (!req.session?.user) return res.status(401).json({ error: 'Login required' });
    const userRoles = req.session.user.roles || [];
    const has = userRoles.some((r) => allowed.includes(r));
    if (!has) return res.status(403).json({ error: 'Forbidden' });
    req.user = req.session.user;
    next();
  };
}
