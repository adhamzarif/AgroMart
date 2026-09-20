// Marketplace.jsx — main Marketplace page.
//
// Data flow: crops are fetched once (a generous limit) from the existing
// GET /api/crops endpoint, then ALL filtering/sorting/pagination happens
// client-side with useMemo — same pattern the original file already used for
// search/category/price/organic/sort, just extended to also cover district
// and in-stock, and to add a "Load More" slice on top. Categories are now
// pulled from GET /api/categories (already existed, just wasn't used here)
// so the dropdown lists every category, not only ones with current listings.
import { useEffect, useMemo, useState } from 'react';
import { Link } from 'react-router-dom';
import { useLang } from '../context/LangContext.jsx';
import { getCrops, getCategories } from '../api/crops.api.js';
import ProductCard from '../components/ui/ProductCard.jsx';
import MarketplaceFilters from '../components/marketplace/MarketplaceFilters.jsx';
import QuickViewModal from '../components/marketplace/QuickViewModal.jsx';
import { useFavorites } from '../hooks/useFavorites.js';
import { useCart } from '../hooks/useCart.js';
import { expandSearchTerms } from '../i18n/cropSynonyms.js';
import { getStockStatus } from '../utils/stock.js';
import { DEMO_CROPS } from '../data/demoCrops.js';

const PAGE_SIZE = 12;
// Pool size fetched from the API once; all filtering/sorting/pagination below
// happens client-side against this pool (see backend crops.controller.js —
// the max `limit` it accepts was raised to match).
const FETCH_POOL_SIZE = 300;

