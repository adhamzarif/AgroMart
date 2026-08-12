// HowItWorks.jsx — role-based steps + live DB stats + CTAs.
// Uses tokens/components already in your design system.
import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { useLang } from '../context/LangContext.jsx';
import { getOverviewStats } from '../api/stats.api.js';

// icons kept as emoji to stay dependency-free; swap for lucide-react later if you want
const ROLES = [
  {
    key: 'farmer',
    accent: 'm1',
    icon: '🌾',
    steps: ['step_f1', 'step_f2', 'step_f3', 'step_f4'],
  },
  {
    key: 'buyer',
    accent: 'm2',
    icon: '🛒',
    steps: ['step_b1', 'step_b2', 'step_b3', 'step_b4'],
  },
  {
    key: 'agent',
    accent: 'm3',
    icon: '🤝',
    steps: ['step_a1', 'step_a2', 'step_a3', 'step_a4'],
  },
];

export default function HowItWorks() {
  const { t } = useLang();
  const [stats, setStats] = useState(null);

  useEffect(() => {
    getOverviewStats()
      .then((r) => setStats(r.stats))
      .catch(() => setStats(null));
  }, []);

  return (
    <>
      {/* Header */}
      <section className="bg-gradient-to-br from-m1-dark via-m1 to-m1-light py-14 text-center text-white">
        <div className="mx-auto max-w-3xl px-6">
          <span className="inline-flex items-center gap-2 rounded-full bg-white/15 px-4 py-1.5 text-sm backdrop-blur">
            <span className="h-2 w-2 rounded-full bg-m1-light" />
            {t('how_badge')}
          </span>
          <h1 className="mt-6 text-4xl font-bold font-display md:text-5xl">
            {t('how_title')}
          </h1>
          <p className="mx-auto mt-4 max-w-2xl text-white/85">{t('how_sub')}</p>
        </div>
      </section>

      {/* Role columns */}
      <section className="mx-auto max-w-6xl px-6 py-16">
        <div className="grid gap-8 md:grid-cols-3">
          {ROLES.map((role) => (
            <RoleCard key={role.key} role={role} />
          ))}
        </div>
      </section>

      {/* Live stats */}
      <section className="bg-gray-50 py-14">
        <div className="mx-auto max-w-5xl px-6">
          <h2 className="mb-8 text-center text-2xl font-bold text-gray-900 font-display">
            {t('how_stats_title')}
          </h2>
          <div className="grid gap-6 sm:grid-cols-3">
            <StatTile value={fmt(stats?.farmers)} label={t('stat_farmers')} tint="bg-success-bg" icon="👥" />
            <StatTile value={fmt(stats?.crops)} label={t('stat_crops')} tint="bg-warning-bg" icon="🌾" />
            <StatTile value={fmt(stats?.districts)} label={t('stat_districts')} tint="bg-info-bg" icon="📍" />
          </div>
        </div>
      </section>

      {/* CTAs */}
      <section className="mx-auto max-w-3xl px-6 py-16 text-center">
        <h2 className="text-3xl font-bold text-gray-900 font-display">{t('how_cta_title')}</h2>
        <p className="mt-3 text-gray-500">{t('how_cta_sub')}</p>
        <div className="mt-8 flex flex-wrap justify-center gap-4">
          <Link
            to="/register"
            className="rounded-full bg-m1 px-7 py-3 font-semibold text-white shadow-3 hover:bg-m1-dark"
          >
            {t('register')} →
          </Link>
          <Link
            to="/marketplace"
            className="rounded-full border border-m1 px-7 py-3 font-semibold text-m1 hover:bg-success-bg"
          >
            {t('nav_marketplace')}
          </Link>
        </div>
      </section>
    </>
  );
}

function RoleCard({ role }) {
  const { t } = useLang();
  const border = { m1: 'border-t-m1', m2: 'border-t-m2', m3: 'border-t-m3' }[role.accent];
  const bg = { m1: 'bg-m1', m2: 'bg-m2', m3: 'bg-m3' }[role.accent];
  return (
    <div className={`rounded-xl2 border-t-4 bg-white p-6 shadow-2 ${border}`}>
      <div className={`mb-4 grid h-14 w-14 place-items-center rounded-xl2 text-2xl text-white ${bg}`}>
        {role.icon}
      </div>
      <h3 className="text-xl font-bold text-gray-900 font-display">{t(`role_${role.key}`)}</h3>
      <p className="mt-1 text-sm text-gray-500">{t(`role_${role.key}_sub`)}</p>
      <ol className="mt-5 space-y-4">
        {role.steps.map((k, i) => (
          <li key={k} className="flex gap-3">
            <span className={`grid h-7 w-7 shrink-0 place-items-center rounded-full ${bg} text-sm font-semibold text-white`}>
              {i + 1}
            </span>
            <span className="text-sm leading-relaxed text-gray-700">{t(k)}</span>
          </li>
        ))}
      </ol>
    </div>
  );
}

function StatTile({ value, label, tint, icon }) {
  return (
    <div className="rounded-xl2 bg-white p-5 text-center shadow-2">
      <div className={`mx-auto mb-3 grid h-12 w-12 place-items-center rounded-xl2 ${tint} text-xl`}>{icon}</div>
      <div className="text-3xl font-bold text-gray-900 font-display">{value}</div>
      <div className="mt-1 text-sm text-gray-500">{label}</div>
    </div>
  );
}

function fmt(n) {
  if (n == null) return '—';
  if (n >= 1000) return `${(n / 1000).toFixed(1).replace(/\.0$/, '')}k+`;
  return `${n}`;
}
