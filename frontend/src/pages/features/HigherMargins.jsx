// HigherMargins.jsx — calculator page showing farmer's earning boost with AgroMart.
import { useEffect, useState } from 'react';
import { useLang } from '../../context/LangContext.jsx';
import { api } from '../../api/client.js';
import {
  BarChart, Bar, XAxis, YAxis, Tooltip, ResponsiveContainer,
  CartesianGrid, Cell,
} from 'recharts';

const CROP_EN = {
  'লাউ': 'Bottle Gourd', 'কাঁচামরিচ': 'Green Chili', 'বেগুন': 'Eggplant',
  'আলু': 'Potato', 'টমেটো': 'Tomato', 'পেঁয়াজ': 'Onion',
  'সরিষা': 'Mustard', 'মুগ ডাল': 'Mung Dal', 'মসুর ডাল': 'Lentils',
};
const ROLE_LABEL_BN = {
  farmer: 'কৃষক', dealer: 'দালাল', wholesaler: 'আড়তদার',
  retailer: 'খুচরা বিক্রেতা', platform: 'AgroMart ফি',
};
const ROLE_LABEL_EN = {
  farmer: 'Farmer', dealer: 'Dealer', wholesaler: 'Wholesaler',
  retailer: 'Retailer', platform: 'AgroMart fee',
};
const BN_DIGITS = ['০','১','২','৩','৪','৫','৬','৭','৮','৯'];
const HERO_IMG = 'https://images.unsplash.com/photo-1464226184884-fa280b87c399?w=1600';

// Colors for stacked bars — farmer stands out, middlemen fade.
const COLORS = {
  farmer:     '#16a34a',
  platform:   '#94a3b8',
  dealer:     '#fbbf24',
  wholesaler: '#f97316',
  retailer:   '#dc2626',
};

