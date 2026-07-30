// db.js — PostgreSQL connection pool + query helpers.
// Ports from: core/Database.php (singleton PDO) + core/Model.php (query helpers).
//
// The tx() helper replaces PHP's $this->db->beginTransaction()/commit()/rollBack().
// Every place the old app used a transaction (order create, loan disburse,
// payment callback) becomes:  await tx(async (client) => { ... })
import pg from 'pg';
import { env } from './env.js';

export const pool = new pg.Pool({
  host: env.DB_HOST,
  port: env.DB_PORT,
  database: env.DB_NAME,
  user: env.DB_USER,
  password: env.DB_PASS,
  max: 10,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 5000, // don't hang forever if DB is down
});

// Surface pool-level errors instead of crashing silently.
pool.on('error', (err) => {
  console.error('[db] unexpected idle client error:', err.message);
});

/**
 * Run a query. Returns the full pg result; callers usually want `.rows`.
 * Always use parameterised queries ($1, $2) — never string-concatenate input.
 *   const { rows } = await query('SELECT * FROM users WHERE user_id = $1', [id]);
 */
export const query = (text, params) => pool.query(text, params);

/** Fetch first row or null. (was: Model::fetchOne) */
export async function fetchOne(text, params) {
  const { rows } = await pool.query(text, params);
  return rows[0] ?? null;
}

/** Fetch all rows. (was: Model::fetchAll) */
export async function fetchAll(text, params) {
  const { rows } = await pool.query(text, params);
  return rows;
}

/** Fetch a single scalar from the first row, or null. (was: Model::fetchScalar) */
export async function fetchScalar(text, params) {
  const { rows } = await pool.query(text, params);
  if (!rows[0]) return null;
  return Object.values(rows[0])[0];
}

/**
 * Transaction helper. Pass an async fn that receives a dedicated client.
 * Commits if it resolves, rolls back if it throws. (was: beginTransaction/commit/rollBack)
 *
 *   const orderId = await tx(async (client) => {
 *     await client.query('UPDATE crops SET quantity = quantity - $1 WHERE crop_id = $2 ...', [...]);
 *     const { rows } = await client.query('INSERT INTO orders (...) VALUES (...) RETURNING order_id', [...]);
 *     return rows[0].order_id;
 *   });
 */
export async function tx(fn) {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');
    const result = await fn(client);
    await client.query('COMMIT');
    return result;
  } catch (err) {
    await client.query('ROLLBACK');
    throw err;
  } finally {
    client.release();
  }
}

/** Quick connectivity check used by /api/health. */
export async function ping() {
  const { rows } = await pool.query('SELECT 1 AS ok');
  return rows[0]?.ok === 1;
}
