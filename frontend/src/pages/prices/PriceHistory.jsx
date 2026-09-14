// PriceHistory.jsx — historical price trend line chart for a crop + district over time.
import { useEffect, useState } from 'react';
import { useLang } from '../../context/LangContext.jsx';
import { api } from '../../api/client.js';
import {
  LineChart, Line, XAxis, YAxis, Tooltip, ResponsiveContainer,
  CartesianGrid, Legend, ReferenceLine,
} from 'recharts';

const CROP_EN = {
  'লাউ': 'Bottle Gourd',
  'কাঁচামরিচ': 'Green Chili',
  'বেগুন': 'Eggplant',
  'আলু': 'Potato',
  'টমেটো': 'Tomato',
};
const DISTRICT_BN = {
  'Dhaka': 'ঢাকা',
  'Chittagong': 'চট্টগ্রাম',
  'Rajshahi': 'রাজশাহী',
  'Khulna': 'খুলনা',
  'Sylhet': 'সিলেট',
  'Barishal': 'বরিশাল',
  'Rangpur': 'রংপুর',
  'Mymensingh': 'ময়মনসিংহ',
  'Rangamati': 'রাঙ্গামাটি',
};
const BN_DIGITS = ['০','১','২','৩','৪','৫','৬','৭','৮','৯'];
const HERO_IMG = 'https://images.unsplash.com/photo-1464226184884-fa280b87c399?w=1600';

const RANGES = [
  { days: 7,   label: '7d',  bn: '৭ দিন' },
  { days: 30,  label: '30d', bn: '৩০ দিন' },
  { days: 90,  label: '90d', bn: '৯০ দিন' },
  { days: 365, label: '1y',  bn: '১ বছর' },
];

