// auth.controller.js — authentication request handlers.
// Ports from: Controllers/AuthController.php (register).
import { createUser, findByPhone } from '../models/user.model.js';
import { validateRegistration } from '../utils/validate.js';

export async function register(req, res, next) {
  try {
    const { ok, errors, value } = validateRegistration(req.body);
    if (!ok) {
      return res.status(422).json({ error: 'Validation failed', fields: errors });
    }

    // duplicate phone check (the DB also enforces this via UNIQUE, but a clean
    // message is friendlier than a 500 from the constraint)
    const existing = await findByPhone(value.phone);
    if (existing) {
      return res.status(409).json({ error: 'An account with this phone already exists' });
    }

    const user = await createUser(
      { fullName: value.fullName, phone: value.phone, password: value.password, email: value.email },
      [value.role]
    );

    return res.status(201).json({
      message: 'Registration successful',
      user: { userId: user.user_id, fullName: user.full_name, phone: user.phone, roles: user.roles },
    });
  } catch (err) {
    // unique_violation safety net if two requests race past the check above
    if (err.code === '23505') {
      return res.status(409).json({ error: 'An account with this phone already exists' });
    }
    next(err);
  }
}
