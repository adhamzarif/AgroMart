// SellNow.jsx — "Sell at the right price" recommendation page.
import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { useLang } from '../../context/LangContext.jsx';
import { api } from '../../api/client.js';
import {
  LineChart, Line, XAxis, YAxis, Tooltip, ResponsiveContainer, CartesianGrid,
} from 'recharts';

const CROP_EN = {
  'লাউ':'Bottle Gourd','কাঁচামরিচ':'Green Chili','বেগুন':'Eggplant',
  'আলু':'Potato','টমেটো':'Tomato','পেঁয়াজ':'Onion',
  'সরিষা':'Mustard','মুগ ডাল':'Mung Dal','মসুর ডাল':'Lentils',
};
const DISTRICT_BN = {
  'Dhaka':'ঢাকা','Chittagong':'চট্টগ্রাম','Rajshahi':'রাজশাহী','Khulna':'খুলনা',
  'Sylhet':'সিলেট','Barishal':'বরিশাল','Rangpur':'রংপুর','Mymensingh':'ময়মনসিংহ','Rangamati':'রাঙ্গামাটি',
};
const BN_DIGITS = ['০','১','২','৩','৪','৫','৬','৭','৮','৯'];
const HERO_IMG = 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=1600';

const VERDICT_STYLE = {
  sell_now: {
    bg: 'from-green-500 to-emerald-600',
    icon: '✅',
    ring: 'ring-green-400/50',
  },
  wait: {
    bg: 'from-red-500 to-orange-600',
    icon: '⏸',
    ring: 'ring-red-400/50',
  },
  hold: {
    bg: 'from-amber-400 to-yellow-500',
    icon: '⚖',
    ring: 'ring-amber-400/50',
  },
};

