// Marketplace.jsx — crop product grid (screenshot 2).
// Fetches from /api/crops and renders a responsive grid of ProductCard.
import { useEffect, useState } from 'react';
import { useLang } from '../context/LangContext.jsx';
import { getCrops } from '../api/crops.api.js';
import ProductCard from '../components/ui/ProductCard.jsx';

export default function Marketplace() {
  const { t } = useLang();
  const [crops, setCrops] = useState([]);
  const [state, setState] = useState('loading'); // loading | ready | error | empty
  const [error, setError] = useState(null);

  useEffect(() => {
    let alive = true;
    getCrops({ limit: 12 })
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
    return () => { alive = false; };
  }, []);

  return (
    <section className="mx-auto max-w-6xl px-6 py-10">
      <h1 className="mb-6 text-2xl font-bold text-gray-900 font-display">
        {t('nav_marketplace')}
      </h1>

      {state === 'loading' && (
        <div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
          {Array.from({ length: 6 }).map((_, i) => (
            <div key={i} className="h-80 animate-pulse rounded-xl2 bg-gray-100" />
          ))}
        </div>
      )}

      {state === 'error' && (
        <div className="rounded-xl2 bg-danger-bg p-6 text-danger-dark">
          {t('market_error')} {error && <span className="opacity-70">({error})</span>}
        </div>
      )}

      {state === 'empty' && (
        <div className="rounded-xl2 bg-gray-50 p-10 text-center text-gray-500">
          {t('market_empty')}
        </div>
      )}

      {state === 'ready' && (
        <div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-3">
          {crops.map((crop) => (
            <ProductCard key={crop.crop_id} crop={crop} />
          ))}
        </div>
      )}
    </section>
  );
}
