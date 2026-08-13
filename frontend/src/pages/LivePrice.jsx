import React, { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { useLang } from '../context/LangContext.jsx';
import { getLivePrices } from '../api/prices.api.js';

const toBnNum = (num) => {
    if (num == null || num === '') return '';
    const bnNums = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    return String(num).replace(/[0-9]/g, (digit) => bnNums[digit]);
};

// Fallback seeds — used only if the API is offline. Same set + shape as the
// live API returns (crop_name in Bengali matches market_prices seed).
const seedCrops = [
    { crop_name: 'কাঁচামরিচ', category_name: 'lp_spices',     bazar_rate: 160, agromart_min: 140, agromart_max: 140, agromart_avg: 140, trend: 'stable', trend_pct: 0, images: ['/crops/kachamorich.jpg'], best_crop_id: null, unit: 'kg' },
    { crop_name: 'বেগুন',      category_name: 'lp_vegetables', bazar_rate: 70,  agromart_min: 58,  agromart_max: 58,  agromart_avg: 58,  trend: 'stable', trend_pct: 0, images: ['/crops/begun.jpg'],       best_crop_id: null, unit: 'kg' },
    { crop_name: 'লাউ',        category_name: 'lp_vegetables', bazar_rate: 60,  agromart_min: 50,  agromart_max: 50,  agromart_avg: 50,  trend: 'stable', trend_pct: 0, images: ['/crops/lau.jpg'],         best_crop_id: null, unit: 'piece' },
    { crop_name: 'আলু',        category_name: 'lp_vegetables', bazar_rate: 40,  agromart_min: 32,  agromart_max: 32,  agromart_avg: 32,  trend: 'stable', trend_pct: 0, images: ['/crops/alu.jpg'],         best_crop_id: null, unit: 'kg' },
    { crop_name: 'টমেটো',      category_name: 'lp_vegetables', bazar_rate: 85,  agromart_min: 70,  agromart_max: 70,  agromart_avg: 70,  trend: 'stable', trend_pct: 0, images: ['/crops/tomato.jpg'],      best_crop_id: null, unit: 'kg' },
    { crop_name: 'পেঁয়াজ',    category_name: 'lp_spices',     bazar_rate: 100, agromart_min: 88,  agromart_max: 88,  agromart_avg: 88,  trend: 'stable', trend_pct: 0, images: ['/crops/peyaj.jpg'],       best_crop_id: null, unit: 'kg' },
    { crop_name: 'সরিষা',      category_name: 'lp_grains',     bazar_rate: 110, agromart_min: 95,  agromart_max: 95,  agromart_avg: 95,  trend: 'stable', trend_pct: 0, images: ['/crops/shorisha.jpg'],    best_crop_id: null, unit: 'kg' },
    { crop_name: 'মুগ ডাল',   category_name: 'lp_grains',     bazar_rate: 130, agromart_min: 115, agromart_max: 115, agromart_avg: 115, trend: 'stable', trend_pct: 0, images: ['/crops/mugdal.jpg'],      best_crop_id: null, unit: 'kg' },
    { crop_name: 'মসুর ডাল',  category_name: 'lp_grains',     bazar_rate: 140, agromart_min: 125, agromart_max: 125, agromart_avg: 125, trend: 'stable', trend_pct: 0, images: ['/crops/mosurdal.jpg'],    best_crop_id: null, unit: 'kg' },
];

// Map Bengali category names (from DB) to your existing i18n keys, so the
// category chip and dropdown filter continue to work with translations.
const CAT_BY_BN = {
    'সবজি': 'lp_vegetables', 'শাকসবজি': 'lp_vegetables',
    'দানাশস্য': 'lp_grains', 'শস্য': 'lp_grains', 'ডাল': 'lp_grains',
    'মসলা': 'lp_spices',
    'ফল': 'lp_fruits',
};
const catKeyOf = (row) => CAT_BY_BN[row.category_name] || row.category_name || 'lp_vegetables';
// Map Bengali crop names -> English display names for the seeded 9 crops.
// If a crop isn't in this map (e.g. a farmer added a new one), the Bengali
// name is used as-is even in English mode. Long-term fix: crop_name_en column.
const CROP_EN = {
    'কাঁচামরিচ': 'Green Chili',
    'বেগুন': 'Eggplant',
    'লাউ': 'Bottle Gourd',
    'আলু': 'Potato',
    'টমেটো': 'Tomato',
    'পেঁয়াজ': 'Onion',
    'সরিষা': 'Mustard',
    'মুগ ডাল': 'Mung Dal',
    'মসুর ডাল': 'Masoor Dal',
};
const cropDisplayName = (row, lang) => (lang === 'en' && CROP_EN[row.crop_name]) || row.crop_name;


// PRICE_LABEL_PATCHED
// LP_TRANSLATE_PATCHED
const LivePrice = () => {
    const { t, lang } = useLang();
    const [crops, setCrops] = useState(seedCrops);
    const [search, setSearch] = useState('');
    const [category, setCategory] = useState('');
    const [userRole, setUserRole] = useState('buyer');

    // Fetch live data on mount AND when role changes (server-side sort differs)
    useEffect(() => {
        let alive = true;
        getLivePrices({ role: userRole })
            .then((data) => {
                if (!alive) return;
                if (data && Array.isArray(data.prices) && data.prices.length > 0) {
                    setCrops(data.prices);
                }
            })
            .catch(() => console.log('/api/prices offline, showing seeds'));
        return () => { alive = false; };
    }, [userRole]);

    const filteredCrops = crops.filter((c) => {
        const cropName = (c.crop_name || '').toLowerCase();
        const matchesSearch = cropName.includes(search.toLowerCase());
        const matchesCat = category ? catKeyOf(c) === category : true;
        return matchesSearch && matchesCat;
    });

    return (
        <div style={{ background: '#f0f7ee', minHeight: '100vh', paddingBottom: '64px' }}>

            {/* Header Banner */}
            <div style={{ background: '#1e5e2f', padding: '40px 16px 60px', textAlign: 'center', color: '#fff' }}>
                <span style={{ background: 'rgba(255, 255, 255, 0.2)', padding: '6px 16px', borderRadius: '20px', fontSize: '13px', fontWeight: '500', display: 'inline-flex', alignItems: 'center', gap: '6px' }}>
                    <span style={{ height: '8px', width: '8px', backgroundColor: '#4caf50', borderRadius: '50%', display: 'inline-block' }}></span>
                    {t('lp_badge')}
                </span>

                <h1 style={{ fontSize: '28px', fontWeight: '800', marginTop: '16px', marginBottom: '20px', textAlign: 'center' }}>
                    {userRole === 'buyer' ? t('lp_buyerTitle') : t('lp_farmerTitle')}
                </h1>

                <div style={{ display: 'inline-flex', background: 'rgba(0, 0, 0, 0.2)', padding: '4px', borderRadius: '30px' }}>
                    <button onClick={() => setUserRole('buyer')} style={roleBtnStyle(userRole === 'buyer')}>{t('lp_buyerBtn')}</button>
                    <button onClick={() => setUserRole('farmer')} style={roleBtnStyle(userRole === 'farmer')}>{t('lp_farmerBtn')}</button>
                </div>
            </div>

            {/* Search + filter */}
            <div className="container" style={{ maxWidth: '1100px', margin: '-30px auto 0', padding: '0 16px', position: 'relative', zIndex: 10 }}>
                <div style={{ background: '#fff', padding: '16px', borderRadius: '12px', display: 'flex', gap: '12px', marginBottom: '24px', boxShadow: '0 4px 12px rgba(0,0,0,0.08)' }}>
                    <input type="text" placeholder={t('lp_searchPlaceholder')} value={search} onChange={(e) => setSearch(e.target.value)}
                        style={{ flex: 1, padding: '10px 14px', border: '1px solid #e0e0e0', borderRadius: '8px', outline: 'none' }} />
                    <select value={category} onChange={(e) => setCategory(e.target.value)}
                        style={{ padding: '10px 14px', border: '1px solid #e0e0e0', borderRadius: '8px', outline: 'none', background: '#fff' }}>
                        <option value="">{t('lp_allCat')}</option>
                        <option value="lp_grains">{t('lp_grains')}</option>
                        <option value="lp_vegetables">{t('lp_vegetables')}</option>
                        <option value="lp_spices">{t('lp_spices')}</option>
                    </select>
                </div>

                {/* Cards */}
                <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(280px, 1fr))', gap: '16px' }}>
                    {filteredCrops.map((c) => (
                        <CropCard key={c.crop_name} c={c} role={userRole} lang={lang} t={t} />
                    ))}
                </div>
            </div>
        </div>
    );
};

