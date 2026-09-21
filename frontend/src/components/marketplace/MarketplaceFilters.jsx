// MarketplaceFilters.jsx — the whole filter bar + active-filter chip row for
// the Marketplace page. Kept as its own component (per the project's file
// layout) so Marketplace.jsx only holds data-fetching + filtering logic.
import { useLang } from '../../context/LangContext.jsx';
import { BD_DISTRICTS } from '../../data/bdDistricts.js';

export default function MarketplaceFilters({
  search,
  onSearchChange,
  category,
  onCategoryChange,
  categories, // [{ id, label }]
  district,
  onDistrictChange,
  minPrice,
  onMinPriceChange,
  maxPrice,
  onMaxPriceChange,
  organicOnly,
  onOrganicOnlyChange,
  inStockOnly,
  onInStockOnlyChange,
  sortBy,
  onSortByChange,
  onClearAll,
}) {
  const { t, lang } = useLang();

  const selectedCategoryLabel =
    category !== 'all' ? categories.find((c) => String(c.id) === String(category))?.label : null;

  // Chips describing every currently-active filter, each removable on its own.
  const chips = [];
  if (search.trim()) {
    chips.push({ key: 'search', label: `"${search.trim()}"`, onRemove: () => onSearchChange('') });
  }
  if (category !== 'all') {
    chips.push({
      key: 'category',
      label: selectedCategoryLabel || category,
      onRemove: () => onCategoryChange('all'),
    });
  }
  if (district !== 'all') {
    chips.push({ key: 'district', label: district, onRemove: () => onDistrictChange('all') });
  }
  if (minPrice !== '' || maxPrice !== '') {
    const lo = minPrice !== '' ? minPrice : '0';
    const hi = maxPrice !== '' ? maxPrice : '∞';
    chips.push({
      key: 'price',
      label: `৳${lo} - ৳${hi}`,
      onRemove: () => {
        onMinPriceChange('');
        onMaxPriceChange('');
      },
    });
  }
  if (organicOnly) {
    chips.push({ key: 'organic', label: t('badge_organic'), onRemove: () => onOrganicOnlyChange(false) });
  }
  if (inStockOnly) {
    chips.push({ key: 'stock', label: t('stock_in'), onRemove: () => onInStockOnlyChange(false) });
  }
  if (sortBy !== 'default') {
    chips.push({ key: 'sort', label: t(`market_sort_${sortBy.replace('-', '_')}`), onRemove: () => onSortByChange('default') });
  }

  return (
    <div className="mb-8 rounded-2xl border border-gray-200 bg-white p-5 shadow-sm">
      {/* Search */}
      <div className="mb-5">
        <label className="mb-2 block text-sm font-semibold text-gray-700">{t('market_search')}</label>
        <input
          type="text"
          value={search}
          onChange={(e) => onSearchChange(e.target.value)}
          placeholder={t('market_search_placeholder')}
          className="w-full rounded-xl border border-gray-200 px-4 py-3 outline-none focus:border-green-500"
        />
      </div>

      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
        {/* Category */}
        <div>
          <label className="mb-2 block text-sm font-semibold text-gray-700">{t('market_category')}</label>
          <select
            value={category}
            onChange={(e) => onCategoryChange(e.target.value)}
            className="w-full rounded-xl border border-gray-200 bg-white px-3 py-3"
          >
            <option value="all">{t('market_all_categories')}</option>
            {categories.map((c) => (
              <option key={c.id} value={c.id}>
                {c.label}
              </option>
            ))}
          </select>
        </div>

        {/* District */}
        <div>
          <label className="mb-2 block text-sm font-semibold text-gray-700">{t('market_district')}</label>
          <select
            value={district}
            onChange={(e) => onDistrictChange(e.target.value)}
            className="w-full rounded-xl border border-gray-200 bg-white px-3 py-3"
          >
            <option value="all">{t('market_all_districts')}</option>
            {BD_DISTRICTS.map((d) => (
              <option key={d.en} value={d.en}>
                {lang === 'bn' ? d.bn : d.en}
              </option>
            ))}
          </select>
        </div>

        {/* Minimum Price */}
        <div>
          <label className="mb-2 block text-sm font-semibold text-gray-700">{t('market_min_price')}</label>
          <input
            type="number"
            min="0"
            value={minPrice}
            onChange={(e) => onMinPriceChange(e.target.value)}
            placeholder="৳ 0"
            className="w-full rounded-xl border border-gray-200 px-3 py-3"
          />
        </div>

        {/* Maximum Price */}
        <div>
          <label className="mb-2 block text-sm font-semibold text-gray-700">{t('market_max_price')}</label>
          <input
            type="number"
            min="0"
            value={maxPrice}
            onChange={(e) => onMaxPriceChange(e.target.value)}
            placeholder="৳ 5000"
            className="w-full rounded-xl border border-gray-200 px-3 py-3"
          />
        </div>
      </div>

      <div className="mt-4 grid gap-4 md:grid-cols-2 lg:grid-cols-4">
        {/* Sort */}
        <div>
          <label className="mb-2 block text-sm font-semibold text-gray-700">{t('market_sort')}</label>
          <select
            value={sortBy}
            onChange={(e) => onSortByChange(e.target.value)}
            className="w-full rounded-xl border border-gray-200 bg-white px-3 py-3"
          >
            <option value="default">{t('market_sort_default')}</option>
            <option value="price-low">{t('market_sort_low_high')}</option>
            <option value="price-high">{t('market_sort_high_low')}</option>
            <option value="name">{t('market_sort_name')}</option>
          </select>
        </div>
      </div>

      {/* Organic + Stock + Clear */}
      <div className="mt-5 flex flex-wrap items-center justify-between gap-4">
        <div className="flex flex-wrap items-center gap-5">
          <label className="flex cursor-pointer items-center gap-2 text-sm font-medium text-gray-700">
            <input
              type="checkbox"
              checked={organicOnly}
              onChange={(e) => onOrganicOnlyChange(e.target.checked)}
              className="h-4 w-4"
            />
            {t('market_organic_only')}
          </label>

          <label className="flex cursor-pointer items-center gap-2 text-sm font-medium text-gray-700">
            <input
              type="checkbox"
              checked={inStockOnly}
              onChange={(e) => onInStockOnlyChange(e.target.checked)}
              className="h-4 w-4"
            />
            {t('market_in_stock_only')}
          </label>
        </div>

        <button
          type="button"
          onClick={onClearAll}
          className="rounded-full border border-gray-300 px-5 py-2 text-sm font-semibold text-gray-700 hover:bg-gray-50"
        >
          {t('market_clear_filters')}
        </button>
      </div>

      {/* Active filter chips */}
      {chips.length > 0 && (
        <div className="mt-4 flex flex-wrap gap-2 border-t border-gray-100 pt-4">
          {chips.map((chip) => (
            <button
              key={chip.key}
              type="button"
              onClick={chip.onRemove}
              className="inline-flex items-center gap-1.5 rounded-full bg-success-bg px-3 py-1.5 text-xs font-semibold text-m1-dark hover:bg-success-light/40"
            >
              {chip.label}
              <span aria-hidden="true">×</span>
            </button>
          ))}
        </div>
      )}
    </div>
  );
}