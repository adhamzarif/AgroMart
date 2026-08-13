// LivePrices.jsx — লাইভ দাম page with buyer/farmer dual view.
// Buyer view: shows savings, "Order now" button, cheapest first.
// Farmer view: shows price band + market gap, "List this crop" button, biggest gap first.
import { useEffect, useMemo, useState } from 'react';
import { Link } from 'react-router-dom';
import { useLang } from '../context/LangContext.jsx';
import { getLivePrices } from '../api/prices.api.js';

export default function LivePrices() {
  const { t } = useLang();
  const [role, setRole] = useState('buyer'); // 'buyer' | 'farmer'
  const [search, setSearch] = useState('');
  const [rows, setRows] = useState([]);
  const [state, setState] = useState('loading'); // loading | ready | empty | error

  // debounced fetch on role + search change
  useEffect(() => {
    let alive = true;
    setState('loading');
    const id = setTimeout(() => {
      getLivePrices({ role, q: search || undefined })
        .then((r) => {
          if (!alive) return;
          const list = r.prices || [];
          setRows(list);
          setState(list.length ? 'ready' : 'empty');
        })
        .catch(() => alive && setState('error'));
    }, 250);
    return () => { alive = false; clearTimeout(id); };
  }, [role, search]);

  return (
    <>
      {/* Header + role toggle */}
      <section className="bg-gradient-to-br from-m1-dark via-m1 to-m1-light py-12 text-center text-white">
        <div className="mx-auto max-w-4xl px-6">
          <span className="inline-flex items-center gap-2 rounded-full bg-white/15 px-4 py-1.5 text-sm backdrop-blur">
            <span className="h-2 w-2 rounded-full bg-m1-light" /> {t('lp_badge')}
          </span>
          <h1 className="mt-6 text-4xl font-bold font-display md:text-5xl">
            {role === 'buyer' ? t('lp_title_buyer') : t('lp_title_farmer')}
          </h1>
          <p className="mx-auto mt-3 max-w-xl text-white/85">
            {role === 'buyer' ? t('lp_sub_buyer') : t('lp_sub_farmer')}
          </p>

          {/* toggle pill */}
          <div className="mx-auto mt-6 inline-flex rounded-full bg-white/15 p-1 backdrop-blur">
            <RoleBtn active={role === 'buyer'}  onClick={() => setRole('buyer')}  label={t('lp_view_buyer')} />
            <RoleBtn active={role === 'farmer'} onClick={() => setRole('farmer')} label={t('lp_view_farmer')} />
          </div>
        </div>
      </section>

      {/* Search + hint */}
      <section className="mx-auto -mt-8 max-w-5xl px-6">
        <div className="rounded-xl2 bg-white p-4 shadow-3">
          <input
            type="search"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder={t('lp_search_ph')}
            className="w-full rounded-lg border border-gray-200 px-4 py-3 text-sm outline-none focus:border-m1"
          />
        </div>
      </section>

      {/* Cards */}
      <section className="mx-auto max-w-5xl px-6 py-10">
        {state === 'loading' && (
          <div className="grid gap-4">
            {Array.from({ length: 4 }).map((_, i) => (
              <div key={i} className="h-32 animate-pulse rounded-xl2 bg-gray-100" />
            ))}
          </div>
        )}
        {state === 'error' && (
          <div className="rounded-xl2 bg-danger-bg p-6 text-danger-dark">{t('lp_error')}</div>
        )}
        {state === 'empty' && (
          <div className="rounded-xl2 bg-gray-50 p-10 text-center text-gray-500">{t('lp_empty')}</div>
        )}
        {state === 'ready' && (
          <div className="grid gap-4">
            {rows.map((row) => (
              <PriceRow key={row.crop_name} row={row} role={role} />
            ))}
          </div>
        )}
      </section>
    </>
  );
}

function RoleBtn({ active, onClick, label }) {
  return (
    <button
      onClick={onClick}
      className={`rounded-full px-6 py-2 text-sm font-semibold transition ${
        active ? 'bg-white text-m1 shadow-2' : 'text-white/85 hover:text-white'
      }`}
    >
      {label}
    </button>
  );
}

