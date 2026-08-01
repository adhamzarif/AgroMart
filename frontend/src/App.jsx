import { BrowserRouter, Routes, Route, Link } from 'react-router-dom';
import Register from './pages/auth/Register.jsx';

function Home() {
  return (
    <div style={{ maxWidth: 420, margin: '40px auto', fontFamily: 'system-ui' }}>
      <h1>AgroMart</h1>
      <p><Link to="/register">Create an account →</Link></p>
    </div>
  );
}

export default function App() {
  return (
    <BrowserRouter>
      <Routes>
        <Route path="/" element={<Home />} />
        <Route path="/register" element={<Register />} />
      </Routes>
    </BrowserRouter>
  );
}
