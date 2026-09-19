// ProductDetails.jsx — /marketplace/:cropId
// Reuses the existing GET /api/crops/:id endpoint (crop.model.js getCropById
// already joins category/farmer/district, so no backend changes were needed
// here) and the same UI primitives (Card, Badge) and favorites hook used on
// the Marketplace grid.
import { useEffect, useState } from 'react';
import { Link, useParams } from 'react-router-dom';
import { useLang } from '../context/LangContext.jsx';
import { getCrop } from '../api/crops.api.js';
import Card from '../components/ui/Card.jsx';
import Badge from '../components/ui/Badge.jsx';
import { useFavorites } from '../hooks/useFavorites.js';
import { getStockStatus } from '../utils/stock.js';

export default function ProductDetails() {
  const { cropId } = useParams();
  const { t } = useLang();
  const { isFavorite, toggleFavorite } = useFavorites();

  const [crop, setCrop] = useState(null);
  const [state, setState] = useState('loading'); // loading | ready | error

  useEffect(() => {
    let alive = true;
    setState('loading');

    getCrop(cropId)
      .then((res) => {
        if (!alive) return;
        // Support either { crop: {...} } or a bare crop object, depending on
        // how the controller shapes the response.
        setCrop(res.crop || res);
        setState('ready');
      })
      .catch(() => {
        if (!alive) return;
        setState('error');
      });

    return () => {
      alive = false;
    };
  }, [cropId]);

  if (state === 'loading') {
    return (
      <section className="mx-auto max-w-5xl px-6 py-10">
        <div className="grid gap-8 md:grid-cols-2">
          <div className="h-96 animate-pulse rounded-xl2 bg-gray-100" />
          <div className="space-y-3">
            <div className="h-8 w-2/3 animate-pulse rounded bg-gray-100" />
            <div className="h-4 w-1/3 animate-pulse rounded bg-gray-100" />
            <div className="h-24 animate-pulse rounded bg-gray-100" />
          </div>
        </div>
      </section>
    );
  }

  if (state === 'error' || !crop) {
    return (
      <section className="mx-auto max-w-3xl px-6 py-16 text-center">
        <div className="mb-2 text-3xl">🌾</div>
        <h1 className="text-xl font-bold text-gray-800">{t('product_details_not_found')}</h1>
        <p className="mt-1 text-sm text-gray-500">{t('product_not_found_sub')}</p>
        <Link
          to="/marketplace"
          className="mt-6 inline-block rounded-full bg-m1 px-6 py-3 text-sm font-semibold text-white hover:bg-m1-dark"
        >
          {t('product_details_back')}
        </Link>
      </section>
    );
  }

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

  const imageList = Array.isArray(images) ? images : images ? [images] : [];
  const price = Number(price_per_unit ?? 0).toFixed(2);
  const stockStatus = getStockStatus(quantity);
  const stockTone = stockStatus === 'in' ? 'success' : stockStatus === 'low' ? 'warning' : 'danger';
  const favorite = isFavorite(crop_id);

  return (
    <section className="mx-auto max-w-5xl px-6 py-10">
      <Link to="/marketplace" className="mb-6 inline-block text-sm font-semibold text-m1 hover:underline">
        {t('product_details_back')}
      </Link>

      <div className="grid gap-8 md:grid-cols-2">
        {/* Images */}
        <div>
          <Card className="relative h-96 overflow-hidden">
            {imageList[0] ? (
              <img src={imageList[0]} alt={crop_name} className="h-full w-full object-cover" />
            ) : (
              <div className="grid h-full place-items-center text-6xl text-gray-300">🌾</div>
            )}
            {is_demo && (
              <span className="absolute left-3 top-3">
                <Badge tone="warning">DEMO</Badge>
              </span>
            )}
          </Card>

          {imageList.length > 1 && (
            <div className="mt-3 grid grid-cols-4 gap-2">
              {imageList.slice(1, 5).map((src, i) => (
                <div key={i} className="h-20 overflow-hidden rounded-lg bg-gray-100">
                  <img src={src} alt={`${crop_name} ${i + 2}`} className="h-full w-full object-cover" />
                </div>
              ))}
            </div>
          )}
        </div>

        {/* Info */}
        <div>
          <div className="mb-3 flex flex-wrap items-center gap-2">
            {category_name && <Badge tone="category">{category_name}</Badge>}
            {is_organic && <Badge tone="success">🌱 {t('badge_organic')}</Badge>}
            <Badge tone={stockTone}>{t(`stock_${stockStatus}`)}</Badge>
          </div>

          <div className="flex items-start justify-between gap-4">
            <h1 className="text-3xl font-bold text-gray-900 font-display">{crop_name}</h1>

            <button
              type="button"
              onClick={() => toggleFavorite(crop_id)}
              aria-label={favorite ? t('fav_remove') : t('fav_add')}
              aria-pressed={favorite}
              className="grid h-11 w-11 shrink-0 place-items-center rounded-full border border-gray-200 text-xl hover:bg-gray-50"
            >
              {favorite ? '❤️' : '🤍'}
            </button>
          </div>

          <div className="mt-4 space-y-2 text-sm text-gray-600">
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
            <div className="mt-6">
              <h2 className="mb-2 text-sm font-semibold text-gray-700">{t('label_description')}</h2>
              <p className="text-sm leading-relaxed text-gray-600">{description}</p>
            </div>
          )}

          <hr className="my-6 border-gray-100" />

          <div className="flex items-end justify-between">
            <div>
              <div className="text-3xl font-bold text-m1 font-display">৳ {price}</div>
              <div className="text-xs text-gray-400">
                {t('per')} {unit}
              </div>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}