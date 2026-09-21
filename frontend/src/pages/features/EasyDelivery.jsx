// EasyDelivery.jsx — delivery calculator + carrier options.
import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { useLang } from '../../context/LangContext.jsx';
import { api } from '../../api/client.js';

const DISTRICT_BN = {
  'Dhaka':'ঢাকা','Chittagong':'চট্টগ্রাম','Rajshahi':'রাজশাহী','Khulna':'খুলনা',
  'Sylhet':'সিলেট','Barishal':'বরিশাল','Rangpur':'রংপুর','Mymensingh':'ময়মনসিংহ','Rangamati':'রাঙ্গামাটি',
};
const BN_DIGITS = ['০','১','২','৩','৪','৫','৬','৭','৮','৯'];
const HERO_IMG = 'https://images.unsplash.com/photo-1601566027502-0aa15fb2df8f?w=1600';

const FEATURE_ICONS = {
  insured:     '🛡️',
  tracking:    '📍',
  cold_storage:'❄️',
};

export default function EasyDelivery() {
  const { t, lang } = useLang();
  const [districts, setDistricts] = useState([]);
  const [from, setFrom] = useState(9);   // default Rangamati
  const [to, setTo] = useState(1);       // default Dhaka
  const [weight, setWeight] = useState(50);
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);

  const dName = (n) => (lang === 'en' ? n : (DISTRICT_BN[n] || n));
  const fmt = (n) => {
    if (n === null || n === undefined) return '';
    const s = typeof n === 'number'
      ? n.toLocaleString('en-US', { maximumFractionDigits: 2 })
      : String(n);
    return lang === 'bn' ? s.replace(/\d/g, (d) => BN_DIGITS[+d]) : s;
  };

  useEffect(() => {
    if (!from || !to || !weight) return;
    setLoading(true);
    api.get(`/api/delivery/estimate?from=${from}&to=${to}&weight=${weight}`)
      .then((r) => {
        setData(r);
        if (r.districts && r.districts.length && districts.length === 0) {
          setDistricts(r.districts);
        }
      })
      .finally(() => setLoading(false));
  }, [from, to, weight]);

  const isSameDistrict = from === to;

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
            {t('de_title')}
          </h1>
          <p className="mt-3 max-w-2xl text-lg text-white/85">{t('de_sub')}</p>
        </div>
      </div>

      <div className="mx-auto max-w-6xl px-6 py-10">
        {/* Inputs */}
        <div className="mb-8 rounded-2xl border border-gray-100 bg-white p-6 shadow-lg sm:p-8">
          <h2 className="mb-5 text-lg font-bold text-gray-900 font-display">
            📦 {t('de_calc_title')}
          </h2>
          <div className="grid gap-6 sm:grid-cols-3">
            <div>
              <label className="mb-2 block text-xs font-semibold uppercase tracking-wider text-gray-500">
                📍 {t('de_from')}
              </label>
              <select
                value={from}
                onChange={(e) => setFrom(Number(e.target.value))}
                className="w-full rounded-xl border-2 border-gray-100 bg-white px-4 py-3 text-base font-semibold text-gray-900 focus:border-m1 focus:outline-none focus:ring-2 focus:ring-m1/20"
              >
                {districts.map((d) => (
                  <option key={d.district_id} value={d.district_id}>{dName(d.district_name)}</option>
                ))}
              </select>
            </div>

            <div>
              <label className="mb-2 block text-xs font-semibold uppercase tracking-wider text-gray-500">
                🏁 {t('de_to')}
              </label>
              <select
                value={to}
                onChange={(e) => setTo(Number(e.target.value))}
                className="w-full rounded-xl border-2 border-gray-100 bg-white px-4 py-3 text-base font-semibold text-gray-900 focus:border-m1 focus:outline-none focus:ring-2 focus:ring-m1/20"
              >
                {districts.map((d) => (
                  <option key={d.district_id} value={d.district_id}>{dName(d.district_name)}</option>
                ))}
              </select>
            </div>

            <div>
              <label className="mb-2 block text-xs font-semibold uppercase tracking-wider text-gray-500">
                ⚖ {t('de_weight')} (kg)
              </label>
              <input
                type="number"
                min="1"
                value={weight}
                onChange={(e) => setWeight(Math.max(1, Number(e.target.value) || 1))}
                className="w-full rounded-xl border-2 border-gray-100 bg-white px-4 py-3 text-base font-semibold text-gray-900 focus:border-m1 focus:outline-none focus:ring-2 focus:ring-m1/20"
              />
              {/* Quick-pick chips */}
              <div className="mt-2 flex gap-2">
                {[10, 50, 100, 500].map((q) => (
                  <button
                    key={q}
                    onClick={() => setWeight(q)}
                    className={
                      'rounded-md px-2.5 py-1 text-xs font-semibold transition ' +
                      (weight === q
                        ? 'bg-m1 text-white'
                        : 'bg-gray-100 text-gray-600 hover:bg-gray-200')
                    }
                  >
                    {fmt(q)}
                  </button>
                ))}
              </div>
            </div>
          </div>
        </div>

        {loading && (
          <div className="h-64 animate-pulse rounded-2xl bg-gray-100" />
        )}

        {!loading && data && (
          <>
            {/* Same-district hint */}
            {isSameDistrict && (
              <div className="mb-6 rounded-xl border border-amber-200 bg-amber-50 p-4 text-sm text-amber-800">
                💡 {t('de_same_district')}
              </div>
            )}

            {/* Route summary */}
            <div className="mb-8 rounded-3xl border border-blue-100 bg-gradient-to-br from-blue-50 via-sky-50 to-white p-6 shadow-sm sm:p-8">
              <div className="flex flex-wrap items-center justify-between gap-4">
                <div className="flex items-baseline gap-3">
                  <span className="text-3xl font-bold text-gray-900 font-display">
                    {dName(data.from?.district_name)}
                  </span>
                  <span className="text-2xl text-blue-500">→</span>
                  <span className="text-3xl font-bold text-gray-900 font-display">
                    {dName(data.to?.district_name)}
                  </span>
                </div>
                <div className="rounded-full bg-white px-4 py-2 text-sm font-bold text-blue-800 shadow-sm">
                  📏 {fmt(data.distance_km)} km
                </div>
              </div>
              <div className="mt-3 text-sm text-gray-500">
                {fmt(data.weight_kg)} kg • {t('de_route_hint')}
              </div>
            </div>

            {/* Carrier cards */}
            <div className="mb-8">
              <h2 className="mb-4 text-lg font-bold text-gray-900 font-display">
                🚚 {t('de_options')}
              </h2>
              <div className="grid gap-4">
                {data.carriers.map((c) => (
                  <CarrierCard
                    key={c.code}
                    carrier={c}
                    fmt={fmt}
                    t={t}
                    lang={lang}
                    etaDate={data.eta_date}
                  />
                ))}
              </div>
            </div>

            {/* CTA */}
            <div className="mb-8 rounded-2xl border border-gray-100 bg-white p-6 text-center shadow-sm sm:p-8">
              <p className="text-sm text-gray-500">{t('de_cta_hint')}</p>
              <Link
                to="/marketplace"
                className="mt-4 inline-flex items-center gap-2 rounded-full bg-m1 px-6 py-3 text-sm font-bold text-white shadow-md transition hover:scale-105 hover:bg-m1-dark"
              >
                {t('de_cta_marketplace')} →
              </Link>
            </div>

            {/* How it works */}
            <div className="rounded-3xl border border-gray-100 bg-white p-6 shadow-sm sm:p-8">
              <h2 className="mb-6 text-xl font-bold text-gray-900 font-display">
                🛠 {t('de_how_title')}
              </h2>
              <div className="grid gap-4 sm:grid-cols-4">
                <Step n={1} title={t('de_step1_title')} desc={t('de_step1_desc')} />
                <Step n={2} title={t('de_step2_title')} desc={t('de_step2_desc')} />
                <Step n={3} title={t('de_step3_title')} desc={t('de_step3_desc')} />
                <Step n={4} title={t('de_step4_title')} desc={t('de_step4_desc')} />
              </div>
            </div>

            <p className="mt-6 text-center text-xs text-gray-400">
              {t('de_disclaimer')}
            </p>
          </>
        )}
      </div>
    </div>
  );
}

