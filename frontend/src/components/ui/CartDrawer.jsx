import React, { useState } from 'react';
import { useCart } from '../../context/CartContext.jsx';
import { useLang } from '../../context/LangContext.jsx';

// Bangla digits converter
const toBnNum = (num) => {
  if (num === null || num === undefined) return '';
  const bnDigits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
  return String(num).replace(/\d/g, (digit) => bnDigits[digit]);
};

// Advanced Case-Insensitive Dictionary
const dictionary = {
  'bottle gourd': { en: 'Bottle Gourd', bn: 'লাউ' },
  'লাউ': { en: 'Bottle Gourd', bn: 'লাউ' },
  'green chili': { en: 'Green Chili', bn: 'কাঁচামরিচ' },
  'কাঁচামরিচ': { en: 'Green Chili', bn: 'কাঁচামরিচ' },
  'eggplant': { en: 'Eggplant', bn: 'বেগুন' },
  'বেগুন': { en: 'Eggplant', bn: 'বেগুন' },
  'mustard': { en: 'Mustard', bn: 'সরিষা' },
  'সরিষা': { en: 'Mustard', bn: 'সরিষা' },
  'moong dal': { en: 'Moong Dal', bn: 'মুগ ডাল' },
  'মুগ ডাল': { en: 'Moong Dal', bn: 'মুগ ডাল' },
  'lentil': { en: 'Lentil', bn: 'মসুর ডাল' },
  'মসুর ডাল': { en: 'Lentil', bn: 'মসুর ডাল' },
  'jute': { en: 'Jute', bn: 'পাট' },
  'পাট': { en: 'Jute', bn: 'পাট' },
  'piece': { en: 'piece', bn: 'টি' },
  'টি': { en: 'piece', bn: 'টি' },
  'kg': { en: 'kg', bn: 'কেজি' },
  'কেজি': { en: 'kg', bn: 'কেজি' }
};

const makeOrderNumber = () => {
  const stamp = Date.now().toString().slice(-8);
  const random = Math.floor(100 + Math.random() * 900);
  return `AGRO-COD-${stamp}${random}`;
};

