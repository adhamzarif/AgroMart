// SellNow.jsx — polished "Sell at the right price" decision page.
import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { useLang } from '../../context/LangContext.jsx';
import { api } from '../../api/client.js';
import {
  AreaChart, Area, XAxis, YAxis, Tooltip, ResponsiveContainer, CartesianGrid,
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
const HERO_IMG = 'https://images.unsplash.com/photo-1464226184884-fa280b87c399?w=1600';

const VERDICT_STYLE = {
  sell_now: {
    bg: 'from-green-500 via-emerald-500 to-teal-600',
    glow: 'shadow-green-500/40',
    icon: '✅',
    accent: 'bg-green-400',
    strokeColor: '#16a34a',
    stroke2: '#22c55e',
  },
  wait: {
    bg: 'from-red-500 via-rose-500 to-orange-600',
    glow: 'shadow-red-500/40',
    icon: '⏸',
    accent: 'bg-red-400',
    strokeColor: '#dc2626',
    stroke2: '#ef4444',
  },
  hold: {
    bg: 'from-amber-400 via-yellow-500 to-orange-500',
    glow: 'shadow-amber-500/40',
    icon: '⚖',
    accent: 'bg-amber-400',
    strokeColor: '#f59e0b',
    stroke2: '#fbbf24',
  },
};

export default function SellNow() {
  const { t, lang } = useLang();
  const [crops, setCrops] = useState([]);
  const [districts, setDistricts] = useState([]);
  const [selectedCrop, setSelectedCrop] = useState('');
  const [localDistrict, setLocalDistrict] = useState(9);
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
    // Load district list from compare endpoint (returns a `districts` array).
    api.get('/api/prices/compare?crop=%E0%A6%B2%E0%A6%BE%E0%A6%89').then((r) => {
      if (r.districts && r.districts.length) {
        setDistricts(r.districts);
      }
    }).catch(() => {});
  }, []);

  useEffect(() => {
    if (!selectedCrop || !localDistrict) return;
    setLoading(true);
    api.get(`/api/prices/recommend?crop=${encodeURIComponent(selectedCrop)}&local_district_id=${localDistrict}`)
      .then((r) => {
        setData(r);
        // fallback: if districts list came back empty from earlier fetch,
        // build one from top_markets so the dropdown at least has some options.
        setDistricts((prev) => {
          if (prev && prev.length > 0) return prev;
          if (r && r.top_markets) {
            return r.top_markets.map((m) => ({
              district_id: m.district_id,
              district_name: m.district_name,
            }));
          }
          return prev;
        });
      })
      .finally(() => setLoading(false));
  }, [selectedCrop, localDistrict]);

  const style = data ? VERDICT_STYLE[data.verdict] : VERDICT_STYLE.hold;

  return (
    <div className="bg-gray-50 pb-24">
      {/* Proper hero band */}
      <div
        className="relative overflow-hidden border-b border-gray-100"
        style={{
          backgroundImage: `linear-gradient(rgba(15,42,30,0.85), rgba(15,42,30,0.75)), url(${HERO_IMG})`,
          backgroundSize: 'cover',
          backgroundPosition: 'center',
        }}
      >
        <div className="mx-auto max-w-6xl px-6 py-20">
          <h1 className="text-4xl font-bold text-white sm:text-5xl font-display drop-shadow">
            {t('sr_title')}
          </h1>
          <p className="mt-3 max-w-2xl text-lg text-white/85">{t('sr_sub')}</p>
        </div>
      </div>

      <div className="mx-auto max-w-6xl px-6 py-10">
        {/* Selectors */}
        <div className="mb-8 rounded-2xl border border-gray-100 bg-white p-6 shadow-lg sm:p-8">
          <div className="grid gap-6 sm:grid-cols-2">
            <div>
              <label className="mb-2 block text-xs font-semibold uppercase tracking-wider text-gray-500">
                🌾 {t('sr_crop')}
              </label>
              <select
                value={selectedCrop}
                onChange={(e) => setSelectedCrop(e.target.value)}
                className="w-full rounded-xl border-2 border-gray-100 bg-white px-4 py-3 text-base font-semibold text-gray-900 transition focus:border-m1 focus:outline-none focus:ring-2 focus:ring-m1/20"
              >
                {crops.map((c) => <option key={c} value={c}>{cropLabel(c)}</option>)}
              </select>
            </div>
            <div>
              <label className="mb-2 block text-xs font-semibold uppercase tracking-wider text-gray-500">
                📍 {t('sr_your_district')}
              </label>
              <select
                value={String(localDistrict)}
                onChange={(e) => setLocalDistrict(Number(e.target.value))}
                className="w-full rounded-xl border-2 border-gray-100 bg-white px-4 py-3 text-base font-semibold text-gray-900 transition focus:border-m1 focus:outline-none focus:ring-2 focus:ring-m1/20"
              >
                {districts.length === 0 && (
                  <option value="9">রাঙ্গামাটি / Rangamati</option>
                )}
                {districts.map((d) => (
                  <option key={d.district_id} value={String(d.district_id)}>
                    {dName(d.district_name)}
                  </option>
                ))}
              </select>
            </div>
          </div>
        </div>

        {loading && (
          <div className="h-72 animate-pulse rounded-3xl bg-gray-100" />
        )}

        {!loading && data && (
          <>
            {/* DRAMATIC VERDICT CARD */}
            <div className={`relative mb-8 overflow-hidden rounded-3xl bg-gradient-to-br ${style.bg} p-10 shadow-2xl ${style.glow} sm:p-14`}>
              {/* Decorative blur circles */}
              <div className="pointer-events-none absolute -right-24 -top-24 h-72 w-72 rounded-full bg-white/20 blur-3xl" />
              <div className="pointer-events-none absolute -bottom-20 -left-16 h-64 w-64 rounded-full bg-white/10 blur-3xl" />
              <div className="pointer-events-none absolute right-10 top-10 text-9xl opacity-10">
                {style.icon}
              </div>

              <div className="relative text-center text-white">
                {/* Small badge */}
                <div className="mx-auto mb-4 inline-flex items-center gap-2 rounded-full bg-white/20 px-4 py-1.5 text-xs font-bold uppercase tracking-wider backdrop-blur">
                  💡 {t('sr_recommendation')}
                </div>

                {/* Icon */}
                <div className="text-8xl drop-shadow-lg sm:text-9xl">{style.icon}</div>

                {/* Verdict text */}
                <div className="mt-4 text-5xl font-bold font-display drop-shadow-md sm:text-6xl">
                  {t('sr_verdict_' + data.verdict)}
                </div>

                {/* Reason */}
                <p className="mx-auto mt-4 max-w-xl text-lg text-white/95 sm:text-xl">
                  {t(data.reason_key)}
                </p>

                {/* CTA — only when SELL NOW */}
                {data.verdict === 'sell_now' && (
                  <Link
                    to="/farmer/crops/new"
                    className="mt-8 inline-flex items-center gap-2 rounded-full bg-white px-8 py-4 text-base font-bold text-green-700 shadow-xl transition hover:scale-105 hover:bg-green-50"
                  >
                    🌱 {t('sr_cta_list')} →
                  </Link>
                )}

                {/* Wait sub-CTA */}
                {data.verdict === 'wait' && (
                  <Link
                    to="/prices/alerts"
                    className="mt-8 inline-flex items-center gap-2 rounded-full bg-white/20 px-6 py-3 text-sm font-semibold text-white shadow-lg backdrop-blur transition hover:bg-white/30"
                  >
                    🔔 {t('sr_cta_alert')} →
                  </Link>
                )}
              </div>
            </div>

            {/* 3 SUPPORTING CARDS — gradient tinted */}
            <div className="mb-8 grid gap-4 sm:grid-cols-3">
              {/* Best market */}
              <div className="group relative overflow-hidden rounded-2xl border border-green-100 bg-gradient-to-br from-green-50 to-white p-6 shadow-sm transition hover:shadow-md">
                <div className="pointer-events-none absolute -right-6 -top-6 h-24 w-24 rounded-full bg-green-100/60 blur-2xl" />
                <div className="relative">
                  <div className="flex items-center gap-2 text-xs font-bold uppercase tracking-wider text-green-700">
                    <span className="text-lg">📍</span> {t('sr_where')}
                  </div>
                  <div className="mt-3 text-3xl font-bold text-gray-900 font-display">
                    {dName(data.best.district_name)}
                  </div>
                  <div className="mt-1 text-sm text-gray-500">
                    ৳{fmt(data.best.retail_price)} / {data.unit}
                  </div>
                  {data.best.gain_pct > 0 ? (
                    <div className="mt-4 flex items-center gap-2">
                      <div className="inline-flex items-center gap-1 rounded-full bg-green-600 px-3 py-1.5 text-xs font-bold text-white shadow-sm">
                        <span>↑</span>
                        +{fmt(data.best.gain_pct)}%
                      </div>
                      <span className="text-xs text-gray-500">{t('sr_vs_local')}</span>
                    </div>
                  ) : (
                    <div className="mt-4 rounded-full bg-gray-100 px-3 py-1.5 text-xs font-bold text-gray-500 inline-block">
                      {t('sr_local')}
                    </div>
                  )}
                </div>
              </div>

              {/* Your market */}
              <div className="group relative overflow-hidden rounded-2xl border border-blue-100 bg-gradient-to-br from-blue-50 to-white p-6 shadow-sm transition hover:shadow-md">
                <div className="pointer-events-none absolute -right-6 -top-6 h-24 w-24 rounded-full bg-blue-100/60 blur-2xl" />
                <div className="relative">
                  <div className="flex items-center gap-2 text-xs font-bold uppercase tracking-wider text-blue-700">
                    <span className="text-lg">🏠</span> {t('sr_your_market')}
                  </div>
                  <div className="mt-3 text-3xl font-bold text-gray-900 font-display">
                    ৳{fmt(data.local.retail_price)}
                  </div>
                  <div className="mt-1 text-sm text-gray-500">
                    {dName(data.local.district_name)}
                  </div>
                  {/* Bar showing local price vs 30d avg */}
                  <div className="mt-4">
                    <div className="mb-1 flex items-baseline justify-between text-xs">
                      <span className="text-gray-500">{t('sr_avg_30d')}</span>
                      <span className="font-bold text-gray-700">৳{fmt(data.trend.avg_30d)}</span>
                    </div>
                    <div className="h-2 overflow-hidden rounded-full bg-gray-100">
                      <div
                        className={data.trend.vs_avg_pct >= 0 ? 'h-full bg-green-500' : 'h-full bg-red-400'}
                        style={{ width: `${Math.min(100, Math.abs(data.trend.vs_avg_pct) * 5 + 20)}%` }}
                      />
                    </div>
                  </div>
                </div>
              </div>

              {/* Trend */}
              <div className={`group relative overflow-hidden rounded-2xl border p-6 shadow-sm transition hover:shadow-md ${
                data.trend.direction === 'rising' ? 'border-green-100 bg-gradient-to-br from-green-50 to-white' :
                data.trend.direction === 'falling' ? 'border-red-100 bg-gradient-to-br from-red-50 to-white' :
                'border-amber-100 bg-gradient-to-br from-amber-50 to-white'
              }`}>
                <div className={`pointer-events-none absolute -right-6 -top-6 h-24 w-24 rounded-full blur-2xl ${
                  data.trend.direction === 'rising' ? 'bg-green-100/60' :
                  data.trend.direction === 'falling' ? 'bg-red-100/60' : 'bg-amber-100/60'
                }`} />
                <div className="relative">
                  <div className={`flex items-center gap-2 text-xs font-bold uppercase tracking-wider ${
                    data.trend.direction === 'rising' ? 'text-green-700' :
                    data.trend.direction === 'falling' ? 'text-red-700' : 'text-amber-700'
                  }`}>
                    <span className="text-lg">
                      {data.trend.direction === 'rising' ? '📈' : data.trend.direction === 'falling' ? '📉' : '➖'}
                    </span> {t('sr_when')}
                  </div>
                  <div className="mt-3 flex items-baseline gap-2">
                    <span className={`text-4xl ${
                      data.trend.direction === 'rising' ? 'text-green-600' :
                      data.trend.direction === 'falling' ? 'text-red-600' : 'text-amber-600'
                    }`}>
                      {data.trend.direction === 'rising' && '↗'}
                      {data.trend.direction === 'falling' && '↘'}
                      {data.trend.direction === 'flat' && '→'}
                    </span>
                    <span className="text-2xl font-bold text-gray-900 font-display">
                      {t('sr_trend_' + data.trend.direction)}
                    </span>
                  </div>
                  <div className="mt-4 text-sm">
                    <span className={data.trend.vs_avg_pct >= 0 ? 'text-green-700 font-bold' : 'text-red-700 font-bold'}>
                      {data.trend.vs_avg_pct >= 0 ? '+' : ''}{fmt(data.trend.vs_avg_pct)}%
                    </span>
                    <span className="text-gray-500"> {t('sr_vs_avg')}</span>
                  </div>
                </div>
              </div>
            </div>

            {/* Top 3 markets — clean table */}
            <div className="mb-8 overflow-hidden rounded-3xl border border-gray-100 bg-white shadow-sm">
              <div className="border-b border-gray-100 px-6 py-5 sm:px-8">
                <h2 className="text-xl font-bold text-gray-900 font-display">
                  🏆 {t('sr_top_markets')}
                </h2>
                <p className="mt-1 text-sm text-gray-500">{t('sr_top_sub')}</p>
              </div>
              <div className="overflow-x-auto">
                <table className="w-full text-sm">
                  <thead className="bg-gray-50 text-xs uppercase tracking-wider text-gray-500">
                    <tr>
                      <th className="px-6 py-3 text-left">#</th>
                      <th className="px-6 py-3 text-left">{t('sr_district_col')}</th>
                      <th className="px-6 py-3 text-right">{t('sr_price_col')}</th>
                      <th className="px-6 py-3 text-right">{t('sr_gain_col')}</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-gray-100">
                    {data.top_markets.map((m, i) => {
                      const isWinner = i === 0 && m.gain_pct > 0;
                      const isLocal = m.gain_pct <= 0;
                      return (
                        <tr key={m.district_id} className={isWinner ? 'bg-green-50/60 hover:bg-green-50' : 'hover:bg-gray-50'}>
                          <td className="px-6 py-4 text-gray-400 font-bold">{fmt(i + 1)}</td>
                          <td className="px-6 py-4">
                            <div className="flex items-center gap-2 font-bold text-gray-900">
                              {dName(m.district_name)}
                              {isWinner && (
                                <span className="rounded-full bg-green-100 px-2 py-0.5 text-xs font-bold text-green-800">
                                  ✓ {t('sr_best')}
                                </span>
                              )}
                              {isLocal && (
                                <span className="rounded-full bg-blue-100 px-2 py-0.5 text-xs font-bold text-blue-700">
                                  🏠 {t('sr_local')}
                                </span>
                              )}
                            </div>
                          </td>
                          <td className="px-6 py-4 text-right">
                            <div className="font-bold text-gray-900">৳{fmt(m.retail_price)}</div>
                            <div className="text-xs text-gray-400">/ {data.unit}</div>
                          </td>
                          <td className="px-6 py-4 text-right">
                            {m.gain_pct > 0 ? (
                              <span className="rounded-full bg-green-100 px-3 py-1 text-xs font-bold text-green-800">
                                ↑ +{fmt(m.gain_pct)}%
                              </span>
                            ) : (
                              <span className="text-xs text-gray-300">—</span>
                            )}
                          </td>
                        </tr>
                      );
                    })}
                  </tbody>
                </table>
              </div>
            </div>

            {/* CHART with gradient area */}
            {data.trend.history_7d.length > 0 && (
              <div className="mb-8 rounded-3xl border border-gray-100 bg-white p-6 shadow-sm sm:p-8">
                <div className="mb-4 flex flex-wrap items-baseline justify-between gap-2">
                  <div>
                    <h2 className="text-xl font-bold text-gray-900 font-display">
                      📊 {t('sr_last_7d')}
                    </h2>
                    <p className="mt-0.5 text-sm text-gray-500">
                      {cropLabel(data.crop)} • {dName(data.local.district_name)}
                    </p>
                  </div>
                </div>
                <div style={{ width: '100%', height: 240 }}>
                  <ResponsiveContainer>
                    <AreaChart data={data.trend.history_7d} margin={{ top: 10, right: 10, left: 0, bottom: 5 }}>
                      <defs>
                        <linearGradient id="priceGradient" x1="0" y1="0" x2="0" y2="1">
                          <stop offset="0%" stopColor={style.strokeColor} stopOpacity={0.3} />
                          <stop offset="100%" stopColor={style.strokeColor} stopOpacity={0} />
                        </linearGradient>
                      </defs>
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
                        formatter={(v) => [`৳${fmt(Number(v).toFixed(2))}`, t('sr_retail')]}
                        contentStyle={{
                          borderRadius: 12,
                          border: '1px solid #e2e8f0',
                          boxShadow: '0 4px 12px rgba(0,0,0,0.08)',
                        }}
                      />
                      <Area
                        type="monotone"
                        dataKey="price"
                        stroke={style.strokeColor}
                        strokeWidth={3}
                        fill="url(#priceGradient)"
                        dot={{ fill: style.strokeColor, r: 4, strokeWidth: 2, stroke: '#fff' }}
                        activeDot={{ r: 6, strokeWidth: 2, stroke: '#fff' }}
                      />
                    </AreaChart>
                  </ResponsiveContainer>
                </div>
              </div>
            )}

            {/* HOW WE DECIDED — explainer */}
            <div className="rounded-3xl border border-gray-100 bg-white p-6 shadow-sm sm:p-8">
              <h2 className="mb-4 text-lg font-bold text-gray-900 font-display">
                💭 {t('sr_how_title')}
              </h2>
              <div className="grid gap-4 sm:grid-cols-3">
                <ReasoningItem
                  icon="🏘️"
                  label={t('sr_reason1_label')}
                  value={data.best.gain_pct > 0 ? `+${fmt(data.best.gain_pct)}%` : `৳${fmt(data.best.retail_price)}`}
                  detail={t('sr_reason1_detail')}
                />
                <ReasoningItem
                  icon="📊"
                  label={t('sr_reason2_label')}
                  value={`${data.trend.vs_avg_pct >= 0 ? '+' : ''}${fmt(data.trend.vs_avg_pct)}%`}
                  detail={t('sr_reason2_detail')}
                />
                <ReasoningItem
                  icon="📈"
                  label={t('sr_reason3_label')}
                  value={t('sr_trend_' + data.trend.direction)}
                  detail={t('sr_reason3_detail')}
                />
              </div>
            </div>

            <p className="mt-6 text-center text-xs text-gray-400">
              {t('sr_disclaimer')}
            </p>
          </>
        )}
      </div>
    </div>
  );
}

function ReasoningItem({ icon, label, value, detail }) {
  return (
    <div className="rounded-xl bg-gray-50 p-4">
      <div className="flex items-center gap-2 text-xs font-bold uppercase tracking-wider text-gray-500">
        <span className="text-lg">{icon}</span> {label}
      </div>
      <div className="mt-2 text-xl font-bold text-gray-900 font-display">{value}</div>
      <div className="mt-1 text-xs text-gray-500">{detail}</div>
    </div>
  );
}
