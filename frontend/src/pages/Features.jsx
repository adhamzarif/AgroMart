import { useLang } from '../context/LangContext.jsx';

const FEATURES = [
  { icon: '🛒', title: 'feat_market_title',   desc: 'feat_market_desc' },
  { icon: '📈', title: 'feat_prices_title',   desc: 'feat_prices_desc' },
  { icon: '🌦️', title: 'feat_weather_title',  desc: 'feat_weather_desc' },
  { icon: '💳', title: 'feat_payments_title', desc: 'feat_payments_desc' },
  { icon: '🏦', title: 'feat_loans_title',    desc: 'feat_loans_desc' },
  { icon: '🤖', title: 'feat_ai_title',       desc: 'feat_ai_desc' },
];

export default function Features() {
  const { t } = useLang();
  return (
    <section className="mx-auto max-w-6xl px-6 py-14">
      <div className="mb-12 text-center">
        <span className="inline-block rounded-full bg-green-50 px-4 py-1 text-xs font-semibold text-green-800">
          {t('feat_badge')}
        </span>
        <h1 className="mt-4 text-3xl font-bold text-gray-900 sm:text-4xl font-display">
          {t('feat_title')}
        </h1>
        <p className="mx-auto mt-3 max-w-2xl text-gray-500">{t('feat_sub')}</p>
      </div>
      <div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
        {FEATURES.map((f) => (
          <div
            key={f.title}
            className="rounded-xl border border-gray-100 bg-white p-6 shadow-sm transition hover:-translate-y-1 hover:shadow-md"
          >
            <div className="mb-4 grid h-12 w-12 place-items-center rounded-lg bg-green-50 text-2xl">
              {f.icon}
            </div>
            <h3 className="mb-2 text-lg font-bold text-gray-900">{t(f.title)}</h3>
            <p className="text-sm leading-relaxed text-gray-600">{t(f.desc)}</p>
          </div>
        ))}
      </div>
    </section>
  );
}
