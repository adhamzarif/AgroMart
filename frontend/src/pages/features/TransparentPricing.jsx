// TransparentPricing.jsx — visualize the "price journey" from farm to consumer.
import { useEffect, useState } from 'react';
import { useLang } from '../../context/LangContext.jsx';
import { api } from '../../api/client.js';

const CROP_EN = {
  'লাউ':'Bottle Gourd','কাঁচামরিচ':'Green Chili','বেগুন':'Eggplant',
  'আলু':'Potato','টমেটো':'Tomato','পেঁয়াজ':'Onion',
  'সরিষা':'Mustard','মুগ ডাল':'Mung Dal','মসুর ডাল':'Lentils',
};
const ROLE_LABEL_BN = {
  farmer: 'কৃষক', dealer: 'দালাল', wholesaler: 'আড়তদার',
  retailer: 'খুচরা বিক্রেতা', platform: 'AgroMart',
  consumer: 'ক্রেতা',
};
const ROLE_LABEL_EN = {
  farmer: 'Farmer', dealer: 'Dealer', wholesaler: 'Wholesaler',
  retailer: 'Retailer', platform: 'AgroMart',
  consumer: 'Consumer',
};
const ROLE_ICON = {
  farmer: '🧑‍🌾', dealer: '🚚', wholesaler: '🏭', retailer: '🏪',
  platform: '🌐', consumer: '👥',
};
const ROLE_COLOR = {
  farmer:     'from-green-500 to-emerald-600',
  dealer:     'from-amber-400 to-yellow-500',
  wholesaler: 'from-orange-400 to-orange-500',
  retailer:   'from-red-400 to-red-500',
  platform:   'from-blue-400 to-blue-500',
  consumer:   'from-gray-400 to-gray-500',
};
const BN_DIGITS = ['০','১','২','৩','৪','৫','৬','৭','৮','৯'];
const HERO_IMG = 'https://images.unsplash.com/photo-1488459716781-31db52582fe9?w=1600';

