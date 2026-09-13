// LiveMarketPrices.jsx — deep-dive page for the "Live market prices" feature.
import { Link } from 'react-router-dom';
import { useLang } from '../../context/LangContext.jsx';

export default function LiveMarketPrices() {
  const { t } = useLang();

  const benefits = [
    { icon: '📊', title: 'lmp_benefit1_title', desc: 'lmp_benefit1_desc' },
    { icon: '🗺️', title: 'lmp_benefit2_title', desc: 'lmp_benefit2_desc' },
    { icon: '📉', title: 'lmp_benefit3_title', desc: 'lmp_benefit3_desc' },
    { icon: '🔔', title: 'lmp_benefit4_title', desc: 'lmp_benefit4_desc' },
  ];

  const steps = [
    { n: 1, title: 'lmp_step1_title', desc: 'lmp_step1_desc' },
    { n: 2, title: 'lmp_step2_title', desc: 'lmp_step2_desc' },
    { n: 3, title: 'lmp_step3_title', desc: 'lmp_step3_desc' },
    { n: 4, title: 'lmp_step4_title', desc: 'lmp_step4_desc' },
  ];

  return (
    <div className="bg-white">
      {/* Breadcrumb */}
      <div className="mx-auto max-w-6xl px-6 pt-8 text-sm text-gray-500">
        <Link to="/features" className="hover:text-m1">{t('nav_features')}</Link>
        <span className="mx-2">/</span>
        <span className="text-gray-900">{t('feat_prices_title')}</span>
      </div>

      {/* Hero */}
      <section className="mx-auto max-w-6xl px-6 py-12 text-center">
        <div className="mx-auto mb-6 grid h-16 w-16 place-items-center rounded-2xl bg-green-50 text-4xl">
          📈
        </div>
        <h1 className="text-4xl font-bold text-gray-900 sm:text-5xl font-display">
          {t('lmp_hero_title')}
        </h1>
        <p className="mx-auto mt-4 max-w-2xl text-lg text-gray-600">
          {t('lmp_hero_sub')}
        </p>
        <div className="mt-8 flex justify-center gap-3">
          <Link to="/prices" className="rounded-full bg-m1 px-6 py-3 text-sm font-semibold text-white hover:bg-m1-dark">
            {t('lmp_cta_view')}
          </Link>
          <Link to="/register" className="rounded-full border border-gray-200 px-6 py-3 text-sm font-semibold text-gray-700 hover:border-m1 hover:text-m1">
            {t('lmp_cta_start')}
          </Link>
        </div>
      </section>

      {/* Benefits */}
      <section className="bg-gray-50 py-14">
        <div className="mx-auto max-w-6xl px-6">
          <h2 className="mb-10 text-center text-2xl font-bold text-gray-900 font-display">
            {t('lmp_benefits_title')}
          </h2>
          <div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-4">
            {benefits.map((b) => (
              <div key={b.title} className="rounded-xl bg-white p-6 shadow-sm">
                <div className="mb-3 text-3xl">{b.icon}</div>
                <h3 className="mb-2 font-bold text-gray-900">{t(b.title)}</h3>
                <p className="text-sm text-gray-600">{t(b.desc)}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Steps */}
      <section className="mx-auto max-w-4xl px-6 py-16">
        <h2 className="mb-12 text-center text-2xl font-bold text-gray-900 font-display">
          {t('lmp_how_title')}
        </h2>
        <div className="space-y-6">
          {steps.map((s) => (
            <div key={s.n} className="flex gap-5 rounded-xl border border-gray-100 bg-white p-6 shadow-sm">
              <div className="grid h-12 w-12 flex-shrink-0 place-items-center rounded-full bg-m1 text-lg font-bold text-white">
                {s.n}
              </div>
              <div>
                <h3 className="mb-1 text-lg font-bold text-gray-900">{t(s.title)}</h3>
                <p className="text-gray-600">{t(s.desc)}</p>
              </div>
            </div>
          ))}
        </div>
      </section>

      {/* Bottom CTA */}
      <section className="bg-m1 py-14 text-center text-white">
        <div className="mx-auto max-w-2xl px-6">
          <h2 className="mb-3 text-2xl font-bold font-display">{t('lmp_cta_title')}</h2>
          <p className="mb-6 text-white/85">{t('lmp_cta_sub')}</p>
          <Link to="/prices" className="inline-block rounded-full bg-white px-6 py-3 text-sm font-semibold text-m1 hover:bg-gray-100">
            {t('lmp_cta_view')}
          </Link>
        </div>
      </section>
    </div>
  );
}
