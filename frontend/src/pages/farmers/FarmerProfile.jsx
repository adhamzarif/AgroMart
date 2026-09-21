// FarmerProfile.jsx — public farmer page: profile card, rating breakdown, reviews list, active crops.
import { useEffect, useState } from 'react';
import { Link, useParams } from 'react-router-dom';
import { useLang } from '../../context/LangContext.jsx';
import { api } from '../../api/client.js';

const BN_DIGITS = ['০','১','২','৩','৪','৫','৬','৭','৮','৯'];

const DISTRICT_BN = {
  'Dhaka':'ঢাকা','Chittagong':'চট্টগ্রাম','Rajshahi':'রাজশাহী','Khulna':'খুলনা',
  'Sylhet':'সিলেট','Barishal':'বরিশাল','Rangpur':'রংপুর','Mymensingh':'ময়মনসিংহ','Rangamati':'রাঙ্গামাটি',
};

export default function FarmerProfile() {
  const { id } = useParams();
  const { t, lang } = useLang();
  const [farmer, setFarmer] = useState(null);
  const [reviews, setReviews] = useState([]);
  const [crops, setCrops] = useState([]);
  const [loading, setLoading] = useState(true);

  const fmt = (n) => {
    if (n === null || n === undefined) return '';
    const s = String(n);
    return lang === 'bn' ? s.replace(/\d/g, (d) => BN_DIGITS[+d]) : s;
  };
  const dName = (n) => (lang === 'en' ? (n || '') : (DISTRICT_BN[n] || n || ''));

  useEffect(() => {
    setLoading(true);
    Promise.all([
      api.get(`/api/farmers/${id}`),
      api.get(`/api/farmers/${id}/reviews?limit=50`),
      api.get(`/api/farmers/${id}/crops`),
    ])
      .then(([f, r, c]) => {
        setFarmer(f);
        setReviews(r.reviews || []);
        setCrops(c.crops || []);
      })
      .finally(() => setLoading(false));
  }, [id]);

  if (loading) {
    return (
      <div className="mx-auto max-w-6xl px-6 py-14">
        <div className="h-40 animate-pulse rounded-2xl bg-gray-100" />
      </div>
    );
  }

  if (!farmer) {
    return (
      <div className="mx-auto max-w-6xl px-6 py-14 text-center text-gray-500">
        {t('fp_not_found')}
      </div>
    );
  }

  const avg = Number(farmer.avg_overall || 0);
  const recommendPct = farmer.review_count > 0
    ? Math.round((farmer.recommend_count / farmer.review_count) * 100)
    : 0;

  return (
    <div className="bg-gray-50 pb-20">
      <div className="border-b border-gray-100 bg-white">
        <div className="mx-auto max-w-6xl px-6 py-10">
          <div className="flex flex-wrap items-start gap-6">
            <div className="grid h-24 w-24 flex-shrink-0 place-items-center rounded-full bg-gradient-to-br from-green-400 to-emerald-600 text-3xl font-bold text-white shadow-md">
              {farmer.full_name.charAt(0)}
            </div>
            <div className="flex-1">
              <div className="flex flex-wrap items-center gap-3">
                <h1 className="text-3xl font-bold text-gray-900 font-display">
                  {farmer.full_name}
                </h1>
                <span className="inline-flex items-center gap-1 rounded-full bg-green-100 px-3 py-1 text-xs font-semibold text-green-800">
                  ✓ {t('fp_verified')}
                </span>
              </div>
              {farmer.district_name && (
                <div className="mt-1 text-sm text-gray-500">
                  📍 {dName(farmer.district_name)}
                </div>
              )}
              <div className="mt-4 flex flex-wrap gap-6">
                <Stat icon="⭐" value={fmt(avg.toFixed(1))} label={t('fp_avg_rating')} />
                <Stat icon="📝" value={fmt(farmer.review_count)} label={t('fp_reviews')} />
                <Stat icon="🌾" value={fmt(farmer.active_crops)} label={t('fp_active_crops')} />
                <Stat icon="📦" value={fmt(farmer.completed_orders)} label={t('fp_orders')} />
                {recommendPct > 0 && (
                  <Stat icon="👍" value={`${fmt(recommendPct)}%`} label={t('fp_recommend')} />
                )}
              </div>
            </div>
          </div>
        </div>
      </div>

      <div className="mx-auto grid max-w-6xl gap-8 px-6 py-10 lg:grid-cols-3">
        <div className="lg:col-span-1">
          <div className="rounded-2xl border border-gray-100 bg-white p-6 shadow-sm">
            <h2 className="mb-4 text-lg font-bold text-gray-900 font-display">
              {t('fp_breakdown')}
            </h2>
            <div className="space-y-3 text-sm">
              <RatingBar label={t('fp_quality')}       value={farmer.avg_quality}       fmt={fmt} />
              <RatingBar label={t('fp_delivery')}      value={farmer.avg_delivery}      fmt={fmt} />
              <RatingBar label={t('fp_communication')} value={farmer.avg_communication} fmt={fmt} />
              <RatingBar label={t('fp_overall')}       value={farmer.avg_overall}       fmt={fmt} bold />
            </div>
          </div>

          {crops.length > 0 && (
            <div className="mt-6 rounded-2xl border border-gray-100 bg-white p-6 shadow-sm">
              <h2 className="mb-4 text-lg font-bold text-gray-900 font-display">
                {t('fp_active_crops_list')}
              </h2>
              <div className="space-y-3">
                {crops.slice(0, 6).map((c) => (
                  <Link
                    key={c.crop_id}
                    to={`/marketplace/${c.crop_id}`}
                    className="flex items-center gap-3 rounded-lg p-2 transition hover:bg-gray-50"
                  >
                    <div className="h-12 w-12 flex-shrink-0 overflow-hidden rounded-lg bg-gray-100">
                      {Array.isArray(c.images) && c.images[0] ? (
                        <img src={c.images[0]} alt="" className="h-full w-full object-cover" />
                      ) : (
                        <div className="grid h-full place-items-center text-lg">🌾</div>
                      )}
                    </div>
                    <div className="min-w-0 flex-1">
                      <div className="truncate text-sm font-semibold text-gray-900">
                        {lang === 'en' && c.crop_name_en ? c.crop_name_en : c.crop_name}
                      </div>
                      <div className="text-xs text-gray-500">
                        ৳{fmt(Number(c.price_per_unit).toFixed(2))} / {c.unit}
                      </div>
                    </div>
                  </Link>
                ))}
              </div>
            </div>
          )}
        </div>

        <div className="lg:col-span-2">
          <div className="mb-4 flex items-baseline justify-between">
            <h2 className="text-lg font-bold text-gray-900 font-display">
              {t('fp_all_reviews')}
            </h2>
            <span className="text-sm text-gray-500">
              {fmt(reviews.length)} {t('fp_reviews_count')}
            </span>
          </div>
          {reviews.length === 0 ? (
            <div className="rounded-2xl bg-white p-10 text-center text-gray-400">
              {t('fp_no_reviews')}
            </div>
          ) : (
            <div className="space-y-4">
              {reviews.map((r) => <ReviewCard key={r.rating_id} r={r} fmt={fmt} dName={dName} t={t} />)}
            </div>
          )}
        </div>
      </div>
    </div>
  );
}