const roleBtnStyle = (active) => ({
    padding: '8px 20px', borderRadius: '25px', border: 'none',
    background: active ? '#fff' : 'transparent',
    color: active ? '#1e5e2f' : '#fff',
    fontWeight: '700', cursor: 'pointer', fontSize: '14px', transition: 'all 0.3s ease',
});

function CropCard({ c, role, lang, t }) {
    const img = Array.isArray(c.images) ? c.images[0] : c.images;
    const bazar = num(c.bazar_rate);
    const amMin = num(c.agromart_min);
    const amMax = num(c.agromart_max);
    const amAvg = num(c.agromart_avg);
    const savings = bazar != null && amMin != null ? Math.max(0, bazar - amMin) : null;
    const gap = bazar != null && amMax != null ? Math.max(0, bazar - amMax) : null;

    return (
        <div style={{ background: '#fff', padding: '16px', borderRadius: '16px', border: '1px solid #e0e0e0', boxShadow: '0 4px 12px rgba(0,0,0,0.03)', display: 'flex', flexDirection: 'column' }}>
            <div style={{ width: '100%', height: '140px', borderRadius: '12px', overflow: 'hidden', marginBottom: '12px', background: '#f5f5f5', position: 'relative' }}>
                {img ? (
                    <img src={img} alt={c.crop_name} style={{ width: '100%', height: '100%', objectFit: 'cover' }} />
                ) : (
                    <div style={{ display: 'grid', placeItems: 'center', height: '100%', fontSize: '48px' }}>🌾</div>
                )}
                {/* Trend chip — top-right of image */}
                <TrendChip trend={c.trend} pct={c.trend_pct} lang={lang} t={t} />
            </div>

            <div>
                <h3 style={{ margin: 0, fontSize: '16px', fontWeight: '700' }}>{cropDisplayName(c, lang)}</h3>
                <small style={{ color: '#666' }}>{t(catKeyOf(c))}</small>
            </div>

            {/* Prices — different visual weight per role */}
            <div style={{ marginTop: '12px', display: 'flex', justifyContent: 'space-between', alignItems: 'flex-end', flex: 1 }}>
                {role === 'buyer' ? (
                    <div>
                        <div style={{ display: 'inline-flex', alignItems: 'center', gap: '5px', background: '#e8f5e9', color: '#2e7d32', padding: '2px 8px', borderRadius: '10px', fontSize: '11px', fontWeight: '700', textTransform: 'uppercase', letterSpacing: '0.5px' }}><span style={{ fontSize: '9px' }}>●</span>{t('lp_agroPrice')}</div>
                        <div style={{ fontSize: '20px', fontWeight: '800', color: '#2e7d32' }}>
                            ৳ {lang === 'bn' ? toBnNum(amMin ?? '—') : (amMin ?? '—')} /{c.unit === 'piece' ? t('lp_perPiece') : t('lp_perKg')}
                        </div>
                        <div style={{ fontSize: '12px', textDecoration: 'line-through', color: '#999' }}>
                            {t('lp_marketPrice')}: ৳ {lang === 'bn' ? toBnNum(bazar ?? '—') : (bazar ?? '—')}
                        </div>
                    </div>
                ) : (
                    <div>
                        <div style={{ display: 'inline-flex', alignItems: 'center', gap: '5px', background: '#e3f2fd', color: '#1565c0', padding: '2px 8px', borderRadius: '10px', fontSize: '11px', fontWeight: '700', textTransform: 'uppercase', letterSpacing: '0.5px' }}><span style={{ fontSize: '9px' }}>●</span>{t('lp_marketPrice')}</div>
                        <div style={{ fontSize: '20px', fontWeight: '800', color: '#1e5e2f' }}>
                            ৳ {lang === 'bn' ? toBnNum(bazar ?? '—') : (bazar ?? '—')} /{c.unit === 'piece' ? t('lp_perPiece') : t('lp_perKg')}
                        </div>
                        <div style={{ fontSize: '12px', color: '#666' }}>
                            {t('lp_othersCharge')}: ৳ {lang === 'bn' ? toBnNum(amAvg != null ? Math.round(amAvg) : '—') : (amAvg != null ? Math.round(amAvg) : '—')}
                        </div>
                    </div>
                )}

                {/* Savings / gap pill */}
                {role === 'buyer' && savings > 0 && (
                    <span style={{ background: '#e8f5e9', color: '#2e7d32', padding: '4px 10px', borderRadius: '12px', fontSize: '12px', fontWeight: '600', whiteSpace: 'nowrap' }}>
                        ৳ {lang === 'bn' ? toBnNum(savings) : savings} {t('lp_savings')}
                    </span>
                )}
                {role === 'farmer' && gap > 0 && (
                    <span style={{ background: '#fff3e0', color: '#e65100', padding: '4px 10px', borderRadius: '12px', fontSize: '12px', fontWeight: '600', whiteSpace: 'nowrap' }}>
                        ৳ {lang === 'bn' ? toBnNum(gap) : gap} {t('lp_diff')}
                    </span>
                )}
            </div>

            {/* Role-specific CTA */}
            <div style={{ marginTop: '14px' }}>
                {role === 'buyer' ? (
                    c.best_crop_id ? (
                        <Link to={`/marketplace/${c.best_crop_id}`}
                              style={ctaBtnStyle('#2e7d32')}>
                            {t('lp_orderNow')} →
                        </Link>
                    ) : (
                        <span style={{ display: 'block', textAlign: 'center', fontSize: '12px', color: '#999' }}>{t('lp_noListings')}</span>
                    )
                ) : (
                    <Link to={`/farmer/crops/new?crop=${encodeURIComponent(c.crop_name)}`}
                          style={ctaBtnStyle('#e65100')}>
                        {t('lp_listNow')} →
                    </Link>
                )}
            </div>
        </div>
    );
}

