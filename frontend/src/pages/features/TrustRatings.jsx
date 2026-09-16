// TrustRatings.jsx — marketing page for the Trust & Ratings feature.
import { Link } from 'react-router-dom';
import { useLang } from '../../context/LangContext.jsx';

const HERO_IMG = 'https://images.unsplash.com/photo-1556155092-490a1ba16284?w=1600';

export default function TrustRatings() {
  const { t } = useLang();

  const pillars = [
    { icon: '✓', title: 'tr_pillar1_title', desc: 'tr_pillar1_desc' },
    { icon: '⭐', title: 'tr_pillar2_title', desc: 'tr_pillar2_desc' },
    { icon: '🛡️', title: 'tr_pillar3_title', desc: 'tr_pillar3_desc' },
    { icon: '🔒', title: 'tr_pillar4_title', desc: 'tr_pillar4_desc' },
  ];

  const steps = [
    { n: 1, title: 'tr_step1_title', desc: 'tr_step1_desc' },
    { n: 2, title: 'tr_step2_title', desc: 'tr_step2_desc' },
    { n: 3, title: 'tr_step3_title', desc: 'tr_step3_desc' },
    { n: 4, title: 'tr_step4_title', desc: 'tr_step4_desc' },
  ];

  return (
    <div className="bg-white">
      {/* Hero */}
      <section
        className="relative overflow-hidden px-6 py-24 text-center text-white"
        style={{
          backgroundImage: `linear-gradient(rgba(15,42,30,0.75), rgba(15,42,30,0.7)), url(${HERO_IMG})`,
          backgroundSize: 'cover',
          backgroundPosition: 'center',
        }}
      >
        <div className="mx-auto max-w-6xl">
          <div className="mx-auto mb-6 grid h-16 w-16 place-items-center rounded-2xl bg-white/20 backdrop-blur text-4xl">
            ⭐
          </div>
          <h1 className="text-4xl font-bold text-white sm:text-5xl font-display drop-shadow">
            {t('tr_hero_title')}
          </h1>
          <p className="mx-auto mt-4 max-w-2xl text-lg text-white/90">
            {t('tr_hero_sub')}
          </p>
          <div className="mt-8 flex justify-center gap-3">
            <Link to="/marketplace" className="rounded-full bg-m1 px-6 py-3 text-sm font-semibold text-white hover:bg-m1-dark">
              {t('tr_cta_explore')}
            </Link>
            <Link to="/farmers/1" className="rounded-full border border-white/40 px-6 py-3 text-sm font-semibold text-white hover:bg-white hover:text-m1">
              {t('tr_cta_sample')}
            </Link>
          </div>
        </div>
      </section>

      {/* Pillars */}
      <section className="bg-gray-50 py-14">
        <div className="mx-auto max-w-6xl px-6">
          <h2 className="mb-10 text-center text-2xl font-bold text-gray-900 font-display">
            {t('tr_pillars_title')}
          </h2>
          <div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-4">
            {pillars.map((p) => (
              <div key={p.title} className="rounded-xl bg-white p-6 shadow-sm">
                <div className="mb-3 grid h-11 w-11 place-items-center rounded-lg bg-green-50 text-2xl text-m1">
                  {p.icon}
                </div>
                <h3 className="mb-2 font-bold text-gray-900">{t(p.title)}</h3>
                <p className="text-sm text-gray-600">{t(p.desc)}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Steps */}
      <section className="mx-auto max-w-4xl px-6 py-16">
        <h2 className="mb-12 text-center text-2xl font-bold text-gray-900 font-display">
          {t('tr_how_title')}
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
          <h2 className="mb-3 text-2xl font-bold font-display">{t('tr_cta_title')}</h2>
          <p className="mb-6 text-white/85">{t('tr_cta_sub')}</p>
          <Link to="/marketplace" className="inline-block rounded-full bg-white px-6 py-3 text-sm font-semibold text-m1 hover:bg-gray-100">
            {t('tr_cta_explore')}
          </Link>
        </div>
      </section>
    </div>
  );
}
