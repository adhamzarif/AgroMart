// index.js — Express application entry point.
import express from 'express';
import helmet from 'helmet';
import cors from 'cors';
import path from 'path';
import { fileURLToPath } from 'url';
import { env, isDev } from './config/env.js';
import { ping } from './config/db.js';
import authRoutes from './routes/auth.routes.js';        // ← CHANGE 1
import cropRoutes from './routes/crops.routes.js';
import categoryRoutes from './routes/categories.routes.js';     // ← ADD THIS

const app = express();

app.use(helmet());
app.use(cors({ origin: env.CLIENT_ORIGIN, credentials: true }));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Health check
app.get('/api/health', async (_req, res) => {
  let db = false;
  try { db = await ping(); } catch { db = false; }
  res.status(db ? 200 : 503).json({ ok: db, db, env: env.NODE_ENV });
});

// ── Routes ──
app.use('/api/auth', authRoutes);                        // ← CHANGE 2
app.use('/api/crops', cropRoutes);
const __b2dir = path.dirname(fileURLToPath(import.meta.url));
app.use('/uploads', express.static(path.resolve(__b2dir, '../storage/uploads')));
app.use('/api/categories', categoryRoutes);


// 404
app.use((_req, res) => {
  res.status(404).json({ error: 'Not found' });
});

// Central error handler
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