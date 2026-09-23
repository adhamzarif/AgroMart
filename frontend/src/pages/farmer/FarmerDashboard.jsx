// FarmerDashboard.jsx — logged-in farmer sees ONLY their crops + stats.
import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { useLang } from '../../context/LangContext.jsx';
import { useAuth } from '../../context/AuthContext.jsx';
import AiChatDrawer from '../../components/ui/AiChatDrawer.jsx';

const BASE = import.meta.env.VITE_API_URL || 'http://localhost:4000';

export default function FarmerDashboard() {
  const [chatOpen, setChatOpen] = useState(false);

  const { t } = useLang();
  const { user } = useAuth();
  const [crops, setCrops] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    let alive = true;
    (async () => {
      try {
        const res = await fetch(`${BASE}/api/farmers/me/crops`, { credentials: 'include' });
        const data = await res.json().catch(() => ({}));
        if (!res.ok) throw new Error(data.error || `HTTP ${res.status}`);
        if (alive) setCrops(data.crops || []);
      } catch (err) {
        if (alive) setError(err.message);
      } finally {
        if (alive) setLoading(false);
      }
    })();
    return () => { alive = false; };
  }, []);

  const totalCrops = crops.length;
  const available = crops.filter((c) => c.status === 'available').length;
  const totalValue = crops.reduce((s, c) => s + (Number(c.quantity || 0) * Number(c.price_per_unit || 0)), 0);

  return (
    <>
      <section className="bg-gradient-to-br from-m1-dark via-m1 to-m1-light py-10 text-white">
        <div className="mx-auto max-w-6xl px-6">
          <h1 className="text-3xl font-bold font-display">{t('fd_hello')}, {user?.fullName || t('fd_farmer')}</h1>
          <p className="mt-1 text-white/85">{t('fd_sub')}</p>
        </div>
      </section>
      <div className="mx-auto max-w-6xl px-6 py-8">
        <div className="mb-8 grid grid-cols-1 gap-4 sm:grid-cols-3">
          <StatCard label={t('fd_stat_total')} value={totalCrops} />
          <StatCard label={t('fd_stat_available')} value={available} />
          <StatCard label={t('fd_stat_value')} value={'\u09F3' + totalValue.toLocaleString()} />
        </div>
        <div className="mb-6 flex items-center justify-between">
          <h2 className="text-xl font-bold text-gray-900">{t('fd_my_crops')}</h2>
          <Link to="/farmer/crops/new" className="rounded-full bg-m1 px-4 py-2 text-sm font-semibold text-white hover:bg-m1-dark">+ {t('fd_add_crop')}</Link>
        </div>
        {loading && <div className="rounded-xl2 bg-gray-50 p-8 text-center text-gray-500">{t('fd_loading')}</div>}
        {error && <div className="rounded-xl2 bg-danger-bg p-6 text-danger-dark">{t('fd_error')} <span className="opacity-70">({error})</span></div>}
        {!loading && !error && crops.length === 0 && (
          <div className="rounded-xl2 border border-dashed border-gray-300 bg-white p-10 text-center">
            <p className="text-gray-500">{t('fd_no_crops')}</p>
            <Link to="/farmer/crops/new" className="mt-4 inline-block rounded-full bg-m1 px-5 py-2 text-sm font-semibold text-white hover:bg-m1-dark">{t('fd_add_first')}</Link>
          </div>
        )}
        {!loading && !error && crops.length > 0 && (
          <div className="overflow-hidden rounded-xl2 border border-gray-100 bg-white shadow-1">
            <table className="w-full">
              <thead className="bg-gray-50 text-xs uppercase tracking-wide text-gray-500">
                <tr>
                  <th className="px-4 py-3 text-left">{t('fd_col_name')}</th>
                  <th className="px-4 py-3 text-left">{t('fd_col_qty')}</th>
                  <th className="px-4 py-3 text-left">{t('fd_col_price')}</th>
                  <th className="px-4 py-3 text-left">{t('fd_col_status')}</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-100">
                {crops.map((c) => (
                  <tr key={c.crop_id} className="hover:bg-gray-50">
                    <td className="px-4 py-3"><div className="font-semibold text-gray-900">{c.crop_name}</div>{c.crop_variety && <div className="text-xs text-gray-500">{c.crop_variety}</div>}</td>
                    <td className="px-4 py-3 text-sm text-gray-700">{c.quantity} {c.unit}</td>
                    <td className="px-4 py-3 text-sm font-semibold text-m1">{'\u09F3' + Number(c.price_per_unit).toLocaleString()}/{c.unit}</td>
                    <td className="px-4 py-3"><span className={`rounded-full px-2 py-0.5 text-xs font-semibold ${c.status === 'available' ? 'bg-success-bg text-m1-dark' : c.status === 'sold' ? 'bg-info-bg text-info-dark' : 'bg-gray-100 text-gray-600'}`}>{c.status}</span></td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </div>
      {/* Floating AI Help button */}
      <button
        onClick={() => setChatOpen(true)}
        className="fixed bottom-6 right-6 z-[800] flex items-center gap-2 rounded-full bg-m1 px-5 py-3 font-semibold text-white shadow-3 hover:bg-m1-dark transition"
        aria-label="AI Help"
      >
        <span className="text-lg">🤖</span>
        <span>{t('ai_help_button')}</span>
      </button>
      <AiChatDrawer open={chatOpen} onClose={() => setChatOpen(false)} />

    </>
  );
}
function StatCard({ label, value }) {
  return (
    <div className="rounded-xl2 bg-white p-5 shadow-1">
      <div className="text-xs uppercase tracking-wide text-gray-500">{label}</div>
      <div className="mt-1 text-2xl font-bold text-gray-900">{value}</div>
    </div>
  );
}