export default function SellNow() {
  const { t, lang } = useLang();
  const [crops, setCrops] = useState([]);
  const [districts, setDistricts] = useState([]);
  const [selectedCrop, setSelectedCrop] = useState('');
  const [localDistrict, setLocalDistrict] = useState(9); // default Rangamati
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);

  const cropLabel = (c) => (lang === 'en' ? (CROP_EN[c] || c) : c);
  const dName = (n) => (lang === 'en' ? n : (DISTRICT_BN[n] || n));
  const fmt = (n) => {
    if (n === null || n === undefined) return '';
    const s = String(n);
    return lang === 'bn' ? s.replace(/\d/g, (d) => BN_DIGITS[+d]) : s;
  };

  useEffect(() => {
    api.get('/api/prices/crops').then((r) => {
      const list = r.crops || [];
      setCrops(list);
      if (list.length && !selectedCrop) setSelectedCrop(list[0]);
    });
    api.get('/api/prices/compare?crop=লাউ').then((r) => {
      if (r.districts) setDistricts(r.districts);
    });
  }, []);

  useEffect(() => {
    if (!selectedCrop || !localDistrict) return;
    setLoading(true);
    api.get(`/api/prices/recommend?crop=${encodeURIComponent(selectedCrop)}&local_district_id=${localDistrict}`)
      .then(setData)
      .finally(() => setLoading(false));
  }, [selectedCrop, localDistrict]);

  const style = data ? VERDICT_STYLE[data.verdict] : VERDICT_STYLE.hold;

  return (
    <div className="bg-gray-50 pb-20">
      {/* Hero */}
      <div
        className="relative overflow-hidden border-b border-gray-100"
        style={{
          backgroundImage: `linear-gradient(rgba(15,42,30,0.85), rgba(15,42,30,0.75)), url(${HERO_IMG})`,
          backgroundSize: 'cover',
          backgroundPosition: 'center',
        }}
      >
        <div className="mx-auto max-w-6xl px-6 py-16">
          <h1 className="text-4xl font-bold text-white sm:text-5xl font-display drop-shadow">
            {t('sr_title')}
          </h1>
          <p className="mt-3 max-w-2xl text-lg text-white/85">{t('sr_sub')}</p>
        </div>
      </div>

      <div className="mx-auto max-w-6xl px-6 py-10">
        {/* Selectors */}
        <div className="mb-8 rounded-2xl border border-gray-100 bg-white p-6 shadow-sm">
          <div className="grid gap-4 sm:grid-cols-2">
            <div>
              <label className="mb-1.5 block text-xs font-semibold uppercase tracking-wider text-gray-500">
                {t('sr_crop')}
              </label>
              <select
                value={selectedCrop}
                onChange={(e) => setSelectedCrop(e.target.value)}
                className="w-full rounded-lg border-2 border-gray-100 bg-white px-4 py-3 text-sm font-semibold text-gray-900 focus:border-m1 focus:outline-none"
              >
                {crops.map((c) => <option key={c} value={c}>{cropLabel(c)}</option>)}
              </select>
            </div>
            <div>
              <label className="mb-1.5 block text-xs font-semibold uppercase tracking-wider text-gray-500">
                {t('sr_your_district')}
              </label>
              <select
                value={localDistrict}
                onChange={(e) => setLocalDistrict(Number(e.target.value))}
                className="w-full rounded-lg border-2 border-gray-100 bg-white px-4 py-3 text-sm font-semibold text-gray-900 focus:border-m1 focus:outline-none"
              >
                {districts.map((d) => (
                  <option key={d.district_id} value={d.district_id}>{dName(d.district_name)}</option>
                ))}
              </select>
            </div>
          </div>
        </div>

        {loading && (
          <div className="h-56 animate-pulse rounded-2xl bg-gray-100" />
        )}

        {!loading && data && (
          <>
            {/* Big verdict card */}
            <div className={`mb-8 rounded-3xl bg-gradient-to-br ${style.bg} p-8 shadow-xl ring-4 ${style.ring} sm:p-12`}>
              <div className="text-center text-white">
                <div className="text-7xl">{style.icon}</div>
                <div className="mt-4 text-4xl font-bold font-display sm:text-5xl">
                  {t('sr_verdict_' + data.verdict)}
                </div>
                <p className="mt-3 mx-auto max-w-xl text-lg text-white/95">
                  {t(data.reason_key)}
                </p>
                {data.verdict === 'sell_now' && (
                  <Link
                    to="/farmer/crops/new"
                    className="mt-6 inline-block rounded-full bg-white px-8 py-3 text-sm font-bold text-gray-900 shadow-md hover:bg-gray-50"
                  >
                    {t('sr_cta_list')} →
                  </Link>
                )}
              </div>
            </div>

            {/* 3 supporting cards */}
            <div className="mb-8 grid gap-4 sm:grid-cols-3">
              {/* Where to sell */}
              <div className="rounded-2xl border border-gray-100 bg-white p-6 shadow-sm">
                <div className="text-xs font-semibold uppercase tracking-wider text-gray-500">
                  📍 {t('sr_where')}
                </div>
                <div className="mt-2 text-2xl font-bold text-gray-900 font-display">
                  {dName(data.best.district_name)}
                </div>
                <div className="mt-1 text-sm text-gray-500">
                  ৳{fmt(data.best.retail_price)} / {data.unit}
                </div>
                {data.best.gain_pct > 0 && (
                  <div className="mt-3 inline-block rounded-full bg-green-100 px-3 py-1 text-xs font-bold text-green-800">
                    +{fmt(data.best.gain_pct)}% {t('sr_vs_local')}
                  </div>
                )}
              </div>

              {/* Compared to local */}
              <div className="rounded-2xl border border-gray-100 bg-white p-6 shadow-sm">
                <div className="text-xs font-semibold uppercase tracking-wider text-gray-500">
                  🏠 {t('sr_your_market')}
                </div>
                <div className="mt-2 text-2xl font-bold text-gray-900 font-display">
                  ৳{fmt(data.local.retail_price)}
                </div>
                <div className="mt-1 text-sm text-gray-500">
                  {dName(data.local.district_name)} • {t('sr_per')} {data.unit}
                </div>
                <div className="mt-3 text-xs text-gray-500">
                  {t('sr_avg_30d')}: ৳{fmt(data.trend.avg_30d)}
                </div>
              </div>

              {/* When to sell */}
              <div className="rounded-2xl border border-gray-100 bg-white p-6 shadow-sm">
                <div className="text-xs font-semibold uppercase tracking-wider text-gray-500">
                  📈 {t('sr_when')}
                </div>
                <div className="mt-2 text-2xl font-bold text-gray-900 font-display">
                  {data.trend.direction === 'rising' && '↗ '}
                  {data.trend.direction === 'falling' && '↘ '}
                  {data.trend.direction === 'flat' && '→ '}
                  {t('sr_trend_' + data.trend.direction)}
                </div>
                <div className="mt-1 text-sm">
                  <span className={data.trend.vs_avg_pct >= 0 ? 'text-green-700' : 'text-red-700'}>
                    {data.trend.vs_avg_pct >= 0 ? '+' : ''}{fmt(data.trend.vs_avg_pct)}%
                  </span>
                  <span className="text-gray-500"> {t('sr_vs_avg')}</span>
                </div>
              </div>
            </div>

            {/* Top 3 markets ranked table */}
            <div className="mb-8 rounded-2xl border border-gray-100 bg-white shadow-sm">
              <div className="border-b border-gray-100 px-6 py-4">
                <h2 className="text-lg font-bold text-gray-900 font-display">
                  🏆 {t('sr_top_markets')}
                </h2>
                <p className="mt-0.5 text-sm text-gray-500">
                  {t('sr_top_sub')}
                </p>
              </div>
              <div>
                {data.top_markets.map((m, i) => (
                  <div key={m.district_id} className={
                    'flex items-center gap-4 px-6 py-4 ' +
                    (i < data.top_markets.length - 1 ? 'border-b border-gray-100' : '')
                  }>
                    <div className="grid h-10 w-10 flex-shrink-0 place-items-center rounded-full bg-gray-100 text-sm font-bold text-gray-500">
                      {['🥇','🥈','🥉'][i]}
                    </div>
                    <div className="flex-1">
                      <div className="font-bold text-gray-900">{dName(m.district_name)}</div>
                      <div className="text-xs text-gray-500">
                        ৳{fmt(m.retail_price)} / {data.unit}
                      </div>
                    </div>
                    {m.gain_pct > 0 ? (
                      <div className="rounded-full bg-green-100 px-3 py-1 text-xs font-bold text-green-800">
                        +{fmt(m.gain_pct)}%
                      </div>
                    ) : (
                      <div className="text-xs text-gray-400">
                        {t('sr_local')}
                      </div>
                    )}
                  </div>
                ))}
              </div>
            </div>

            {/* Mini 7-day trend chart */}
            {data.trend.history_7d.length > 0 && (
              <div className="rounded-2xl border border-gray-100 bg-white p-6 shadow-sm">
                <h2 className="mb-1 text-lg font-bold text-gray-900 font-display">
                  📉 {t('sr_last_7d')}
                </h2>
                <p className="mb-4 text-sm text-gray-500">
                  {cropLabel(data.crop)} • {dName(data.local.district_name)}
                </p>
                <div style={{ width: '100%', height: 200 }}>
                  <ResponsiveContainer>
                    <LineChart data={data.trend.history_7d} margin={{ top: 5, right: 10, left: 0, bottom: 5 }}>
                      <CartesianGrid vertical={false} stroke="#f1f5f9" />
                      <XAxis
                        dataKey="date"
                        tick={{ fontSize: 11, fill: '#64748b' }}
                        axisLine={false}
                        tickLine={false}
                        tickFormatter={(d) => {
                          const dt = new Date(d);
                          return dt.toLocaleDateString(lang === 'bn' ? 'bn-BD' : 'en-GB', { day: 'numeric', month: 'short' });
                        }}
                      />
                      <YAxis
                        tick={{ fontSize: 11, fill: '#64748b' }}
                        axisLine={false}
                        tickLine={false}
                        tickFormatter={(v) => `৳${fmt(v)}`}
                      />
                      <Tooltip
                        formatter={(v) => `৳${fmt(Number(v).toFixed(2))}`}
                        contentStyle={{
                          borderRadius: 12,
                          border: '1px solid #e2e8f0',
                          boxShadow: '0 4px 12px rgba(0,0,0,0.05)',
                        }}
                      />
                      <Line
                        type="monotone"
                        dataKey="price"
                        stroke="#16a34a"
                        strokeWidth={2.5}
                        dot={{ fill: '#16a34a', r: 4 }}
                      />
                    </LineChart>
                  </ResponsiveContainer>
                </div>
              </div>
            )}

            <p className="mt-6 text-center text-xs text-gray-400">
              {t('sr_disclaimer')}
            </p>
          </>
        )}
      </div>
    </div>
  );
}
