// Cart.jsx — /marketplace/cart
//
// This is a frontend-only cart (see hooks/useCart.js for why: no login yet,
// so there's no buyer_id to attach a real order to). The page lets the user
// review items, change quantity, and remove items, but the "Checkout"
// button is disabled with an explanatory notice instead of creating a real
// order — swap that block out once login + a real orders/cart API exist.
import { Link } from 'react-router-dom';
import { useLang } from '../context/LangContext.jsx';
import { useCart } from '../hooks/useCart.js';
import Card from '../components/ui/Card.jsx';
import Badge from '../components/ui/Badge.jsx';

export default function Cart() {
  const { t } = useLang();
  const { items, totalCount, subtotal, setQuantity, removeItem, clearCart } = useCart();

  if (items.length === 0) {
    return (
      <section className="mx-auto max-w-3xl px-6 py-16 text-center">
        <div className="mb-2 text-4xl">🛒</div>
        <h1 className="text-xl font-bold text-gray-800">{t('cart_empty_title')}</h1>
        <p className="mt-1 text-sm text-gray-500">{t('cart_empty_sub')}</p>
        <Link
          to="/marketplace"
          className="mt-6 inline-block rounded-full bg-m1 px-6 py-3 text-sm font-semibold text-white hover:bg-m1-dark"
        >
          {t('cart_browse_marketplace')}
        </Link>
      </section>
    );
  }

  return (
    <section className="mx-auto max-w-4xl px-6 py-10">
      <div className="mb-6 flex items-center justify-between">
        <h1 className="text-2xl font-bold text-gray-900 font-display">
          {t('cart_title')} ({totalCount})
        </h1>

        <button
          type="button"
          onClick={clearCart}
          className="text-sm font-semibold text-danger-dark hover:underline"
        >
          {t('cart_clear')}
        </button>
      </div>

      {/* Cart is local to this browser only — see useCart.js */}
      <div className="mb-6 rounded-xl2 border border-warning-dark/20 bg-warning-bg px-4 py-3 text-sm text-warning-dark">
        ⚠️ {t('cart_local_notice')}
      </div>

      <div className="space-y-4">
        {items.map((item) => {
          const lineTotal = (item.quantity * Number(item.price_per_unit || 0)).toFixed(2);
          const atMax = Number.isFinite(item.maxQuantity) && item.quantity >= item.maxQuantity;

          return (
            <Card key={item.crop_id} className="flex items-center gap-4 p-4">
              <div className="h-20 w-20 shrink-0 overflow-hidden rounded-lg bg-gray-100">
                {item.image ? (
                  <img src={item.image} alt={item.crop_name} className="h-full w-full object-cover" />
                ) : (
                  <div className="grid h-full place-items-center text-2xl text-gray-300">🌾</div>
                )}
              </div>

              <div className="min-w-0 flex-1">
                <div className="flex items-center gap-2">
                  <h3 className="truncate font-semibold text-gray-900">{item.crop_name}</h3>
                  {item.is_demo && <Badge tone="warning">DEMO</Badge>}
                </div>
                <div className="text-sm text-gray-500">
                  ৳ {Number(item.price_per_unit).toFixed(2)} {t('per')} {item.unit}
                </div>

                <div className="mt-2 flex items-center gap-2">
                  <button
                    type="button"
                    onClick={() => setQuantity(item.crop_id, item.quantity - 1)}
                    disabled={item.quantity <= 1}
                    className="grid h-8 w-8 place-items-center rounded-lg border border-gray-300 font-bold text-gray-700 disabled:opacity-40"
                  >
                    −
                  </button>

                  <span className="w-8 text-center font-semibold text-gray-800">{item.quantity}</span>

                  <button
                    type="button"
                    onClick={() => setQuantity(item.crop_id, item.quantity + 1)}
                    disabled={atMax}
                    className="grid h-8 w-8 place-items-center rounded-lg border border-gray-300 font-bold text-gray-700 disabled:opacity-40"
                  >
                    +
                  </button>

                  {atMax && (
                    <span className="text-xs text-gray-400">{t('cart_max_stock')}</span>
                  )}
                </div>
              </div>

              <div className="flex shrink-0 flex-col items-end gap-2">
                <div className="font-bold text-m1">৳ {lineTotal}</div>
                <button
                  type="button"
                  onClick={() => removeItem(item.crop_id)}
                  className="text-xs font-semibold text-danger-dark hover:underline"
                >
                  {t('cart_remove')}
                </button>
              </div>
            </Card>
          );
        })}
      </div>

      {/* Summary + checkout */}
      <Card className="mt-6 p-5">
        <div className="mb-4 flex items-center justify-between text-lg font-bold text-gray-900">
          <span>{t('cart_subtotal')}</span>
          <span>৳ {subtotal.toFixed(2)}</span>
        </div>

        {/* Real checkout needs a logged-in buyer_id (see useCart.js header
            comment) — disabled for now instead of pretending to place an
            order. Swap this block for a working checkout once login lands. */}
        <button
          type="button"
          disabled
          title={t('cart_checkout_disabled_reason')}
          className="w-full cursor-not-allowed rounded-full bg-gray-300 px-6 py-3 text-sm font-semibold text-gray-500"
        >
          {t('cart_checkout')}
        </button>
        <p className="mt-2 text-center text-xs text-gray-400">{t('cart_checkout_disabled_reason')}</p>
      </Card>

      <div className="mt-6 text-center">
        <Link to="/marketplace" className="text-sm font-semibold text-m1 hover:underline">
          {t('cart_continue_shopping')}
        </Link>
      </div>
    </section>
  );
}