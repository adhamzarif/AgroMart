import React, { useState, useEffect } from 'react';
import { useLang } from '../context/LangContext.jsx'; 

const toBnNum = (num) => {
    const bnNums = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    return String(num).replace(/[0-9]/g, (digit) => bnNums[digit]);
};

const seedCrops = [
    { id: 1, key: 'crop_kachamorich', catKey: 'lp_spices', market: 160, agrofin: 140, gap: 20, image: '/crops/kachamorich.jpg' },
    { id: 2, key: 'crop_begun', catKey: 'lp_vegetables', market: 70, agrofin: 58, gap: 12, image: '/crops/begun.jpg' },
    { id: 3, key: 'crop_lau', catKey: 'lp_vegetables', market: 60, agrofin: 50, gap: 10, image: '/crops/lau.jpg' },
    { id: 4, key: 'crop_alu', catKey: 'lp_vegetables', market: 40, agrofin: 32, gap: 8, image: '/crops/alu.jpg' },
    { id: 5, key: 'crop_tomato', catKey: 'lp_vegetables', market: 85, agrofin: 70, gap: 15, image: '/crops/tomato.jpg' },
    { id: 6, key: 'crop_peyaj', catKey: 'lp_spices', market: 100, agrofin: 88, gap: 12, image: '/crops/peyaj.jpg' },
    { id: 7, key: 'crop_shorisha', catKey: 'lp_grains', market: 110, agrofin: 95, gap: 15, image: '/crops/shorisha.jpg' },
    { id: 8, key: 'crop_mugdal', catKey: 'lp_grains', market: 130, agrofin: 115, gap: 15, image: '/crops/mugdal.jpg' },
    { id: 9, key: 'crop_mosurdal', catKey: 'lp_grains', market: 140, agrofin: 125, gap: 15, image: '/crops/mosurdal.jpg' }
];

