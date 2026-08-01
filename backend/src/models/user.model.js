// user.model.js — user data access.
// Ports from: Models/UserModel.php (create, findByPhone, authenticate, getRoles).
// Fixes applied: bcryptjs cost 12 (old code used PASSWORD_DEFAULT = cost 10);
// parameterised queries; account_status/preferred_language correct column names.
import bcrypt from 'bcryptjs';
import { fetchOne, fetchAll, tx } from '../config/db.js';

const BCRYPT_COST = 12;

/** Find a user by phone (used for login + duplicate check). */
export function findByPhone(phone) {
  return fetchOne('SELECT * FROM users WHERE phone = $1', [phone]);
}

/** Find a user by id, without the password hash. */
export function findById(userId) {
  return fetchOne(
    `SELECT user_id, full_name, phone, email, district_id, account_status,
            preferred_language, wallet_balance, created_at
     FROM users WHERE user_id = $1`,
    [userId]
  );
}

/** Return an array of role strings for a user. */
export async function getRoles(userId) {
  const rows = await fetchAll('SELECT role FROM user_roles WHERE user_id = $1', [userId]);
  return rows.map((r) => r.role);
}

/**
 * Create a user and assign roles, atomically.
 * @param {{fullName, phone, password, email?, districtId?}} data
 * @param {string[]} roles  e.g. ['farmer']
 * @returns the new user row (no password hash) plus roles
 */
export async function createUser(data, roles) {
  const hash = await bcrypt.hash(data.password, BCRYPT_COST);
  return tx(async (client) => {
    const { rows } = await client.query(
      `INSERT INTO users (full_name, phone, email, password_hash, district_id, account_status)
       VALUES ($1, $2, $3, $4, $5, 'active')
       RETURNING user_id, full_name, phone, email, district_id, account_status, created_at`,
      [data.fullName, data.phone, data.email ?? null, hash, data.districtId ?? null]
    );
    const user = rows[0];
    for (const role of roles) {
      await client.query(
        `INSERT INTO user_roles (user_id, role) VALUES ($1, $2)
         ON CONFLICT (user_id, role) DO NOTHING`,
        [user.user_id, role]
      );
    }
    user.roles = roles;
    return user;
  });
}

/** Verify credentials; returns the user (with roles) or null. */
export async function authenticate(phone, password) {
  const user = await findByPhone(phone);
  if (!user) return null;
  const ok = await bcrypt.compare(password, user.password_hash);
  if (!ok) return null;
  delete user.password_hash;
  user.roles = await getRoles(user.user_id);
  return user;
}
