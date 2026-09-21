// ProtectedRoute.jsx — wrap routes that need login and/or specific roles.
// Usage:
//   <Route element={<ProtectedRoute />}>          // any logged-in user
//     <Route path="/settings" element={<Settings />} />
//   </Route>
//
//   <Route element={<ProtectedRoute roles={['farmer','admin']} />}>
//     <Route path="/farmer/*" element={<FarmerLayout />} />
//   </Route>
import { Navigate, Outlet, useLocation } from 'react-router-dom';
import { useAuth } from '../../context/AuthContext.jsx';

export default function ProtectedRoute({ roles }) {
  const { user, loading } = useAuth();
  const location = useLocation();

  // While the initial /me hydration is running, render nothing — flicker-free.
  if (loading) return null;

  // Not logged in → send to /login with a return address
  if (!user) {
    return <Navigate to={`/login?from=${encodeURIComponent(location.pathname + location.search)}`} replace />;
  }

  // Logged in but role not allowed → also send to /login per your choice
  if (roles && roles.length > 0) {
    const has = (user.roles || []).some((r) => roles.includes(r));
    if (!has) {
      return <Navigate to={`/login?from=${encodeURIComponent(location.pathname + location.search)}`} replace />;
    }
  }

  return <Outlet />;
}
