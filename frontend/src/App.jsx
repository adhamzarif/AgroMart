// MARKETPLACE_PROTECTED

import { BrowserRouter, Routes, Route } from 'react-router-dom';

import { AuthProvider } from './context/AuthContext.jsx';
import { LangProvider } from './context/LangContext.jsx';

import ProtectedRoute from './components/routing/ProtectedRoute.jsx';

import Navbar from './components/layout/Navbar.jsx';
import Footer from './components/layout/Footer.jsx';

import Home from './pages/Home.jsx';
import Contact from './pages/Contact.jsx';

import Login from './pages/auth/Login.jsx';
import Register from './pages/auth/Register.jsx';

import BuyerDashboard from './pages/buyer/BuyerDashboard.jsx';
import AdminDashboard from './pages/admin/AdminDashboard.jsx';
import FarmerDashboard from './pages/farmer/FarmerDashboard.jsx';

import Marketplace from './pages/Marketplace.jsx';
import ProductDetails from './pages/ProductDetails.jsx';

import LivePrice from './pages/LivePrice.jsx';
import PriceCompare from './pages/prices/PriceCompare.jsx';
import PriceHistory from './pages/prices/PriceHistory.jsx';
import PriceAlerts from './pages/prices/PriceAlerts.jsx';
import SellNow from './pages/prices/SellNow.jsx';

import FarmerProfile from './pages/farmers/FarmerProfile.jsx';
import CropForm from './pages/farmer/CropForm.jsx';

import HowItWorks from './pages/HowItWorks.jsx';

import Features from './pages/Features.jsx';
import DirectSales from './pages/features/DirectSales.jsx';
import LiveMarketPrices from './pages/features/LiveMarketPrices.jsx';
import WeatherAlerts from './pages/features/WeatherAlerts.jsx';
import AiAdvisor from './pages/features/AiAdvisor.jsx';
import MicroLoans from './pages/features/MicroLoans.jsx';
import SecurePayments from './pages/features/SecurePayments.jsx';
import HigherMargins from './pages/features/HigherMargins.jsx';
import TransparentPricing from './pages/features/TransparentPricing.jsx';
import EasyDelivery from './pages/features/EasyDelivery.jsx';
import TrustRatings from './pages/features/TrustRatings.jsx';

export default function App() {
  return (
    <AuthProvider>
      <LangProvider>
        <BrowserRouter>
          <div className="flex min-h-screen flex-col">
            <Navbar />

            <main className="flex-grow">
              <Routes>
                {/* =========================
                    Public Routes
                ========================== */}

                <Route path="/" element={<Home />} />

                <Route
                  path="/register"
                  element={<Register />}
                />

                <Route
                  path="/login"
                  element={<Login />}
                />

                <Route
                  path="/prices"
                  element={<LivePrice />}
                />

                <Route
                  path="/prices/compare"
                  element={<PriceCompare />}
                />

                <Route
                  path="/prices/history"
                  element={<PriceHistory />}
                />

                <Route
                  path="/prices/alerts"
                  element={<PriceAlerts />}
                />

                <Route
                  path="/prices/sell-now"
                  element={<SellNow />}
                />

                <Route
                  path="/how-it-works"
                  element={<HowItWorks />}
                />

                <Route
                  path="/features"
                  element={<Features />}
                />

                <Route
                  path="/features/direct-sales"
                  element={<DirectSales />}
                />

                <Route
                  path="/features/live-prices"
                  element={<LiveMarketPrices />}
                />

                <Route
                  path="/features/weather-alerts"
                  element={<WeatherAlerts />}
                />

                <Route
                  path="/features/ai-advisor"
                  element={<AiAdvisor />}
                />

                <Route
                  path="/features/micro-loans"
                  element={<MicroLoans />}
                />

                <Route
                  path="/features/secure-payments"
                  element={<SecurePayments />}
                />

                <Route
                  path="/features/higher-margins"
                  element={<HigherMargins />}
                />

                <Route
                  path="/features/transparent-pricing"
                  element={<TransparentPricing />}
                />

                <Route
                  path="/features/easy-delivery"
                  element={<EasyDelivery />}
                />

                <Route
                  path="/features/trust-ratings"
                  element={<TrustRatings />}
                />

                <Route
                  path="/contact"
                  element={<Contact />}
                />

                <Route
                  path="/farmers/:id"
                  element={<FarmerProfile />}
                />

                {/* =========================
                    Marketplace
                    Buyer / Admin / Farmer
                ========================== */}

                <Route
                  element={
                    <ProtectedRoute
                      roles={['buyer', 'admin', 'farmer']}
                    />
                  }
                >
                  <Route
                    path="/marketplace"
                    element={<Marketplace />}
                  />
                </Route>

                {/* Product Details */}

                <Route
                  path="/marketplace/:cropId"
                  element={<ProductDetails />}
                />

                {/* =========================
                    Farmer Routes
                ========================== */}

                <Route
                  element={
                    <ProtectedRoute
                      roles={['farmer', 'admin']}
                    />
                  }
                >
                  <Route
                    path="/farmer/dashboard"
                    element={<FarmerDashboard />}
                  />

                  <Route
                    path="/farmer/crops/new"
                    element={<CropForm />}
                  />
                </Route>

                {/* =========================
                    Admin Routes
                ========================== */}

                <Route
                  element={
                    <ProtectedRoute
                      roles={['admin']}
                    />
                  }
                >
                  <Route
                    path="/admin"
                    element={<AdminDashboard />}
                  />
                </Route>

                {/* =========================
                    Buyer Routes
                ========================== */}

                <Route
                  element={
                    <ProtectedRoute
                      roles={['buyer', 'admin']}
                    />
                  }
                >
                  <Route
                    path="/buyer/dashboard"
                    element={<BuyerDashboard />}
                  />
                </Route>
              </Routes>
            </main>

            <Footer />
          </div>
        </BrowserRouter>
      </LangProvider>
    </AuthProvider>
  );
}