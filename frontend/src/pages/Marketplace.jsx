import { useEffect, useMemo, useState } from 'react';
import { useLang } from '../context/LangContext.jsx';
import { getCrops } from '../api/crops.api.js';
import ProductCard from '../components/ui/ProductCard.jsx';

export default function Marketplace() {
  const { t, lang } = useLang();

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

  // Load crops
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

  // Get category list
  const categories = useMemo(() => {
    const map = new Map();

    crops.forEach((crop) => {
      const id = crop.category_id;

      const name =
        lang === 'bn'
          ? crop.category_name_bn ||
            crop.category_name ||
            crop.category ||
            ''
          : crop.category_name_en ||
            crop.category_name ||
            crop.category_name_bn ||
            crop.category ||
            '';

      if (id && name) {
        map.set(String(id), name);
      }
    });

    return Array.from(map.entries());
  }, [crops, lang]);

  // Search, filter and sort
  const filteredCrops = useMemo(() => {
    let result = [...crops];

    // Search
    if (search.trim()) {
      const q = search.trim().toLowerCase();

      result = result.filter((crop) => {
        const bnName = String(
          crop.crop_name_bn ||
            crop.crop_name ||
            crop.name ||
            ''
        ).toLowerCase();

        const enName = String(
          crop.crop_name_en ||
            crop.crop_name ||
            crop.name ||
            ''
        ).toLowerCase();

        return bnName.includes(q) || enName.includes(q);
      });
    }

    // Category filter
    if (category !== 'all') {
      result = result.filter(
        (crop) => String(crop.category_id) === category
      );
    }

    // Minimum price
    if (minPrice !== '') {
      const min = Number(minPrice);

      result = result.filter(
        (crop) =>
          Number(crop.price_per_unit ?? crop.price ?? 0) >= min
      );
    }

    // Maximum price
    if (maxPrice !== '') {
      const max = Number(maxPrice);

      result = result.filter(
        (crop) =>
          Number(crop.price_per_unit ?? crop.price ?? 0) <= max
      );
    }

    // Organic only
    if (organicOnly) {
      result = result.filter(
        (crop) =>
          crop.is_organic === true ||
          crop.is_organic === 1 ||
          crop.is_organic === 'true'
      );
    }

    // Price: Low to High
    if (sortBy === 'price-low') {
      result.sort(
        (a, b) =>
          Number(a.price_per_unit ?? a.price ?? 0) -
          Number(b.price_per_unit ?? b.price ?? 0)
      );
    }

    // Price: High to Low
    if (sortBy === 'price-high') {
      result.sort(
        (a, b) =>
          Number(b.price_per_unit ?? b.price ?? 0) -
          Number(a.price_per_unit ?? a.price ?? 0)
      );
    }

    // Sort by name
    if (sortBy === 'name') {
      result.sort((a, b) => {
        const nameA =
          lang === 'bn'
            ? a.crop_name_bn ||
              a.crop_name ||
              a.name ||
              ''
            : a.crop_name_en ||
              a.crop_name ||
              a.crop_name_bn ||
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
              b.crop_name_bn ||
              b.name ||
              '';

        return nameA.localeCompare(nameB);
      });
    }

    return result;
  }, [
    crops,
    search,
    category,
    minPrice,
    maxPrice,
    organicOnly,
    sortBy,
    lang,
  ]);

  // Clear all filters
  function clearFilters() {
    setSearch('');
    setCategory('all');
    setMinPrice('');
    setMaxPrice('');
    setOrganicOnly(false);
    setSortBy('default');
  }

  const filterActive =
    search !== '' ||
    category !== 'all' ||
    minPrice !== '' ||
    maxPrice !== '' ||
    organicOnly ||
    sortBy !== 'default';

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

        {/* Search */}
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

          {/* Category */}
          <div>
            <label className="mb-2 block text-sm font-semibold text-gray-700">
              {t('market_category')}
            </label>

            <select
              value={category}
              onChange={(e) => setCategory(e.target.value)}
              className="w-full rounded-xl border border-gray-200 bg-white px-3 py-3"
            >
              <option value="all">
                {t('market_all_categories')}
              </option>

              {categories.map(([id, name]) => (
                <option key={id} value={id}>
                  {name}
                </option>
              ))}
            </select>
          </div>

          {/* Minimum Price */}
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

          {/* Maximum Price */}
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

          {/* Sort */}
          <div>
            <label className="mb-2 block text-sm font-semibold text-gray-700">
              {t('market_sort')}
            </label>

            <select
              value={sortBy}
              onChange={(e) => setSortBy(e.target.value)}
              className="w-full rounded-xl border border-gray-200 bg-white px-3 py-3"
            >
              <option value="default">
                {t('market_sort_default')}
              </option>

              <option value="price-low">
                {t('market_sort_low_high')}
              </option>

              <option value="price-high">
                {t('market_sort_high_low')}
              </option>

              <option value="name">
                {t('market_sort_name')}
              </option>
            </select>
          </div>
        </div>

        {/* Organic + Clear */}
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

      {/* Loading */}
      {state === 'loading' && (
        <div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
          {Array.from({ length: 6 }).map((_, i) => (
            <div
              key={i}
              className="h-80 animate-pulse rounded-xl2 bg-gray-100"
            />
          ))}
        </div>
      )}

      {/* Error */}
      {state === 'error' && (
        <div className="rounded-xl2 bg-danger-bg p-6 text-danger-dark">
          {t('market_error')}

          {error && (
            <span className="opacity-70">
              {' '}({error})
            </span>
          )}
        </div>
      )}

      {/* Empty Marketplace */}
      {state === 'empty' && (
        <div className="rounded-xl2 bg-gray-50 p-10 text-center text-gray-500">
          {t('market_empty')}
        </div>
      )}

      {/* Ready */}
      {state === 'ready' && (
        <>
          <div className="mb-4 flex items-center justify-between">

            <p className="text-sm text-gray-500">
              {t('market_found')}:{' '}

              <strong className="text-gray-900">
                {filteredCrops.length}
              </strong>{' '}

              {t('market_products')}
            </p>

            {filterActive && (
              <span className="rounded-full bg-green-50 px-3 py-1 text-xs font-semibold text-green-700">
                {t('market_filter_active')}
              </span>
            )}
          </div>

          {/* Products */}
          {filteredCrops.length > 0 ? (
            <div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
              {filteredCrops.map((crop) => (
                <ProductCard
                  key={crop.crop_id}
                  crop={crop}
                />
              ))}
            </div>
          ) : (
            <div className="rounded-2xl bg-gray-50 p-12 text-center">

              <div className="mb-2 text-3xl">
                🔍
              </div>

              <h2 className="font-semibold text-gray-800">
                {t('market_no_results')}
              </h2>

              <p className="mt-1 text-sm text-gray-500">
                {t('market_try_another')}
              </p>

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
    </section>
  );
}