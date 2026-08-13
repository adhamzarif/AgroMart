import { BrowserRouter, Routes, Route } from 'react-router-dom';
import CropForm from './pages/farmer/CropForm.jsx';
import HowItWorks from './pages/HowItWorks.jsx';
import LivePrices from './pages/LivePrices.jsx';
import { LangProvider } from './context/LangContext.jsx';
import Navbar from './components/layout/Navbar.jsx';
import Home from './pages/Home.jsx';
import Register from './pages/auth/Register.jsx';
import LivePrice from './pages/LivePrice.jsx';

export default function App() {
  return (
    <LangProvider>
      <BrowserRouter>
        <Navbar />
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/register" element={<Register />} />
          <Route path="/farmer/crops/new" element={<CropForm/>} />
          <Route path="/how-it-works" element={<HowItWorks/>} />
          <Route path="/prices" element={<LivePrice />} />
          <Route path="/prices" element={<LivePrices/>} />
        </Routes>
      </BrowserRouter>
    </LangProvider>
  );
}