function CarrierCard({ carrier, fmt, t, lang, etaDate }) {
  const eta = new Date(etaDate);
  const etaDisplay = eta.toLocaleDateString(lang === 'bn' ? 'bn-BD' : 'en-GB', {
    day: 'numeric', month: 'short', hour: '2-digit', minute: '2-digit',
  });

  const FEATURE_LABEL = {
    insured:     t('de_feat_insured'),
    tracking:    t('de_feat_tracking'),
    cold_storage:t('de_feat_cold_storage'),
  };

  return (
    <div className="relative overflow-hidden rounded-2xl border-2 border-green-100 bg-gradient-to-br from-green-50/50 to-white p-6 shadow-md">
      <div className="pointer-events-none absolute -right-8 -top-8 h-32 w-32 rounded-full bg-green-100/40 blur-2xl" />
      <div className="relative flex flex-wrap items-start justify-between gap-4">
        <div>
          <div className="flex items-center gap-3">
            <div className="grid h-14 w-14 place-items-center rounded-2xl bg-gradient-to-br from-green-500 to-emerald-600 text-3xl shadow-md">
              {carrier.icon}
            </div>
            <div>
              <div className="text-xl font-bold text-gray-900 font-display">{carrier.name}</div>
              <div className="text-sm text-gray-500">{t(carrier.tagline_key)}</div>
            </div>
          </div>

          {/* Feature badges */}
          <div className="mt-4 flex flex-wrap gap-2">
            {carrier.features.map((f) => (
              <span
                key={f}
                className="inline-flex items-center gap-1.5 rounded-full bg-white px-3 py-1 text-xs font-semibold text-gray-700 shadow-sm ring-1 ring-gray-100"
              >
                <span>{FEATURE_ICONS[f]}</span> {FEATURE_LABEL[f]}
              </span>
            ))}
          </div>
        </div>

        {/* Cost + ETA */}
        <div className="text-right">
          <div className="text-3xl font-bold text-gray-900 font-display">
            ৳{fmt(carrier.cost)}
          </div>
          <div className="text-xs text-gray-500">{t('de_total_cost')}</div>
          <div className="mt-3 rounded-full bg-green-100 px-3 py-1 text-xs font-bold text-green-800 inline-block">
            ⏱ {t('de_eta')}: {fmt(carrier.eta_hours)}h
          </div>
          <div className="mt-1 text-xs text-gray-500">{etaDisplay}</div>
        </div>
      </div>
    </div>
  );
}

function Step({ n, title, desc }) {
  return (
    <div>
      <div className="mb-2 grid h-10 w-10 place-items-center rounded-full bg-m1 text-sm font-bold text-white">
        {n}
      </div>
      <h3 className="font-bold text-gray-900">{title}</h3>
      <p className="mt-1 text-sm text-gray-600">{desc}</p>
    </div>
  );
}