export default function HigherMargins() {
  const { t, lang } = useLang();
  const [crops, setCrops] = useState([]);
  const [selectedCrop, setSelectedCrop] = useState('');
  const [quantity, setQuantity] = useState(500);
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);

  const cropLabel = (c) => (lang === 'en' ? (CROP_EN[c] || c) : c);
  const roleLabel = (r) => (lang === 'en' ? (ROLE_LABEL_EN[r] || r) : (ROLE_LABEL_BN[r] || r));
  const fmt = (n) => {
    const s = typeof n === 'number' ? n.toString() : String(n);
    return lang === 'bn' ? s.replace(/\d/g, (d) => BN_DIGITS[+d]) : s;
  };

  // fetch crop list once (via any crop's calc)
  useEffect(() => {
    api.get('/api/margins/calculate?crop=লাউ&quantity=1').then((r) => {
      const list = r.crops || [];
      setCrops(list);
      if (list.length && !selectedCrop) setSelectedCrop(list[0]);
    });
  }, []);

  // recalculate whenever crop or quantity changes
  useEffect(() => {
    if (!selectedCrop || !quantity) return;
    setLoading(true);
    api.get(`/api/margins/calculate?crop=${encodeURIComponent(selectedCrop)}&quantity=${quantity}`)
      .then(setData)
      .finally(() => setLoading(false));
  }, [selectedCrop, quantity]);

  // build chart data — two rows (Traditional, AgroMart), each summed
  const chartData = data ? [
    {
      label: lang === 'en' ? 'Traditional' : 'সাধারণ পদ্ধতি',
      ...Object.fromEntries(data.traditional.map((r) => [r.role, r.amount])),
    },
    {
      label: lang === 'en' ? 'AgroMart' : 'AgroMart',
      ...Object.fromEntries(data.agromart.map((r) => [r.role, r.amount])),
    },
  ] : [];

  return (
    <div className="bg-gray-50 pb-20">
      {/* Hero */}
      <div
        className="relative overflow-hidden border-b border-gray-100"
        style={{
          backgroundImage: `linear-gradient(rgba(15, 42, 30, 0.85), rgba(15, 42, 30, 0.75)), url(${HERO_IMG})`,
          backgroundSize: 'cover',
          backgroundPosition: 'center',
        }}
      >
        <div className="mx-auto max-w-6xl px-6 py-16">
          <h1 className="text-4xl font-bold text-white sm:text-5xl font-display drop-shadow">
            {t('hm_title')}
          </h1>
          <p className="mt-3 max-w-2xl text-lg text-white/85">{t('hm_sub')}</p>
        </div>
      </div>

      <div className="mx-auto max-w-6xl px-6 py-10">
        {/* Inputs */}
        <div className="mb-8 rounded-2xl border border-gray-100 bg-white p-6 shadow-sm">
          <div className="grid gap-6 sm:grid-cols-2">
            <div>
              <label className="mb-2 block text-xs font-semibold uppercase tracking-wider text-gray-500">
                {t('hm_crop')}
              </label>
              <select
                value={selectedCrop}
                onChange={(e) => setSelectedCrop(e.target.value)}
                className="w-full rounded-lg border border-gray-200 bg-white px-4 py-3 text-sm font-semibold text-gray-900 focus:border-m1 focus:outline-none focus:ring-1 focus:ring-m1"
              >
                {crops.map((c) => (
                  <option key={c} value={c}>{cropLabel(c)}</option>
                ))}
              </select>
            </div>
            <div>
              <label className="mb-2 block text-xs font-semibold uppercase tracking-wider text-gray-500">
                {t('hm_quantity')} ({data?.unit || 'kg'})
              </label>
              <input
                type="number"
                min="1"
                value={quantity}
                onChange={(e) => setQuantity(Math.max(1, Number(e.target.value) || 1))}
                className="w-full rounded-lg border border-gray-200 bg-white px-4 py-3 text-sm font-semibold text-gray-900 focus:border-m1 focus:outline-none focus:ring-1 focus:ring-m1"
              />
            </div>
          </div>
        </div>

        {loading && (
          <div className="grid gap-4 sm:grid-cols-3">
            {[1,2,3].map((i) => <div key={i} className="h-32 animate-pulse rounded-2xl bg-gray-100" />)}
          </div>
        )}

        {!loading && data && (
          <>
            {/* Headline */}
            <div className="mb-8 rounded-2xl border border-green-100 bg-gradient-to-br from-green-50 to-white p-8 shadow-sm">
              <div className="text-xs font-semibold uppercase tracking-wider text-green-700">
                {t('hm_headline')}
              </div>
              <div className="mt-3 text-5xl font-bold text-gray-900 font-display sm:text-6xl">
                ৳{fmt(data.gain.toLocaleString('en-US'))}
              </div>
              <div className="mt-2 text-lg text-gray-600">
                {t('hm_more_per_sale')} — {fmt(data.gain_pct)}% {t('hm_gain_pct')}
              </div>
              <div className="mt-4 text-sm text-gray-500">
                {fmt(data.quantity)} {data.unit} × ৳{fmt(data.retail_price)} = ৳{fmt(data.total_revenue.toLocaleString('en-US'))} {t('hm_total_retail')}
              </div>
            </div>

            {/* Two-row summary */}
            <div className="mb-8 grid gap-4 sm:grid-cols-2">
              <SummaryCard
                title={t('hm_traditional')}
                subtitle={t('hm_traditional_sub')}
                farmerEarn={data.traditional_farmer_earnings}
                fmt={fmt}
                tone="red"
              />
              <SummaryCard
                title={t('hm_agromart')}
                subtitle={t('hm_agromart_sub')}
                farmerEarn={data.agromart_farmer_earnings}
                fmt={fmt}
                tone="green"
                highlight
              />
            </div>

            {/* Stacked bar chart */}
            <div className="mb-8 rounded-2xl border border-gray-100 bg-white p-6 shadow-sm sm:p-8">
              <div className="mb-4">
                <h2 className="text-xl font-bold text-gray-900 font-display">
                  {t('hm_chart_title')}
                </h2>
                <p className="text-sm text-gray-500">
                  {t('hm_chart_sub')}
                </p>
              </div>
              <div style={{ width: '100%', height: 320 }}>
                <ResponsiveContainer>
                  <BarChart data={chartData} layout="vertical" margin={{ top: 10, right: 20, left: 20, bottom: 10 }}>
                    <CartesianGrid horizontal={false} stroke="#f1f5f9" />
                    <XAxis
                      type="number"
                      tick={{ fontSize: 12, fill: '#64748b' }}
                      axisLine={false}
                      tickLine={false}
                      tickFormatter={(v) => `৳${fmt(v)}`}
                    />
                    <YAxis
                      type="category"
                      dataKey="label"
                      tick={{ fontSize: 13, fill: '#111827', fontWeight: 600 }}
                      axisLine={false}
                      tickLine={false}
                      width={120}
                    />
                    <Tooltip
                      cursor={{ fill: '#f8fafc' }}
                      formatter={(v, name) => [`৳${fmt(Number(v).toFixed(2))}`, roleLabel(name)]}
                      contentStyle={{
                        borderRadius: 12,
                        border: '1px solid #e2e8f0',
                        boxShadow: '0 4px 12px rgba(0,0,0,0.05)',
                      }}
                    />
                    {['farmer','dealer','wholesaler','retailer','platform'].map((role) => (
                      <Bar key={role} dataKey={role} stackId="a" fill={COLORS[role]} name={role} />
                    ))}
                  </BarChart>
                </ResponsiveContainer>
              </div>
              {/* legend */}
              <div className="mt-4 flex flex-wrap gap-4 text-xs">
                {['farmer','dealer','wholesaler','retailer','platform'].map((role) => (
                  <span key={role} className="inline-flex items-center gap-1.5 text-gray-600">
                    <span className="h-3 w-3 rounded-sm" style={{ backgroundColor: COLORS[role] }} />
                    {roleLabel(role)}
                  </span>
                ))}
              </div>
            </div>

            {/* Breakdown table */}
            <div className="overflow-hidden rounded-2xl border border-gray-100 bg-white shadow-sm">
              <div className="border-b border-gray-100 px-6 py-4 sm:px-8">
                <h2 className="text-lg font-bold text-gray-900 font-display">
                  {t('hm_breakdown_title')}
                </h2>
              </div>
              <div className="grid gap-0 sm:grid-cols-2">
                <BreakdownList
                  title={t('hm_traditional')}
                  rows={data.traditional}
                  roleLabel={roleLabel}
                  fmt={fmt}
                  total={data.total_revenue}
                />
                <BreakdownList
                  title={t('hm_agromart')}
                  rows={data.agromart}
                  roleLabel={roleLabel}
                  fmt={fmt}
                  total={data.total_revenue}
                  highlight
                />
              </div>
            </div>

            <p className="mt-6 text-center text-xs text-gray-400">
              {t('hm_disclaimer')}
            </p>
          </>
        )}
      </div>
    </div>
  );
}

