import {
  useEffect,
  useMemo,
  useState,
} from 'react';

import { useLang } from '../context/LangContext.jsx';

import {
  getCrops,
  getCategories,
} from '../api/crops.api.js';

import ProductCard from '../components/ui/ProductCard.jsx';

import MarketplaceFilters from '../components/marketplace/MarketplaceFilters.jsx';

import QuickViewModal from '../components/marketplace/QuickViewModal.jsx';

import { useFavorites } from '../hooks/useFavorites.js';

import { expandSearchTerms } from '../i18n/cropSynonyms.js';

import { getStockStatus } from '../utils/stock.js';

import { DEMO_CROPS } from '../data/demoCrops.js';

const PAGE_SIZE = 12;
const FETCH_POOL_SIZE = 300;

export default function Marketplace() {
  const { t, lang } = useLang();

  const {
    isFavorite,
    toggleFavorite,
  } = useFavorites();

  // Data
  const [crops, setCrops] = useState([]);

  const [state, setState] =
    useState('loading');

  const [error, setError] =
    useState(null);

  const [
    usingDemoData,
    setUsingDemoData,
  ] = useState(false);

  // Category options
  const [
    categoryOptions,
    setCategoryOptions,
  ] = useState([]);

  // Filters
  const [search, setSearch] =
    useState('');

  const [category, setCategory] =
    useState('all');

  const [district, setDistrict] =
    useState('all');

  const [minPrice, setMinPrice] =
    useState('');

  const [maxPrice, setMaxPrice] =
    useState('');

  const [
    organicOnly,
    setOrganicOnly,
  ] = useState(false);

  const [
    inStockOnly,
    setInStockOnly,
  ] = useState(false);

  const [sortBy, setSortBy] =
    useState('default');

  // Pagination
  const [
    visibleCount,
    setVisibleCount,
  ] = useState(PAGE_SIZE);

  // Quick View
  const [
    quickViewCrop,
    setQuickViewCrop,
  ] = useState(null);

  // ---------------------------------------------------
  // Load Crops
  // ---------------------------------------------------

  useEffect(() => {
    let alive = true;

    setState('loading');
    setError(null);

    getCrops({
      limit: FETCH_POOL_SIZE,
    })
      .then((res) => {
        if (!alive) return;

        const list =
          res.crops || [];

        setCrops(list);

        setUsingDemoData(false);

        setState(
          list.length
            ? 'ready'
            : 'empty'
        );
      })
      .catch((err) => {
        if (!alive) return;

        // Development fallback
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

  // ---------------------------------------------------
  // Load Categories
  // ---------------------------------------------------

  useEffect(() => {
    let alive = true;

    getCategories()
      .then((res) => {
        if (!alive) return;

        const list = (
          res.categories || []
        ).map((c) => ({
          id: c.category_id,

          label:
            lang === 'bn'
              ? c.category_name_bn ||
                c.category_name
              : c.category_name_en ||
                c.category_name ||
                c.category_name_bn,
        }));

        setCategoryOptions(list);
      })
      .catch(() => {
        // Non-fatal
      });

    return () => {
      alive = false;
    };
  }, [lang]);

  // ---------------------------------------------------
  // Reset Pagination
  // ---------------------------------------------------

  useEffect(() => {
    setVisibleCount(PAGE_SIZE);
  }, [
    search,
    category,
    district,
    minPrice,
    maxPrice,
    organicOnly,
    inStockOnly,
    sortBy,
  ]);

  // ---------------------------------------------------
  // Filter + Sort
  // ---------------------------------------------------

  const filteredCrops =
    useMemo(() => {
      let result = [...crops];

      // Search
      if (search.trim()) {
        const terms =
          expandSearchTerms(search);

        result =
          result.filter((crop) => {
            const names = [
              crop.crop_name,
              crop.crop_name_bn,
              crop.crop_name_en,
              crop.name,
            ]
              .filter(Boolean)
              .map((name) =>
                String(
                  name
                ).toLowerCase()
              );

            return terms.some(
              (term) => {
                const q =
                  String(
                    term
                  ).toLowerCase();

                return names.some(
                  (name) =>
                    name.includes(q)
                );
              }
            );
          });
      }

      // Category
      if (
        category !== 'all'
      ) {
        result =
          result.filter(
            (crop) =>
              String(
                crop.category_id
              ) ===
              String(category)
          );
      }

      // District
      if (
        district !== 'all'
      ) {
        result =
          result.filter(
            (crop) => {
              const values = [
                crop.district_name,
                crop.district_name_bn,
                crop.district_name_en,
              ]
                .filter(Boolean)
                .map((value) =>
                  String(
                    value
                  ).toLowerCase()
                );

              return values.includes(
                String(
                  district
                ).toLowerCase()
              );
            }
          );
      }

      // Min Price
      if (
        minPrice !== ''
      ) {
        const min =
          Number(minPrice);

        if (
          !Number.isNaN(min)
        ) {
          result =
            result.filter(
              (crop) =>
                Number(
                  crop.price_per_unit ??
                    crop.price ??
                    0
                ) >= min
            );
        }
      }

      // Max Price
      if (
        maxPrice !== ''
      ) {
        const max =
          Number(maxPrice);

        if (
          !Number.isNaN(max)
        ) {
          result =
            result.filter(
              (crop) =>
                Number(
                  crop.price_per_unit ??
                    crop.price ??
                    0
                ) <= max
            );
        }
      }

      // Organic
      if (organicOnly) {
        result =
          result.filter(
            (crop) =>
              crop.is_organic ===
                true ||
              crop.is_organic ===
                1 ||
              crop.is_organic ===
                'true'
          );
      }

      // In Stock
      if (inStockOnly) {
        result =
          result.filter(
            (crop) =>
              getStockStatus(
                crop.quantity
              ) !== 'out'
          );
      }

      // Price Low -> High
      if (
        sortBy ===
        'price-low'
      ) {
        result.sort(
          (a, b) =>
            Number(
              a.price_per_unit ??
                a.price ??
                0
            ) -
            Number(
              b.price_per_unit ??
                b.price ??
                0
            )
        );
      }

      // Price High -> Low
      else if (
        sortBy ===
        'price-high'
      ) {
        result.sort(
          (a, b) =>
            Number(
              b.price_per_unit ??
                b.price ??
                0
            ) -
            Number(
              a.price_per_unit ??
                a.price ??
                0
            )
        );
      }

      // Name
      else if (
        sortBy === 'name'
      ) {
        result.sort(
          (a, b) => {
            const nameA =
              lang === 'bn'
                ? a.crop_name_bn ||
                  a.crop_name ||
                  a.name ||
                  ''
                : a.crop_name_en ||
                  a.crop_name ||
                  a.name ||
                  '';

            const nameB =
              lang === 'bn'
                ? b.crop_name_bn ||
                  b.crop_name ||
                  b.name ||
                  ''
                : b.crop_name_en ||
                  b.crop_name ||
                  b.name ||
                  '';

            return String(
              nameA
            ).localeCompare(
              String(nameB),
              lang
            );
          }
        );
      }

      return result;
    }, [
      crops,
      search,
      category,
      district,
      minPrice,
      maxPrice,
      organicOnly,
      inStockOnly,
      sortBy,
      lang,
    ]);

  // ---------------------------------------------------
  // Pagination
  // ---------------------------------------------------

  const visibleCrops =
    filteredCrops.slice(
      0,
      visibleCount
    );

  const hasMore =
    visibleCount <
    filteredCrops.length;

  // ---------------------------------------------------
  // Clear Filters
  // ---------------------------------------------------

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

  // ---------------------------------------------------
  // Render
  // ---------------------------------------------------

  return (
    <section className="mx-auto max-w-6xl px-6 py-10">
      {/* Heading */}

      <div className="mb-6">
        <h1 className="text-2xl font-bold text-gray-900 font-display">
          {t(
            'nav_marketplace'
          )}
        </h1>

        <p className="mt-1 text-sm text-gray-500">
          {t(
            'market_subtitle'
          )}
        </p>
      </div>

      {/* Demo Data */}

      {usingDemoData && (
        <div className="mb-6 rounded-xl border border-yellow-200 bg-yellow-50 px-4 py-3 text-sm text-yellow-800">
          ⚠️{' '}
          {t(
            'market_demo_notice'
          )}
        </div>
      )}

      {/* Filters */}

      <MarketplaceFilters
        search={search}
        onSearchChange={
          setSearch
        }
        category={category}
        onCategoryChange={
          setCategory
        }
        categories={
          categoryOptions
        }
        district={district}
        onDistrictChange={
          setDistrict
        }
        minPrice={minPrice}
        onMinPriceChange={
          setMinPrice
        }
        maxPrice={maxPrice}
        onMaxPriceChange={
          setMaxPrice
        }
        organicOnly={
          organicOnly
        }
        onOrganicOnlyChange={
          setOrganicOnly
        }
        inStockOnly={
          inStockOnly
        }
        onInStockOnlyChange={
          setInStockOnly
        }
        sortBy={sortBy}
        onSortByChange={
          setSortBy
        }
        onClearAll={
          clearFilters
        }
      />

      {/* Loading */}

      {state ===
        'loading' && (
        <div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">
          {Array.from({
            length: 8,
          }).map((_, i) => (
            <div
              key={i}
              className="h-80 animate-pulse rounded-2xl bg-gray-100"
            />
          ))}
        </div>
      )}

      {/* Error */}

      {state ===
        'error' && (
        <div className="rounded-2xl bg-red-50 p-6 text-red-700">
          {t(
            'market_error'
          )}

          {error && (
            <span className="opacity-70">
              {' '}
              ({error})
            </span>
          )}
        </div>
      )}

      {/* Empty */}

      {state ===
        'empty' && (
        <div className="rounded-2xl bg-gray-50 p-10 text-center text-gray-500">
          {t(
            'market_empty'
          )}
        </div>
      )}

      {/* Products */}

      {state ===
        'ready' && (
        <>
          <div className="mb-4 flex items-center justify-between gap-4">
            <p className="text-sm text-gray-500">
              {t(
                'market_found'
              )}
              :{' '}

              <strong className="text-gray-900">
                {
                  filteredCrops.length
                }
              </strong>{' '}

              {t(
                'market_products'
              )}
            </p>

            {filterActive && (
              <span className="rounded-full bg-green-50 px-3 py-1 text-xs font-semibold text-green-700">
                {t(
                  'market_filter_active'
                )}
              </span>
            )}
          </div>

          {visibleCrops.length >
          0 ? (
            <>
              <div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">
                {visibleCrops.map(
                  (crop) => (
                    <ProductCard
                      key={
                        crop.crop_id ||
                        crop.id
                      }
                      crop={
                        crop
                      }
                      onQuickView={
                        setQuickViewCrop
                      }
                      isFavorite={isFavorite(
                        crop.crop_id ||
                          crop.id
                      )}
                      onToggleFavorite={
                        toggleFavorite
                      }
                    />
                  )
                )}
              </div>

              {/* Load More */}

              <div className="mt-6 flex flex-col items-center gap-3">
                <p className="text-xs text-gray-400">
                  {t(
                    'market_showing'
                  )}{' '}

                  {
                    visibleCrops.length
                  }{' '}

                  {t(
                    'market_of_total'
                  )}{' '}

                  {
                    filteredCrops.length
                  }
                </p>

                {hasMore && (
                  <button
                    type="button"
                    onClick={() =>
                      setVisibleCount(
                        (
                          current
                        ) =>
                          current +
                          PAGE_SIZE
                      )
                    }
                    className="rounded-full bg-m1 px-8 py-3 text-sm font-semibold text-white hover:bg-m1-dark"
                  >
                    {t(
                      'market_load_more'
                    )}
                  </button>
                )}
              </div>
            </>
          ) : (
            <div className="rounded-2xl bg-gray-50 p-12 text-center">
              <div className="mb-2 text-3xl">
                🔍
              </div>

              <h2 className="font-semibold text-gray-800">
                {t(
                  'market_no_results'
                )}
              </h2>

              <p className="mt-1 text-sm text-gray-500">
                {t(
                  'market_try_another'
                )}
              </p>

              <button
                type="button"
                onClick={
                  clearFilters
                }
                className="mt-4 rounded-full bg-emerald-700 px-5 py-2 text-sm font-semibold text-white hover:bg-emerald-800"
              >
                {t(
                  'market_clear_filters'
                )}
              </button>
            </div>
          )}
        </>
      )}

      {/* Quick View */}

      {quickViewCrop && (
        <QuickViewModal
          crop={
            quickViewCrop
          }
          onClose={() =>
            setQuickViewCrop(
              null
            )
          }
        />
      )}
    </section>
  );
}