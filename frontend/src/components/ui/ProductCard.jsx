// ProductCard.jsx — one crop card. Photo, price, farmer, district, rating, "Details" button.
import { Link } from 'react-router-dom';
import { useLang } from '../../context/LangContext.jsx';
import Card from './Card.jsx';
import Badge from './Badge.jsx';
import StarBadge from './StarBadge.jsx';

export default function ProductCard({ crop }) {
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
    images,
    is_new = true,
    farmer_avg_rating,
    farmer_review_count,
  } = crop;

  const displayName     = lang === 'en' && crop_name_en     ? crop_name_en     : crop_name;
  const displayCategory = lang === 'en' && category_name_en ? category_name_en : category_name;
  const displayDistrict = lang === 'en' && district_name_en ? district_name_en : district_name;

  const img = Array.isArray(images) ? images[0] : images;
  const price = Number(price_per_unit).toFixed(2);

  return (
    <Card hover className="overflow-hidden">
      <div className="relative h-48 bg-gray-100">
        {img ? (
          <img src={img} alt={displayName} className="h-full w-full object-cover" />
        ) : (
          <div className="grid h-full place-items-center text-gray-400">🌾</div>
        )}
        {is_new && (
          <span className="absolute right-3 top-3">
            <Badge tone="new">★ {t('badge_new')}</Badge>
          </span>
        )}
      </div>

      <div className="p-5">
        {displayCategory && (
          <Badge tone="category" className="mb-3">
            {displayCategory}
          </Badge>
        )}
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
        </div>

        <hr className="my-4 border-gray-100" />

        <div className="flex items-end justify-between">
          <div>
            <div className="text-2xl font-bold text-m1 font-display">৳ {price}</div>
            <div className="text-xs text-gray-400">
              {t('per')} {unit}
            </div>
          </div>
          <Link
            to={`/marketplace/${crop_id}`}
            className="rounded-lg bg-m1 px-5 py-2.5 text-sm font-semibold text-white hover:bg-m1-dark"
          >
            {t('details')}
          </Link>
        </div>
      </div>
    </Card>
  );
}
