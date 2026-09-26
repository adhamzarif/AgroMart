// BuyerDashboard.jsx — light landing for buyers; they mostly use the marketplace.
import { Link } from 'react-router-dom';
import { useLang } from '../../context/LangContext.jsx';
import { useAuth } from '../../context/AuthContext.jsx';

export default function BuyerDashboard() {
  const { t } = useLang();
  const { user } = useAuth();

  return (
    <>
      <section className="bg-gradient-to-br from-info-dark via-blue-600 to-blue-500 py-10 text-white">
        <div className="mx-auto max-w-6xl px-6">
          <h1 className="text-3xl font-bold font-display">{t('bd_hello')}, {user?.fullName}</h1>
          <p className="mt-1 text-white/85">{t('bd_sub')}</p>
        </div>
      </section>
      <div className="mx-auto max-w-6xl px-6 py-8">
        <div className="grid grid-cols-1 gap-4 sm:grid-cols-2">
          <Link to="/marketplace" className="group rounded-xl2 bg-white p-6 shadow-1 hover:shadow-3 transition">
            <div className="mb-2 text-3xl">🛒</div>
            <h2 className="text-lg font-bold text-gray-900 group-hover:text-m1">{t('bd_browse_title')}</h2>
            <p className="mt-1 text-sm text-gray-600">{t('bd_browse_sub')}</p>
          </Link>
          <Link to="/prices" className="group rounded-xl2 bg-white p-6 shadow-1 hover:shadow-3 transition">
            <div className="mb-2 text-3xl">📊</div>
            <h2 className="text-lg font-bold text-gray-900 group-hover:text-m1">{t('bd_prices_title')}</h2>
            <p className="mt-1 text-sm text-gray-600">{t('bd_prices_sub')}</p>
          </Link>
        </div>
      </div>
    </>
  );
}
