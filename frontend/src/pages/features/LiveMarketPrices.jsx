// LiveMarketPrices.jsx — deep-dive page for the "Live market prices" feature.
import { Link } from 'react-router-dom';
import { useLang } from '../../context/LangContext.jsx';

const HERO_IMG = 'https://images.unsplash.com/photo-1573246123716-6b1782bfc499?w=1600';

export default function LiveMarketPrices() {
  const { t } = useLang();

  const benefits = [
    { icon: '📊', title: 'lmp_benefit1_title', desc: 'lmp_benefit1_desc',
      img: 'https://images.unsplash.com/photo-1542838132-92c53300491e?w=600' },
    { icon: '🗺️', title: 'lmp_benefit2_title', desc: 'lmp_benefit2_desc', to: '/prices/compare',
      img: 'https://images.unsplash.com/photo-1488459716781-31db52582fe9?w=600' },
    { icon: '📉', title: 'lmp_benefit3_title', desc: 'lmp_benefit3_desc', to: '/prices/history',
      img: 'https://images.unsplash.com/photo-1464226184884-fa280b87c399?w=600' },
    { icon: '🔔', title: 'lmp_benefit4_title', desc: 'lmp_benefit4_desc',
      img: '/crops/tomato.jpg' },
  ];

  const steps = [
    { n: 1, title: 'lmp_step1_title', desc: 'lmp_step1_desc' },
    { n: 2, title: 'lmp_step2_title', desc: 'lmp_step2_desc' },
    { n: 3, title: 'lmp_step3_title', desc: 'lmp_step3_desc' },
    { n: 4, title: 'lmp_step4_title', desc: 'lmp_step4_desc' },
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
          📈
        </div>
        <h1 className="text-4xl font-bold text-white sm:text-5xl font-display drop-shadow">
          {t('lmp_hero_title')}
        </h1>
        <p className="mx-auto mt-4 max-w-2xl text-lg text-white/90">
          {t('lmp_hero_sub')}
        </p>
        <div className="mt-8 flex justify-center gap-3">
          <Link to="/prices/compare" className="rounded-full bg-m1 px-6 py-3 text-sm font-semibold text-white hover:bg-m1-dark">
            {t('lmp_cta_view')}
          </Link>
          <Link to="/register" className="rounded-full border border-white/40 px-6 py-3 text-sm font-semibold text-white hover:bg-white hover:text-m1">
            {t('lmp_cta_start')}
          </Link>
        </div>
        </div>
      </section>
      {/* Benefits */}
      <section className="bg-gray-50 py-14">
        <div className="mx-auto max-w-6xl px-6">
          <h2 className="mb-10 text-center text-2xl font-bold text-gray-900 font-display">
            {t('lmp_benefits_title')}
          </h2>
          <div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-4">
            {benefits.map((b) => {
              const inner = (
                <>
                  <div className="relative h-32 overflow-hidden">
                    <img src={b.img} alt="" className="h-full w-full object-cover" />
                    <div className="absolute left-3 top-3 grid h-9 w-9 place-items-center rounded-lg bg-white/90 text-lg shadow-sm backdrop-blur">
                      {b.icon}
                    </div>
                  </div>
                  <div className="p-6">
                    <h3 className="mb-2 font-bold text-gray-900">{t(b.title)}</h3>
                    <p className="text-sm text-gray-600">{t(b.desc)}</p>
                    {b.to && (
                      <span className="mt-3 inline-block text-sm font-semibold text-m1">
                        {t('feat_learn_more')} →
                      </span>
                    )}
                  </div>
                </>
              );
              const cls = 'block overflow-hidden rounded-xl bg-white shadow-sm transition ' + (b.to ? 'hover:-translate-y-1 hover:shadow-md' : '');
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
