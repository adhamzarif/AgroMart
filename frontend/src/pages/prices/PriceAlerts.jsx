// PriceAlerts.jsx — create + manage price alerts.
import { useEffect, useState } from 'react';
import { useLang } from '../../context/LangContext.jsx';
import { api } from '../../api/client.js';

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
const HERO_IMG = 'https://images.unsplash.com/photo-1611974789855-9c2a0a7236a3?w=1600';

export default function PriceAlerts() {
  const { t, lang } = useLang();
  const [alerts, setAlerts]         = useState([]);
  const [crops, setCrops]           = useState([]);
  const [districts, setDistricts]   = useState([]);
  const [loading, setLoading]       = useState(true);
  const [saving, setSaving]         = useState(false);
  const [form, setForm] = useState({
    crop_name: '',
    district_id: '',
    direction: 'above',
    target_price: '',
  });

  const cropLabel = (c) => (lang === 'en' ? (CROP_EN[c] || c) : c);
  const dName = (n) => (lang === 'en' ? n : (DISTRICT_BN[n] || n));
  const fmt = (n) => {
    if (n === null || n === undefined) return '';
    const s = String(n);
    return lang === 'bn' ? s.replace(/\d/g, (d) => BN_DIGITS[+d]) : s;
  };

  async function load() {
    setLoading(true);
    try {
      const [a, c, cmp] = await Promise.all([
        api.get('/api/alerts'),
        api.get('/api/prices/crops'),
        api.get('/api/prices/compare?crop=লাউ'),
      ]);
      setAlerts(a.alerts || []);
      const cropList = c.crops || [];
      setCrops(cropList);
      setDistricts(cmp.districts ? cmp.districts.slice(0, 9)
        : (a.alerts || [])
            .map(x => ({ district_id: x.district_id, district_name: x.district_name }))
            .filter(d => d.district_id));
      if (cropList.length && !form.crop_name) {
        setForm(f => ({ ...f, crop_name: cropList[0] }));
      }
    } finally {
      setLoading(false);
    }
  }

  useEffect(() => { load(); }, []);

  // fetch districts properly (from Compare's response we already got them, but be safe)
  useEffect(() => {
    if (districts.length === 0) {
      // Fallback: derive from CROP names hitting compare endpoint
      api.get('/api/prices/compare?crop=লাউ').then(r => {
        if (r.districts) setDistricts(r.districts);
      });
    }
  }, [districts.length]);

  async function submit(e) {
    e.preventDefault();
    if (!form.crop_name || !form.target_price) return;
    setSaving(true);
    try {
      await api.post('/api/alerts', {
        crop_name: form.crop_name,
        district_id: form.district_id ? Number(form.district_id) : null,
        direction: form.direction,
        target_price: Number(form.target_price),
      });
      setForm(f => ({ ...f, target_price: '' }));
      await load();
    } finally {
      setSaving(false);
    }
  }

  async function toggle(id, is_active) {
    await api.patch(`/api/alerts/${id}`, { is_active: !is_active });
    await load();
  }

  async function remove(id) {
    await api.delete(`/api/alerts/${id}`);
    await load();
  }

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
            🔔 {t('pa_title')}
          </h1>
          <p className="mt-3 max-w-2xl text-lg text-white/85">{t('pa_sub')}</p>
        </div>
      </div>

      <div className="mx-auto max-w-6xl px-6 py-10">
        {/* Create alert form */}
        <div className="mb-8 rounded-2xl border border-gray-100 bg-white p-6 shadow-lg sm:p-8">
          <h2 className="mb-5 text-lg font-bold text-gray-900 font-display">
            {t('pa_create_title')}
          </h2>
          <form onSubmit={submit} className="grid gap-4 sm:grid-cols-[1fr_1fr_auto_1fr_auto] sm:items-end">
            <div>
              <label className="mb-1.5 block text-xs font-semibold uppercase tracking-wider text-gray-500">
                {t('pa_crop')}
              </label>
              <select
                value={form.crop_name}
                onChange={(e) => setForm(f => ({ ...f, crop_name: e.target.value }))}
                className="w-full rounded-lg border-2 border-gray-100 bg-white px-3 py-2.5 text-sm font-semibold text-gray-900 focus:border-m1 focus:outline-none"
              >
                {crops.map(c => <option key={c} value={c}>{cropLabel(c)}</option>)}
              </select>
            </div>

            <div>
              <label className="mb-1.5 block text-xs font-semibold uppercase tracking-wider text-gray-500">
                {t('pa_district')}
              </label>
              <select
                value={form.district_id}
                onChange={(e) => setForm(f => ({ ...f, district_id: e.target.value }))}
                className="w-full rounded-lg border-2 border-gray-100 bg-white px-3 py-2.5 text-sm font-semibold text-gray-900 focus:border-m1 focus:outline-none"
              >
                <option value="">{t('pa_any_district')}</option>
                {districts.map(d => (
                  <option key={d.district_id} value={d.district_id}>{dName(d.district_name)}</option>
                ))}
              </select>
            </div>

            {/* Direction toggle */}
            <div>
              <label className="mb-1.5 block text-xs font-semibold uppercase tracking-wider text-gray-500">
                {t('pa_when')}
              </label>
              <div className="inline-flex overflow-hidden rounded-lg border-2 border-gray-100 bg-white">
                <button
                  type="button"
                  onClick={() => setForm(f => ({ ...f, direction: 'above' }))}
                  className={
                    'px-3 py-2.5 text-xs font-bold transition ' +
                    (form.direction === 'above'
                      ? 'bg-red-500 text-white'
                      : 'text-gray-500 hover:bg-gray-50')
                  }
                >
                  ↑ {t('pa_above')}
                </button>
                <button
                  type="button"
                  onClick={() => setForm(f => ({ ...f, direction: 'below' }))}
                  className={
                    'px-3 py-2.5 text-xs font-bold transition ' +
                    (form.direction === 'below'
                      ? 'bg-green-600 text-white'
                      : 'text-gray-500 hover:bg-gray-50')
                  }
                >
                  ↓ {t('pa_below')}
                </button>
              </div>
            </div>

            <div>
              <label className="mb-1.5 block text-xs font-semibold uppercase tracking-wider text-gray-500">
                {t('pa_target')} (৳)
              </label>
              <input
                type="number"
                min="1"
                step="0.01"
                value={form.target_price}
                onChange={(e) => setForm(f => ({ ...f, target_price: e.target.value }))}
                placeholder="100.00"
                className="w-full rounded-lg border-2 border-gray-100 bg-white px-3 py-2.5 text-sm font-semibold text-gray-900 focus:border-m1 focus:outline-none"
              />
            </div>

            <button
              type="submit"
              disabled={saving}
              className="rounded-lg bg-m1 px-5 py-2.5 text-sm font-bold text-white shadow transition hover:bg-m1-dark disabled:opacity-50"
            >
              {saving ? t('pa_creating') : t('pa_create')}
            </button>
          </form>
        </div>

        {/* Alerts list */}
        <div className="mb-3 flex items-baseline justify-between">
          <h2 className="text-lg font-bold text-gray-900 font-display">
            {t('pa_your_alerts')}
          </h2>
          <span className="text-sm text-gray-500">
            {fmt(alerts.length)} {t('pa_alerts_count')}
          </span>
        </div>

        {loading ? (
          <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
            {[1,2,3].map(i => <div key={i} className="h-40 animate-pulse rounded-2xl bg-gray-100" />)}
          </div>
        ) : alerts.length === 0 ? (
          <div className="rounded-2xl bg-white p-10 text-center text-gray-400 shadow-sm">
            {t('pa_empty')}
          </div>
        ) : (
          <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
            {alerts.map(a => (
              <AlertCard
                key={a.alert_id}
                a={a}
                cropLabel={cropLabel}
                dName={dName}
                fmt={fmt}
                t={t}
                onToggle={() => toggle(a.alert_id, a.is_active)}
                onDelete={() => remove(a.alert_id)}
              />
            ))}
          </div>
        )}

        <p className="mt-8 text-center text-xs text-gray-400">
          📱 {t('pa_notify_sms')} • 🔔 {t('pa_notify_app')}
        </p>
      </div>
    </div>
  );
}

