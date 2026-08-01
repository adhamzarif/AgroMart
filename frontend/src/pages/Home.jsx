// Home.jsx — landing page: hero (green gradient) + stat card row.
// Matches the reference screenshot; text is bilingual via useLang.
import { Link } from 'react-router-dom';
import { useLang } from '../context/LangContext.jsx';
import Button from '../components/ui/Button.jsx';
import StatCard from '../components/ui/StatCard.jsx';

export default function Home() {
  const { t } = useLang();
  return (
    <section className="relative overflow-hidden bg-gradient-to-br from-m1-dark via-m1 to-m1-light">
      {/* soft curved bottom */}
      <div className="absolute inset-x-0 bottom-0 h-16 rounded-t-[50%] bg-white/95" />

      <div className="relative mx-auto max-w-4xl px-6 pt-16 pb-28 text-center">
        {/* badge */}
        <span className="inline-flex items-center gap-2 rounded-full bg-white/15 px-4 py-1.5 text-sm text-white backdrop-blur">
          <span className="h-2 w-2 rounded-full bg-m1-light" />
          {t('hero_badge')}
        </span>

        {/* title */}
        <h1 className="mt-8 text-4xl font-bold leading-tight text-white md:text-6xl font-display">
          {t('hero_title_1')}
          <span className="text-m1-light">{t('hero_title_accent')}</span>
          <br />
          {t('hero_title_2')}
        </h1>

        {/* subtitle */}
        <p className="mx-auto mt-6 max-w-2xl text-base leading-relaxed text-white/85">
          {t('hero_sub')}
        </p>

        {/* CTAs */}
        <div className="mt-8 flex flex-wrap items-center justify-center gap-4">
          <Link to="/register">
            <Button variant="solid" className="bg-white text-m1 hover:bg-white/90">
              {t('hero_cta_start')} →
            </Button>
          </Link>
          <Link to="/how-it-works">
            <Button variant="outline">▶ {t('hero_cta_how')}</Button>
          </Link>
        </div>
      </div>

      {/* stat card floating over the curve */}
      <div className="relative mx-auto -mb-10 max-w-4xl px-6">
        <div className="grid gap-6 rounded-xl2 bg-white p-6 shadow-4 sm:grid-cols-3">
          <StatCard
            icon={<span className="text-m1">👥</span>}
            value="10k+"
            label={t('stat_farmers')}
            tint="bg-success-bg"
          />
          <StatCard
            icon={<span className="text-m3">📈</span>}
            value="32+"
            label={t('stat_prices')}
            tint="bg-warning-bg"
          />
          <StatCard
            icon={<span className="text-info">🛡️</span>}
            value="৳50M+"
            label={t('stat_txns')}
            tint="bg-info-bg"
          />
        </div>
      </div>
      <div className="h-16 bg-white" />
    </section>
  );
}
