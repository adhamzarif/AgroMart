import React from 'react';
import { useLang } from '../../context/LangContext.jsx';

// Helper for converting numbers to Bangla digits
const toBnNum = (num) => {
  if (num === null || num === undefined) return '';
  const bnDigits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
  return String(num).replace(/\d/g, (digit) => bnDigits[digit]);
};

export default function ProductCard({ crop, onSelect }) {
  const { lang } = useLang();

  // Translations & Fallbacks
  const cropName = lang === 'bn' 
    ? (crop.crop_name_bn || crop.crop_name || crop.name) 
    : (crop.crop_name_en || crop.crop_name || crop.name);

  const categoryName = lang === 'bn'
    ? (crop.category_name_bn || crop.category_name || crop.category || 'খাদ্যশস্য')
    : (crop.category_name_en || crop.category_name || crop.category || 'Grains');

  const farmerName = lang === 'bn'
    ? (crop.farmer_name_bn || crop.farmer_name || 'আব্দুল হালিম')
    : (crop.farmer_name_en || crop.farmer_name || 'Abdul Halim');

  const districtName = lang === 'bn'
    ? (crop.district_name_bn || crop.district_name || 'রাঙ্গামাটি')
    : (crop.district_name_en || crop.district_name || 'Rangamati');

  // 1. Dynamic Unit Name
  const rawUnit = crop.unit_en || crop.unit || 'piece';
  const unitName = lang === 'bn'
    ? (crop.unit_bn || (rawUnit === 'kg' ? 'কেজি' : rawUnit === 'piece' ? 'টি' : rawUnit))
    : rawUnit;

  // 2. Dynamic Price Digits
  const rawPrice = Number(crop.price_per_unit ?? crop.price ?? 0).toFixed(2);
  const formattedPrice = lang === 'bn' ? toBnNum(rawPrice) : rawPrice;

  const imageUrl = crop.image_url || crop.image || (Array.isArray(crop.images) ? crop.images[0] : '');

  return (
    <div className="group relative flex flex-col justify-between overflow-hidden rounded-2xl border border-gray-100 bg-white p-4 shadow-sm transition-all hover:shadow-md">
      <div>
        {/* Image & Badge */}
        <div className="relative mb-3 h-48 w-full overflow-hidden rounded-xl bg-gray-100">
          {imageUrl ? (
            <img
              src={imageUrl}
              alt={cropName}
              className="h-full w-full object-cover transition-transform duration-300 group-hover:scale-105"
            />
          ) : (
            <div className="flex h-full items-center justify-center text-4xl">🌾</div>
          )}

          <span className="absolute top-2 right-2 rounded-full bg-white/90 px-2.5 py-0.5 text-xs font-semibold text-gray-700 shadow-sm backdrop-blur-sm">
            ★ {lang === 'bn' ? 'নতুন' : 'New'}
          </span>
        </div>

        {/* Category Pill */}
        <div className="mb-2">
          <span className="inline-block rounded-md bg-emerald-50 px-2.5 py-1 text-xs font-medium text-emerald-700">
            {categoryName}
          </span>
        </div>

        {/* Title */}
        <h3 className="text-lg font-bold text-gray-900">{cropName}</h3>

        {/* Farmer Info */}
        <div className="mt-1 space-y-0.5 text-xs text-gray-500">
          <p className="flex items-center gap-1">👤 {farmerName}</p>
          <p className="flex items-center gap-1">📍 {districtName}</p>
        </div>
      </div>

      {/* Price & Details Button */}
      <div className="mt-4 flex items-end justify-between border-t border-gray-50 pt-3">
        <div>
          <div className="flex items-baseline gap-1">
            <span className="text-xl font-extrabold text-emerald-600">৳{formattedPrice}</span>
          </div>
          <span className="text-xs text-gray-400">
            {lang === 'bn' ? `প্রতি ${unitName}` : `per ${unitName}`}
          </span>
        </div>

        {/* 3. Translated Details Button */}
        <button
          type="button"
          onClick={onSelect}
          className="rounded-xl bg-emerald-800 px-4 py-2 text-sm font-semibold text-white transition hover:bg-emerald-900 shadow-sm active:scale-95 cursor-pointer"
        >
          {lang === 'bn' ? 'বিস্তারিত' : 'Details'}
        </button>
      </div>
    </div>
  );
}