const LivePrice = () => {
    const { t, lang } = useLang(); 

    const [crops, setCrops] = useState(seedCrops);
    const [search, setSearch] = useState('');
    const [category, setCategory] = useState('');
    const [userRole, setUserRole] = useState('buyer'); // 'buyer' or 'farmer'

    useEffect(() => {
        fetch('/api/crops')
            .then(res => res.json())
            .then(data => {
                if (data && (Array.isArray(data) || Array.isArray(data.crops))) {
                    const list = Array.isArray(data) ? data : data.crops;
                    if (list.length > 0) {
                        const mergedCrops = list.map(item => {
                            const localSeed = seedCrops.find(s => s.id === item.id);
                            return {
                                ...item,
                                key: item.key || (localSeed ? localSeed.key : 'crop_tomato'),
                                catKey: item.catKey || (localSeed ? localSeed.catKey : 'lp_vegetables'),
                                image: item.image || (localSeed ? localSeed.image : '/crops/tomato.jpg')
                            };
                        });
                        setCrops(mergedCrops);
                    }
                }
            })
            .catch(() => console.log("API offline, showing seeds"));
    }, []);

    const filteredCrops = crops.filter(c => {
        const cropName = (t(c.key) || '').toLowerCase();
        const matchesSearch = cropName.includes(search.toLowerCase());
        const matchesCat = category ? c.catKey === category : true;
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
                
                {/* Clean Title Without Emoji */}
                <h1 style={{ fontSize: '28px', fontWeight: '800', marginTop: '16px', marginBottom: '20px', textAlign: 'center' }}>
                    {userRole === 'buyer' ? t('lp_buyerTitle') : t('lp_farmerTitle')}
                </h1>

                {/* Buyer / Farmer Switcher */}
                <div style={{ display: 'inline-flex', background: 'rgba(0, 0, 0, 0.2)', padding: '4px', borderRadius: '30px' }}>
                    <button 
                        onClick={() => setUserRole('buyer')}
                        style={{
                            padding: '8px 20px',
                            borderRadius: '25px',
                            border: 'none',
                            background: userRole === 'buyer' ? '#fff' : 'transparent',
                            color: userRole === 'buyer' ? '#1e5e2f' : '#fff',
                            fontWeight: '700',
                            cursor: 'pointer',
                            fontSize: '14px',
                            transition: 'all 0.3s ease'
                        }}
                    >
                        {t('lp_buyerBtn')}
                    </button>
                    <button 
                        onClick={() => setUserRole('farmer')}
                        style={{
                            padding: '8px 20px',
                            borderRadius: '25px',
                            border: 'none',
                            background: userRole === 'farmer' ? '#fff' : 'transparent',
                            color: userRole === 'farmer' ? '#1e5e2f' : '#fff',
                            fontWeight: '700',
                            cursor: 'pointer',
                            fontSize: '14px',
                            transition: 'all 0.3s ease'
                        }}
                    >
                        {t('lp_farmerBtn')}
                    </button>
                </div>
            </div>

            {/* Main Content Container */}
            <div className="container" style={{ maxWidth: '1100px', margin: '-30px auto 0', padding: '0 16px', position: 'relative', zIndex: 10 }}>
                
                {/* Search & Filter */}
                <div style={{ background: '#fff', padding: '16px', borderRadius: '12px', display: 'flex', gap: '12px', marginBottom: '24px', boxShadow: '0 4px 12px rgba(0,0,0,0.08)' }}>
                    <input 
                        type="text" 
                        placeholder={t('lp_searchPlaceholder')} 
                        value={search} 
                        onChange={e => setSearch(e.target.value)} 
                        style={{ flex: 1, padding: '10px 14px', border: '1px solid #e0e0e0', borderRadius: '8px', outline: 'none' }} 
                    />
                    <select 
                        value={category} 
                        onChange={e => setCategory(e.target.value)} 
                        style={{ padding: '10px 14px', border: '1px solid #e0e0e0', borderRadius: '8px', outline: 'none', background: '#fff' }}>
                        <option value="">{t('lp_allCat')}</option>
                        <option value="lp_grains">{t('lp_grains')}</option>
                        <option value="lp_vegetables">{t('lp_vegetables')}</option>
                        <option value="lp_spices">{t('lp_spices')}</option>
                    </select>
                </div>

                {/* Crop Cards */}
                <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(280px, 1fr))', gap: '16px' }}>
                    {filteredCrops.map(c => (
                        <div key={c.id} style={{ background: '#fff', padding: '16px', borderRadius: '16px', border: '1px solid #e0e0e0', boxShadow: '0 4px 12px rgba(0,0,0,0.03)' }}>
                            <div style={{ width: '100%', height: '140px', borderRadius: '12px', overflow: 'hidden', marginBottom: '12px', background: '#f5f5f5' }}>
                                <img 
                                    src={c.image} 
                                    alt={t(c.key)} 
                                    style={{ width: '100%', height: '100%', objectFit: 'cover' }}
                                />
                            </div>

                            <div>
                                <h3 style={{ margin: 0, fontSize: '16px', fontWeight: '700' }}>
                                    {t(c.key)}
                                </h3>
                                <small style={{ color: '#666' }}>
                                    {t(c.catKey)}
                                </small>
                            </div>
                            
                            <div style={{ marginTop: '12px', display: 'flex', justifyContent: 'space-between', alignItems: 'flex-end' }}>
                                <div>
                                    <small style={{ color: '#666' }}>{t('lp_agroPrice')}</small>
                                    <div style={{ fontSize: '20px', fontWeight: '800', color: '#2e7d32' }}>
                                        ৳ {lang === 'bn' ? toBnNum(c.agrofin) : c.agrofin} /{t('lp_perKg')}
                                    </div>
                                    <div style={{ fontSize: '12px', textDecoration: 'line-through', color: '#999' }}>
                                        {t('lp_marketPrice')}: ৳ {lang === 'bn' ? toBnNum(c.market) : c.market}
                                    </div>
                                </div>
                                {c.gap && (
                                    <span style={{ background: '#e8f5e9', color: '#2e7d32', padding: '4px 10px', borderRadius: '12px', fontSize: '12px', fontWeight: '600' }}>
                                        ৳ {lang === 'bn' ? toBnNum(c.gap) : c.gap} {userRole === 'farmer' ? t('lp_diff') : t('lp_savings')}
                                    </span>
                                )}
                            </div>
                        </div>
                    ))}
                </div>
            </div>
        </div>
    );
};

export default LivePrice;