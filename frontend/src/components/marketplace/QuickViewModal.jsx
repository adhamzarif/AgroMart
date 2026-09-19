// QuickViewModal.jsx — the modal opened by a ProductCard's "Quick View" button.
// Shows a larger summary of the crop without navigating away from Marketplace.
// Closes on: the × button, clicking the dark overlay, or pressing Escape.
import { useEffect } from 'react';
import { Link } from 'react-router-dom';
import { useLang } from '../../context/LangContext.jsx';
import Badge from '../ui/Badge.jsx';
import { getStockStatus } from '../../utils/stock.js';

export default function QuickViewModal({ crop, onClose }) {
  const { t } = useLang();

  useEffect(() => {
    function onKeyDown(e) {
      if (e.key === 'Escape') onClose();
    }
    window.addEventListener('keydown', onKeyDown);
    return () => window.removeEventListener('keydown', onKeyDown);
  }, [onClose]);

  if (!crop) return null;

  const {
    crop_id,
    crop_name,
    category_name,
    farmer_name,
    district_name,
    price_per_unit,
    unit,
    quantity,
    is_organic,
    description,
    images,
    is_demo,
  } = crop;

  const img = Array.isArray(images) ? images[0] : images;
  const price = Number(price_per_unit ?? 0).toFixed(2);
  const stockStatus = getStockStatus(quantity);
  const stockTone = stockStatus === 'in' ? 'success' : stockStatus === 'low' ? 'warning' : 'danger';
  const stockLabel = t(`stock_${stockStatus}`);

  return (
    <div
      className="fixed inset-0 z-50 flex items-center justify-center bg-black/50 p-4"
      onClick={onClose}
      role="dialog"
      aria-modal="true"
      aria-label={crop_name}
    >
      <div
        className="max-h-[90vh] w-full max-w-2xl overflow-y-auto rounded-2xl bg-white shadow-5"
        onClick={(e) => e.stopPropagation()}
      >
        <div className="relative h-64 bg-gray-100 sm:h-80">
          {img ? (
            <img src={img} alt={crop_name} className="h-full w-full object-cover" />
          ) : (
            <div className="grid h-full place-items-center text-5xl text-gray-300">🌾</div>
          )}

          <button
            type="button"
            onClick={onClose}
            aria-label={t('quickview_close')}
            className="absolute right-3 top-3 grid h-9 w-9 place-items-center rounded-full bg-white/90 text-lg font-bold text-gray-700 shadow-2 hover:bg-white"
          >
            ×
          </button>

          {is_demo && (
            <span className="absolute left-3 top-3">
              <Badge tone="warning">DEMO</Badge>
            </span>
          )}
        </div>

        <div className="p-6">
          <div className="mb-3 flex flex-wrap items-center gap-2">
            {category_name && <Badge tone="category">{category_name}</Badge>}
            {is_organic && <Badge tone="success">🌱 {t('badge_organic')}</Badge>}
            <Badge tone={stockTone}>{stockLabel}</Badge>
          </div>

          <h2 className="text-2xl font-bold text-gray-900 font-display">{crop_name}</h2>

          <div className="mt-3 grid grid-cols-2 gap-y-2 text-sm text-gray-600 sm:grid-cols-2">
            {farmer_name && (
              <div>
                <span className="text-gray-400">{t('label_farmer')}: </span>
                {farmer_name}
              </div>
            )}
            {district_name && (
              <div>
                <span className="text-gray-400">{t('label_district')}: </span>
                {district_name}
              </div>
            )}
            <div>
              <span className="text-gray-400">{t('label_quantity')}: </span>
              {quantity ?? 0} {unit}
            </div>
            <div>
              <span className="text-gray-400">{t('badge_organic')}: </span>
              {is_organic ? t('organic_yes') : t('organic_no')}
            </div>
          </div>

          {description && (
            <div className="mt-4">
              <div className="mb-1 text-sm font-semibold text-gray-700">{t('label_description')}</div>
              <p className="text-sm text-gray-600">{description}</p>
            </div>
          )}

          <hr className="my-5 border-gray-100" />

          <div className="flex items-center justify-between gap-4">
            <div>
              <div className="text-2xl font-bold text-m1 font-display">৳ {price}</div>
              <div className="text-xs text-gray-400">
                {t('per')} {unit}
              </div>
            </div>

            <Link
              to={`/marketplace/${crop_id}`}
              onClick={onClose}
              className="rounded-full bg-m1 px-6 py-3 text-sm font-semibold text-white hover:bg-m1-dark"
            >
              {t('view_full_details')}
            </Link>
          </div>
        </div>
      </div>
    </div>
  );
}