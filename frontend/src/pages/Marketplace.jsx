import { useEffect, useMemo, useState } from 'react';
import { useLang } from '../context/LangContext.jsx';
import { useCart } from '../context/CartContext.jsx';
import { getCrops } from '../api/crops.api.js';
import ProductCard from '../components/ui/ProductCard.jsx';

// Helper to convert numbers to Bangla digits
const toBnNum = (num) => {
  const bnDigits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
  return String(num).replace(/\d/g, (digit) => bnDigits[digit]);
};

// Comprehensive Dynamic Fallback Dictionary
const translations = {
  // Categories
  'Grains': { en: 'Grains', bn: 'খাদ্যশস্য' },
  'Vegetables': { en: 'Vegetables', bn: 'সবজি' },
  'Fruits': { en: 'Fruits', bn: 'ফলমূল' },
  'খাদ্যশস্য': { en: 'Grains', bn: 'খাদ্যশস্য' },
  'সবজি': { en: 'Vegetables', bn: 'সবজি' },
  'ফলমূল': { en: 'Fruits', bn: 'ফলমূল' },

  // Products
  'বেগুন': { en: 'Eggplant', bn: 'বেগুন' },
  'সরিষা': { en: 'Mustard', bn: 'সরিষা' },
  'লাউ': { en: 'Bottle Gourd', bn: 'লাউ' },
  'কাঁচামরিচ': { en: 'Green Chili', bn: 'কাঁচামরিচ' },
  'মুগ ডাল': { en: 'Moong Dal', bn: 'মুগ ডাল' },
  'মসুর ডাল': { en: 'Lentil (Masoor)', bn: 'মসুর ডাল' },

  // Farmers & Locations
  'Abdul Halim': { en: 'Abdul Halim', bn: 'আব্দুল হালিম' },
  'আব্দুল হালিম': { en: 'Abdul Halim', bn: 'আব্দুল হালিম' },
  'Rangamati': { en: 'Rangamati', bn: 'রাঙ্গামাটি' },
  'রাঙ্গামাটি': { en: 'Rangamati', bn: 'রাঙ্গামাটি' },
  'Bogura': { en: 'Bogura', bn: 'বগুড়া' },
  'বগুড়া': { en: 'Bogura', bn: 'বগুড়া' }
};

