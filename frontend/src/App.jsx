import { BrowserRouter, Routes, Route } from 'react-router-dom';
import { LangProvider } from './context/LangContext.jsx';
import Navbar from './components/layout/Navbar.jsx';

import Home from './pages/Home.jsx';
import Register from './pages/auth/Register.jsx';
import CropForm from './pages/farmer/CropForm.jsx';
import HowItWorks from './pages/HowItWorks.jsx';
import LivePrice from './pages/LivePrice.jsx';
import Marketplace from './pages/Marketplace.jsx';
import Features from './pages/Features.jsx';
import DirectSales from './pages/features/DirectSales.jsx';
import LiveMarketPrices from './pages/features/LiveMarketPrices.jsx';
import WeatherAlerts from './pages/features/WeatherAlerts.jsx';
import AiAdvisor from './pages/features/AiAdvisor.jsx';
import MicroLoans from './pages/features/MicroLoans.jsx';
import SecurePayments from './pages/features/SecurePayments.jsx';

export default function App() {
  return (
    <LangProvider>
      <BrowserRouter>
        <Navbar />
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/register" element={<Register />} />
          <Route path="/marketplace" element={<Marketplace />} />
          <Route path="/prices" element={<LivePrice />} />
          <Route path="/how-it-works" element={<HowItWorks />} />
          <Route path="/farmer/crops/new" element={<CropForm />} />
          <Route path="/features" element={<Features />} />
          <Route path="/features/direct-sales" element={<DirectSales />} />
          <Route path="/features/live-prices" element={<LiveMarketPrices />} />
          <Route path="/features/weather-alerts" element={<WeatherAlerts />} />
          <Route path="/features/ai-advisor" element={<AiAdvisor />} />
          <Route path="/features/micro-loans" element={<MicroLoans />} />
          <Route path="/features/secure-payments" element={<SecurePayments />} />
        </Routes>
      </BrowserRouter>
    </LangProvider>
  );
}
