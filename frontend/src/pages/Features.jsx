import { Link } from 'react-router-dom';
import { useLang } from '../context/LangContext.jsx';

const FEATURES = [
  {
    icon: '🛒',
    title: 'feat_market_title',
    desc: 'feat_market_desc',
    to: '/features/direct-sales',
    img: 'https://images.unsplash.com/photo-1488459716781-31db52582fe9?w=800',
  },
  {
    icon: '📈',
    title: 'feat_prices_title',
    desc: 'feat_prices_desc',
    to: '/features/live-prices',
    img: 'https://images.unsplash.com/photo-1573246123716-6b1782bfc499?w=800',
  },
  {
    icon: '🌦️',
    title: 'feat_weather_title',
    desc: 'feat_weather_desc',
    to: '/features/weather-alerts',
    img: 'https://images.unsplash.com/photo-1561553873-e8491a564fd0?w=800',
  },
  {
    icon: '💳',
    title: 'feat_payments_title',
    desc: 'feat_payments_desc',
    to: '/features/secure-payments',
    img: 'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=800',
  },
  {
    icon: '🏦',
    title: 'feat_loans_title',
    desc: 'feat_loans_desc',
    to: '/features/micro-loans',
    img: 'https://images.unsplash.com/photo-1579621970588-a35d0e7ab9b6?w=800',
  },
  {
    icon: '🤖',
    title: 'feat_ai_title',
    desc: 'feat_ai_desc',
    to: '/features/ai-advisor',
    img: 'https://images.unsplash.com/photo-1620712943543-bcc4688e7485?w=800',
  },
];

function Card({ f, t }) {
  const inner = (
    <>
      {/* Photo with icon badge */}
      <div className="relative h-40 overflow-hidden">
        <img src={f.img} alt="" className="h-full w-full object-cover" />
        <div className="absolute left-4 top-4 grid h-10 w-10 place-items-center rounded-lg bg-white/90 text-xl shadow-sm backdrop-blur">
          {f.icon}
        </div>
      </div>
      {/* Body */}
      <div className="p-6">
        <h3 className="mb-2 text-lg font-bold text-gray-900">{t(f.title)}</h3>
        <p className="text-sm leading-relaxed text-gray-600">{t(f.desc)}</p>
        {f.to && (
          <span className="mt-4 inline-block text-sm font-semibold text-m1">
            {t('feat_learn_more')} →
          </span>
        )}
      </div>
    </>
  );

  const className =
    'block overflow-hidden rounded-xl border border-gray-100 bg-white shadow-sm transition hover:-translate-y-1 hover:shadow-md';

  return f.to ? (
    <Link to={f.to} className={className}>{inner}</Link>
  ) : (
    <div className={className}>{inner}</div>
  );
}

export default function Features() {
  const { t } = useLang();
  return (
    <section className="mx-auto max-w-6xl px-6 py-14">
      <div className="mb-12 text-center">
        <h1 className="mt-4 text-3xl font-bold text-gray-900 sm:text-4xl font-display">
          {t('feat_title')}
        </h1>
        <p className="mx-auto mt-3 max-w-2xl text-gray-500">{t('feat_sub')}</p>
      </div>
      <div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
        {FEATURES.map((f) => <Card key={f.title} f={f} t={t} />)}
      </div>
    </section>
  );
}