export default function CartDrawer() {
  const {
    cartItems,
    removeFromCart,
    updateQuantity,
    clearCart,
    isCartOpen,
    setIsCartOpen,
  } = useCart();
  const { lang } = useLang();

  const [loading, setLoading] = useState(false);
  const [checkoutOpen, setCheckoutOpen] = useState(false);
  const [paymentMethod, setPaymentMethod] = useState('online');
  const [customerName, setCustomerName] = useState('');
  const [customerPhone, setCustomerPhone] = useState('');
  const [deliveryAddress, setDeliveryAddress] = useState('');
  const [orderPlaced, setOrderPlaced] = useState(null);

  if (!isCartOpen) return null;

  // Smart Translate Function
  const smartTranslate = (item, defaultKey) => {
    if (lang === 'bn') {
      const explicitBn = item.crop_name_bn || item.name_bn || item.title_bn || item.unit_bn;
      if (explicitBn) return explicitBn;
    } else {
      const explicitEn = item.crop_name_en || item.name_en || item.title_en || item.unit_en;
      if (explicitEn) return explicitEn;
    }

    const rawVal = item[defaultKey] || item.title || item.crop_name || item.name || item.unit || '';
    const cleanKey = String(rawVal).trim().toLowerCase();

    if (dictionary[cleanKey]) {
      return dictionary[cleanKey][lang];
    }

    return rawVal;
  };

  const formatPrice = (amount) => {
    const fixed = Number(amount).toFixed(2);
    return lang === 'bn' ? `৳${toBnNum(fixed)}` : `৳${fixed}`;
  };

  const formatNum = (num) => {
    return lang === 'bn' ? toBnNum(num) : num;
  };

  const totalAmount = cartItems.reduce(
    (acc, item) => acc + Number(item.price || 0) * Number(item.quantity || 0),
    0
  );

  const closeDrawer = () => {
    setCheckoutOpen(false);
    setOrderPlaced(null);
    setIsCartOpen(false);
  };

  // Step 1: Checkout button opens the payment-method selection.
  const openCheckout = () => {
    setOrderPlaced(null);
    setCheckoutOpen(true);
  };

  // Online payment -> existing SSLCommerz flow.
  const handleOnlineCheckout = async () => {
    try {
      setLoading(true);

      const response = await fetch('http://localhost:4000/api/payment/initiate', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          amount: Number(totalAmount.toFixed(2)),
          cartItems,
          customerName: customerName.trim() || 'AgroMart Customer',
          customerEmail: 'farmer@test.com',
          customerPhone: customerPhone.trim() || '01700000000',
        }),
      });

      const data = await response.json();

      if (!response.ok) {
        throw new Error(data?.reason || data?.message || 'Payment initiation failed');
      }

      if (data.gatewayUrl || data.url) {
        window.location.href = data.gatewayUrl || data.url;
        return;
      }

      throw new Error('SSLCommerz Gateway URL was not returned');
    } catch (error) {
      console.error('Online Checkout Error:', error);
      alert(
        lang === 'bn'
          ? `অনলাইন পেমেন্ট শুরু করা যায়নি: ${error.message}`
          : `Online payment could not be started: ${error.message}`
      );
    } finally {
      setLoading(false);
    }
  };

  // COD is handled locally for now because this project does not yet have
  // a connected buyer-login/order-creation API. It creates a demo order
  // record so the team can demonstrate the complete UX safely.
  const handleCashOnDelivery = () => {
    if (!customerName.trim() || !customerPhone.trim() || !deliveryAddress.trim()) {
      alert(
        lang === 'bn'
          ? 'নাম, ফোন নম্বর এবং ডেলিভারি ঠিকানা দিন।'
          : 'Please provide your name, phone number and delivery address.'
      );
      return;
    }

    const orderNumber = makeOrderNumber();
    const newOrder = {
      orderNumber,
      paymentMethod: 'COD',
      paymentStatus: 'PENDING',
      orderStatus: 'CONFIRMED',
      customer: {
        name: customerName.trim(),
        phone: customerPhone.trim(),
        address: deliveryAddress.trim(),
      },
      items: cartItems,
      totalAmount: Number(totalAmount.toFixed(2)),
      createdAt: new Date().toISOString(),
    };

    try {
      const existingOrders = JSON.parse(localStorage.getItem('agromart_cod_orders') || '[]');
      localStorage.setItem(
        'agromart_cod_orders',
        JSON.stringify([newOrder, ...existingOrders].slice(0, 20))
      );
    } catch (storageError) {
      console.warn('Could not persist demo COD order locally:', storageError);
    }

    setOrderPlaced(newOrder);
    clearCart();
  };

  // ------------------------------------------------------------
  // Order confirmation view
  // ------------------------------------------------------------
  if (orderPlaced) {
    return (
      <div className="fixed inset-0 z-[9999] flex justify-end bg-black/50 backdrop-blur-sm">
        <div className="w-full max-w-md bg-white h-full p-6 shadow-2xl overflow-y-auto flex flex-col">
          <div className="flex items-center justify-end">
            <button
              onClick={closeDrawer}
              className="h-8 w-8 rounded-full bg-gray-100 flex items-center justify-center font-bold text-gray-500 hover:bg-gray-200"
              aria-label="Close"
            >
              ✕
            </button>
          </div>

          <div className="flex-1 flex flex-col justify-center text-center">
            <div className="mx-auto mb-5 h-16 w-16 rounded-full bg-emerald-100 flex items-center justify-center text-3xl">
              ✓
            </div>

            <h2 className="text-2xl font-extrabold text-gray-900">
              {lang === 'bn' ? 'অর্ডার সফলভাবে করা হয়েছে!' : 'Order placed successfully!'}
            </h2>

            <p className="mt-2 text-gray-500">
              {lang === 'bn'
                ? 'Cash on Delivery নির্বাচন করা হয়েছে। পণ্য পৌঁছানোর সময় টাকা পরিশোধ করবেন।'
                : 'Cash on Delivery is selected. Pay when your order is delivered.'}
            </p>

            <div className="mt-6 rounded-2xl bg-gray-50 border p-5 text-left space-y-3">
              <div className="flex justify-between gap-4">
                <span className="text-gray-500">
                  {lang === 'bn' ? 'অর্ডার নম্বর' : 'Order No.'}
                </span>
                <span className="font-bold text-right break-all">{orderPlaced.orderNumber}</span>
              </div>

              <div className="flex justify-between gap-4">
                <span className="text-gray-500">
                  {lang === 'bn' ? 'পেমেন্ট' : 'Payment'}
                </span>
                <span className="font-bold">
                  {lang === 'bn' ? 'ক্যাশ অন ডেলিভারি' : 'Cash on Delivery'}
                </span>
              </div>

              <div className="flex justify-between gap-4">
                <span className="text-gray-500">
                  {lang === 'bn' ? 'মোট' : 'Total'}
                </span>
                <span className="font-extrabold text-emerald-700">
                  {formatPrice(orderPlaced.totalAmount)}
                </span>
              </div>

              <div>
                <div className="text-gray-500">
                  {lang === 'bn' ? 'ডেলিভারি ঠিকানা' : 'Delivery address'}
                </div>
                <div className="mt-1 font-semibold text-gray-800">{orderPlaced.customer.address}</div>
              </div>
            </div>

            <button
              onClick={closeDrawer}
              className="mt-6 w-full rounded-2xl bg-emerald-700 py-3 font-bold text-white hover:bg-emerald-800"
            >
              {lang === 'bn' ? 'ঠিক আছে' : 'Done'}
            </button>
          </div>
        </div>
      </div>
    );
  }

  // ------------------------------------------------------------
  // Checkout / payment method view
  // ------------------------------------------------------------
  if (checkoutOpen) {
    return (
      <div className="fixed inset-0 z-[9999] flex justify-end bg-black/50 backdrop-blur-sm">
        <div className="w-full max-w-md bg-white h-full p-6 shadow-2xl overflow-y-auto flex flex-col">
          <div className="flex items-center justify-between border-b pb-4 mb-5">
            <div>
              <h2 className="text-xl font-bold">
                {lang === 'bn' ? 'চেকআউট' : 'Checkout'}
              </h2>
              <p className="text-xs text-gray-500 mt-1">
                {lang === 'bn' ? 'পেমেন্ট পদ্ধতি নির্বাচন করুন' : 'Choose a payment method'}
              </p>
            </div>
            <button
              onClick={closeDrawer}
              className="h-8 w-8 rounded-full bg-gray-100 flex items-center justify-center font-bold text-gray-500 hover:bg-gray-200"
              aria-label="Close"
            >
              ✕
            </button>
          </div>

          <div className="space-y-4 flex-1">
            <div className="rounded-2xl border p-4 bg-gray-50">
              <div className="flex items-center justify-between">
                <span className="font-semibold text-gray-700">
                  {lang === 'bn' ? 'অর্ডার মোট' : 'Order total'}
                </span>
                <span className="font-extrabold text-emerald-700 text-xl">
                  {formatPrice(totalAmount)}
                </span>
              </div>
            </div>

            <div>
              <p className="text-sm font-bold text-gray-800 mb-3">
                {lang === 'bn' ? 'Payment Method' : 'Payment Method'}
              </p>

              <div className="space-y-3">
                <label className={`block rounded-2xl border p-4 cursor-pointer ${paymentMethod === 'online' ? 'border-emerald-600 bg-emerald-50' : 'border-gray-200'}`}>
                  <div className="flex items-start gap-3">
                    <input
                      type="radio"
                      name="paymentMethod"
                      value="online"
                      checked={paymentMethod === 'online'}
                      onChange={(e) => setPaymentMethod(e.target.value)}
                      className="mt-1"
                    />
                    <div>
                      <div className="font-bold text-gray-900">
                        {lang === 'bn' ? 'অনলাইন পেমেন্ট' : 'Online Payment'}
                      </div>
                      <div className="text-xs text-gray-500 mt-1">
                        {lang === 'bn'
                          ? 'SSLCommerz Sandbox ব্যবহার করে পেমেন্ট করুন'
                          : 'Pay securely through SSLCommerz Sandbox'}
                      </div>
                    </div>
                  </div>
                </label>

                <label className={`block rounded-2xl border p-4 cursor-pointer ${paymentMethod === 'cod' ? 'border-emerald-600 bg-emerald-50' : 'border-gray-200'}`}>
                  <div className="flex items-start gap-3">
                    <input
                      type="radio"
                      name="paymentMethod"
                      value="cod"
                      checked={paymentMethod === 'cod'}
                      onChange={(e) => setPaymentMethod(e.target.value)}
                      className="mt-1"
                    />
                    <div>
                      <div className="font-bold text-gray-900">
                        {lang === 'bn' ? 'ক্যাশ অন ডেলিভারি' : 'Cash on Delivery'}
                      </div>
                      <div className="text-xs text-gray-500 mt-1">
                        {lang === 'bn'
                          ? 'পণ্য হাতে পাওয়ার সময় টাকা পরিশোধ করুন'
                          : 'Pay when the order is delivered'}
                      </div>
                    </div>
                  </div>
                </label>
              </div>
            </div>

            <div className="space-y-3">
              <div>
                <label className="text-sm font-semibold text-gray-700">
                  {lang === 'bn' ? 'নাম' : 'Name'}
                </label>
                <input
                  value={customerName}
                  onChange={(e) => setCustomerName(e.target.value)}
                  placeholder={lang === 'bn' ? 'আপনার নাম' : 'Your name'}
                  className="mt-1 w-full rounded-xl border border-gray-200 px-4 py-3 outline-none focus:border-emerald-500"
                />
              </div>

              <div>
                <label className="text-sm font-semibold text-gray-700">
                  {lang === 'bn' ? 'ফোন নম্বর' : 'Phone number'}
                </label>
                <input
                  value={customerPhone}
                  onChange={(e) => setCustomerPhone(e.target.value)}
                  placeholder="01XXXXXXXXX"
                  inputMode="tel"
                  className="mt-1 w-full rounded-xl border border-gray-200 px-4 py-3 outline-none focus:border-emerald-500"
                />
              </div>

              <div>
                <label className="text-sm font-semibold text-gray-700">
                  {lang === 'bn' ? 'ডেলিভারি ঠিকানা' : 'Delivery address'}
                </label>
                <textarea
                  value={deliveryAddress}
                  onChange={(e) => setDeliveryAddress(e.target.value)}
                  rows={3}
                  placeholder={lang === 'bn' ? 'বাড়ি, রাস্তা, এলাকা, জেলা' : 'House, road, area, district'}
                  className="mt-1 w-full rounded-xl border border-gray-200 px-4 py-3 outline-none focus:border-emerald-500 resize-none"
                />
              </div>
            </div>
          </div>

          <div className="border-t pt-4 mt-5">
            {paymentMethod === 'cod' ? (
              <button
                onClick={handleCashOnDelivery}
                disabled={loading}
                className="w-full rounded-2xl bg-emerald-700 py-3 font-bold text-white hover:bg-emerald-800 disabled:bg-emerald-400"
              >
                {lang === 'bn' ? 'Cash on Delivery অর্ডার করুন' : 'Place COD Order'}
              </button>
            ) : (
              <button
                onClick={handleOnlineCheckout}
                disabled={loading}
                className="w-full rounded-2xl bg-emerald-700 py-3 font-bold text-white hover:bg-emerald-800 disabled:bg-emerald-400"
              >
                {loading
                  ? (lang === 'bn' ? 'SSLCommerz খুলছে...' : 'Redirecting to SSLCommerz...')
                  : (lang === 'bn' ? 'অনলাইন পেমেন্ট করুন' : 'Continue to Online Payment')}
              </button>
            )}

            <button
              onClick={() => setCheckoutOpen(false)}
              disabled={loading}
              className="w-full mt-2 rounded-2xl border border-gray-200 py-3 font-semibold text-gray-700 hover:bg-gray-50 disabled:opacity-60"
            >
              {lang === 'bn' ? 'কার্টে ফিরে যান' : 'Back to Cart'}
            </button>
          </div>
        </div>
      </div>
    );
  }

  // ------------------------------------------------------------
  // Cart view
  // ------------------------------------------------------------
  return (
    <div className="fixed inset-0 z-[9999] flex justify-end bg-black/50 backdrop-blur-sm">
      <div className="w-full max-w-md bg-white h-full p-6 flex flex-col justify-between shadow-2xl overflow-y-auto">
        <div>
          <div className="flex items-center justify-between border-b pb-4 mb-4">
            <h2 className="text-xl font-bold flex items-center gap-2">
              🛒 {lang === 'bn' ? 'আপনার কার্ট' : 'Your Cart'}
            </h2>
            <button
              onClick={closeDrawer}
              className="h-8 w-8 rounded-full bg-gray-100 flex items-center justify-center font-bold text-gray-500 hover:bg-gray-200"
            >
              ✕
            </button>
          </div>

          {cartItems.length === 0 ? (
            <div className="py-12 text-center text-gray-500">
              {lang === 'bn' ? 'কার্ট খালি আছে' : 'Your cart is empty'}
            </div>
          ) : (
            <div className="space-y-4">
              {cartItems.map((item) => {
                const itemTitle = smartTranslate(item, 'title');
                const itemUnit = smartTranslate(item, 'unit');
                const unitPrice = formatPrice(item.price);
                const totalPrice = formatPrice(item.price * item.quantity);

                return (
                  <div key={item.id} className="flex gap-4 p-3 border rounded-2xl bg-gray-50 items-center justify-between">
                    <img src={item.image || item.image_url} alt={itemTitle} className="w-16 h-16 object-cover rounded-xl" />

                    <div className="flex-1">
                      <h3 className="font-bold text-gray-800">{itemTitle}</h3>
                      <p className="text-xs text-gray-500">
                        {unitPrice} / {itemUnit}
                      </p>

                      <div className="flex items-center gap-2 mt-2">
                        <button
                          onClick={() => updateQuantity(item.id, -1)}
                          className="w-6 h-6 bg-gray-200 rounded flex items-center justify-center font-bold"
                        >
                          -
                        </button>
                        <span className="text-sm font-bold">
                          {formatNum(item.quantity)}
                        </span>
                        <button
                          onClick={() => updateQuantity(item.id, 1)}
                          className="w-6 h-6 bg-gray-200 rounded flex items-center justify-center font-bold"
                        >
                          +
                        </button>
                      </div>
                    </div>

                    <div className="text-right">
                      <p className="font-extrabold text-emerald-700">{totalPrice}</p>
                      <button
                        onClick={() => removeFromCart(item.id)}
                        className="text-xs text-red-500 hover:underline mt-1 block"
                      >
                        {lang === 'bn' ? 'মুছুন' : 'Remove'}
                      </button>
                    </div>
                  </div>
                );
              })}
            </div>
          )}
        </div>

        {cartItems.length > 0 && (
          <div className="border-t pt-4 mt-6">
            <div className="flex justify-between items-center mb-4">
              <span className="font-bold text-gray-700">
                {lang === 'bn' ? 'মোট:' : 'Total:'}
              </span>
              <span className="text-2xl font-extrabold text-emerald-700">
                {formatPrice(totalAmount)}
              </span>
            </div>

            <button
              onClick={openCheckout}
              className="w-full text-white py-3 rounded-2xl font-bold transition flex items-center justify-center gap-2 bg-emerald-700 hover:bg-emerald-800 cursor-pointer"
            >
              <span>⚡ {lang === 'bn' ? 'চেকআউট করুন' : 'Proceed to Checkout'}</span>
            </button>
          </div>
        )}
      </div>
    </div>
  );
}
