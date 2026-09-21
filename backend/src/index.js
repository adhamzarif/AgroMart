import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';

// Existing Routes Import
import authRoutes from './routes/auth.routes.js';
import cropsRoutes from './routes/crops.routes.js';
import pricesRoutes from './routes/prices.routes.js';
import farmersRoutes from './routes/farmers.routes.js';
import categoriesRoutes from './routes/categories.routes.js';
import statsRoutes from './routes/stats.routes.js';
import alertsRoutes from './routes/alerts.routes.js';
import marginsRoutes from './routes/margins.routes.js';
import priceCompareRoutes from './routes/priceCompare.routes.js';

// Payment Route Import
import paymentRoutes from './routes/payment.routes.js';

dotenv.config();

const app = express();
const PORT = process.env.PORT || 4000;

// CORS Fix for credentials: 'include'
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
app.use('/api/crops', cropsRoutes);
app.use('/api/prices', pricesRoutes);
app.use('/api/farmers', farmersRoutes);
app.use('/api/categories', categoriesRoutes);
app.use('/api/stats', statsRoutes);
app.use('/api/alerts', alertsRoutes);
app.use('/api/margins', marginsRoutes);
app.use('/api/price-compare', priceCompareRoutes);
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