export default function Marketplace() {
  const { t, lang } = useLang();
  const { isFavorite, toggleFavorite } = useFavorites();
  const { addItem: addToCart, totalCount: cartCount } = useCart();

  const [crops, setCrops] = useState([]);
  const [state, setState] = useState('loading'); // loading | ready | empty | error
  const [error, setError] = useState(null);
  const [usingDemoData, setUsingDemoData] = useState(false);

  const [categoryOptions, setCategoryOptions] = useState([]); // [{id, label}]

  // Filter state
  const [search, setSearch] = useState('');
  const [category, setCategory] = useState('all');
  const [district, setDistrict] = useState('all');
  const [minPrice, setMinPrice] = useState('');
  const [maxPrice, setMaxPrice] = useState('');
  const [organicOnly, setOrganicOnly] = useState(false);
  const [inStockOnly, setInStockOnly] = useState(false);
  const [sortBy, setSortBy] = useState('default');

  const [visibleCount, setVisibleCount] = useState(PAGE_SIZE);
  const [quickViewCrop, setQuickViewCrop] = useState(null);

  // Load crops (with a dev-only demo fallback if the API call fails).
  useEffect(() => {
    let alive = true;

    getCrops({ limit: FETCH_POOL_SIZE })
      .then((res) => {
        if (!alive) return;
        const list = res.crops || [];
        setCrops(list);
        setUsingDemoData(false);
        setState(list.length ? 'ready' : 'empty');
      })
      .catch((err) => {
        if (!alive) return;

        // Development-only fallback so the UI can still be demonstrated
        // while the backend is down. Never used in production builds, and
        // every demo item is flagged (is_demo: true) so it's never mistaken
        // for a real listing — see data/demoCrops.js and ProductCard.jsx.
        if (import.meta.env.DEV) {
          setCrops(DEMO_CROPS);
          setUsingDemoData(true);
          setState('ready');
          return;
        }

        setError(err.message);
        setState('error');
      });

    return () => {
      alive = false;
    };
  }, []);

  // Load categories from the backend (GET /api/categories), independent of
  // which categories currently have active listings.
  useEffect(() => {
    let alive = true;
    getCategories()
      .then((res) => {
        if (!alive) return;
        const list = (res.categories || []).map((c) => ({
          id: c.category_id,
          label: lang === 'bn' ? c.category_name_bn || c.category_name : c.category_name,
        }));
        setCategoryOptions(list);
      })
      .catch(() => {
        // Non-fatal — the category filter just falls back to "All Categories" only.
      });
    return () => {
      alive = false;
    };
  }, [lang]);

  // Reset pagination whenever a filter changes.
  useEffect(() => {
    setVisibleCount(PAGE_SIZE);
  }, [search, category, district, minPrice, maxPrice, organicOnly, inStockOnly, sortBy]);

  const filteredCrops = useMemo(() => {
    let result = [...crops];

    // Search — matches Bangla or English crop names via the synonym table.
    if (search.trim()) {
      const terms = expandSearchTerms(search);
      result = result.filter((crop) => {
        const name = String(crop.crop_name ?? crop.name ?? '').toLowerCase();
        return terms.some((term) => name.includes(term));
      });
    }

    // Category filter
    if (category !== 'all') {
      result = result.filter((crop) => String(crop.category_id) === String(category));
    }

    // District filter
    if (district !== 'all') {
      result = result.filter(
        (crop) => String(crop.district_name || '').toLowerCase() === district.toLowerCase()
      );
    }

    // Minimum price
    if (minPrice !== '') {
      const min = Number(minPrice);
      if (!Number.isNaN(min)) {
        result = result.filter((crop) => Number(crop.price_per_unit ?? crop.price ?? 0) >= min);
      }
    }

    // Maximum price
    if (maxPrice !== '') {
      const max = Number(maxPrice);
      if (!Number.isNaN(max)) {
        result = result.filter((crop) => Number(crop.price_per_unit ?? crop.price ?? 0) <= max);
      }
    }

    // Organic only
    if (organicOnly) {
      result = result.filter(
        (crop) => crop.is_organic === true || crop.is_organic === 1 || crop.is_organic === 'true'
      );
    }

    // In stock only
    if (inStockOnly) {
      result = result.filter((crop) => getStockStatus(crop.quantity) !== 'out');
    }

    // Sorting
    if (sortBy === 'price-low') {
      result.sort((a, b) => Number(a.price_per_unit ?? 0) - Number(b.price_per_unit ?? 0));
    } else if (sortBy === 'price-high') {
      result.sort((a, b) => Number(b.price_per_unit ?? 0) - Number(a.price_per_unit ?? 0));
    } else if (sortBy === 'name') {
      result.sort((a, b) => String(a.crop_name ?? '').localeCompare(String(b.crop_name ?? ''), lang));
    }

    return result;
  }, [crops, search, category, district, minPrice, maxPrice, organicOnly, inStockOnly, sortBy, lang]);

  const visibleCrops = filteredCrops.slice(0, visibleCount);
  const hasMore = visibleCount < filteredCrops.length;

  function clearFilters() {
    setSearch('');
    setCategory('all');
    setDistrict('all');
    setMinPrice('');
    setMaxPrice('');
    setOrganicOnly(false);
    setInStockOnly(false);
    setSortBy('default');
  }

  const filterActive =
    search !== '' ||
    category !== 'all' ||
    district !== 'all' ||
    minPrice !== '' ||
    maxPrice !== '' ||
    organicOnly ||
    inStockOnly ||
    sortBy !== 'default';

  return (
    <section className="mx-auto max-w-6xl px-6 py-10">
      {/* Heading */}
      <div className="mb-6 flex items-start justify-between gap-4">
        <div>
          <h1 className="text-2xl font-bold text-gray-900 font-display">{t('nav_marketplace')}</h1>
          <p className="mt-1 text-sm text-gray-500">{t('market_subtitle')}</p>
        </div>

        <Link
          to="/marketplace/cart"
          className="relative flex shrink-0 items-center gap-2 rounded-full border border-gray-300 px-4 py-2.5 text-sm font-semibold text-gray-700 hover:bg-gray-50"
        >
          🛒 {t('cart_title')}
          {cartCount > 0 && (
            <span className="absolute -right-2 -top-2 grid h-5 min-w-5 place-items-center rounded-full bg-m1 px-1 text-xs font-bold text-white">
              {cartCount}
            </span>
          )}
        </Link>
      </div>

      {/* Demo data notice */}
      {usingDemoData && (
        <div className="mb-6 rounded-xl2 border border-warning-dark/20 bg-warning-bg px-4 py-3 text-sm text-warning-dark">
          ⚠️ {t('market_demo_notice')}
        </div>
      )}

      {/* Filters */}
      <MarketplaceFilters
        search={search}
        onSearchChange={setSearch}
        category={category}
        onCategoryChange={setCategory}
        categories={categoryOptions}
        district={district}
        onDistrictChange={setDistrict}
        minPrice={minPrice}
        onMinPriceChange={setMinPrice}
        maxPrice={maxPrice}
        onMaxPriceChange={setMaxPrice}
        organicOnly={organicOnly}
        onOrganicOnlyChange={setOrganicOnly}
        inStockOnly={inStockOnly}
        onInStockOnlyChange={setInStockOnly}
        sortBy={sortBy}
        onSortByChange={setSortBy}
        onClearAll={clearFilters}
      />

      {/* Loading */}
      {state === 'loading' && (
        <div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
          {Array.from({ length: 6 }).map((_, i) => (
            <div key={i} className="h-80 animate-pulse rounded-xl2 bg-gray-100" />
          ))}
        </div>
      )}

      {/* Error (production only — dev falls back to demo data above) */}
      {state === 'error' && (
        <div className="rounded-xl2 bg-danger-bg p-6 text-danger-dark">
          {t('market_error')}
          {error && <span className="opacity-70"> ({error})</span>}
        </div>
      )}

      {/* Empty marketplace (no crops in DB at all) */}
      {state === 'empty' && (
        <div className="rounded-xl2 bg-gray-50 p-10 text-center text-gray-500">{t('market_empty')}</div>
      )}

      {/* Ready */}
      {state === 'ready' && (
        <>
          <div className="mb-4 flex items-center justify-between">
            <p className="text-sm text-gray-500">
              {t('market_found')}: <strong className="text-gray-900">{filteredCrops.length}</strong>{' '}
              {t('market_products')}
            </p>

            {filterActive && (
              <span className="rounded-full bg-green-50 px-3 py-1 text-xs font-semibold text-green-700">
                {t('market_filter_active')}
              </span>
            )}
          </div>

          {/* Products */}
          {visibleCrops.length > 0 ? (
            <>
              <div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">
                {visibleCrops.map((crop) => (
                  <ProductCard
                    key={crop.crop_id}
                    crop={crop}
                    onQuickView={setQuickViewCrop}
                    isFavorite={isFavorite(crop.crop_id)}
                    onToggleFavorite={toggleFavorite}
                    onAddToCart={addToCart}
                  />
                ))}
              </div>

              <div className="mt-6 flex flex-col items-center gap-3">
                <p className="text-xs text-gray-400">
                  {t('market_showing')} {visibleCrops.length} {t('market_of_total')} {filteredCrops.length}
                </p>

                {hasMore && (
                  <button
                    type="button"
                    onClick={() => setVisibleCount((n) => n + PAGE_SIZE)}
                    className="rounded-full bg-m1 px-8 py-3 text-sm font-semibold text-white hover:bg-m1-dark"
                  >
                    {t('market_load_more')}
                  </button>
                )}
              </div>
            </>
          ) : (
            <div className="rounded-2xl bg-gray-50 p-12 text-center">
              <div className="mb-2 text-3xl">🔍</div>
              <h2 className="font-semibold text-gray-800">{t('market_no_results')}</h2>
              <p className="mt-1 text-sm text-gray-500">{t('market_try_another')}</p>
              <button
                type="button"
                onClick={clearFilters}
                className="mt-4 rounded-full bg-m1 px-5 py-2 text-sm font-semibold text-white"
              >
                {t('market_clear_filters')}
              </button>
            </div>
          )}
        </>
      )}

      {/* Quick View modal */}
      {quickViewCrop && (
        <QuickViewModal
          crop={quickViewCrop}
          onClose={() => setQuickViewCrop(null)}
          onAddToCart={addToCart}
        />
      )}
    </section>
  );
}