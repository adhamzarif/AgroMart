// DirectSales.jsx — deep-dive page for the "Direct sales" feature.
import { Link } from 'react-router-dom';
import { useLang } from '../../context/LangContext.jsx';

const HERO_IMG = 'https://images.unsplash.com/photo-1488459716781-31db52582fe9?w=1600';

export default function DirectSales() {
  const { t } = useLang();

  const benefits = [
    { icon: '💰', title: 'ds_benefit1_title', desc: 'ds_benefit1_desc', to: '/features/higher-margins' },
    { icon: '🤝', title: 'ds_benefit2_title', desc: 'ds_benefit2_desc', to: '/features/trust-ratings' },
    { icon: '🚚', title: 'ds_benefit3_title', desc: 'ds_benefit3_desc', to: '/features/easy-delivery' },
    { icon: '⭐', title: 'ds_benefit4_title', desc: 'ds_benefit4_desc', to: '/features/transparent-pricing' },
  ];

  const steps = [
    { n: 1, title: 'ds_step1_title', desc: 'ds_step1_desc' },
    { n: 2, title: 'ds_step2_title', desc: 'ds_step2_desc' },
    { n: 3, title: 'ds_step3_title', desc: 'ds_step3_desc' },
    { n: 4, title: 'ds_step4_title', desc: 'ds_step4_desc' },
  ];

  return (
    <div className="bg-white">
      {/* Hero with background image */}
      <section
        className="relative overflow-hidden px-6 py-24 text-center text-white"
        style={{
          backgroundImage: `linear-gradient(rgba(0,0,0,0.55), rgba(0,0,0,0.55)), url(${HERO_IMG})`,
          backgroundSize: "cover",
          backgroundPosition: "center",
        }}
      >
        <div className="mx-auto max-w-6xl">
        <div className="mx-auto mb-6 grid h-16 w-16 place-items-center rounded-2xl bg-white/20 backdrop-blur text-4xl">
          🛒
        </div>
        <h1 className="text-4xl font-bold text-white sm:text-5xl font-display drop-shadow">
          {t('ds_hero_title')}
        </h1>
        <p className="mx-auto mt-4 max-w-2xl text-lg text-white/90">
          {t('ds_hero_sub')}
        </p>
        <div className="mt-8 flex justify-center gap-3">
          <Link
            to="/register"
            className="rounded-full bg-m1 px-6 py-3 text-sm font-semibold text-white hover:bg-m1-dark"
          >
            {t('ds_cta_start')}
          </Link>
          <Link
            to="/marketplace"
            className="rounded-full border border-white/40 px-6 py-3 text-sm font-semibold text-white hover:bg-white hover:text-m1"
          >
            {t('ds_cta_browse')}
          </Link>
        </div>
        </div>
      </section>
      {/* Benefits */}
      <section className="bg-gray-50 py-14">
        <div className="mx-auto max-w-6xl px-6">
          <h2 className="mb-10 text-center text-2xl font-bold text-gray-900 font-display">
            {t('ds_benefits_title')}
          </h2>
          <div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-4">
            {benefits.map((b) => {
              const inner = (
                <>
                  <div className="mb-3 text-3xl">{b.icon}</div>
                  <h3 className="mb-2 font-bold text-gray-900">{t(b.title)}</h3>
                  <p className="text-sm text-gray-600">{t(b.desc)}</p>
                  {b.to && (
                    <span className="mt-3 inline-block text-sm font-semibold text-m1">
                      {t('feat_learn_more')} →
                    </span>
                  )}
                </>
              );
              const cls = 'block rounded-xl bg-white p-6 shadow-sm transition ' + (b.to ? 'hover:-translate-y-1 hover:shadow-md' : '');
              return b.to
                ? <Link key={b.title} to={b.to} className={cls}>{inner}</Link>
                : <div key={b.title} className={cls}>{inner}</div>;
            })}
          </div>
        </div>
      </section>

      {/* Steps */}
      <section className="mx-auto max-w-4xl px-6 py-16">
        <h2 className="mb-12 text-center text-2xl font-bold text-gray-900 font-display">
          {t('ds_how_title')}
        </h2>
        <div className="space-y-6">
          {steps.map((s) => (
            <div
              key={s.n}
              className="flex gap-5 rounded-xl border border-gray-100 bg-white p-6 shadow-sm"
            >
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
          <h2 className="mb-3 text-2xl font-bold font-display">{t('ds_cta_title')}</h2>
          <p className="mb-6 text-white/85">{t('ds_cta_sub')}</p>
          <Link
            to="/register"
            className="inline-block rounded-full bg-white px-6 py-3 text-sm font-semibold text-m1 hover:bg-gray-100"
          >
            {t('ds_cta_start')}
          </Link>
        </div>
      </section>
    </div>
  );
}
