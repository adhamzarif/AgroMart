// admin.controller.js — read-only endpoints for admin dashboard.
import { pool } from '../config/db.js';

export async function getStats(req, res, next) {
  try {
    const [users, crops, listings, today] = await Promise.all([
      pool.query('SELECT COUNT(*)::int AS c FROM users'),
      pool.query('SELECT COUNT(*)::int AS c FROM crops'),
      pool.query("SELECT COUNT(*)::int AS c FROM crops WHERE status='available'"),
      pool.query("SELECT COUNT(*)::int AS c FROM users WHERE created_at::date = CURRENT_DATE"),
    ]);
    res.json({
      totalUsers: users.rows[0].c,
      totalCrops: crops.rows[0].c,
      activeListings: listings.rows[0].c,
      newUsersToday: today.rows[0].c,
    });
  } catch (err) { next(err); }
}

export async function listUsers(req, res, next) {
  try {
    const search = req.query.q?.trim() || '';
    const roleFilter = req.query.role?.trim() || '';
    const params = [];
    let where = 'WHERE 1=1';
    if (search) {
      params.push(`%${search}%`);
      where += ` AND (u.full_name ILIKE $${params.length} OR u.phone ILIKE $${params.length})`;
    }
    if (roleFilter) {
      params.push(roleFilter);
      where += ` AND EXISTS (SELECT 1 FROM user_roles ur WHERE ur.user_id=u.user_id AND ur.role=$${params.length})`;
    }
    const { rows } = await pool.query(
      `SELECT u.user_id, u.full_name, u.phone, u.email, u.account_status, u.created_at,
              COALESCE(array_agg(ur.role) FILTER (WHERE ur.role IS NOT NULL), '{}') AS roles
       FROM users u
       LEFT JOIN user_roles ur ON ur.user_id = u.user_id
       ${where}
       GROUP BY u.user_id
       ORDER BY u.created_at DESC
       LIMIT 50`,
      params
    );
    res.json({ users: rows, count: rows.length });
  } catch (err) { next(err); }
}

export async function listCropsAdmin(req, res, next) {
  try {
    const { rows } = await pool.query(
      `SELECT c.crop_id, c.crop_name, c.quantity, c.unit, c.price_per_unit, c.status,
              c.created_at, u.full_name AS farmer_name, u.phone AS farmer_phone
       FROM crops c
       LEFT JOIN users u ON u.user_id = c.farmer_id
       ORDER BY c.created_at DESC
       LIMIT 100`
    );
    res.json({ crops: rows, count: rows.length });
  } catch (err) { next(err); }
}