export default function TransparentPricing() {
  const { t, lang } = useLang();
  const [crops, setCrops] = useState([]);
  const [selectedCrop, setSelectedCrop] = useState('');
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);

  const cropLabel = (c) => (lang === 'en' ? (CROP_EN[c] || c) : c);
  const roleLabel = (r) => (lang === 'en' ? (ROLE_LABEL_EN[r] || r) : (ROLE_LABEL_BN[r] || r));
  const fmt = (n) => {
    if (n === null || n === undefined) return '';
    const s = typeof n === 'number'
      ? n.toLocaleString('en-US', { maximumFractionDigits: 2 })
      : String(n);
    return lang === 'bn' ? s.replace(/\d/g, (d) => BN_DIGITS[+d]) : s;
  };

  useEffect(() => {
    api.get('/api/margins/journey?crop=আলু').then((r) => {
      const list = r.crops || [];
      setCrops(list);
      if (list.length && !selectedCrop) setSelectedCrop(list[0]);
    });
  }, []);

  useEffect(() => {
    if (!selectedCrop) return;
    setLoading(true);
    api.get(`/api/margins/journey?crop=${encodeURIComponent(selectedCrop)}`)
      .then(setData)
      .finally(() => setLoading(false));
  }, [selectedCrop]);

  return (
    <div className="bg-gray-50 pb-24">
      {/* Hero */}
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
            {t('tp_title')}
          </h1>
          <p className="mt-3 max-w-2xl text-lg text-white/85">{t('tp_sub')}</p>
        </div>
      </div>

      <div className="mx-auto max-w-6xl px-6 py-10">
        {/* Crop selector */}
        <div className="mb-8 rounded-2xl border border-gray-100 bg-white p-6 shadow-lg sm:p-8">
          <label className="mb-2 block text-xs font-semibold uppercase tracking-wider text-gray-500">
            🌾 {t('tp_pick_crop')}
          </label>
          <select
            value={selectedCrop}
            onChange={(e) => setSelectedCrop(e.target.value)}
            className="w-full rounded-xl border-2 border-gray-100 bg-white px-4 py-3 text-base font-semibold text-gray-900 focus:border-m1 focus:outline-none focus:ring-2 focus:ring-m1/20 sm:max-w-md"
          >
            {crops.map((c) => (
              <option key={c} value={c}>{cropLabel(c)}</option>
            ))}
          </select>
        </div>

        {loading && (
          <div className="grid gap-6">
            <div className="h-40 animate-pulse rounded-2xl bg-gray-100" />
            <div className="h-64 animate-pulse rounded-2xl bg-gray-100" />
          </div>
        )}

        {!loading && data && (
          <>
            {/* Top headline card */}
            <div className="mb-8 rounded-3xl border border-blue-100 bg-gradient-to-br from-blue-50 via-cyan-50 to-white p-8 shadow-sm sm:p-10">
              <div className="text-xs font-semibold uppercase tracking-wider text-blue-700">
                🔍 {t('tp_headline_label')}
              </div>
              <div className="mt-3 flex flex-wrap items-baseline gap-3">
                <span className="text-3xl font-bold text-gray-900 font-display sm:text-4xl">
                  {cropLabel(data.crop)}
                </span>
                <span className="rounded-full bg-white px-3 py-1 text-sm font-bold text-gray-700 shadow-sm">
                  ৳{fmt(data.retail_price)} / {data.unit}
                </span>
              </div>
              <p className="mt-3 max-w-2xl text-gray-700">
                {t('tp_headline_desc')}
              </p>
            </div>

            {/* TRADITIONAL PATH */}
            <div className="mb-6 rounded-3xl border border-gray-100 bg-white p-6 shadow-sm sm:p-8">
              <div className="mb-2 flex items-baseline gap-2">
                <span className="rounded-full bg-red-100 px-3 py-1 text-xs font-bold text-red-800">
                  {t('tp_traditional')}
                </span>
                <span className="text-xs text-gray-500">{fmt(data.traditional.length)} {t('tp_hops')}</span>
              </div>
              <h2 className="text-xl font-bold text-gray-900 font-display">
                {t('tp_traditional_title')}
              </h2>
              <p className="mt-1 text-sm text-gray-500">{t('tp_traditional_sub')}</p>

              {/* Journey flow */}
              <div className="mt-8">
                <PathFlow
                  hops={[...data.traditional, { role: 'consumer', amount: data.retail_price, share_pct: 100 }]}
                  roleLabel={roleLabel}
                  fmt={fmt}
                  unit={data.unit}
                  showEndCap
                />
              </div>

              {/* Farmer earnings on traditional path */}
              <div className="mt-8 rounded-xl bg-red-50/50 p-5">
                <div className="text-xs font-semibold uppercase tracking-wider text-red-700">
                  {t('tp_farmer_gets')}
                </div>
                <div className="mt-1 flex items-baseline gap-3">
                  <span className="text-3xl font-bold text-gray-900 font-display">
                    ৳{fmt(data.traditional_farmer_earnings)}
                  </span>
                  <span className="text-sm text-gray-500">
                    ({fmt(data.traditional.find((r) => r.role === 'farmer')?.share_pct || 0)}% {t('tp_of_retail')})
                  </span>
                </div>
              </div>
            </div>

            {/* AGROMART PATH */}
            <div className="mb-6 rounded-3xl border-2 border-green-200 bg-gradient-to-br from-green-50/60 to-white p-6 shadow-lg sm:p-8">
              <div className="mb-2 flex items-baseline gap-2">
                <span className="rounded-full bg-green-600 px-3 py-1 text-xs font-bold text-white">
                  ✓ {t('tp_agromart')}
                </span>
                <span className="text-xs text-gray-500">{t('tp_hops_direct')}</span>
              </div>
              <h2 className="text-xl font-bold text-gray-900 font-display">
                {t('tp_agromart_title')}
              </h2>
              <p className="mt-1 text-sm text-gray-500">{t('tp_agromart_sub')}</p>

              <div className="mt-8">
                <PathFlow
                  hops={[{ role: 'farmer', amount: data.agromart_farmer_earnings, share_pct: data.agromart[0]?.share_pct || 85 },
                         { role: 'consumer', amount: data.retail_price, share_pct: 100 }]}
                  roleLabel={roleLabel}
                  fmt={fmt}
                  unit={data.unit}
                  showEndCap
                  green
                />
              </div>

              <div className="mt-8 rounded-xl bg-green-100/50 p-5">
                <div className="text-xs font-semibold uppercase tracking-wider text-green-700">
                  {t('tp_farmer_gets')}
                </div>
                <div className="mt-1 flex items-baseline gap-3">
                  <span className="text-3xl font-bold text-gray-900 font-display">
                    ৳{fmt(data.agromart_farmer_earnings)}
                  </span>
                  <span className="text-sm text-gray-500">
                    ({fmt(data.agromart[0]?.share_pct || 85)}% {t('tp_of_retail')})
                  </span>
                </div>
                <div className="mt-3 inline-flex items-center gap-2 rounded-full bg-green-600 px-4 py-1.5 text-sm font-bold text-white shadow-sm">
                  ↑ +৳{fmt(data.gain)} ({fmt(data.gain_pct)}% {t('tp_more')})
                </div>
              </div>
            </div>

            {/* Comparison bar */}
            <div className="mb-8 rounded-3xl border border-gray-100 bg-white p-6 shadow-sm sm:p-8">
              <h2 className="mb-1 text-xl font-bold text-gray-900 font-display">
                📊 {t('tp_comparison_title')}
              </h2>
              <p className="mb-6 text-sm text-gray-500">{t('tp_comparison_sub')}</p>

              <div className="space-y-6">
                <ComparisonBar
                  label={t('tp_traditional')}
                  value={data.traditional_farmer_earnings}
                  max={data.retail_price}
                  color="bg-red-400"
                  fmt={fmt}
                />
                <ComparisonBar
                  label={t('tp_agromart')}
                  value={data.agromart_farmer_earnings}
                  max={data.retail_price}
                  color="bg-green-500"
                  highlight
                  fmt={fmt}
                />
              </div>
            </div>

<p className="mt-6 text-center text-xs text-gray-400">
              {t('tp_disclaimer')}
            </p>
          </>
        )}
      </div>
    </div>
  );
}