function SummaryCard({ title, subtitle, farmerEarn, fmt, tone, highlight }) {
  const bg = tone === 'green'
    ? 'border-green-200 bg-gradient-to-br from-green-50 to-white'
    : 'border-red-100 bg-gradient-to-br from-red-50 to-white';
  return (
    <div className={`rounded-2xl border p-6 shadow-sm ${bg} ${highlight ? 'ring-2 ring-green-500 ring-offset-2' : ''}`}>
      <div className="text-xs font-semibold uppercase tracking-wider text-gray-500">{title}</div>
      <div className="mt-1 text-sm text-gray-500">{subtitle}</div>
      <div className="mt-4 text-3xl font-bold text-gray-900 font-display">
        ৳{fmt(farmerEarn.toLocaleString('en-US'))}
      </div>
    </div>
  );
}

function BreakdownList({ title, rows, roleLabel, fmt, total, highlight }) {
  return (
    <div className={`border-r border-gray-100 p-6 sm:p-8 ${highlight ? 'bg-green-50/40' : ''}`}>
      <h3 className="mb-4 font-bold text-gray-900">{title}</h3>
      <div className="space-y-3">
        {rows.map((r) => (
          <div key={r.role} className="flex items-center justify-between text-sm">
            <span className="text-gray-700">{roleLabel(r.role)}</span>
            <span className="text-right">
              <span className="font-bold text-gray-900">৳{fmt(r.amount.toLocaleString('en-US'))}</span>
              <span className="ml-2 text-xs text-gray-400">({fmt(r.share_pct)}%)</span>
            </span>
          </div>
        ))}
      </div>
      <div className="mt-4 border-t border-gray-100 pt-3 text-xs text-gray-500">
        Total ৳{fmt(total.toLocaleString('en-US'))}
      </div>
    </div>
  );
}
