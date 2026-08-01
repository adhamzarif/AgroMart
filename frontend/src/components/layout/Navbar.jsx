// Navbar.jsx — top navigation bar with logo, links, login/register, language toggle.
import { Link } from 'react-router-dom';
import { useLang } from '../../context/LangContext.jsx';

export default function Navbar() {
  const { t, lang, toggle } = useLang();
  const links = [
    ['nav_home', '/'],
    ['nav_features', '/features'],
    ['nav_marketplace', '/marketplace'],
    ['nav_prices', '/prices'],
    ['nav_how', '/how-it-works'],
    ['nav_contact', '/contact'],
  ];
  return (
    <header
      className="sticky top-0 z-50 flex items-center justify-between bg-white px-6 shadow-1"
      style={{ height: 'var(--nav-h)' }}
    >
      {/* Brand */}
      <Link to="/" className="flex items-center gap-2">
        <span className="grid h-8 w-8 place-items-center rounded-lg bg-m1 text-white font-bold">
          A
        </span>
        <span className="text-xl font-bold font-display text-m1">{t('brand')}</span>
      </Link>

      {/* Links (hidden on small screens) */}
      <nav className="hidden items-center gap-7 md:flex">
        {links.map(([key, to]) => (
          <Link
            key={key}
            to={to}
            className="text-sm font-medium text-gray-700 hover:text-m1"
          >
            {t(key)}
          </Link>
        ))}
      </nav>

      {/* Right side */}
      <div className="flex items-center gap-3">
        <button
          onClick={toggle}
          className="rounded-full border border-gray-200 px-3 py-1 text-xs font-semibold text-gray-600 hover:border-m1 hover:text-m1"
          aria-label="Toggle language"
        >
          {lang === 'bn' ? 'EN' : 'বাং'}
        </button>
        <Link to="/login" className="text-sm font-medium text-gray-700 hover:text-m1">
          {t('login')}
        </Link>
        <Link
          to="/register"
          className="rounded-full bg-m1 px-5 py-2 text-sm font-semibold text-white hover:bg-m1-dark"
        >
          {t('register')}
        </Link>
      </div>
    </header>
  );
}