function PathFlow({ hops, roleLabel, fmt, unit, showEndCap, green }) {
  return (
    <div className="relative">
      <div className="flex flex-wrap items-center justify-center gap-2 sm:gap-3">
        {hops.map((hop, i) => (
          <div key={hop.role + i} className="contents">
            <HopCard hop={hop} roleLabel={roleLabel} fmt={fmt} unit={unit} highlight={green && hop.role === 'farmer'} />
            {i < hops.length - 1 && (
              <div className="grid place-items-center">
                <div className={`text-2xl ${green ? 'text-green-500' : 'text-gray-400'}`}>→</div>
              </div>
            )}
          </div>
        ))}
      </div>
    </div>
  );
}

function HopCard({ hop, roleLabel, fmt, unit, highlight }) {
  const gradient = ROLE_COLOR[hop.role] || 'from-gray-400 to-gray-500';
  const icon = ROLE_ICON[hop.role] || '👤';

  return (
    <div className={
      'flex w-32 flex-col items-center rounded-2xl border p-3 text-center shadow-sm sm:w-36 sm:p-4 ' +
      (highlight
        ? 'border-green-400 bg-white ring-2 ring-green-200'
        : 'border-gray-100 bg-white')
    }>
      <div className={`grid h-12 w-12 place-items-center rounded-full bg-gradient-to-br ${gradient} text-2xl shadow-md sm:h-14 sm:w-14`}>
        {icon}
      </div>
      <div className="mt-2 text-xs font-bold text-gray-900">{roleLabel(hop.role)}</div>
      {hop.role !== 'consumer' && (
        <>
          <div className="mt-1 text-sm font-bold text-gray-900">
            ৳{fmt(hop.amount)}
          </div>
          <div className="text-[10px] text-gray-500">
            {fmt(hop.share_pct)}%
          </div>
        </>
      )}
      {hop.role === 'consumer' && (
        <div className="mt-1 text-xs text-gray-500">
          ৳{fmt(hop.amount)}/{unit}
        </div>
      )}
    </div>
  );
}

function ComparisonBar({ label, value, max, color, highlight, fmt }) {
  const pct = max > 0 ? (value / max) * 100 : 0;
  return (
    <div>
      <div className="mb-2 flex items-baseline justify-between">
        <span className={`font-bold ${highlight ? 'text-green-700' : 'text-gray-700'}`}>{label}</span>
        <span className="text-lg font-bold text-gray-900 font-display">
          ৳{fmt(value)} <span className="text-xs font-normal text-gray-500">({fmt(pct.toFixed(0))}%)</span>
        </span>
      </div>
      <div className="h-6 overflow-hidden rounded-full bg-gray-100">
        <div
          className={`h-full ${color} transition-all duration-500`}
          style={{ width: `${pct}%` }}
        />
      </div>
    </div>
  );
}
