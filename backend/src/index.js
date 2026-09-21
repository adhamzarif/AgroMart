import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import path from 'path';
import { fileURLToPath } from 'url';
import { env, isDev } from './config/env.js';
import { ping } from './config/db.js';

// Route Imports
import authRoutes from './routes/auth.routes.js';
import cropRoutes from './routes/crops.routes.js';
import priceRoutes from './routes/prices.routes.js';
import priceCompareRoutes from './routes/priceCompare.routes.js';
import marginRoutes from './routes/margins.routes.js';
import farmerRoutes from './routes/farmers.routes.js';
import alertRoutes from './routes/alerts.routes.js';
import deliveryRoutes from './routes/delivery.routes.js';
import statsRoutes from './routes/stats.routes.js';
import paymentRoutes from './routes/payment.routes.js';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 4000;

// CORS Configuration
app.use(cors({
  origin: 'http://localhost:5173',
  credentials: true
}));

app.use(express.json());
app.use(express.urlencoded({ extended: false }));

// Health Check
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', message: 'AgroMart API is healthy' });
});

// API Routes
app.use('/api/auth', authRoutes);
app.use('/api/crops', cropRoutes);
app.use('/api/prices', priceRoutes);
app.use('/api/price-compare', priceCompareRoutes);
app.use('/api/margins', marginRoutes);
app.use('/api/farmers', farmerRoutes);
app.use('/api/alerts', alertRoutes);
app.use('/api/delivery', deliveryRoutes);
app.use('/api/stats', statsRoutes);
app.use('/api/payment', paymentRoutes);

// Global Error Handler
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({
    success: false,
    message: err.message || 'Internal Server Error',
  });
});

app.listen(PORT, () => {
  console.log(`AgroMart API running on http://localhost:${PORT}`);
});