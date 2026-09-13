// Footer.jsx — site footer with brand, quick links, and copyright.
import { Link } from 'react-router-dom';
import { useLang } from '../../context/LangContext.jsx';

export default function Footer() {
  const { t } = useLang();
  const year = new Date().getFullYear();
  return (
    <footer className="bg-m1-dark text-white/80">
      <div className="mx-auto grid max-w-6xl gap-8 px-6 py-12 sm:grid-cols-3">
        {/* brand */}
        <div>
          <div className="flex items-center gap-2">
            <span className="grid h-8 w-8 place-items-center rounded-lg bg-white text-m1 font-bold">
              A
            </span>
            <span className="text-lg font-bold font-display text-white">{t('brand')}</span>
          </div>
          <p className="mt-3 text-sm leading-relaxed text-white/70">{t('footer_tagline')}</p>
        </div>

        {/* quick links */}
        <div>
          <h4 className="mb-3 font-semibold text-white">{t('footer_links')}</h4>
          <ul className="space-y-2 text-sm">
            <li><Link to="/marketplace" className="hover:text-white">{t('nav_marketplace')}</Link></li>
            <li><Link to="/prices" className="hover:text-white">{t('nav_prices')}</Link></li>
            <li><Link to="/how-it-works" className="hover:text-white">{t('nav_how')}</Link></li>
            <li><Link to="/contact" className="hover:text-white">{t('nav_contact')}</Link></li>
          </ul>
        </div>

        {/* contact */}
        <div>
          <h4 className="mb-3 font-semibold text-white">{t('footer_contact')}</h4>
          <p className="text-sm text-white/70">support@agromart.com.bd</p>
        </div>
      </div>

      <div className="border-t border-white/10 py-4 text-center text-xs text-white/50">
        © {year} {t('brand')}. {t('footer_rights')}
      </div>
    </footer>
  );
}
