// demoCrops.js — DEVELOPMENT-ONLY fallback so the Marketplace UI can still be
// demonstrated if the backend/API is down. Every item is flagged with
// `is_demo: true`; ProductCard/QuickViewModal/ProductDetails all render a
// visible "DEMO" badge whenever that flag is set, so demo data is never
// confused with real database records. Marketplace.jsx only reaches for this
// list on a failed API call, and only in dev builds (import.meta.env.DEV) —
// see Marketplace.jsx. The moment the real API responds, this list is
// dropped and real data takes over.
export const DEMO_CROPS = [
  {
    crop_id: 'demo-1',
    crop_name: 'আম (ডেমো)',
    category_name: 'Fruits',
    farmer_name: 'ডেমো কৃষক',
    district_name: 'Rajshahi',
    price_per_unit: 90,
    unit: 'kg',
    quantity: 40,
    is_organic: true,
    is_new: true,
    is_demo: true,
    images: null,
    description: 'This is placeholder demo data shown because the crops API could not be reached.',
    created_at: new Date().toISOString(),
  },
  {
    crop_id: 'demo-2',
    crop_name: 'আলু (ডেমো)',
    category_name: 'Vegetables',
    farmer_name: 'ডেমো কৃষক',
    district_name: 'Munshiganj',
    price_per_unit: 28,
    unit: 'kg',
    quantity: 5,
    is_organic: false,
    is_new: false,
    is_demo: true,
    images: null,
    description: 'This is placeholder demo data shown because the crops API could not be reached.',
    created_at: new Date().toISOString(),
  },
  {
    crop_id: 'demo-3',
    crop_name: 'মসুর ডাল (ডেমো)',
    category_name: 'Pulses',
    farmer_name: 'ডেমো কৃষক',
    district_name: 'Faridpur',
    price_per_unit: 110,
    unit: 'kg',
    quantity: 0,
    is_organic: false,
    is_new: false,
    is_demo: true,
    images: null,
    description: 'This is placeholder demo data shown because the crops API could not be reached.',
    created_at: new Date().toISOString(),
  },
];