import { Link } from 'react-router-dom';
import { useLang } from '../../context/LangContext.jsx';

import Card from './Card.jsx';
import Badge from './Badge.jsx';
import StarBadge from './StarBadge.jsx';

import { getStockStatus } from '../../utils/stock.js';

// Convert English numbers to Bangla digits
const toBnNum = (num) => {
  if (num === null || num === undefined) return '';

  const bnDigits = [
    '০',
    '১',
    '২',
    '৩',
    '৪',
    '৫',
    '৬',
    '৭',
    '৮',
    '৯',
  ];

  return String(num).replace(
    /\d/g,
    (digit) => bnDigits[digit]
  );
};

export default function ProductCard({
  crop,
  onQuickView,
  isFavorite = false,
  onToggleFavorite,
}) {
  const { t, lang } = useLang();

  const {
    crop_id,

    crop_name,
    crop_name_en,
    crop_name_bn,

    category_name,
    category_name_en,
    category_name_bn,

    farmer_id,
    farmer_name,
    farmer_name_en,
    farmer_name_bn,

    district_name,
    district_name_en,
    district_name_bn,

    price_per_unit,
    price,

    unit,
    unit_en,
    unit_bn,

    quantity,

    is_organic,
    is_new = false,

    images,
    image_url,
    image,

    is_demo,

    farmer_avg_rating,
    farmer_review_count,
  } = crop;

  // Crop name
  const displayName =
    lang === 'bn'
      ? crop_name_bn ||
        crop_name ||
        crop_name_en ||
        'পণ্য'
      : crop_name_en ||
        crop_name ||
        crop_name_bn ||
        'Product';

  // Category
  const displayCategory =
    lang === 'bn'
      ? category_name_bn ||
        category_name ||
        category_name_en
      : category_name_en ||
        category_name ||
        category_name_bn;

  // Farmer
  const displayFarmer =
    lang === 'bn'
      ? farmer_name_bn ||
        farmer_name ||
        farmer_name_en
      : farmer_name_en ||
        farmer_name ||
        farmer_name_bn;

  // District
  const displayDistrict =
    lang === 'bn'
      ? district_name_bn ||
        district_name ||
        district_name_en
      : district_name_en ||
        district_name ||
        district_name_bn;

  // Unit
  const rawUnit = unit_en || unit || 'piece';

  const displayUnit =
    lang === 'bn'
      ? unit_bn ||
        (rawUnit === 'kg'
          ? 'কেজি'
          : rawUnit === 'piece'
            ? 'টি'
            : rawUnit === 'ton'
              ? 'টন'
              : rawUnit)
      : rawUnit;

  // Image
  const img =
    image_url ||
    image ||
    (Array.isArray(images)
      ? images[0]
      : images);

  // Price
  const rawPrice = Number(
    price_per_unit ?? price ?? 0
  ).toFixed(2);

  const displayPrice =
    lang === 'bn'
      ? toBnNum(rawPrice)
      : rawPrice;

  // Quantity
  const displayQuantity =
    lang === 'bn'
      ? toBnNum(quantity ?? 0)
      : quantity ?? 0;

  // Stock status
  const stockStatus =
    getStockStatus(quantity);

  const stockTone =
    stockStatus === 'in'
      ? 'success'
      : stockStatus === 'low'
        ? 'warning'
        : 'danger';

  const stockLabel =
    t(`stock_${stockStatus}`);

  return (
    <Card hover className="overflow-hidden">
      {/* Product Image */}

      <div className="relative h-48 bg-gray-100">
        {img ? (
          <img
            src={img}
            alt={displayName}
            className="h-full w-full object-cover"
          />
        ) : (
          <div className="grid h-full place-items-center text-4xl text-gray-400">
            🌾
          </div>
        )}

        {/* Badges */}

        <div className="absolute right-3 top-3 flex flex-col items-end gap-2">
          {is_new && (
            <Badge tone="new">
              ★{' '}
              {lang === 'bn'
                ? 'নতুন'
                : t('badge_new')}
            </Badge>
          )}

          {is_demo && (
            <Badge tone="warning">
              DEMO
            </Badge>
          )}
        </div>

        {/* Favorite */}

        {onToggleFavorite && (
          <button
            type="button"
            onClick={() =>
              onToggleFavorite(crop_id)
            }
            aria-label={
              isFavorite
                ? t('fav_remove')
                : t('fav_add')
            }
            aria-pressed={isFavorite}
            className="absolute left-3 top-3 grid h-9 w-9 place-items-center rounded-full bg-white/90 text-lg shadow hover:bg-white"
          >
            {isFavorite ? '❤️' : '🤍'}
          </button>
        )}
      </div>

      <div className="p-5">
        {/* Category */}

        <div className="mb-3 flex flex-wrap items-center gap-2">
          {displayCategory && (
            <Badge tone="category">
              {displayCategory}
            </Badge>
          )}

          {is_organic && (
            <Badge tone="success">
              🌱 {t('badge_organic')}
            </Badge>
          )}
        </div>

        {/* Name */}

        <h3 className="text-xl font-bold text-gray-900">
          {displayName}
        </h3>

        {/* Farmer / District / Quantity */}

        <div className="mt-2 space-y-1.5 text-sm text-gray-500">
          {displayFarmer && (
            <div className="flex items-center justify-between gap-2">
              <Link
                to={
                  farmer_id
                    ? `/farmers/${farmer_id}`
                    : '#'
                }
                className="flex items-center gap-1.5 hover:text-m1"
              >
                <span>👤</span>

                {displayFarmer}
              </Link>

              <StarBadge
                rating={farmer_avg_rating}
                count={farmer_review_count}
              />
            </div>
          )}

          {displayDistrict && (
            <div className="flex items-center gap-1.5">
              <span>📍</span>

              {displayDistrict}
            </div>
          )}

          <div className="flex items-center gap-1.5">
            <span>📦</span>

            {displayQuantity}{' '}
            {displayUnit}
          </div>
        </div>

        {/* Stock */}

        <div className="mt-2">
          <Badge tone={stockTone}>
            {stockLabel}
          </Badge>
        </div>

        {/* Price */}

        <div className="mb-3 mt-3">
          <div className="text-2xl font-bold text-m1 font-display">
            ৳ {displayPrice}
          </div>

          <div className="text-xs text-gray-400">
            {lang === 'bn'
              ? `প্রতি ${displayUnit}`
              : `${t('per')} ${displayUnit}`}
          </div>
        </div>

        {/* Actions */}

        <div className="flex items-center gap-2">
          {onQuickView && (
            <button
              type="button"
              onClick={() =>
                onQuickView(crop)
              }
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