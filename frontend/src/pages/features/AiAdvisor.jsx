// AiAdvisor.jsx — deep-dive page for the "AI advisor" feature.
import { Link } from 'react-router-dom';
import { useLang } from '../../context/LangContext.jsx';

const HERO_IMG = 'https://images.unsplash.com/photo-1620712943543-bcc4688e7485?w=1600';

export default function AiAdvisor() {
  const { t } = useLang();

  const benefits = [
    { icon: '🌱', title: 'ai_benefit1_title', desc: 'ai_benefit1_desc' },
    { icon: '🔬', title: 'ai_benefit2_title', desc: 'ai_benefit2_desc' },
    { icon: '💹', title: 'ai_benefit3_title', desc: 'ai_benefit3_desc' },
    { icon: '💬', title: 'ai_benefit4_title', desc: 'ai_benefit4_desc' },
  ];

  const steps = [
    { n: 1, title: 'ai_step1_title', desc: 'ai_step1_desc' },
    { n: 2, title: 'ai_step2_title', desc: 'ai_step2_desc' },
    { n: 3, title: 'ai_step3_title', desc: 'ai_step3_desc' },
    { n: 4, title: 'ai_step4_title', desc: 'ai_step4_desc' },
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
          🤖
        </div>
        <h1 className="text-4xl font-bold text-white sm:text-5xl font-display drop-shadow">
          {t('ai_hero_title')}
        </h1>
        <p className="mx-auto mt-4 max-w-2xl text-lg text-white/90">
          {t('ai_hero_sub')}
        </p>
        <div className="mt-8 flex justify-center gap-3">
          <Link to="/register" className="rounded-full bg-m1 px-6 py-3 text-sm font-semibold text-white hover:bg-m1-dark">
            {t('ai_cta_start')}
          </Link>
          <Link to="/features" className="rounded-full border border-white/40 px-6 py-3 text-sm font-semibold text-white hover:bg-white hover:text-m1">
            {t('ai_cta_more')}
          </Link>
        </div>
        </div>
      </section>

      {/* Benefits */}
      <section className="bg-gray-50 py-14">
        <div className="mx-auto max-w-6xl px-6">
          <h2 className="mb-10 text-center text-2xl font-bold text-gray-900 font-display">
            {t('ai_benefits_title')}
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
          {t('ai_how_title')}
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
          <h2 className="mb-3 text-2xl font-bold font-display">{t('ai_cta_title')}</h2>
          <p className="mb-6 text-white/85">{t('ai_cta_sub')}</p>
          <Link to="/register" className="inline-block rounded-full bg-white px-6 py-3 text-sm font-semibold text-m1 hover:bg-gray-100">
            {t('ai_cta_start')}
          </Link>
        </div>
      </section>
    </div>
  );
}