export default function PriceHistory() {
  const { t, lang } = useLang();
  const [crops, setCrops] = useState([]);
  const [districts, setDistricts] = useState([]);
  const [selectedCrop, setSelectedCrop] = useState('');
  const [selectedDistrict, setSelectedDistrict] = useState('');
  const [days, setDays] = useState(30);
  const [rows, setRows] = useState([]);
  const [loading, setLoading] = useState(true);

  const cropLabel = (c) => (lang === 'en' ? (CROP_EN[c] || c) : c);
  const dName = (n) => (lang === 'en' ? n : (DISTRICT_BN[n] || n));
  const fmt = (n) => {
    const s = typeof n === 'number' ? n.toString() : String(n);
    return lang === 'bn' ? s.replace(/\d/g, (d) => BN_DIGITS[+d]) : s;
  };

  // Load crop list once
  useEffect(() => {
    api.get('/api/prices/crops').then((r) => {
      const list = r.crops || [];
      setCrops(list);
      if (list.length && !selectedCrop) setSelectedCrop(list[0]);
    });
  }, []);

  // Fetch history whenever selection changes
  useEffect(() => {
    if (!selectedCrop) return;
    setLoading(true);
    const district = selectedDistrict || 9; // default Rangamati
    api
      .get(`/api/prices/history?crop=${encodeURIComponent(selectedCrop)}&district_id=${district}&days=${days}`)
      .then((r) => {
        setRows(r.rows || []);
        if (r.districts && !selectedDistrict) {
          setDistricts(r.districts);
          setSelectedDistrict(district);
        } else if (r.districts) {
          setDistricts(r.districts);
        }
      })
      .finally(() => setLoading(false));
  }, [selectedCrop, selectedDistrict, days]);

  // Stats
  const first = rows[0];
  const last = rows[rows.length - 1];
  const change = first && last ? Number(last.retail_price) - Number(first.retail_price) : 0;
  const changePct = first ? (change / Number(first.retail_price)) * 100 : 0;
  const avg =
    rows.length > 0
      ? rows.reduce((s, r) => s + Number(r.retail_price), 0) / rows.length
      : 0;
  const highest = rows.length > 0 ? Math.max(...rows.map((r) => Number(r.retail_price))) : 0;
  const lowest = rows.length > 0 ? Math.min(...rows.map((r) => Number(r.retail_price))) : 0;
  const unit = rows[0]?.unit || 'kg';

  // Tighten Y-axis
  const yMin = rows.length > 0 ? Math.max(0, Math.floor(lowest / 10) * 10 - 5) : 0;
  const yMax = rows.length > 0 ? Math.ceil(highest / 10) * 10 + 5 : 100;

  // Format date labels
  const formatDate = (dateStr) => {
    const d = new Date(dateStr);
    const opts = { day: 'numeric', month: 'short' };
    const s = d.toLocaleDateString(lang === 'bn' ? 'bn-BD' : 'en-GB', opts);
    return s;
  };

  const districtNameLookup = (id) => {
    const d = districts.find((d) => d.district_id === Number(id));
    return d ? dName(d.district_name) : '';
  };

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
            {t('ph_title')}
          </h1>
          <p className="mt-3 max-w-2xl text-lg text-white/85">{t('ph_sub')}</p>
        </div>
      </div>

      <div className="mx-auto max-w-6xl px-6 py-10">
        {/* Selectors */}
        <div className="mb-8 rounded-2xl border border-gray-100 bg-white p-5 shadow-sm">
          <div className="flex flex-wrap items-center gap-4">
            {/* Crop */}
            <div>
              <label className="mb-1 block text-xs font-semibold uppercase tracking-wider text-gray-500">
                {t('ph_crop')}
              </label>
              <select
                value={selectedCrop}
                onChange={(e) => setSelectedCrop(e.target.value)}
                className="rounded-lg border border-gray-200 bg-white px-4 py-2 text-sm font-semibold text-gray-900 focus:border-m1 focus:outline-none focus:ring-1 focus:ring-m1"
              >
                {crops.map((c) => (
                  <option key={c} value={c}>{cropLabel(c)}</option>
                ))}
              </select>
            </div>

            {/* District */}
            <div>
              <label className="mb-1 block text-xs font-semibold uppercase tracking-wider text-gray-500">
                {t('ph_district')}
              </label>
              <select
                value={selectedDistrict}
                onChange={(e) => setSelectedDistrict(Number(e.target.value))}
                className="rounded-lg border border-gray-200 bg-white px-4 py-2 text-sm font-semibold text-gray-900 focus:border-m1 focus:outline-none focus:ring-1 focus:ring-m1"
              >
                {districts.map((d) => (
                  <option key={d.district_id} value={d.district_id}>
                    {dName(d.district_name)}
                  </option>
                ))}
              </select>
            </div>

            {/* Range toggle */}
            <div className="ml-auto">
              <label className="mb-1 block text-xs font-semibold uppercase tracking-wider text-gray-500">
                {t('ph_range')}
              </label>
              <div className="inline-flex rounded-lg bg-gray-100 p-1">
                {RANGES.map((r) => (
                  <button
                    key={r.days}
                    onClick={() => setDays(r.days)}
                    className={
                      'rounded-md px-3 py-1.5 text-xs font-semibold transition ' +
                      (days === r.days
                        ? 'bg-white text-m1 shadow-sm'
                        : 'text-gray-500 hover:text-gray-700')
                    }
                  >
                    {lang === 'bn' ? r.bn : r.label}
                  </button>
                ))}
              </div>
            </div>
          </div>
        </div>

        {loading && (
          <div className="grid gap-4 sm:grid-cols-4">
            {[1,2,3,4].map((i) => <div key={i} className="h-28 animate-pulse rounded-2xl bg-gray-100" />)}
          </div>
        )}

        {!loading && rows.length > 0 && (
          <>
            {/* Stat cards */}
            <div className="mb-8 grid gap-4 sm:grid-cols-4">
              <Stat
                label={t('ph_current')}
                value={`৳${fmt(Number(last.retail_price).toFixed(2))}`}
                sub={`${t('ph_per')} ${unit}`}
              />
              <Stat
                label={t('ph_change')}
                value={`${change >= 0 ? '+' : ''}৳${fmt(change.toFixed(2))}`}
                sub={`${change >= 0 ? '+' : ''}${fmt(changePct.toFixed(1))}%`}
                tone={change >= 0 ? 'red' : 'green'}
              />
              <Stat
                label={t('ph_avg')}
                value={`৳${fmt(avg.toFixed(2))}`}
                sub={`${fmt(rows.length)} ${t('ph_days')}`}
                tone="blue"
              />
              <Stat
                label={t('ph_range_label')}
                value={`৳${fmt(lowest.toFixed(0))} – ৳${fmt(highest.toFixed(0))}`}
                sub={`${t('ph_low')} → ${t('ph_high')}`}
                tone="gray"
              />
            </div>

            {/* Chart */}
            <div className="rounded-2xl border border-gray-100 bg-white p-6 shadow-sm sm:p-8">
              <div className="mb-4 flex flex-wrap items-baseline justify-between gap-2">
                <div>
                  <h2 className="text-xl font-bold text-gray-900 font-display">
                    {t('ph_chart_title')}
                  </h2>
                  <p className="text-sm text-gray-500">
                    {cropLabel(selectedCrop)} • {districtNameLookup(selectedDistrict)} • {t('ph_last')} {fmt(days)} {t('ph_days')}
                  </p>
                </div>
                <div className="flex gap-3 text-xs">
                  <LegendChip color="#94a3b8" label={t('ph_wholesale')} />
                  <LegendChip color="#16a34a" label={t('ph_retail')} />
                  <LegendChip color="#f59e0b" label={t('ph_avg')} dashed />
                </div>
              </div>

              <div style={{ width: '100%', height: 380 }}>
                <ResponsiveContainer>
                  <LineChart data={rows} margin={{ top: 10, right: 20, left: 0, bottom: 10 }}>
                    <CartesianGrid vertical={false} stroke="#f1f5f9" />
                    <XAxis
                      dataKey="price_date"
                      tick={{ fontSize: 11, fill: '#64748b' }}
                      axisLine={false}
                      tickLine={false}
                      tickFormatter={formatDate}
                      minTickGap={30}
                    />
                    <YAxis
                      domain={[yMin, yMax]}
                      tick={{ fontSize: 12, fill: '#64748b' }}
                      axisLine={false}
                      tickLine={false}
                      tickFormatter={(v) => `৳${fmt(v)}`}
                    />
                    <Tooltip
                      cursor={{ stroke: '#94a3b8', strokeDasharray: '3 3' }}
                      formatter={(v) => `৳${fmt(Number(v).toFixed(2))}`}
                      labelFormatter={formatDate}
                      contentStyle={{
                        borderRadius: 12,
                        border: '1px solid #e2e8f0',
                        boxShadow: '0 4px 12px rgba(0,0,0,0.05)',
                      }}
                    />
                    <ReferenceLine y={avg} stroke="#f59e0b" strokeDasharray="4 4" strokeWidth={1.5} />
                    <Line
                      type="monotone"
                      dataKey="wholesale_price"
                      name={t('ph_wholesale')}
                      stroke="#94a3b8"
                      strokeWidth={2}
                      dot={false}
                      activeDot={{ r: 4 }}
                    />
                    <Line
                      type="monotone"
                      dataKey="retail_price"
                      name={t('ph_retail')}
                      stroke="#16a34a"
                      strokeWidth={2.5}
                      dot={false}
                      activeDot={{ r: 5 }}
                    />
                  </LineChart>
                </ResponsiveContainer>
              </div>
            </div>

            <p className="mt-6 text-center text-xs text-gray-400">
              {t('ph_source')}: DAM • {t('ph_disclaimer')}
            </p>
          </>
        )}
      </div>
    </div>
  );
}

function Stat({ label, value, sub, tone = 'default' }) {
  const tones = {
    default: 'border-gray-100 bg-white',
    green: 'border-green-100 bg-gradient-to-br from-green-50 to-white',
    red: 'border-red-100 bg-gradient-to-br from-red-50 to-white',
    blue: 'border-blue-100 bg-gradient-to-br from-blue-50 to-white',
    gray: 'border-gray-100 bg-gradient-to-br from-gray-50 to-white',
  };
  return (
    <div className={`rounded-2xl border p-5 shadow-sm ${tones[tone]}`}>
      <div className="text-xs font-semibold uppercase tracking-wider text-gray-500">{label}</div>
      <div className="mt-2 text-2xl font-bold text-gray-900 font-display">{value}</div>
      <div className="mt-1 text-xs text-gray-500">{sub}</div>
    </div>
  );
}

function LegendChip({ color, label, dashed }) {
  return (
    <span className="inline-flex items-center gap-1.5 text-gray-600">
      <span
        className="h-0.5 w-4"
        style={{
          backgroundColor: dashed ? 'transparent' : color,
          borderTop: dashed ? `2px dashed ${color}` : 'none',
        }}
      />
      {label}
    </span>
  );
}