const ctaBtnStyle = (color) => ({
    display: 'block', width: '100%', textAlign: 'center',
    background: color, color: '#fff',
    padding: '10px 14px', borderRadius: '10px', border: 'none',
    fontWeight: '700', fontSize: '13px', cursor: 'pointer',
    textDecoration: 'none',
});

function TrendChip({ trend, pct, lang, t }) {
    const map = {
        up:     { icon: '↑', bg: '#ffebee', color: '#c62828' },
        down:   { icon: '↓', bg: '#e8f5e9', color: '#2e7d32' },
        stable: { icon: '→', bg: '#f5f5f5', color: '#666' },
    };
    const cfg = map[trend] || map.stable;
    const displayPct = pct != null ? Math.abs(Number(pct)) : null;
    return (
        <span style={{
            position: 'absolute', top: '8px', right: '8px',
            background: cfg.bg, color: cfg.color,
            padding: '3px 8px', borderRadius: '10px',
            fontSize: '11px', fontWeight: '700',
            display: 'inline-flex', alignItems: 'center', gap: '3px',
        }}>
            {cfg.icon} {displayPct != null ? `${lang === 'bn' ? toBnNum(displayPct) : displayPct}%` : ''}
        </span>
    );
}

function num(v) {
    if (v == null || v === '') return null;
    const n = Number(v);
    return Number.isFinite(n) ? n : null;
}

export default LivePrice;
