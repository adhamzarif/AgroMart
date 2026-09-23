// web_app: Dynamic Bangla/English AiAdvisor Component

import { useState } from 'react';
import { Link, useNavigate, useSearchParams } from 'react-router-dom';
import { useLang } from '../../context/LangContext.jsx';

const HERO_IMG =
  'https://images.unsplash.com/photo-1620712943543-bcc4688e7485?w=1600';

export default function AiAdvisor() {
  const { lang, t } = useLang();
  const isBn = lang === 'bn';
  const navigate = useNavigate();
  const [searchParams, setSearchParams] = useSearchParams();

  // URL Query Parameter `?tab=...`
  const activeTab = searchParams.get('tab');

  // Soil Analysis Form & Recommendation States
  const [soilType, setSoilType] = useState('loamy');
  const [district, setDistrict] = useState('bogura');
  const [season, setSeason] = useState('robi');
  const [landArea, setLandArea] = useState('3');
  const [loading, setLoading] = useState(false);
  const [recommendation, setRecommendation] = useState(null);

  // Leaf Scanner States
  const [scanLoading, setScanLoading] = useState(false);
  const [scanResult, setScanResult] = useState(null);

  // Price Forecast State
  const [selectedCrop, setSelectedCrop] = useState('tomato');

  // Voice & Q&A States
  const [expandedFaq, setExpandedFaq] = useState(null);
  const [customQuestion, setCustomQuestion] = useState('');
  const [chatResponse, setChatResponse] = useState(null);
  const [isAsking, setIsAsking] = useState(false);
  const [isListening, setIsListening] = useState(false);

  // =========================================================
  // CROP PRICE DATA
  // =========================================================
  const cropPriceData = {
    chili: {
      name: 'Green Chili',
      bnName: 'কাঁচা মরিচ',
      currentPrice: isBn ? '৳১৪৮/কেজি' : '৳148/kg',
      peakPrice: isBn ? '৳১৭২/কেজি' : '৳172/kg',
      trend: isBn ? '↑ বৃদ্ধি পাচ্ছে' : '↑ Rising',
      insight: isBn
        ? 'আগামী ১ মাসে কাঁচা মরিচের সরবরাহ হ্রাস পাওয়ার সম্ভাবনা থাকায় দাম প্রায় ১৬% বৃদ্ধি পেতে পারে।'
        : 'In the next month, green chili supply is predicted to drop, leading to a ~16% price increase.',
      actualPath: 'M 30,120 L 150,90 L 270,64',
      forecastPath:
        'M 30,120 L 150,90 L 270,64 L 390,40 L 510,24 L 630,16',
      actualPoints: [
        { x: 30, y: 120, val: isBn ? '৳১২০' : '৳120' },
        { x: 150, y: 90, val: isBn ? '৳১৩৫' : '৳135' },
        { x: 270, y: 64, val: isBn ? '৳১৪৮' : '৳148' },
      ],
    },

    potato: {
      name: 'Potato',
      bnName: 'আলু',
      currentPrice: isBn ? '৳৩৫/কেজি' : '৳35/kg',
      peakPrice: isBn ? '৳৩৮/কেজি' : '৳38/kg',
      trend: isBn ? '→ স্থিতিশীল' : '→ Stable',
      insight: isBn
        ? 'আলুর বাজারে সরবরাহ স্বাভাবিক রয়েছে। আগামী ৪ সপ্তাহে মূল্যে বড় ধরনের পরিবর্তনের সম্ভাবনা নেই।'
        : 'Potato supply remains steady. No major price fluctuations expected over the next 4 weeks.',
      actualPath: 'M 30,136 L 150,132 L 270,130',
      forecastPath:
        'M 30,136 L 150,132 L 270,130 L 390,128 L 510,126 L 630,124',
      actualPoints: [
        { x: 30, y: 136, val: isBn ? '৳৩২' : '৳32' },
        { x: 150, y: 132, val: isBn ? '৳৩৪' : '৳34' },
        { x: 270, y: 130, val: isBn ? '৳৩৫' : '৳35' },
      ],
    },

    tomato: {
      name: 'Tomato',
      bnName: 'টমেটো',
      currentPrice: isBn ? '৳৭৫/কেজি' : '৳75/kg',
      peakPrice: isBn ? '৳৮৫/কেজি' : '৳85/kg',
      trend: isBn ? '↑ বৃদ্ধি পাচ্ছে' : '↑ Rising',
      insight: isBn
        ? 'ঢাকা শহর থেকে উচ্চ চাহিদার পূর্বাভাষ পাওয়া গেছে। ১০-১৫% বেশি লাভ পেতে আরও ২ সপ্তাহ ফসল মজুত রাখার পরামর্শ দিচ্ছে AI।'
        : 'Rising demand from Dhaka markets predicted. AI suggests holding stock for 2 more weeks for 10–15% better return.',
      actualPath: 'M 30,60 L 150,64 L 270,50',
      forecastPath:
        'M 30,60 L 150,64 L 270,50 L 390,36 L 510,40 L 630,30',
      actualPoints: [
        { x: 30, y: 60, val: isBn ? '৳৭০' : '৳70' },
        { x: 150, y: 64, val: isBn ? '৳৬৮' : '৳68' },
        { x: 270, y: 50, val: isBn ? '৳৭৫' : '৳75' },
      ],
    },
  };

  // =========================================================
  // POPULAR FAQ DATA
  // =========================================================
  const faqList = [
    {
      id: 1,
      q: isBn
        ? 'এই মাসে কোন ফসল চাষ করা ভালো?'
        : 'Which crops are best to cultivate this month?',
      a: isBn
        ? 'বর্তমান রবি মৌসুমে ধান (বোরো), গম, সরিষা, আলু ও বিভিন্ন ধরনের শীতকালীন শাকসবজি চাষের জন্য সবচেয়ে উপযোগী সময়।'
        : 'In the current Robi season, Boro Rice, Wheat, Mustard, Potato, and winter vegetables are most suitable.',
    },

    {
      id: 2,
      q: isBn
        ? 'সার কতটুকু দিতে হবে?'
        : 'How much fertilizer should be applied?',
      a: isBn
        ? 'প্রতি বিঘা জমির মাটির ধরন ও ফসলের উপর নির্ভর করে। সাধারণ ধান চাষে বিঘা প্রতি ২৫ কেজি ইউরিয়া, ১২ কেজি টিএসপি এবং ১৫ কেজি এমওপি সার ব্যবহার করা উত্তম।'
        : 'It depends on soil type and crop. For general rice farming, applying 25 kg Urea, 12 kg TSP, and 15 kg MOP per bigha is recommended.',
    },

    {
      id: 3,
      q: isBn
        ? 'পাতায় হলুদ দাগ কেন হয়?'
        : 'Why do yellow spots appear on leaves?',
      a: isBn
        ? 'পাতায় হলুদ দাগ হওয়ার প্রধান কারণ হলো নাইট্রোজেন সারের ঘাটতি অথবা ছত্রাক সংক্রমণ (যেমন: Bacterial Leaf Blight)। সঠিক চিকিৎসার জন্য আমাদের "Leaf Scanner" অপশনটি ব্যবহার করুন।'
        : 'Yellow spots are usually caused by nitrogen deficiency or fungal/bacterial leaf blight infection. Use our Leaf Scanner feature to diagnose accurately.',
    },

    {
      id: 4,
      q: isBn
        ? 'AgroMart-এ কিভাবে বিক্রি করব?'
        : 'How do I sell products on AgroMart?',
      a: isBn
        ? 'AgroMart প্ল্যাটফর্মে আপনার ফসলের ছবি, পরিমাণ ও নির্ধারিত মূল্য লিখে "Post Product" ট্যাবে যুক্ত করুন। সরাসরি ক্রেতারা আপনার সাথে যোগাযোগ করবেন।'
        : 'Upload your crop photos, quantity, and price in the "Post Product" tab on AgroMart. Buyers will directly contact you.',
    },

    {
      id: 5,
      q: isBn
        ? 'ঋণ কিভাবে পাব?'
        : 'How can I apply for an Agri Loan?',
      a: isBn
        ? 'আমাদের AgriLoan সেকশনে গিয়ে আপনার জাতীয় পরিচয়পত্র, জমির তথ্য এবং ফসলের বিবরণী জমা দিয়ে সরকারি ও বেসরকারি ব্যাংকের স্বল্প সুদের কৃষি ঋণের জন্য আবেদন করতে পারেন।'
        : 'Go to our AgriLoan section and submit your NID, land records, and crop details to apply for low-interest agricultural loans.',
    },
  ];

  // =========================================================
  // FOUR MAIN AI FEATURES
  // =========================================================
  const benefits = [
    {
      id: 'crop',
      icon: '🌱',
      title: 'ai_benefit1_title',
      desc: 'ai_benefit1_desc',
    },
    {
      id: 'disease',
      icon: '🔬',
      title: 'ai_benefit2_title',
      desc: 'ai_benefit2_desc',
    },
    {
      id: 'price',
      icon: '💹',
      title: 'ai_benefit3_title',
      desc: 'ai_benefit3_desc',
    },
    {
      id: 'voice',
      icon: '💬',
      title: 'ai_benefit4_title',
      desc: 'ai_benefit4_desc',
    },
  ];

  // =========================================================
  // EXISTING AI FEATURE STEPS
  // =========================================================
  const steps = [
    { n: 1, title: 'ai_step1_title', desc: 'ai_step1_desc' },
    { n: 2, title: 'ai_step2_title', desc: 'ai_step2_desc' },
    { n: 3, title: 'ai_step3_title', desc: 'ai_step3_desc' },
    { n: 4, title: 'ai_step4_title', desc: 'ai_step4_desc' },
  ];

  // =========================================================
  // CARD CLICK
  // =========================================================
  const handleCardClick = (id) => {
    setSearchParams({ tab: id });
    window.scrollTo({ top: 0, behavior: 'smooth' });
  };

  // =========================================================
  // BACK TO MAIN AI ADVISOR
  // =========================================================
  const handleBack = () => {
    setSearchParams({});
    setRecommendation(null);
    setScanResult(null);
    setChatResponse(null);
    setExpandedFaq(null);
    window.scrollTo({ top: 0, behavior: 'smooth' });
  };

  // =========================================================
  // CROP RECOMMENDATION
  // =========================================================
  const handleGetRecommendation = (e) => {
    e.preventDefault();

    setLoading(true);
    setRecommendation(null);

    setTimeout(() => {
      setLoading(false);

      setRecommendation({
        primaryCrop:
          season === 'robi'
            ? isBn
              ? 'ধান (বোরো / উফশী)'
              : 'Rice (Boro / HYV)'
            : isBn
              ? 'পাট ও ধান'
              : 'Jute & Paddy',

        matchScore: isBn ? '৯৫%' : '95%',

        estimatedYield: isBn
          ? `${(parseFloat(landArea) || 1) * 22} - ${(parseFloat(landArea) || 1) * 28} মন`
          : `${(parseFloat(landArea) || 1) * 22} - ${(parseFloat(landArea) || 1) * 28} Mon`,

        fertilizer: isBn
          ? [
              'ইউরিয়া: ২৫ কেজি/বিঘা (৩ কিস্তিতে)',
              'টিএসপি: ১২ কেজি/বিঘা (জমি তৈরির সময়)',
              'এমওপি: ১৫ কেজি/বিঘা',
            ]
          : [
              'Urea: 25 kg/bigha (in 3 splits)',
              'TSP: 12 kg/bigha (during land prep)',
              'MOP: 15 kg/bigha',
            ],

        advice: isBn
          ? `${district} জেলার মাটির পানির ধারণক্ষমতা ও আবহাওয়া বিবেচনা করে এই ফসলটি চাষ করলে সর্বোচ্চ মুনাফা অর্জন সম্ভব।`
          : `Considering the soil water retention and weather in ${district}, cultivating this crop offers maximum profitability.`,
      });
    }, 1200);
  };

  // =========================================================
  // DEMO DISEASE SCAN
  // =========================================================
  const handleDemoScan = () => {
    setScanLoading(true);
    setScanResult(null);

    setTimeout(() => {
      setScanLoading(false);

      setScanResult({
        diseaseName: isBn
          ? 'ধানের পাতা পোড়া রোগ (Bacterial Leaf Blight)'
          : 'Bacterial Leaf Blight',

        confidence: isBn ? '৯৬%' : '96%',

        severity: isBn ? 'মাঝারি (Medium)' : 'Medium',

        symptoms: isBn
          ? [
              'পাতার কিনারা হালকা হলুদ বা ধূসর হয়ে শুকিয়ে যাওয়া',
              'আক্রান্ত অংশ তরঙ্গের মতো নিচের দিকে ছড়িয়ে পড়া',
              'শিশিরে ভেজা সকালে পাতার গায়ে হলুদ তরলের ফোটা দেখা দেওয়া',
            ]
          : [
              'Leaf edges turning light yellow/grey and drying up',
              'Infected areas waving downward along leaf blades',
              'Yellow bacterial droplets visible in morning dew',
            ],

        treatments: isBn
          ? [
              'কপার অক্সিক্লোরাইড (যেমন: কুপ্রাভিট) প্রতি লিটার পানিতে ২ গ্রাম হারে মিশিয়ে স্প্রে করুন।',
              'নাইট্রোজেন সার অতিরিক্ত ব্যবহার থেকে বিরত থাকুন।',
              'জমিতে জমা পানি নিষ্কাশনের সঠিক ব্যবস্থা নিশ্চিত করুন।',
            ]
          : [
              'Spray Copper Oxychloride (e.g. Cupravit) at 2g per liter of water.',
              'Avoid excessive usage of Nitrogen fertilizers.',
              'Ensure adequate drainage system in the field.',
            ],

        organicAdvice: isBn
          ? 'জৈব প্রতিকার হিসেবে নিম পাতার রস বা পটাশযুক্ত ছাই ব্যবহার করতে পারেন।'
          : 'As an organic remedy, you can use neem leaf extract or potash-rich ash.',
      });
    }, 1500);
  };

  // =========================================================
  // FAQ TOGGLE
  // =========================================================
  const toggleFaq = (id) => {
    setExpandedFaq(expandedFaq === id ? null : id);
  };

  // =========================================================
  // VOICE SEARCH SIMULATION
  // =========================================================
  const handleVoiceListen = () => {
    setIsListening(true);
    setChatResponse(null);

    setTimeout(() => {
      setIsListening(false);

      setCustomQuestion(
        isBn
          ? 'টমেটো গাছে ফল ছিদ্রকারী পোকা দমনে করণীয় কী?'
          : 'How to control fruit borers in tomato plants?'
      );

      setChatResponse(
        isBn
          ? 'টমেটোর ফল ছিদ্রকারী পোকা দমনে ফেরোমন ট্র্যাপ ব্যবহার করুন এবং আক্রমণ বেশি হলে জৈব বালাইনাশক (যেমন: সাইপারমেথ্রিন) সঠিক মাত্রায় প্রয়োগ করুন।'
          : 'Use pheromone traps for tomato fruit borers. If infestation is high, apply organic bio-pesticides or recommended spray in appropriate doses.'
      );
    }, 2500);
  };

  // =========================================================
  // CUSTOM QUESTION SUBMIT
  // =========================================================
  const handleAskSubmit = (e) => {
    e.preventDefault();

    if (!customQuestion.trim()) return;

    setIsAsking(true);
    setChatResponse(null);

    setTimeout(() => {
      setIsAsking(false);

      setChatResponse(
        isBn
          ? `আপনার প্রশ্ন: "${customQuestion}"-এর জন্য এআই পরামর্শ হলো: স্থানীয় আবহাওয়া ও মাটির গুণাগুণ বিবেচনা করে সঠিক সেচ ও সুষম সার প্রয়োগ নিশ্চিত করুন।`
          : `For your query: "${customQuestion}", AI advises: Ensure proper irrigation and balanced fertilizer based on local soil and weather conditions.`
      );
    }, 1200);
  };

  // =========================================================================
  // 1. DEDICATED VIEW: CROP RECOMMENDATION
  // =========================================================================
  if (activeTab === 'crop') {
    return (
      <div className="min-h-screen bg-gray-50">
        <section className="bg-emerald-900 px-6 py-12 text-white">
          <div className="mx-auto max-w-5xl">
            <button
              onClick={handleBack}
              className="mb-4 inline-flex items-center text-sm font-medium text-emerald-200 transition hover:text-white"
            >
              ← {isBn ? 'AI-অ্যাডভাইজর পেজে ফিরে যান' : 'Back to AI Advisor Page'}
            </button>

            <h1 className="text-3xl font-bold font-display sm:text-4xl">
              {isBn
                ? 'মাটি ও ফসল বিশ্লেষণ (Soil Analysis)'
                : 'Soil & Crop Analysis'}
            </h1>

            <p className="mt-2 text-sm text-emerald-100 sm:text-base">
              {isBn
                ? 'আপনার জমির তথ্য প্রদান করে এআই চালিত সঠিক ফসল সুপারিশ গ্রহণ করুন।'
                : 'Input your soil details to get AI-driven crop recommendations.'}
            </p>
          </div>
        </section>

        <div className="mx-auto max-w-5xl space-y-8 px-6 py-10">
          <div className="rounded-2xl border border-emerald-100 bg-white p-8 shadow-sm">
            <span className="mb-4 inline-block rounded-full bg-emerald-100 px-3 py-1 text-xs font-semibold text-emerald-800">
              {isBn
                ? 'স্বয়ংক্রিয় সুপারিশ সিস্টেম'
                : 'Automated Recommendation System'}
            </span>

            <form
              className="grid grid-cols-1 gap-5 sm:grid-cols-2"
              onSubmit={handleGetRecommendation}
            >
              <div>
                <label className="text-xs font-bold tracking-wider text-gray-500">
                  {isBn ? 'SOIL TYPE (মাটির ধরন)' : 'SOIL TYPE'}
                </label>

                <select
                  value={soilType}
                  onChange={(e) => setSoilType(e.target.value)}
                  className="mt-1 w-full rounded-xl border border-gray-300 p-3 text-sm text-gray-700 outline-none focus:border-emerald-500 focus:ring-1 focus:ring-emerald-500"
                >
                  <option value="loamy">
                    {isBn ? 'দোআঁশ মাটি (Loamy)' : 'Loamy Soil'}
                  </option>

                  <option value="clay">
                    {isBn ? 'এঁটেল মাটি (Clay)' : 'Clay Soil'}
                  </option>

                  <option value="sandy">
                    {isBn ? 'বেলে মাটি (Sandy)' : 'Sandy Soil'}
                  </option>
                </select>
              </div>

              <div>
                <label className="text-xs font-bold tracking-wider text-gray-500">
                  {isBn ? 'DISTRICT (জেলা)' : 'DISTRICT'}
                </label>

                <select
                  value={district}
                  onChange={(e) => setDistrict(e.target.value)}
                  className="mt-1 w-full rounded-xl border border-gray-300 p-3 text-sm text-gray-700 outline-none focus:border-emerald-500 focus:ring-1 focus:ring-emerald-500"
                >
                  <option value="bogura">
                    {isBn ? 'বগুড়া' : 'Bogura'}
                  </option>

                  <option value="rangpur">
                    {isBn ? 'রংপুর' : 'Rangpur'}
                  </option>

                  <option value="jessore">
                    {isBn ? 'যশোর' : 'Jhenaidah / Jashore'}
                  </option>

                  <option value="dinajpur">
                    {isBn ? 'দিনাজপুর' : 'Dinajpur'}
                  </option>
                </select>
              </div>

              <div>
                <label className="text-xs font-bold tracking-wider text-gray-500">
                  {isBn ? 'SEASON (মৌসুম)' : 'SEASON'}
                </label>

                <select
                  value={season}
                  onChange={(e) => setSeason(e.target.value)}
                  className="mt-1 w-full rounded-xl border border-gray-300 p-3 text-sm text-gray-700 outline-none focus:border-emerald-500 focus:ring-1 focus:ring-emerald-500"
                >
                  <option value="robi">
                    {isBn ? 'রবি মৌসুম' : 'Robi Season'}
                  </option>

                  <option value="kharif1">
                    {isBn ? 'খরিফ-১' : 'Kharif-1'}
                  </option>

                  <option value="kharif2">
                    {isBn ? 'খরিফ-২' : 'Kharif-2'}
                  </option>
                </select>
              </div>

              <div>
                <label className="text-xs font-bold tracking-wider text-gray-500">
                  {isBn ? 'LAND AREA (জমি - বিঘা)' : 'LAND AREA (Bigha)'}
                </label>

                <input
                  type="number"
                  value={landArea}
                  onChange={(e) => setLandArea(e.target.value)}
                  placeholder={isBn ? 'যেমন: ৩' : 'e.g. 3'}
                  className="mt-1 w-full rounded-xl border border-gray-300 p-3 text-sm text-gray-700 outline-none focus:border-emerald-500 focus:ring-1 focus:ring-emerald-500"
                />
              </div>

              <div className="mt-4 sm:col-span-2">
                <button
                  type="submit"
                  disabled={loading}
                  className="flex w-full items-center justify-center gap-2 rounded-xl bg-emerald-600 py-3.5 font-semibold text-white transition hover:bg-emerald-700 disabled:opacity-60"
                >
                  {loading ? (
                    <>
                      <span className="animate-spin">⏳</span>

                      {isBn
                        ? 'এআই মাটি বিশ্লেষণ করছে...'
                        : 'AI Analyzing Soil...'}
                    </>
                  ) : isBn ? (
                    '🌾 ফসল সুপারিশ দেখুন →'
                  ) : (
                    '🌾 Get Crop Recommendation →'
                  )}
                </button>
              </div>
            </form>
          </div>

          {recommendation && (
            <div className="animate-fadeIn rounded-2xl border border-emerald-200 bg-white p-8 shadow-sm">
              <div className="flex flex-wrap items-center justify-between gap-4 border-b border-gray-100 pb-6">
                <div>
                  <span className="text-xs font-bold uppercase tracking-wider text-emerald-600">
                    {isBn
                      ? 'এআই কর্তৃক প্রস্তাবিত সেরা ফসল'
                      : 'AI Recommended Best Crop'}
                  </span>

                  <h2 className="mt-1 text-2xl font-bold text-gray-900">
                    {recommendation.primaryCrop}
                  </h2>
                </div>

                <div className="rounded-2xl border border-emerald-100 bg-emerald-50 px-4 py-2 text-right">
                  <div className="text-xs font-medium text-gray-500">
                    {isBn ? 'উপযোগিতা স্কেল' : 'Suitability Score'}
                  </div>

                  <div className="text-xl font-extrabold text-emerald-700">
                    {recommendation.matchScore}{' '}
                    {isBn ? 'উপযুক্ত' : 'Match'}
                  </div>
                </div>
              </div>

              <div className="mt-6 grid grid-cols-1 gap-6 md:grid-cols-2">
                <div className="rounded-xl border border-gray-100 bg-gray-50 p-5">
                  <h4 className="mb-2 flex items-center gap-2 text-sm font-bold text-gray-800">
                    <span>📈</span>

                    {isBn
                      ? `সম্ভাব্য আনুমানিক ফলন (${landArea} বিঘা)`
                      : `Estimated Yield (${landArea} Bigha)`}
                  </h4>

                  <p className="text-lg font-semibold text-emerald-800">
                    {recommendation.estimatedYield}
                  </p>
                </div>

                <div className="rounded-xl border border-gray-100 bg-gray-50 p-5">
                  <h4 className="mb-2 flex items-center gap-2 text-sm font-bold text-gray-800">
                    <span>🧪</span>

                    {isBn
                      ? 'সার ও পুষ্টি ব্যবস্থাপনা (প্রতি বিঘা)'
                      : 'Fertilizer & Nutrition (per Bigha)'}
                  </h4>

                  <ul className="space-y-1 text-xs text-gray-600">
                    {recommendation.fertilizer.map((item, index) => (
                      <li key={index}>• {item}</li>
                    ))}
                  </ul>
                </div>
              </div>

              <div className="mt-6 rounded-xl border border-emerald-100 bg-emerald-50/70 p-5 text-sm text-emerald-950">
                <strong>
                  🤖 {isBn ? 'এআই পরামর্শ:' : 'AI Advisory:'}
                </strong>{' '}
                {recommendation.advice}
              </div>
            </div>
          )}
        </div>
      </div>
    );
  }

  // =========================================================================
  // 2. DEDICATED VIEW: DISEASE DETECTION
  // =========================================================================
  if (activeTab === 'disease') {
    return (
      <div className="min-h-screen bg-gray-50">
        <section className="bg-emerald-800 px-6 py-10 text-white">
          <div className="mx-auto max-w-5xl">
            <button
              onClick={handleBack}
              className="mb-3 inline-flex items-center text-sm font-medium text-emerald-200 transition hover:text-white"
            >
              ← {isBn ? 'AI-অ্যাডভাইজর পেজে ফিরে যান' : 'Back to AI Advisor Page'}
            </button>

            <div className="mb-2 inline-block rounded-full border border-emerald-600 bg-emerald-700/80 px-3 py-1 text-xs font-medium text-emerald-100">
              AI — Leaf Scanner
            </div>

            <h1 className="text-3xl font-bold font-display sm:text-4xl">
              {isBn
                ? 'রোগ শনাক্তকরণ (Disease Detection)'
                : 'Disease Detection'}
            </h1>
          </div>
        </section>

        <div className="mx-auto max-w-5xl px-6 py-8">
          <div className="rounded-2xl border border-emerald-100 bg-white p-6 shadow-sm sm:p-8">
            <div className="mb-6 flex items-center gap-3 rounded-xl border border-emerald-100 bg-emerald-50 p-4 text-sm text-emerald-900">
              <span className="text-xl">🔬</span>

              <span>
                {isBn
                  ? 'আক্রান্ত পাতার ছবি তুলুন বা আপলোড করুন এবং তাৎক্ষণিক AI রোগ নির্ণয় ও প্রতিকার লাভ করুন।'
                  : 'Take or upload a photo of a diseased leaf and get instant AI diagnosis with treatment recommendations.'}
              </span>
            </div>

            <div className="mb-8 grid grid-cols-1 gap-5 sm:grid-cols-2">
              <div className="group flex cursor-pointer flex-col items-center justify-center rounded-2xl border-2 border-dashed border-emerald-300 p-8 text-center transition hover:bg-emerald-50/40">
                <div className="grid h-14 w-14 place-items-center rounded-full bg-emerald-100 text-3xl transition group-hover:scale-110">
                  📷
                </div>

                <span className="mt-3 text-base font-bold text-gray-800">
                  {isBn ? 'ক্যামেরা খুলুন' : 'Open Camera'}
                </span>

                <span className="mt-1 text-xs text-gray-400">
                  {isBn ? 'এখনই ছবি তুলুন' : 'Take a photo now'}
                </span>
              </div>

              <div className="group flex cursor-pointer flex-col items-center justify-center rounded-2xl border-2 border-dashed border-gray-300 p-8 text-center transition hover:bg-gray-50">
                <div className="grid h-14 w-14 place-items-center rounded-full bg-gray-100 text-3xl transition group-hover:scale-110">
                  🖼️
                </div>

                <span className="mt-3 text-base font-bold text-gray-800">
                  {isBn ? 'ছবি আপলোড করুন' : 'Upload Photo'}
                </span>

                <span className="mt-1 text-xs text-gray-400">
                  {isBn ? 'গ্যালারি থেকে নির্বাচন করুন' : 'From your gallery'}
                </span>
              </div>
            </div>

            <div className="mb-8 rounded-xl border border-gray-100 bg-gray-50/80 p-5">
              <h4 className="mb-3 text-xs font-bold uppercase tracking-wider text-gray-500">
                {isBn ? 'সঠিক ফলাফলের টিপস' : 'TIPS FOR BEST RESULTS'}
              </h4>

              <ul className="grid grid-cols-1 gap-2 text-xs font-medium text-gray-600 sm:grid-cols-2">
                <li>
                  📸{' '}
                  {isBn
                    ? 'দিনের আলোতে ছবি তুলুন'
                    : 'Photo in natural daylight'}
                </li>

                <li>
                  🍃{' '}
                  {isBn
                    ? 'একটি পাতা পরিষ্কারভাবে রাখুন'
                    : 'Single leaf clearly visible'}
                </li>

                <li>
                  🔍{' '}
                  {isBn
                    ? 'রোগের দাগ স্পষ্ট দেখান'
                    : 'Symptoms clearly visible in frame'}
                </li>

                <li>
                  📐{' '}
                  {isBn
                    ? 'ফোন ২০-৩০ সেমি দূরত্বে রাখুন'
                    : 'Hold phone 20-30cm from leaf'}
                </li>
              </ul>
            </div>

            <button
              onClick={handleDemoScan}
              disabled={scanLoading}
              className="flex w-full items-center justify-center gap-2 rounded-xl bg-emerald-600 py-4 text-center text-base font-bold text-white shadow-sm transition hover:bg-emerald-700 disabled:opacity-60"
            >
              {scanLoading ? (
                <>
                  <span className="animate-spin">⏳</span>

                  {isBn
                    ? 'AI স্ক্যান করছে... অনুগ্রহ করে অপেক্ষা করুন...'
                    : 'AI scanning... Please wait...'}
                </>
              ) : isBn ? (
                '🧪 ডেমো স্ক্যান (নমুনা পাতা)'
              ) : (
                '🧪 Demo Scan (Sample Leaf)'
              )}
            </button>

            {scanResult && (
              <div className="animate-fadeIn mt-8 space-y-6 rounded-2xl border border-emerald-200 bg-white p-6 shadow-sm">
                <div className="flex flex-wrap items-center justify-between gap-4 border-b border-gray-100 pb-4">
                  <div>
                    <span className="mb-1 inline-block rounded-md bg-red-100 px-2.5 py-0.5 text-xs font-bold text-red-700">
                      {isBn
                        ? 'রোগ শনাক্তকরণ সম্পূর্ণ'
                        : 'Diagnosis Completed'}
                    </span>

                    <h3 className="text-xl font-bold text-gray-900">
                      {scanResult.diseaseName}
                    </h3>
                  </div>

                  <div className="flex gap-2">
                    <div className="rounded-xl border border-emerald-100 bg-emerald-50 px-3 py-1.5 text-center">
                      <div className="text-[10px] font-medium text-gray-500">
                        {isBn ? 'সঠিকতা' : 'Accuracy'}
                      </div>

                      <div className="text-sm font-bold text-emerald-700">
                        {scanResult.confidence}
                      </div>
                    </div>

                    <div className="rounded-xl border border-emerald-100 bg-emerald-50 px-3 py-1.5 text-center">
                      <div className="text-[10px] font-medium text-gray-500">
                        {isBn ? 'ঝুঁকির মাত্রা' : 'Severity'}
                      </div>

                      <div className="text-sm font-bold text-emerald-700">
                        {scanResult.severity}
                      </div>
                    </div>
                  </div>
                </div>

                <div className="grid grid-cols-1 gap-6 md:grid-cols-2">
                  <div className="rounded-xl border border-gray-100 bg-gray-50 p-4">
                    <h4 className="mb-2 flex items-center gap-2 text-sm font-bold text-gray-800">
                      <span>🩺</span>
                      {isBn ? 'উপসর্গসমূহ (Symptoms)' : 'Symptoms'}
                    </h4>

                    <ul className="list-inside list-disc space-y-1.5 text-xs text-gray-600">
                      {scanResult.symptoms.map((s, idx) => (
                        <li key={idx}>{s}</li>
                      ))}
                    </ul>
                  </div>

                  <div className="rounded-xl border border-emerald-100 bg-emerald-50/50 p-4">
                    <h4 className="mb-2 flex items-center gap-2 text-sm font-bold text-emerald-900">
                      <span>💊</span>

                      {isBn
                        ? 'প্রস্তাবিত চিকিৎসা (Treatment)'
                        : 'Recommended Treatment'}
                    </h4>

                    <ul className="list-inside list-disc space-y-1.5 text-xs text-emerald-900">
                      {scanResult.treatments.map((treatment, idx) => (
                        <li key={idx}>{treatment}</li>
                      ))}
                    </ul>
                  </div>
                </div>

                <div className="rounded-xl border border-emerald-100 bg-emerald-50 p-4 text-xs text-emerald-950">
                  <strong>
                    🌿 {isBn ? 'জৈব পরামর্শ:' : 'Organic Advisory:'}
                  </strong>{' '}
                  {scanResult.organicAdvice}
                </div>
              </div>
            )}
          </div>
        </div>
      </div>
    );
  }

  // =========================================================================
  // 3. DEDICATED VIEW: PRICE FORECAST
  // =========================================================================
  if (activeTab === 'price') {
    const currentCropData = cropPriceData[selectedCrop];

    return (
      <div className="min-h-screen bg-gray-50">
        <section className="bg-emerald-800 px-6 py-10 text-white">
          <div className="mx-auto max-w-5xl">
            <button
              onClick={handleBack}
              className="mb-3 inline-flex items-center text-sm font-medium text-emerald-200 transition hover:text-white"
            >
              ← {isBn ? 'AI-অ্যাডভাইজর পেজে ফিরে যান' : 'Back to AI Advisor Page'}
            </button>

            <div className="mb-2 inline-block rounded-full border border-emerald-600 bg-emerald-700/80 px-3 py-1 text-xs font-medium text-emerald-100">
              AI — Market Prediction
            </div>

            <h1 className="text-3xl font-bold font-display sm:text-4xl">
              {isBn
                ? 'বাজার দর পূর্বাভাস (Price Forecast)'
                : 'Price Forecast'}
            </h1>
          </div>
        </section>

        <div className="mx-auto max-w-5xl px-6 py-8">
          <div className="space-y-6 rounded-2xl border border-emerald-100 bg-white p-6 shadow-sm sm:p-8">
            <div className="flex items-center gap-3 rounded-xl border border-emerald-100 bg-emerald-50 p-4 text-sm text-emerald-900">
              <span className="text-lg">📈</span>

              <span>
                {isBn
                  ? 'আবহাওয়া, ঐতিহাসিক তথ্য ও বাজারের চাহিদার ওপর ভিত্তি করে ৬ সপ্তাহের দর পূর্বাভাস।'
                  : 'AI-powered 6-week price forecast based on weather patterns, historical data, and market demand signals.'}
              </span>
            </div>

            <div className="grid grid-cols-3 gap-3">
              <button
                onClick={() => setSelectedCrop('chili')}
                className={`rounded-xl py-3 text-center text-sm font-semibold transition ${
                  selectedCrop === 'chili'
                    ? 'bg-emerald-600 text-white shadow-sm'
                    : 'border border-gray-200 bg-white text-gray-700 hover:bg-gray-50'
                }`}
              >
                {isBn ? 'কাঁচা মরিচ' : 'Green Chili'}
              </button>

              <button
                onClick={() => setSelectedCrop('potato')}
                className={`rounded-xl py-3 text-center text-sm font-semibold transition ${
                  selectedCrop === 'potato'
                    ? 'bg-emerald-600 text-white shadow-sm'
                    : 'border border-gray-200 bg-white text-gray-700 hover:bg-gray-50'
                }`}
              >
                {isBn ? 'আলু' : 'Potato'}
              </button>

              <button
                onClick={() => setSelectedCrop('tomato')}
                className={`rounded-xl py-3 text-center text-sm font-semibold transition ${
                  selectedCrop === 'tomato'
                    ? 'bg-emerald-600 text-white shadow-sm'
                    : 'border border-gray-200 bg-white text-gray-700 hover:bg-gray-50'
                }`}
              >
                {isBn ? 'টমেটো' : 'Tomato'}
              </button>
            </div>

            <div className="grid grid-cols-1 gap-4 sm:grid-cols-3">
              <div className="rounded-2xl border border-gray-100 bg-gray-50/80 p-5 text-center">
                <div className="text-2xl font-extrabold text-gray-800">
                  {currentCropData.currentPrice}
                </div>

                <div className="mt-1 text-xs font-medium text-gray-500">
                  {isBn ? 'বর্তমান মূল্য' : 'Current Price'}
                </div>
              </div>

              <div className="rounded-2xl border border-emerald-100 bg-emerald-50/80 p-5 text-center">
                <div className="text-2xl font-extrabold text-emerald-600">
                  {currentCropData.peakPrice}
                </div>

                <div className="mt-1 text-xs font-medium text-emerald-700">
                  {isBn ? '৬ সপ্তাহের সর্বোচ্চ' : '6-Wk Peak'}
                </div>
              </div>

              <div className="rounded-2xl border border-emerald-100 bg-emerald-50/80 p-5 text-center">
                <div className="text-2xl font-extrabold text-emerald-600">
                  {currentCropData.trend}
                </div>

                <div className="mt-1 text-xs font-medium text-emerald-700">
                  {isBn ? 'ট্রেন্ড' : 'Trend'}
                </div>
              </div>
            </div>

            <div className="rounded-2xl border border-gray-100 bg-gray-50/50 p-6">
              <div className="mb-4 flex items-center justify-between text-sm font-bold text-gray-800">
                <span>
                  {isBn
                    ? 'মূল্য ধারা (বর্তমান বনাম AI পূর্বাভাস) · ৳/কেজি'
                    : 'Price Trend (Actual vs AI Forecast) · ৳/kg'}
                </span>

                <span className="rounded-full bg-emerald-100 px-2.5 py-0.5 text-xs font-semibold text-emerald-700">
                  {currentCropData.name} ({currentCropData.bnName})
                </span>
              </div>

              <div className="relative w-full overflow-x-auto">
                <svg
                  viewBox="0 0 660 180"
                  className="h-48 min-w-[500px] w-full"
                >
                  <line
                    x1="0"
                    y1="30"
                    x2="660"
                    y2="30"
                    stroke="#E5E7EB"
                    strokeDasharray="3 3"
                  />

                  <line
                    x1="0"
                    y1="75"
                    x2="660"
                    y2="75"
                    stroke="#E5E7EB"
                    strokeDasharray="3 3"
                  />

                  <line
                    x1="0"
                    y1="120"
                    x2="660"
                    y2="120"
                    stroke="#E5E7EB"
                    strokeDasharray="3 3"
                  />

                  <line
                    x1="0"
                    y1="165"
                    x2="660"
                    y2="165"
                    stroke="#9CA3AF"
                    strokeWidth="1.5"
                  />

                  <path
                    d={`${currentCropData.actualPath} L 270,165 L 30,165 Z`}
                    fill="rgba(16, 185, 129, 0.08)"
                  />

                  <path
                    d={currentCropData.forecastPath}
                    fill="none"
                    stroke="#059669"
                    strokeWidth="3"
                    strokeDasharray="6 4"
                  />

                  <path
                    d={currentCropData.actualPath}
                    fill="none"
                    stroke="#10B981"
                    strokeWidth="3.5"
                  />

                  {currentCropData.actualPoints.map((pt, index) => (
                    <g key={index}>
                      <circle
                        cx={pt.x}
                        cy={pt.y}
                        r="6"
                        fill="#10B981"
                        stroke="#FFFFFF"
                        strokeWidth="2"
                      />

                      <text
                        x={pt.x}
                        y={pt.y - 10}
                        textAnchor="middle"
                        fontSize="10"
                        fontWeight="bold"
                        fill="#065F46"
                      >
                        {pt.val}
                      </text>
                    </g>
                  ))}

                  <text
                    x="30"
                    y="178"
                    textAnchor="middle"
                    fontSize="11"
                    fill="#6B7280"
                    fontWeight="bold"
                  >
                    W1
                  </text>

                  <text
                    x="150"
                    y="178"
                    textAnchor="middle"
                    fontSize="11"
                    fill="#6B7280"
                    fontWeight="bold"
                  >
                    W2
                  </text>

                  <text
                    x="270"
                    y="178"
                    textAnchor="middle"
                    fontSize="11"
                    fill="#6B7280"
                    fontWeight="bold"
                  >
                    W3
                  </text>

                  <text
                    x="390"
                    y="178"
                    textAnchor="middle"
                    fontSize="11"
                    fill="#6B7280"
                  >
                    W4
                  </text>

                  <text
                    x="510"
                    y="178"
                    textAnchor="middle"
                    fontSize="11"
                    fill="#6B7280"
                  >
                    W5
                  </text>

                  <text
                    x="630"
                    y="178"
                    textAnchor="middle"
                    fontSize="11"
                    fill="#6B7280"
                  >
                    W6
                  </text>
                </svg>
              </div>

              <div className="mt-4 flex items-center justify-center gap-6 text-xs font-semibold">
                <div className="flex items-center gap-2">
                  <span className="h-1 w-5 rounded bg-emerald-500"></span>

                  <span className="text-gray-700">
                    {isBn ? 'বর্তমান' : 'Actual'}
                  </span>
                </div>

                <div className="flex items-center gap-2">
                  <span className="h-0.5 w-5 border-b-2 border-dashed border-emerald-600"></span>

                  <span className="text-gray-700">
                    {isBn ? 'AI পূর্বাভাস' : 'AI Forecast'}
                  </span>
                </div>
              </div>
            </div>

            <div className="rounded-xl border border-emerald-100 bg-emerald-50 p-5 text-sm text-emerald-950">
              <div className="mb-1 flex items-center gap-2 font-bold text-emerald-900">
                <span>🤖</span>

                {isBn ? 'AI অন্তর্দৃষ্টি' : 'AI Insight'}
              </div>

              <p className="text-xs font-medium leading-relaxed text-emerald-900 sm:text-sm">
                {currentCropData.insight}
              </p>
            </div>
          </div>
        </div>
      </div>
    );
  }

  // =========================================================================
  // 4. DEDICATED VIEW: VOICE Q&A
  // =========================================================================
  if (activeTab === 'voice') {
    return (
      <div className="min-h-screen bg-gray-50">
        <section className="bg-emerald-700 px-6 py-10 text-white">
          <div className="mx-auto max-w-2xl text-center">
            <button
              onClick={handleBack}
              className="mb-3 inline-flex items-center text-xs font-medium text-emerald-100 transition hover:text-white"
            >
              ← {isBn ? 'AI-অ্যাডভাইজর পেজে ফিরে যান' : 'Back to AI Advisor Page'}
            </button>

            <h1 className="text-2xl font-bold font-display sm:text-3xl">
              {isBn ? 'বাংলা প্রশ্নোত্তর' : 'Voice Q&A'}
            </h1>
          </div>
        </section>

        <div className="mx-auto max-w-2xl space-y-6 px-4 py-6">
          <div className="rounded-2xl border border-gray-100 bg-white p-6 shadow-sm">
            {/* Voice Mic */}
            <div className="mb-6 rounded-2xl border border-emerald-100 bg-emerald-50 p-6 text-center">
              <button
                onClick={handleVoiceListen}
                disabled={isListening}
                className={`mx-auto grid h-16 w-16 place-items-center rounded-full text-3xl text-white shadow-md transition ${
                  isListening
                    ? 'scale-110 animate-pulse bg-emerald-700'
                    : 'bg-emerald-600 hover:scale-105'
                }`}
              >
                🎤
              </button>

              <p className="mt-3 text-sm font-bold text-gray-800">
                {isListening
                  ? isBn
                    ? 'কণ্ঠস্বর শোনা হচ্ছে...'
                    : 'Listening to voice...'
                  : isBn
                    ? 'ভয়েস বাটন চাপুন'
                    : 'Press Voice Button'}
              </p>

              <p className="mt-0.5 text-xs text-gray-500">
                {isBn
                  ? 'বাংলায় যেকোনো কৃষি প্রশ্ন করুন'
                  : 'Ask any farming query in Bangla/English'}
              </p>
            </div>

            {/* Question Input */}
            <form onSubmit={handleAskSubmit} className="mb-6 flex gap-2">
              <input
                type="text"
                value={customQuestion}
                onChange={(e) => setCustomQuestion(e.target.value)}
                placeholder={
                  isBn ? 'প্রশ্ন লিখুন...' : 'Type your question...'
                }
                className="flex-1 rounded-xl border border-gray-200 px-4 py-2.5 text-sm outline-none focus:border-emerald-500 focus:ring-1 focus:ring-emerald-500"
              />

              <button
                type="submit"
                disabled={isAsking}
                className="rounded-xl bg-emerald-600 px-5 py-2.5 text-sm font-semibold text-white transition hover:bg-emerald-700 disabled:opacity-60"
              >
                {isAsking
                  ? '...'
                  : isBn
                    ? 'জিজ্ঞাসা করুন'
                    : 'Ask'}
              </button>
            </form>

            {chatResponse && (
              <div className="animate-fadeIn mb-6 rounded-xl border border-emerald-200 bg-emerald-50 p-4 text-xs text-gray-800 sm:text-sm">
                <span className="mb-1 block font-bold text-emerald-700">
                  🤖 AI Answer:
                </span>

                <p className="leading-relaxed">{chatResponse}</p>
              </div>
            )}

            {/* FAQ */}
            <div className="border-t border-gray-100 pt-6">
              <h3 className="mb-4 text-sm font-bold text-gray-800">
                {isBn
                  ? 'জনপ্রিয় প্রশ্ন ও উত্তর'
                  : 'Popular Questions & Answers'}
              </h3>

              <div className="space-y-3">
                {faqList.map((faq) => {
                  const isOpen = expandedFaq === faq.id;

                  return (
                    <div
                      key={faq.id}
                      className="overflow-hidden rounded-xl border border-gray-200/80 bg-white transition"
                    >
                      <button
                        onClick={() => toggleFaq(faq.id)}
                        className="flex w-full items-center justify-between gap-3 px-4 py-3 text-left text-xs font-semibold text-gray-800 transition hover:bg-gray-50 sm:text-sm"
                      >
                        <span>{faq.q}</span>

                        <span
                          className={`text-xs text-gray-400 transition-transform duration-200 ${
                            isOpen ? 'rotate-180' : ''
                          }`}
                        >
                          ▼
                        </span>
                      </button>

                      {isOpen && (
                        <div className="border-t border-gray-100 bg-emerald-50/30 px-4 pb-3.5 pt-2 text-xs leading-relaxed text-gray-700 sm:text-sm">
                          <span className="font-semibold text-emerald-700">
                            🤖{' '}
                          </span>

                          {faq.a}
                        </div>
                      )}
                    </div>
                  );
                })}
              </div>
            </div>
          </div>
        </div>
      </div>
    );
  }

  // =========================================================================
  // DEFAULT MAIN PAGE
  // =========================================================================
  return (
    <div className="min-h-screen bg-white">
      {/* =====================================================
          HERO
      ====================================================== */}
      <section
        className="relative overflow-hidden px-6 py-24 text-center text-white"
        style={{
          backgroundImage: `linear-gradient(rgba(0,0,0,0.65), rgba(0,0,0,0.65)), url(${HERO_IMG})`,
          backgroundSize: 'cover',
          backgroundPosition: 'center',
        }}
      >
        <div className="mx-auto max-w-6xl">
          <div className="mx-auto mb-6 grid h-16 w-16 place-items-center rounded-2xl bg-white/20 text-4xl backdrop-blur">
            🤖
          </div>

          <h1 className="text-4xl font-bold font-display text-white drop-shadow sm:text-5xl">
            {t('ai_hero_title')}
          </h1>

          <p className="mx-auto mt-4 max-w-2xl text-lg text-white/90">
            {t('ai_hero_sub')}
          </p>

          <div className="mt-8 flex justify-center gap-3">
            <Link
              to="/register"
              className="rounded-full bg-emerald-600 px-6 py-3 text-sm font-semibold text-white transition hover:bg-emerald-700"
            >
              {t('ai_cta_start')}
            </Link>
          </div>
        </div>
      </section>

      {/* =====================================================
          WHY THE AI ADVISOR – EXISTING 4 FEATURES
      ====================================================== */}
      <section className="bg-gray-50 py-16">
        <div className="mx-auto max-w-6xl px-6">
          <h2 className="mb-3 text-center text-2xl font-bold font-display text-gray-900">
            {t('ai_benefits_title')}
          </h2>

          <div className="grid gap-6 sm:grid-cols-2 lg:grid-cols-4">
            {benefits.map((b) => (
              <div
                key={b.id}
                onClick={() => handleCardClick(b.id)}
                className="group relative cursor-pointer rounded-2xl border border-emerald-100 bg-white p-6 shadow-sm transition-all duration-300 hover:border-emerald-500 hover:shadow-md"
              >
                <div className="mb-4 text-4xl">
                  {b.icon}
                </div>

                <h3 className="mb-2 font-bold text-gray-900 transition group-hover:text-emerald-600">
                  {t(b.title)}
                </h3>

                <p className="mb-6 text-sm text-gray-600">
                  {t(b.desc)}
                </p>

                <div className="inline-flex items-center text-xs font-semibold text-emerald-600 transition-transform group-hover:translate-x-1">
                  {isBn ? 'বিস্তারিত দেখুন →' : 'View Details →'}
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* =====================================================
          HOW IT WORKS – SAME AI ADVISOR THEME
      ====================================================== */}
      <section className="bg-gray-50 py-16">
        <div className="mx-auto max-w-4xl px-6">
          <h2 className="mb-12 text-center text-2xl font-bold font-display text-gray-900">
            {isBn ? 'কিভাবে কাজ করে' : 'How It Works'}
          </h2>

          <div className="relative">
            {/* Vertical Connecting Line */}
            <div className="absolute bottom-6 left-6 top-6 w-0.5 bg-emerald-200" />

            <div className="space-y-6">
              {/* STEP 1 */}
              <div className="relative flex items-start gap-5">
                <div className="relative z-10 grid h-12 w-12 flex-shrink-0 place-items-center rounded-full bg-emerald-600 text-lg font-bold text-white shadow-md">
                  1
                </div>

                <div className="flex-1 rounded-xl border border-emerald-100 bg-white p-5 shadow-sm transition hover:border-emerald-300 hover:shadow-md">
                  <h3 className="text-lg font-bold text-gray-900">
                    {isBn ? 'প্রশ্ন করুন' : 'Ask Your Question'}
                  </h3>

                  <p className="mt-1 text-sm leading-relaxed text-gray-600">
                    {isBn
                      ? 'আপনার ফসল, জমি, রোগ বা বাজার সম্পর্কে যেকোনো প্রশ্ন করুন।'
                      : 'Ask any question about your crops, land, diseases, or market.'}
                  </p>
                </div>
              </div>

              {/* STEP 2 */}
              <div className="relative flex items-start gap-5">
                <div className="relative z-10 grid h-12 w-12 flex-shrink-0 place-items-center rounded-full bg-emerald-600 text-lg font-bold text-white shadow-md">
                  2
                </div>

                <div className="flex-1 rounded-xl border border-emerald-100 bg-white p-5 shadow-sm transition hover:border-emerald-300 hover:shadow-md">
                  <h3 className="text-lg font-bold text-gray-900">
                    {isBn ? 'AI বিশ্লেষণ' : 'AI Analysis'}
                  </h3>

                  <p className="mt-1 text-sm leading-relaxed text-gray-600">
                    {isBn
                      ? 'AI আপনার তথ্য ও বর্তমান কৃষি পরিস্থিতি বিশ্লেষণ করে।'
                      : 'AI analyzes your information and current agricultural conditions.'}
                  </p>
                </div>
              </div>

              {/* STEP 3 */}
              <div className="relative flex items-start gap-5">
                <div className="relative z-10 grid h-12 w-12 flex-shrink-0 place-items-center rounded-full bg-emerald-600 text-lg font-bold text-white shadow-md">
                  3
                </div>

                <div className="flex-1 rounded-xl border border-emerald-100 bg-white p-5 shadow-sm transition hover:border-emerald-300 hover:shadow-md">
                  <h3 className="text-lg font-bold text-gray-900">
                    {isBn ? 'পরামর্শ পান' : 'Get Advice'}
                  </h3>

                  <p className="mt-1 text-sm leading-relaxed text-gray-600">
                    {isBn
                      ? 'আপনার পরিস্থিতি অনুযায়ী সহজ ও কার্যকর কৃষি পরামর্শ পান।'
                      : 'Receive simple and practical farming advice based on your situation.'}
                  </p>
                </div>
              </div>

              {/* STEP 4 */}
              <div className="relative flex items-start gap-5">
                <div className="relative z-10 grid h-12 w-12 flex-shrink-0 place-items-center rounded-full bg-emerald-600 text-lg font-bold text-white shadow-md">
                  4
                </div>

                <div className="flex-1 rounded-xl border border-emerald-100 bg-white p-5 shadow-sm transition hover:border-emerald-300 hover:shadow-md">
                  <h3 className="text-lg font-bold text-gray-900">
                    {isBn ? 'প্রয়োগ করুন' : 'Take Action'}
                  </h3>

                  <p className="mt-1 text-sm leading-relaxed text-gray-600">
                    {isBn
                      ? 'পরামর্শ অনুসরণ করে আপনার কৃষিকাজে সঠিক সিদ্ধান্ত নিন।'
                      : 'Apply the recommendations and make better farming decisions.'}
                  </p>
                </div>
              </div>
            </div>
          </div>

          {/* GET STARTED BUTTON */}
          <div className="mt-12 text-center">
            <Link
              to="/register"
              className="inline-flex items-center gap-2 rounded-full bg-emerald-600 px-8 py-3 font-semibold text-white shadow-md transition hover:bg-emerald-700"
            >
              {isBn ? 'শুরু করুন →' : 'Get Started →'}
            </Link>
          </div>
        </div>
      </section>
    </div>
  );
} 