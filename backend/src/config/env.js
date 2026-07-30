// env.js — loads and validates environment variables.
// Ports from: core/Env.php  (but fails CLOSED — missing critical config is fatal,
// unlike the old PHP which fell back to insecure defaults).
import dotenv from 'dotenv';
dotenv.config();

function required(key) {
  const v = process.env[key];
  if (v === undefined || v === '') {
    // Fail closed. The old PHP app defaulted DB_USER to 'root' with no password
    // when .env was missing — that is exactly the bug we are not repeating.
    throw new Error(`Missing required env var: ${key} (check your .env file)`);
  }
  return v;
}

function optional(key, fallback) {
  const v = process.env[key];
  return v === undefined || v === '' ? fallback : v;
}

export const env = {
  NODE_ENV: optional('NODE_ENV', 'development'),
  PORT: parseInt(optional('PORT', '4000'), 10),

  // Database — these are REQUIRED. No insecure fallback.
  DB_HOST: required('DB_HOST'),
  DB_PORT: parseInt(optional('DB_PORT', '5432'), 10),
  DB_NAME: required('DB_NAME'),
  DB_USER: required('DB_USER'),
  DB_PASS: required('DB_PASS'),

  // Auth
  JWT_SECRET: optional('JWT_SECRET', ''), // required once auth lands (Phase 1)

  // Frontend origin for CORS
  CLIENT_ORIGIN: optional('CLIENT_ORIGIN', 'http://localhost:5173'),
};

export const isDev = env.NODE_ENV === 'development';