function PriceRow({ row, role }) {
  const { t } = useLang();
  const img = Array.isArray(row.images) ? row.images[0] : row.images;

  const bazar = num(row.bazar_rate);
  const amMin = num(row.agromart_min);
  const amMax = num(row.agromart_max);
  const amAvg = num(row.agromart_avg);
  const savings = bazar != null && amMin != null ? bazar - amMin : null;
  const savingsPct = bazar ? Math.round((savings / bazar) * 100) : null;
  const gap = bazar != null && amMax != null ? bazar - amMax : null;

  return (
    <div className="grid grid-cols-1 items-center gap-4 rounded-xl2 bg-white p-4 shadow-2 sm:grid-cols-[80px_1fr_auto]">
      {/* image */}
      <div className="h-20 w-20 overflow-hidden rounded-xl bg-gray-100">
        {img ? <img src={img} alt={row.crop_name} className="h-full w-full object-cover" /> : <div className="grid h-full place-items-center text-3xl">🌾</div>}
      </div>

      {/* info */}
      <div className="min-w-0">
        <div className="flex items-center gap-2">
          <h3 className="truncate text-lg font-bold text-gray-900">{row.crop_name}</h3>
          {row.category_name && (
            <span className="rounded-full bg-success-bg px-2 py-0.5 text-xs font-semibold text-m1-dark">
              {row.category_name}
            </span>
          )}
          <TrendChip trend={row.trend} pct={row.trend_pct} />
        </div>

        {role === 'buyer' ? (
          <BuyerRow bazar={bazar} amMin={amMin} amCount={row.agromart_count} unit={row.unit} savings={savings} savingsPct={savingsPct} t={t} />
        ) : (
          <FarmerRow bazar={bazar} amMin={amMin} amMax={amMax} amAvg={amAvg} unit={row.unit} gap={gap} t={t} />
        )}
      </div>

      {/* CTA */}
      <div className="sm:justify-self-end">
        {role === 'buyer' ? (
          row.best_crop_id ? (
            <Link to={`/marketplace/${row.best_crop_id}`} className="inline-block rounded-full bg-m1 px-5 py-2.5 text-sm font-semibold text-white hover:bg-m1-dark">
              {t('lp_order_now')} →
            </Link>
          ) : (
            <span className="text-xs text-gray-400">{t('lp_no_listings')}</span>
          )
        ) : (
          <Link
            to={`/farmer/crops/new?crop=${encodeURIComponent(row.crop_name)}`}
            className="inline-block rounded-full bg-m1 px-5 py-2.5 text-sm font-semibold text-white hover:bg-m1-dark"
          >
            {t('lp_list_now')} →
          </Link>
        )}
      </div>
    </div>
  );
}

function BuyerRow({ bazar, amMin, amCount, unit, savings, savingsPct, t }) {
  return (
    <div className="mt-2 grid gap-1 text-sm sm:grid-cols-2">
      <div>
        <div className="text-xs uppercase tracking-wide text-gray-400">{t('lp_agromart_price')}</div>
        <div className="text-2xl font-bold text-m1 font-display">
          {amMin != null ? `৳ ${amMin.toFixed(0)}` : '—'} <span className="text-xs font-normal text-gray-500">/{unit}</span>
        </div>
        {amCount > 0 && <div className="text-xs text-gray-400">{amCount} {t('lp_listings')}</div>}
      </div>
      <div>
        <div className="text-xs uppercase tracking-wide text-gray-400">{t('lp_bazar_rate')}</div>
        <div className="text-lg text-gray-500 line-through decoration-gray-300">
          {bazar != null ? `৳ ${bazar.toFixed(0)}` : '—'}
        </div>
        {savings > 0 && (
          <div className="mt-1 inline-block rounded-full bg-success-bg px-2 py-0.5 text-xs font-semibold text-m1-dark">
            {t('lp_save')} ৳{savings.toFixed(0)} ({savingsPct}%)
          </div>
        )}
      </div>
    </div>
  );
}

function FarmerRow({ bazar, amMin, amMax, amAvg, unit, gap, t }) {
  const hasBand = amMin != null && amMax != null;
  return (
    <div className="mt-2 grid gap-1 text-sm sm:grid-cols-2">
      <div>
        <div className="text-xs uppercase tracking-wide text-gray-400">{t('lp_agromart_band')}</div>
        <div className="text-2xl font-bold text-m1 font-display">
          {hasBand ? `৳${amMin.toFixed(0)} – ৳${amMax.toFixed(0)}` : '—'}
          <span className="text-xs font-normal text-gray-500"> /{unit}</span>
        </div>
        {amAvg != null && <div className="text-xs text-gray-400">{t('lp_avg')} ৳{amAvg.toFixed(0)}</div>}
      </div>
      <div>
        <div className="text-xs uppercase tracking-wide text-gray-400">{t('lp_bazar_rate')}</div>
        <div className="text-lg font-semibold text-gray-700">
          {bazar != null ? `৳ ${bazar.toFixed(0)}` : '—'}
        </div>
        {gap > 0 && (
          <div className="mt-1 inline-block rounded-full bg-warning-bg px-2 py-0.5 text-xs font-semibold text-warning-dark">
            {t('lp_gap_room')} ৳{gap.toFixed(0)}
          </div>
        )}
      </div>
    </div>
  );
}

function TrendChip({ trend, pct }) {
  const map = {
    up:     { icon: '↑', tone: 'bg-danger-bg text-danger-dark' },
    down:   { icon: '↓', tone: 'bg-success-bg text-m1-dark' },
    stable: { icon: '→', tone: 'bg-gray-100 text-gray-500' },
  };
  const cfg = map[trend] || map.stable;
  return (
    <span className={`inline-flex items-center gap-1 rounded-full px-2 py-0.5 text-xs font-semibold ${cfg.tone}`}>
      {cfg.icon} {pct != null ? `${Math.abs(pct)}%` : ''}
    </span>
  );
}

function num(v) {
  if (v == null) return null;
  const n = Number(v);
  return Number.isFinite(n) ? n : null;
}
