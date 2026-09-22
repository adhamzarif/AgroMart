// Navbar.jsx — public links + login/register OR user dropdown.
import { useState, useRef, useEffect } from 'react';
import { Link, useNavigate } from 'react-router-dom';
import { useLang } from '../../context/LangContext.jsx';
import { useAuth } from '../../context/AuthContext.jsx';

export default function Navbar() {
  const { t, lang, toggle } = useLang();
  const { user, logout } = useAuth();
  const nav = useNavigate();
  const [menuOpen, setMenuOpen] = useState(false);
  const menuRef = useRef(null);

  useEffect(() => {
    const onClick = (e) => {
      if (menuRef.current && !menuRef.current.contains(e.target)) setMenuOpen(false);
    };
    document.addEventListener('mousedown', onClick);
    return () => document.removeEventListener('mousedown', onClick);
  }, []);

  const links = [
    ['nav_home', '/'],
    ['nav_features', '/features'],
    ['nav_marketplace', '/marketplace'],
    ['nav_prices', '/prices'],
    ['nav_how', '/how-it-works'],
    ['nav_contact', '/contact'],
  ];

  async function onLogout() {
    setMenuOpen(false);
    await logout();
    nav('/');
  }

  const roleLinks = user
    ? [
        user.roles?.includes('admin')  && { label: t('nav_admin'),     to: '/admin' },
        user.roles?.includes('farmer') && { label: t('nav_dashboard'), to: '/farmer/dashboard' },
        user.roles?.includes('buyer')  && { label: t('nav_orders'),    to: '/marketplace' },
      ].filter(Boolean)
    : [];

  return (
    <header
      className="sticky top-0 z-50 flex items-center justify-between bg-white px-6 shadow-1"
      style={{ height: 'var(--nav-h)' }}
    >
      <Link to="/" className="flex items-center gap-2">
        <span className="grid h-8 w-8 place-items-center rounded-lg bg-m1 text-white font-bold">A</span>
        <span className="text-xl font-bold font-display text-m1">{t('brand')}</span>
      </Link>

      <nav className="hidden items-center gap-7 md:flex">
        {links.map(([key, to]) => (
          <Link key={key} to={to} className="text-sm font-medium text-gray-700 hover:text-m1">
            {t(key)}
          </Link>
        ))}
      </nav>

      <div className="flex items-center gap-3">
        <button
          onClick={toggle}
          className="rounded-full border border-gray-200 px-3 py-1 text-xs font-semibold text-gray-600 hover:border-m1 hover:text-m1"
          aria-label="Toggle language"
        >
          {lang === 'bn' ? 'EN' : 'বাং'}
        </button>

        {user ? (
          <div className="relative" ref={menuRef}>
            <button
              onClick={() => setMenuOpen((v) => !v)}
              className="flex items-center gap-2 rounded-full border border-gray-200 px-3 py-1.5 text-sm font-medium text-gray-700 hover:border-m1 hover:text-m1"
            >
              <span className="grid h-6 w-6 place-items-center rounded-full bg-m1 text-xs font-bold text-white">
                {user.fullName?.[0]?.toUpperCase() || 'U'}
              </span>
              <span className="max-w-[8rem] truncate">{user.fullName}</span>
              <span className="text-xs">▾</span>
            </button>

            {menuOpen && (
              <div className="absolute right-0 mt-2 w-56 rounded-xl2 border border-gray-100 bg-white py-2 shadow-3">
                <div className="border-b border-gray-100 px-4 py-2">
                  <div className="text-xs text-gray-500">{t('login_signed_in_as')}</div>
                  <div className="text-sm font-semibold text-gray-900">{user.phone}</div>
                  <div className="mt-1 flex flex-wrap gap-1">
                    {(user.roles || []).map((r) => (
                      <span key={r} className="rounded-full bg-success-bg px-2 py-0.5 text-xs font-semibold text-m1-dark">
                        {t(`role_${r}`)}
                      </span>
                    ))}
                  </div>
                </div>
                {roleLinks.map((item) => (
                  <Link
                    key={item.to}
                    to={item.to}
                    onClick={() => setMenuOpen(false)}
                    className="block px-4 py-2 text-sm text-gray-700 hover:bg-gray-50"
                  >
                    {item.label}
                  </Link>
                ))}
                <button
                  onClick={onLogout}
                  className="block w-full border-t border-gray-100 px-4 py-2 text-left text-sm text-danger-dark hover:bg-danger-bg"
                >
                  {t('logout')}
                </button>
              </div>
            )}
          </div>
        ) : (
          <>
            <Link to="/login" className="text-sm font-medium text-gray-700 hover:text-m1">
              {t('login')}
            </Link>
            <Link
              to="/register"
              className="rounded-full bg-m1 px-5 py-2 text-sm font-semibold text-white hover:bg-m1-dark"
            >
              {t('register')}
            </Link>
          </>
        )}
      </div>
    </header>
  );
}
