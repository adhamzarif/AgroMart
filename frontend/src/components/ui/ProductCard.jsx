// ProductCard.jsx — one crop tile in the marketplace grid (matches screenshot 2).
// Expects a `crop` object; falls back gracefully if fields are missing.
import { Link } from 'react-router-dom';
import { useLang } from '../../context/LangContext.jsx';
import Card from './Card.jsx';
import Badge from './Badge.jsx';

export default function ProductCard({ crop }) {
  const { t, lang } = useLang();
  const {
    crop_id,
    crop_name,
    category_name,
    farmer_name,
    district_name,
    price_per_unit,
    unit,
    images,
    is_new = true,
  } = crop;

  // images may be a JSON array (from JSONB) or a single url string
  const img = Array.isArray(images) ? images[0] : images;
  const price = Number(price_per_unit).toFixed(2);

  return (
    <Card hover className="overflow-hidden">
      {/* image with "new" badge */}
      <div className="relative h-48 bg-gray-100">
        {img ? (
          <img src={img} alt={crop_name} className="h-full w-full object-cover" />
        ) : (
          <div className="grid h-full place-items-center text-gray-400">🌾</div>
        )}
        {is_new && (
          <span className="absolute right-3 top-3">
            <Badge tone="new">★ {t('badge_new')}</Badge>
          </span>
        )}
      </div>

      {/* body */}
      <div className="p-5">
        {category_name && (
          <Badge tone="category" className="mb-3">
            {category_name}
          </Badge>
        )}
        <h3 className="text-xl font-bold text-gray-900">{crop_name}</h3>

        <div className="mt-2 space-y-1 text-sm text-gray-500">
          {farmer_name && (
            <div className="flex items-center gap-1.5">
              <span>👤</span> {farmer_name}
            </div>
          )}
          {district_name && (
            <div className="flex items-center gap-1.5">
              <span>📍</span> {district_name}
            </div>
          )}
        </div>

        <hr className="my-4 border-gray-100" />

        {/* price + action */}
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
