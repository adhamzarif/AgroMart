// FeaturedCrops.jsx — a preview grid of the newest 6 crops, shown on the Home page
// below the hero. Fetches /api/crops?limit=6 and links to the full marketplace.
import { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';
import { useLang } from '../../context/LangContext.jsx';
import { getCrops } from '../../api/crops.api.js';
import ProductCard from '../ui/ProductCard.jsx';

export default function FeaturedCrops() {
  const { t } = useLang();
  const [crops, setCrops] = useState([]);
  const [state, setState] = useState('loading'); // loading | ready | empty | error

  useEffect(() => {
    let alive = true;
    getCrops({ limit: 6 })
      .then((res) => {
        if (!alive) return;
        const list = res.crops || [];
        setCrops(list);
        setState(list.length ? 'ready' : 'empty');
      })
      .catch(() => alive && setState('error'));
    return () => { alive = false; };
  }, []);

  // don't render the section at all if there's nothing and it errored/empty
  if (state === 'empty' || state === 'error') return null;

  return (
    <section className="bg-gray-50">
      <div className="mx-auto max-w-6xl px-6 py-16">
        {/* header row */}
        <div className="mb-8 flex items-end justify-between">
          <div>
            <h2 className="text-3xl font-bold text-gray-900 font-display">
              {t('featured_title')}
            </h2>
            <p className="mt-1 text-gray-500">{t('featured_sub')}</p>
          </div>
          <Link
            to="/marketplace"
            className="hidden rounded-full border border-m1 px-5 py-2 text-sm font-semibold text-m1 hover:bg-m1 hover:text-white sm:inline-block"
          >
            {t('featured_see_all')} →
          </Link>
        </div>

        {/* grid */}
        {state === 'loading' ? (
          <div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
            {Array.from({ length: 6 }).map((_, i) => (
              <div key={i} className="h-80 animate-pulse rounded-xl2 bg-gray-100" />
            ))}
          </div>
        ) : (
          <div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
            {crops.map((crop) => (
              <ProductCard key={crop.crop_id} crop={crop} />
            ))}
          </div>
        )}

        {/* mobile see-all */}
        <div className="mt-8 text-center sm:hidden">
          <Link
            to="/marketplace"
            className="inline-block rounded-full border border-m1 px-6 py-2.5 text-sm font-semibold text-m1"
          >
            {t('featured_see_all')} →
          </Link>
        </div>
      </div>
    </section>
  );
}
