// ProtectedRoute.jsx — wrap routes needing login and/or specific roles.
// Not-logged-in OR wrong-role → redirect to /login.
import { Navigate, Outlet, useLocation } from 'react-router-dom';
import { useAuth } from '../../context/AuthContext.jsx';

export default function ProtectedRoute({ roles }) {
  const { user, loading } = useAuth();
  const location = useLocation();
  if (loading) return null;
  if (!user) return <Navigate to="/login" state={{ from: location.pathname }} replace />;
  if (roles && roles.length > 0) {
    const has = (user.roles || []).some((r) => roles.includes(r));
    if (!has) return <Navigate to="/login" replace />;
  }
  return <Outlet />;
}
