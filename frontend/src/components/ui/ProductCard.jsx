// ProductCard.jsx — one crop tile in the marketplace grid.
// Expects a `crop` object; falls back gracefully if fields are missing.
//
// Supports: organic + stock badges, quantity/unit line, a Quick View button
// (calls onQuickView), a favorite/wishlist heart button (calls
// onToggleFavorite — see hooks/useFavorites.js), an Add to Cart button
// (calls onAddToCart — see hooks/useCart.js), bilingual crop/category/district
// names (falls back to the Bangla field when no _en value exists), and a
// farmer rating badge (StarBadge). All callbacks are optional so this card
// still works anywhere else in the app without those props.
import { Link } from 'react-router-dom';
import { useLang } from '../../context/LangContext.jsx';
import Card from './Card.jsx';
import Badge from './Badge.jsx';
import StarBadge from './StarBadge.jsx';
import { getStockStatus } from '../../utils/stock.js';

export default function ProductCard({
  crop,
  onQuickView,
  isFavorite = false,
  onToggleFavorite,
  onAddToCart,
}) {
  const { t, lang } = useLang();
  const {
    crop_id,
    crop_name,
    crop_name_en,
    category_name,
    category_name_en,
    farmer_id,
    farmer_name,
    district_name,
    district_name_en,
    price_per_unit,
    unit,
    quantity,
    is_organic,
    is_new = false,
    images,
    is_demo,
    farmer_avg_rating,
    farmer_review_count,
  } = crop;

  const displayName = lang === 'en' && crop_name_en ? crop_name_en : crop_name;
  const displayCategory = lang === 'en' && category_name_en ? category_name_en : category_name;
  const displayDistrict = lang === 'en' && district_name_en ? district_name_en : district_name;

  // images may be a JSON array (from JSONB) or a single url string
  const img = Array.isArray(images) ? images[0] : images;
  const price = Number(price_per_unit ?? 0).toFixed(2);

  const stockStatus = getStockStatus(quantity);
  const stockTone = stockStatus === 'in' ? 'success' : stockStatus === 'low' ? 'warning' : 'danger';
  const stockLabel = t(`stock_${stockStatus}`);

  return (
    <Card hover className="overflow-hidden">
      {/* image with new/demo badge + favorite button */}
      <div className="relative h-48 bg-gray-100">
        {img ? (
          <img src={img} alt={displayName} className="h-full w-full object-cover" />
        ) : (
          <div className="grid h-full place-items-center text-gray-400">🌾</div>
        )}

        <div className="absolute right-3 top-3 flex flex-col items-end gap-2">
          {is_new && <Badge tone="new">★ {t('badge_new')}</Badge>}
          {is_demo && <Badge tone="warning">DEMO</Badge>}
        </div>

        {onToggleFavorite && (
          <button
            type="button"
            onClick={() => onToggleFavorite(crop_id)}
            aria-label={isFavorite ? t('fav_remove') : t('fav_add')}
            aria-pressed={isFavorite}
            className="absolute left-3 top-3 grid h-9 w-9 place-items-center rounded-full bg-white/90 text-lg shadow-1 hover:bg-white"
          >
            {isFavorite ? '❤️' : '🤍'}
          </button>
        )}
      </div>

      <div className="p-5">
        <div className="mb-3 flex flex-wrap items-center gap-2">
          {displayCategory && <Badge tone="category">{displayCategory}</Badge>}
          {is_organic && <Badge tone="success">🌱 {t('badge_organic')}</Badge>}
        </div>

        <h3 className="text-xl font-bold text-gray-900">{displayName}</h3>

        <div className="mt-2 space-y-1.5 text-sm text-gray-500">
          {farmer_name && (
            <div className="flex items-center justify-between gap-2">
              <Link
                to={farmer_id ? `/farmers/${farmer_id}` : '#'}
                className="flex items-center gap-1.5 hover:text-m1"
              >
                <span>👤</span> {farmer_name}
              </Link>
              <StarBadge rating={farmer_avg_rating} count={farmer_review_count} />
            </div>
          )}
          {displayDistrict && (
            <div className="flex items-center gap-1.5">
              <span>📍</span> {displayDistrict}
            </div>
          )}
          <div className="flex items-center gap-1.5">
            <span>📦</span> {quantity ?? 0} {unit}
          </div>
        </div>

        <div className="mt-2">
          <Badge tone={stockTone}>{stockLabel}</Badge>
        </div>

        <hr className="my-4 border-gray-100" />

        {/* price */}
        <div className="mb-3 flex items-end justify-between">
          <div>
            <div className="text-2xl font-bold text-m1 font-display">৳ {price}</div>
            <div className="text-xs text-gray-400">{t('per')} {unit}</div>
          </div>
        </div>

        {/* add to cart — disabled once out of stock */}
        {onAddToCart && (
          <button
            type="button"
            onClick={() => onAddToCart(crop)}
            disabled={stockStatus === 'out'}
            className="mb-2 w-full rounded-lg bg-m1-dark px-4 py-2.5 text-sm font-semibold text-white hover:bg-m1 disabled:cursor-not-allowed disabled:bg-gray-300"
          >
            🛒 {stockStatus === 'out' ? t('stock_out') : t('cart_add')}
          </button>
        )}

        {/* actions: quick view + view details */}
        <div className="flex items-center gap-2">
          {onQuickView && (
            <button
              type="button"
              onClick={() => onQuickView(crop)}
              className="flex-1 rounded-lg border border-gray-300 px-4 py-2.5 text-sm font-semibold text-gray-700 hover:bg-gray-50"
            >
              {t('quickview')}
            </button>
          )}
          <Link
            to={`/marketplace/${crop_id}`}
            className="flex-1 rounded-lg bg-m1 px-4 py-2.5 text-center text-sm font-semibold text-white hover:bg-m1-dark"
          >
            {t('details')}
          </Link>
        </div>
      </div>
    </Card>
  );
}