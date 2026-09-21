// auth.controller.js — auth request handlers: register (existing), login, logout, me (new).
import { createUser, findByPhone, authenticate, findById, getRoles } from '../models/user.model.js';
import { validateRegistration } from '../utils/validate.js';

// ─── REGISTER (existing) ─────────────────────────────────────────
export async function register(req, res, next) {
  try {
    const { ok, errors, value } = validateRegistration(req.body);
    if (!ok) return res.status(422).json({ error: 'Validation failed', fields: errors });

    const existing = await findByPhone(value.phone);
    if (existing) return res.status(409).json({ error: 'An account with this phone already exists' });

    const user = await createUser(
      { fullName: value.fullName, phone: value.phone, password: value.password, email: value.email },
      [value.role]
    );

    return res.status(201).json({
      message: 'Registration successful',
      user: { userId: user.user_id, fullName: user.full_name, phone: user.phone, roles: user.roles },
    });
  } catch (err) {
    if (err.code === '23505') return res.status(409).json({ error: 'An account with this phone already exists' });
    next(err);
  }
}

// ─── LOGIN ───────────────────────────────────────────────────────
// POST /api/auth/login  { phone, password }
// On success: sets a session cookie, returns { user }
export async function login(req, res, next) {
  try {
    const phone = String(req.body.phone || '').trim();
    const password = String(req.body.password || '');

    if (!phone || !password) {
      return res.status(422).json({ error: 'Phone and password are required' });
    }

    const user = await authenticate(phone, password);
    if (!user) {
      // Same message for "no such user" and "wrong password" — don't leak which
      return res.status(401).json({ error: 'Invalid phone or password' });
    }

    // Save just what the app needs into the session — never the password hash
    req.session.user = {
      userId: user.user_id,
      fullName: user.full_name,
      phone: user.phone,
      email: user.email,
      roles: user.roles,
    };

    res.json({ message: 'Login successful', user: req.session.user });
  } catch (err) {
    next(err);
  }
}

// ─── LOGOUT ──────────────────────────────────────────────────────
// POST /api/auth/logout  — destroys the session, clears the cookie
export async function logout(req, res, next) {
  try {
    if (!req.session) return res.json({ message: 'Already logged out' });
    req.session.destroy((err) => {
      if (err) return next(err);
      res.clearCookie('agromart.sid');
      res.json({ message: 'Logged out' });
    });
  } catch (err) {
    next(err);
  }
}

// ─── ME ──────────────────────────────────────────────────────────
// GET /api/auth/me  — returns the current logged-in user (or null)
// Used by the frontend on page load to hydrate the AuthContext.
export async function me(req, res, next) {
  try {
    if (!req.session?.user) return res.json({ user: null });

    // Refresh roles from DB in case they changed since login
    const roles = await getRoles(req.session.user.userId);
    const user = { ...req.session.user, roles };
    req.session.user = user; // keep session in sync
    res.json({ user });
  } catch (err) {
    next(err);
  }
}