function Stat({ icon, value, label }) {
  return (
    <div>
      <div className="text-lg font-bold text-gray-900">
        <span className="mr-1">{icon}</span>{value}
      </div>
      <div className="text-xs uppercase tracking-wider text-gray-400">{label}</div>
    </div>
  );
}

function RatingBar({ label, value, fmt, bold }) {
  const num = Number(value || 0);
  const pct = (num / 5) * 100;
  return (
    <div>
      <div className="mb-1 flex items-baseline justify-between">
        <span className={`text-gray-700 ${bold ? 'font-bold' : ''}`}>{label}</span>
        <span className="text-xs font-bold text-gray-900">{fmt(num.toFixed(1))}</span>
      </div>
      <div className="h-2 overflow-hidden rounded-full bg-gray-100">
        <div className="h-full bg-amber-400" style={{ width: `${pct}%` }} />
      </div>
    </div>
  );
}

function ReviewCard({ r, fmt, dName, t }) {
  const stars = Math.round(Number(r.overall_rating));
  return (
    <div className="rounded-2xl border border-gray-100 bg-white p-6 shadow-sm">
      <div className="flex items-start justify-between gap-3">
        <div className="flex items-center gap-3">
          <div className="grid h-10 w-10 flex-shrink-0 place-items-center rounded-full bg-gray-100 text-sm font-bold text-gray-500">
            {r.buyer_name.charAt(0)}
          </div>
          <div>
            <div className="text-sm font-semibold text-gray-900">{r.buyer_name}</div>
            <div className="text-xs text-gray-500">
              {r.buyer_district && <>{dName(r.buyer_district)} • </>}
              {new Date(r.created_at).toLocaleDateString(t('lang_code') === 'bn' ? 'bn-BD' : 'en-GB', { day: 'numeric', month: 'short', year: 'numeric' })}
            </div>
          </div>
        </div>
        <div className="text-right">
          <div className="text-amber-500">
            {'★'.repeat(stars)}<span className="text-gray-300">{'★'.repeat(5 - stars)}</span>
          </div>
          {r.is_verified_purchase && (
            <div className="mt-1 text-xs font-semibold text-green-700">
              ✓ {t('fp_verified_purchase')}
            </div>
          )}
        </div>
      </div>
      {r.review_title && (
        <h3 className="mt-3 font-bold text-gray-900">{r.review_title}</h3>
      )}
      {r.review_text && (
        <p className="mt-2 text-sm leading-relaxed text-gray-600">{r.review_text}</p>
      )}
      {r.helpful_count > 0 && (
        <div className="mt-3 text-xs text-gray-400">
          👍 {fmt(r.helpful_count)} {t('fp_helpful')}
        </div>
      )}
    </div>
  );
}