export default function Marketplace() {
  const { t, lang } = useLang();
  const { addToCart, setIsCartOpen } = useCart(); // Cart Context added

  const [crops, setCrops] = useState([]);
  const [state, setState] = useState('loading');
  const [error, setError] = useState(null);

  // Filter states
  const [search, setSearch] = useState('');
  const [category, setCategory] = useState('all');
  const [minPrice, setMinPrice] = useState('');
  const [maxPrice, setMaxPrice] = useState('');
  const [organicOnly, setOrganicOnly] = useState(false);
  const [sortBy, setSortBy] = useState('default');

  // Modal State
  const [selectedCrop, setSelectedCrop] = useState(null);
  const [quantity, setQuantity] = useState(1);
  const [activeImage, setActiveImage] = useState('');

  useEffect(() => {
    let alive = true;

    getCrops({ limit: 100 })
      .then((res) => {
        if (!alive) return;
        const list = res.crops || [];
        setCrops(list);
        setState(list.length ? 'ready' : 'empty');
      })
      .catch((err) => {
        if (!alive) return;
        setError(err.message);
        setState('error');
      });

    return () => {
      alive = false;
    };
  }, []);

  // Helper for dynamic translation
  const translateVal = (value, targetLang) => {
    if (!value) return '';
    if (translations[value] && translations[value][targetLang]) {
      return translations[value][targetLang];
    }
    return value;
  };

  // Get category list
  const categories = useMemo(() => {
    const map = new Map();

    crops.forEach((crop) => {
      const id = crop.category_id;
      const rawName = crop.category_name || crop.category_name_bn || crop.category_name_en || crop.category || '';
      const name = lang === 'bn' 
        ? (crop.category_name_bn || translateVal(rawName, 'bn')) 
        : (crop.category_name_en || translateVal(rawName, 'en'));

      if (id && name) {
        map.set(String(id), name);
      }
    });

    return Array.from(map.entries());
  }, [crops, lang]);

  // Filter & Sort
  const filteredCrops = useMemo(() => {
    let result = [...crops];

    if (search.trim()) {
      const q = search.trim().toLowerCase();
      result = result.filter((crop) => {
        const bnName = String(crop.crop_name_bn || crop.crop_name || crop.name || '').toLowerCase();
        const enName = String(crop.crop_name_en || crop.crop_name || crop.name || '').toLowerCase();
        return bnName.includes(q) || enName.includes(q);
      });
    }

    if (category !== 'all') {
      result = result.filter((crop) => String(crop.category_id) === category);
    }

    if (minPrice !== '') {
      result = result.filter((crop) => Number(crop.price_per_unit ?? crop.price ?? 0) >= Number(minPrice));
    }

    if (maxPrice !== '') {
      result = result.filter((crop) => Number(crop.price_per_unit ?? crop.price ?? 0) <= Number(maxPrice));
    }

    if (organicOnly) {
      result = result.filter(
        (crop) => crop.is_organic === true || crop.is_organic === 1 || crop.is_organic === 'true'
      );
    }

    if (sortBy === 'price-low') {
      result.sort((a, b) => Number(a.price_per_unit ?? a.price ?? 0) - Number(b.price_per_unit ?? b.price ?? 0));
    } else if (sortBy === 'price-high') {
      result.sort((a, b) => Number(b.price_per_unit ?? b.price ?? 0) - Number(a.price_per_unit ?? a.price ?? 0));
    } else if (sortBy === 'name') {
      result.sort((a, b) => {
        const nameA = lang === 'bn' ? a.crop_name_bn || a.crop_name || a.name || '' : a.crop_name_en || a.crop_name || a.name || '';
        const nameB = lang === 'bn' ? b.crop_name_bn || b.crop_name || b.name || '' : b.crop_name_en || b.crop_name || b.name || '';
        return nameA.localeCompare(nameB);
      });
    }

    return result;
  }, [crops, search, category, minPrice, maxPrice, organicOnly, sortBy, lang]);

  function clearFilters() {
    setSearch('');
    setCategory('all');
    setMinPrice('');
    setMaxPrice('');
    setOrganicOnly(false);
    setSortBy('default');
  }

  const filterActive = search !== '' || category !== 'all' || minPrice !== '' || maxPrice !== '' || organicOnly || sortBy !== 'default';

  const openModal = (crop) => {
    setSelectedCrop(crop);
    setQuantity(1);

    const cropImages = Array.isArray(crop.images)
      ? crop.images
      : crop.images ? [crop.images] : [crop.image_url || crop.image];

    setActiveImage(cropImages[0] || '');
  };

  // Dynamic Resolution
  const cropImages = selectedCrop ? (
    Array.isArray(selectedCrop.images) && selectedCrop.images.length > 0
      ? selectedCrop.images
      : [selectedCrop.images || selectedCrop.image_url || selectedCrop.image].filter(Boolean)
  ) : [];

  const mainImage = activeImage || cropImages[0];
  const unitPriceNum = Number(selectedCrop?.price_per_unit ?? selectedCrop?.price ?? 0);

  const rawCropName = selectedCrop?.crop_name_bn || selectedCrop?.crop_name || selectedCrop?.name || '';
  const cropName = lang === 'bn'
    ? (selectedCrop?.crop_name_bn || translateVal(rawCropName, 'bn'))
    : (selectedCrop?.crop_name_en || translateVal(rawCropName, 'en'));

  const rawCategoryName = selectedCrop?.category_name_bn || selectedCrop?.category_name || selectedCrop?.category || '';
  const categoryName = lang === 'bn'
    ? (selectedCrop?.category_name_bn || translateVal(rawCategoryName, 'bn'))
    : (selectedCrop?.category_name_en || translateVal(rawCategoryName, 'en'));

  const rawFarmerName = selectedCrop?.farmer_name_bn || selectedCrop?.farmer_name || 'Abdul Halim';
  const farmerName = lang === 'bn'
    ? (selectedCrop?.farmer_name_bn || translateVal(rawFarmerName, 'bn'))
    : (selectedCrop?.farmer_name_en || translateVal(rawFarmerName, 'en'));

  const rawDistrictName = selectedCrop?.district_name_bn || selectedCrop?.district_name || 'Rangamati';
  const districtName = lang === 'bn'
    ? (selectedCrop?.district_name_bn || translateVal(rawDistrictName, 'bn'))
    : (selectedCrop?.district_name_en || translateVal(rawDistrictName, 'en'));

  const rawUnit = selectedCrop?.unit_en || selectedCrop?.unit || 'kg';
  const unitName = lang === 'bn'
    ? (selectedCrop?.unit_bn || (rawUnit === 'kg' ? 'কেজি' : rawUnit === 'piece' ? 'টি' : rawUnit))
    : rawUnit;

  const formatNum = (num) => (lang === 'bn' ? toBnNum(num) : num);
  const formatPrice = (price) => {
    const formatted = price.toFixed(2);
    return lang === 'bn' ? `৳${toBnNum(formatted)}` : `৳${formatted}`;
  };

  // WhatsApp Handler
  const handleWhatsAppClick = () => {
    if (!selectedCrop) return;
    const phone = selectedCrop.farmer_phone || selectedCrop.phone || '8801700000000';
    const cleanPhone = phone.replace(/[^0-9]/g, '');
    const msg = lang === 'bn'
      ? `হ্যালো! আমি ${cropName} কিনতে আগ্রহী। মূল্য: ${formatPrice(unitPriceNum)}`
      : `Hello! I am interested in buying ${cropName}. Price: ${formatPrice(unitPriceNum)}`;
    window.open(`https://wa.me/${cleanPhone}?text=${encodeURIComponent(msg)}`, '_blank');
  };

  // Cart Add Handler
  const handleAddToCartClick = () => {
    if (!selectedCrop) return;

    addToCart({
      id: selectedCrop.crop_id || selectedCrop.id,
      title: cropName,
      price: unitPriceNum,
      unit: unitName,
      image: mainImage,
      farmer: farmerName,
      quantity: quantity
    });

    setSelectedCrop(null);
    setIsCartOpen(true);
  };

  return (
    <section className="mx-auto max-w-6xl px-6 py-10">

      {/* Heading */}
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-gray-900 font-display">
          {t('nav_marketplace')}
        </h1>
        <p className="mt-1 text-sm text-gray-500">
          {t('market_subtitle')}
        </p>
      </div>

      {/* Filter Box */}
      <div className="mb-8 rounded-2xl border border-gray-200 bg-white p-5 shadow-sm">
        <div className="mb-5">
          <label className="mb-2 block text-sm font-semibold text-gray-700">
            {t('market_search')}
          </label>
          <input
            type="text"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder={t('market_search_placeholder')}
            className="w-full rounded-xl border border-gray-200 px-4 py-3 outline-none focus:border-green-500"
          />
        </div>

        <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
          <div>
            <label className="mb-2 block text-sm font-semibold text-gray-700">
              {t('market_category')}
            </label>
            <select
              value={category}
              onChange={(e) => setCategory(e.target.value)}
              className="w-full rounded-xl border border-gray-200 bg-white px-3 py-3"
            >
              <option value="all">{t('market_all_categories')}</option>
              {categories.map(([id, name]) => (
                <option key={id} value={id}>
                  {name}
                </option>
              ))}
            </select>
          </div>

          <div>
            <label className="mb-2 block text-sm font-semibold text-gray-700">
              {t('market_min_price')}
            </label>
            <input
              type="number"
              min="0"
              value={minPrice}
              onChange={(e) => setMinPrice(e.target.value)}
              placeholder="৳ 0"
              className="w-full rounded-xl border border-gray-200 px-3 py-3"
            />
          </div>

          <div>
            <label className="mb-2 block text-sm font-semibold text-gray-700">
              {t('market_max_price')}
            </label>
            <input
              type="number"
              min="0"
              value={maxPrice}
              onChange={(e) => setMaxPrice(e.target.value)}
              placeholder="৳ 5000"
              className="w-full rounded-xl border border-gray-200 px-3 py-3"
            />
          </div>

          <div>
            <label className="mb-2 block text-sm font-semibold text-gray-700">
              {t('market_sort')}
            </label>
            <select
              value={sortBy}
              onChange={(e) => setSortBy(e.target.value)}
              className="w-full rounded-xl border border-gray-200 bg-white px-3 py-3"
            >
              <option value="default">{t('market_sort_default')}</option>
              <option value="price-low">{t('market_sort_low_high')}</option>
              <option value="price-high">{t('market_sort_high_low')}</option>
              <option value="name">{t('market_sort_name')}</option>
            </select>
          </div>
        </div>

        <div className="mt-5 flex flex-wrap items-center justify-between gap-4">
          <label className="flex cursor-pointer items-center gap-2 text-sm font-medium text-gray-700">
            <input
              type="checkbox"
              checked={organicOnly}
              onChange={(e) => setOrganicOnly(e.target.checked)}
              className="h-4 w-4"
            />
            {t('market_organic_only')}
          </label>

          <button
            type="button"
            onClick={clearFilters}
            className="rounded-full border border-gray-300 px-5 py-2 text-sm font-semibold text-gray-700 hover:bg-gray-50"
          >
            {t('market_clear_filters')}
          </button>
        </div>
      </div>

      {/* States */}
      {state === 'loading' && (
        <div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
          {Array.from({ length: 6 }).map((_, i) => (
            <div key={i} className="h-80 animate-pulse rounded-2xl bg-gray-100" />
          ))}
        </div>
      )}

      {state === 'error' && (
        <div className="rounded-2xl bg-red-50 p-6 text-red-700">
          {t('market_error')} {error && <span className="opacity-70">({error})</span>}
        </div>
      )}

      {state === 'empty' && (
        <div className="rounded-2xl bg-gray-50 p-10 text-center text-gray-500">
          {t('market_empty')}
        </div>
      )}

      {state === 'ready' && (
        <>
          <div className="mb-4 flex items-center justify-between">
            <p className="text-sm text-gray-500">
              {t('market_found')}: <strong className="text-gray-900">{filteredCrops.length}</strong> {t('market_products')}
            </p>
            {filterActive && (
              <span className="rounded-full bg-green-50 px-3 py-1 text-xs font-semibold text-green-700">
                {t('market_filter_active')}
              </span>
            )}
          </div>

          {filteredCrops.length > 0 ? (
            <div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
              {filteredCrops.map((crop) => (
                <ProductCard
                  key={crop.crop_id}
                  crop={crop}
                  onSelect={() => openModal(crop)}
                />
              ))}
            </div>
          ) : (
            <div className="rounded-2xl bg-gray-50 p-12 text-center">
              <div className="mb-2 text-3xl">🔍</div>
              <h2 className="font-semibold text-gray-800">{t('market_no_results')}</h2>
              <p className="mt-1 text-sm text-gray-500">{t('market_try_another')}</p>
              <button
                type="button"
                onClick={clearFilters}
                className="mt-4 rounded-full bg-emerald-700 px-5 py-2 text-sm font-semibold text-white"
              >
                {t('market_clear_filters')}
              </button>
            </div>
          )}
        </>
      )}

      {/* FULLY TRANSLATED PRODUCT DETAILS MODAL */}
      {selectedCrop && (
        <div className="fixed inset-0 z-[999] flex items-center justify-center bg-black/60 p-4 backdrop-blur-sm">
          <div className="relative max-h-[90vh] w-full max-w-lg overflow-y-auto rounded-3xl bg-white p-6 shadow-2xl">
            
            {/* Modal Header */}
            <div className="mb-4 flex items-center justify-between border-b pb-3">
              <h2 className="text-lg font-bold text-gray-900">
                {lang === 'bn' ? 'পণ্যের বিস্তারিত' : 'Product Details'}
              </h2>
              <button
                onClick={() => setSelectedCrop(null)}
                className="flex h-8 w-8 items-center justify-center rounded-full bg-gray-100 text-gray-500 hover:bg-gray-200 font-bold"
              >
                ✕
              </button>
            </div>

            {/* Product Image */}
            <div className="relative mb-3 overflow-hidden rounded-2xl bg-gray-100">
              {mainImage ? (
                <img src={mainImage} alt={cropName} className="h-56 w-full object-cover" />
              ) : (
                <div className="grid h-56 place-items-center text-4xl">🌾</div>
              )}

              {(selectedCrop.is_organic || selectedCrop.is_organic === 1) && (
                <span className="absolute top-3 left-3 rounded-full bg-emerald-500 px-3 py-1 text-xs font-semibold text-white shadow">
                  ✓ {lang === 'bn' ? 'অর্গানিক প্রমানিত' : 'Certified Organic'}
                </span>
              )}
            </div>

            {/* Thumbnails */}
            {cropImages.length > 0 && (
              <div className="mb-4 flex gap-2 overflow-x-auto pb-1">
                {cropImages.map((imgUrl, index) => (
                  <img
                    key={index}
                    src={imgUrl}
                    alt={`thumb-${index}`}
                    onClick={() => setActiveImage(imgUrl)}
                    className={`h-14 w-14 rounded-xl object-cover cursor-pointer border-2 transition ${
                      mainImage === imgUrl ? 'border-emerald-500 scale-105' : 'border-transparent opacity-70'
                    }`}
                  />
                ))}
              </div>
            )}

            {/* Crop Name & Category */}
            <div className="mb-3">
              <h3 className="text-2xl font-bold text-gray-900">{cropName}</h3>
              <p className="text-sm text-gray-500">{categoryName}</p>
            </div>

            {/* Price & Stock */}
            <div className="mb-4 flex items-center justify-between rounded-2xl bg-gray-50 p-4">
              <div>
                <span className="text-xs font-bold uppercase tracking-wider text-emerald-600">
                  ● {lang === 'bn' ? 'এগ্রোমার্ট মূল্য' : 'AGROMART PRICE'}
                </span>
                <div className="flex items-baseline gap-1">
                  <span className="text-3xl font-extrabold text-emerald-600">
                    {formatPrice(unitPriceNum)}
                  </span>
                  <span className="text-sm text-gray-500">/{unitName}</span>
                </div>
              </div>
              <div className="text-right">
                <p className="text-lg font-bold text-gray-800">
                  {formatNum(selectedCrop.quantity || selectedCrop.stock || 100)} {unitName}
                </p>
                <p className="text-xs text-gray-400">
                  {lang === 'bn' ? 'মজুদ আছে' : 'Available stock'}
                </p>
              </div>
            </div>

            {/* Seller Information */}
            <div className="mb-4 flex items-center justify-between rounded-2xl border border-gray-200 p-3">
              <div className="flex items-center gap-3">
                <div className="flex h-10 w-10 items-center justify-center rounded-full bg-emerald-100 text-lg font-bold text-emerald-700">
                  {farmerName[0]}
                </div>
                <div>
                  <h4 className="text-sm font-bold text-gray-800">{farmerName}</h4>
                  <p className="text-xs text-gray-500">
                    📍 {districtName} · ⭐ {formatNum(selectedCrop.farmer_avg_rating || 4.7)}
                  </p>
                </div>
              </div>
              <button 
                type="button"
                onClick={handleWhatsAppClick}
                className="rounded-xl border border-emerald-500 bg-emerald-50 px-3 py-1.5 text-xs font-semibold text-emerald-700 hover:bg-emerald-100 flex items-center gap-1 cursor-pointer"
              >
                💬 WhatsApp
              </button>
            </div>

            {/* Quantity Controls */}
            <div className="mb-6 flex items-center justify-between">
              <span className="text-sm font-semibold text-gray-700">
                {lang === 'bn' ? 'পরিমাণ:' : 'Quantity:'}
              </span>
              <div className="flex items-center gap-3">
                <div className="flex items-center rounded-xl border border-gray-200">
                  <button
                    type="button"
                    onClick={() => setQuantity((q) => Math.max(1, q - 1))}
                    className="px-3 py-1 text-lg font-bold text-gray-600 hover:bg-gray-100"
                  >
                    -
                  </button>
                  <span className="px-4 font-semibold text-gray-800">{formatNum(quantity)}</span>
                  <button
                    type="button"
                    onClick={() => setQuantity((q) => q + 1)}
                    className="px-3 py-1 text-lg font-bold text-gray-600 hover:bg-gray-100"
                  >
                    +
                  </button>
                </div>
                <span className="text-sm text-gray-500">{unitName}</span>
              </div>
              <span className="text-xl font-bold text-gray-900">
                {formatPrice(unitPriceNum * quantity)}
              </span>
            </div>

            {/* Action Buttons */}
            <div className="grid grid-cols-2 gap-3">
              <button
                type="button"
                onClick={handleAddToCartClick}
                className="w-full rounded-2xl border-2 border-emerald-700 py-3 text-sm font-bold text-emerald-700 transition hover:bg-emerald-50 cursor-pointer"
              >
                🛒 {lang === 'bn' ? 'কার্টে যোগ করুন' : 'Add to Cart'}
              </button>
              <button
                type="button"
                onClick={handleAddToCartClick}
                className="w-full rounded-2xl bg-emerald-700 py-3 text-sm font-bold text-white transition hover:bg-emerald-800 cursor-pointer"
              >
                ⚡ {lang === 'bn' ? 'এখনই কিনুন' : 'Buy Now'}
              </button>
            </div>

          </div>
        </div>
      )}

    </section>
  );
}