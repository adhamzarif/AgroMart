import { BrowserRouter, Routes, Route } from 'react-router-dom';
import { LangProvider } from './context/LangContext.jsx';
import Navbar from './components/layout/Navbar.jsx';
import Home from './pages/Home.jsx';
import Register from './pages/auth/Register.jsx';
import Marketplace from './pages/Marketplace.jsx';
import Features from './pages/Features.jsx';
import DirectSales from './pages/features/DirectSales.jsx';

export default function App() {
  return (
    <LangProvider>
      <BrowserRouter>
        <Navbar />
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/register" element={<Register />} />
          <Route path="/marketplace" element={<Marketplace />} />
          <Route path="/features" element={<Features />} />
          <Route path="/features/direct-sales" element={<DirectSales />} />
        </Routes>
      </BrowserRouter>
    </LangProvider>
  );
}