function AlertCard({ a, cropLabel, dName, fmt, t, onToggle, onDelete }) {
  const triggered = a.triggered;
  const status = !a.is_active ? 'paused' : (triggered ? 'triggered' : 'watching');

  const statusStyles = {
    triggered: 'bg-green-100 text-green-800',
    watching: 'bg-blue-100 text-blue-800',
    paused: 'bg-gray-100 text-gray-500',
  };
  const statusLabel = {
    triggered: `🔔 ${t('pa_status_triggered')}`,
    watching:  `👀 ${t('pa_status_watching')}`,
    paused:    `⏸ ${t('pa_status_paused')}`,
  };

  const dirIcon = a.direction === 'above' ? '↑' : '↓';
  const dirColor = a.direction === 'above' ? 'text-red-600' : 'text-green-600';

  return (
    <div className={`relative overflow-hidden rounded-2xl border bg-white p-5 shadow-sm transition ${triggered && a.is_active ? 'border-green-300 ring-2 ring-green-100' : 'border-gray-100'}`}>
      {/* status pill */}
      <div className="mb-3 flex items-center justify-between">
        <span className={`rounded-full px-2.5 py-1 text-xs font-bold ${statusStyles[status]}`}>
          {statusLabel[status]}
        </span>
        <button
          onClick={onDelete}
          className="text-xs text-gray-400 hover:text-red-500"
          aria-label="delete"
        >
          ✕
        </button>
      </div>

      {/* crop + rule */}
      <div className="mb-4">
        <div className="text-xl font-bold text-gray-900 font-display">{cropLabel(a.crop_name)}</div>
        <div className="mt-1 text-sm text-gray-500">
          {a.district_name ? dName(a.district_name) : t('pa_any_district')}
        </div>
      </div>

      {/* rule */}
      <div className="mb-4 rounded-lg bg-gray-50 p-3">
        <div className="text-xs font-semibold uppercase tracking-wider text-gray-500">
          {t('pa_rule')}
        </div>
        <div className="mt-1 flex items-baseline gap-2">
          <span className={`text-2xl font-bold ${dirColor}`}>{dirIcon}</span>
          <span className="text-xl font-bold text-gray-900">
            ৳{fmt(Number(a.target_price).toFixed(2))}
          </span>
        </div>
      </div>

      {/* current */}
      {a.current_price !== null && (
        <div className="mb-4 text-sm">
          <span className="text-gray-500">{t('pa_current')}: </span>
          <span className={`font-bold ${triggered ? 'text-green-700' : 'text-gray-900'}`}>
            ৳{fmt(Number(a.current_price).toFixed(2))}
          </span>
        </div>
      )}

      {/* toggle */}
      <button
        onClick={onToggle}
        className={
          'w-full rounded-lg px-3 py-2 text-xs font-bold transition ' +
          (a.is_active
            ? 'bg-gray-100 text-gray-600 hover:bg-gray-200'
            : 'bg-m1 text-white hover:bg-m1-dark')
        }
      >
        {a.is_active ? t('pa_pause') : t('pa_resume')}
      </button>
    </div>
  );
}
