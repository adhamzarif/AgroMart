// index.js — Express application entry point.
import express from 'express';
import helmet from 'helmet';
import cors from 'cors';
import session from 'express-session';
import path from 'path';
import { fileURLToPath } from 'url';
import { env, isDev } from './config/env.js';
import { ping } from './config/db.js';
import authRoutes from './routes/auth.routes.js';        // ← CHANGE 1
import cropRoutes from './routes/crops.routes.js';
import priceRoutes from './routes/prices.routes.js';
import priceCompareRoutes from './routes/priceCompare.routes.js';
import marginRoutes from './routes/margins.routes.js';
import farmerRoutes from './routes/farmers.routes.js';
import alertRoutes from './routes/alerts.routes.js';
import deliveryRoutes from './routes/delivery.routes.js';
import statsRoutes from './routes/stats.routes.js';
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

// Sessions (in-memory store — fine for demo; use connect-pg-simple in production).
app.use(session({
  name: 'agromart.sid',
  secret: process.env.SESSION_SECRET || 'agromart-dev-change-me',
  resave: false,
  saveUninitialized: false,
  cookie: {
    httpOnly: true,
    sameSite: 'lax',
    secure: false, // set true when running behind HTTPS
    maxAge: 1000 * 60 * 60 * 24 * 7, // 7 days
  },
}));

app.use('/api/auth', authRoutes);                        // ← CHANGE 2
app.use('/api/crops', cropRoutes);
app.use('/api/prices', priceRoutes);
app.use('/api/prices', priceCompareRoutes);
app.use('/api/margins', marginRoutes);
app.use('/api/farmers', farmerRoutes);
app.use('/api/alerts', alertRoutes);
app.use('/api/delivery', deliveryRoutes);
app.use('/api/stats', statsRoutes);
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