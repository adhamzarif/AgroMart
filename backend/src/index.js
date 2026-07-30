// index.js — Express application entry point.
// Ports from: index.php (bootstrap + front controller).
import express from 'express';
import helmet from 'helmet';
import cors from 'cors';
import { env, isDev } from './config/env.js';
import { ping } from './config/db.js';

const app = express();

// ── Security headers (was: missing entirely in the PHP app — a flagged gap) ──
app.use(helmet());

// ── CORS: allow the React dev server to call the API ──
app.use(cors({ origin: env.CLIENT_ORIGIN, credentials: true }));

// ── Body parsing ──
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// ── Health check — the Phase 0 milestone ──
// GET /api/health -> { ok: true, db: true }
app.get('/api/health', async (_req, res) => {
  let db = false;
  try {
    db = await ping();
  } catch {
    db = false;
  }
  // If the DB is down, report 503 (the old PHP app returned 200 on DB failure —
  // a flagged bug that broke monitoring). We do it right here.
  res.status(db ? 200 : 503).json({ ok: db, db, env: env.NODE_ENV });
});

// ── Routes get mounted here as phases land ──
// import authRoutes from './routes/auth.routes.js';
// app.use('/api/auth', authRoutes);

// ── 404 ──
app.use((_req, res) => {
  res.status(404).json({ error: 'Not found' });
});

// ── Central error handler (was: the try/catch around Router::dispatch) ──
// eslint-disable-next-line no-unused-vars
app.use((err, _req, res, _next) => {
  console.error('[error]', err.message);
  res.status(err.status || 500).json({
    error: isDev ? err.message : 'Internal server error',
  });
});

app.listen(env.PORT, () => {
  console.log(`AgroMart API on http://localhost:${env.PORT}  (${env.NODE_ENV})`);
  console.log(`Health: http://localhost:${env.PORT}/api/health`);
});
