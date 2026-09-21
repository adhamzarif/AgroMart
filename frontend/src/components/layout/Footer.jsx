// Footer.jsx — site footer with brand, quick links, and copyright.
import { Link } from 'react-router-dom';
import { useLang } from '../../context/LangContext.jsx';

export default function Footer() {
  const { t, lang } = useLang(); 
  const year = new Date().getFullYear();

  const getText = (key, bnText, enText) => {
    const translation = t(key);
    if (!translation || translation === key) {
      return lang === 'en' ? enText : bnText;
    }
    return translation;
  };

  return (
    <footer className="bg-m1-dark text-white/80">
      <div className="mx-auto grid max-w-6xl gap-8 px-6 py-12 sm:grid-cols-4">
        {/* Brand */}
        <div>
          <div className="flex items-center gap-2">
            <span className="grid h-8 w-8 place-items-center rounded-lg bg-white text-m1 font-bold">
              A
            </span>
            <span className="text-lg font-bold font-display text-white">{t('brand')}</span>
          </div>
          <p className="mt-3 text-sm leading-relaxed text-white/70">{t('footer_tagline')}</p>
        </div>

        {/* Quick links */}
        <div>
          <h4 className="mb-3 font-semibold text-white">{t('footer_links')}</h4>
          <ul className="space-y-2 text-sm">
            <li><Link to="/marketplace" className="hover:text-white">{t('nav_marketplace')}</Link></li>
            <li><Link to="/prices" className="hover:text-white">{t('nav_prices')}</Link></li>
            <li><Link to="/how-it-works" className="hover:text-white">{t('nav_how')}</Link></li>
            <li><Link to="/features" className="hover:text-white">{getText('nav_features', 'ফিচারসমূহ', 'Features')}</Link></li>
          </ul>
        </div>
        

        {/* Support */}
        <div>
          <h4 className="mb-3 font-semibold text-white">{t('footer_contact')}</h4>
          <ul className="space-y-2 text-sm">
            <li><Link to="/help-center" className="hover:text-white">{getText('footer_help', 'হেল্প সেন্টার', 'Help Center')}</Link></li>
            <li><Link to="/farmer-guide" className="hover:text-white">{getText('footer_guide', 'কৃষক নির্দেশিকা', 'Farmer Guide')}</Link></li>
            <li><Link to="/buyer-faq" className="hover:text-white">{getText('footer_faq', 'ক্রেতা জিজ্ঞাসা', 'Buyer FAQ')}</Link></li>
            <li><Link to="/contact" className="hover:text-white">{t('nav_contact')}</Link></li>
          </ul>
        </div>

        {/* Legal */}
        <div>
          <h4 className="mb-3 font-semibold text-white">{getText('footer_legal', 'আইনি তথ্য', 'Legal')}</h4>
          <ul className="space-y-2 text-sm">
            <li><Link to="/privacy-policy" className="hover:text-white">{getText('footer_privacy', 'গোপনীয়তা নীতি', 'Privacy Policy')}</Link></li>
            <li><Link to="/terms-of-use" className="hover:text-white">{getText('footer_terms', 'ব্যবহারের শর্তাবলী', 'Terms of Use')}</Link></li>
            <li><Link to="/refund-policy" className="hover:text-white">{getText('footer_refund', 'রিফান্ড নীতি', 'Refund Policy')}</Link></li>
            <li><Link to="/cookie-policy" className="hover:text-white">{getText('footer_cookie', 'কুকি নীতি', 'Cookie Policy')}</Link></li>
          </ul>
        </div>
      </div>

      {/* Copyright */}
      <div className="border-t border-white/10 py-4 text-center text-xs text-white/50">
        © {year} {t('brand')}. {t('footer_rights')}
      </div>
    </footer>
  );
}