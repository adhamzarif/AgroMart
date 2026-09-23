// MicroLoans.jsx – deep-dive page for the "Micro-loans" feature

import { Link } from 'react-router-dom';
import { useLang } from '../../context/LangContext';
import { useState } from 'react';

const HERO_IMG =
  'https://images.unsplash.com/photo-1555212697-194d092e3b8f';

// Helper function to convert English digits to Bangla digits
const toBnNum = (str, isBn) => {
  if (!isBn) return str;
  const bnDigits = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
  return String(str).replace(/\d/g, (digit) => bnDigits[digit]);
};

export default function MicroLoans() {
  const { t, lang } = useLang();

  // Active View: null | 'status' | 'analytics' | 'repayment' | 'collateral'
  const [activePage, setActivePage] = useState(null);

  // Dynamic Current Step for Status Tracker
  const [currentStep, setCurrentStep] = useState(2);

  // Interactive States for Repayment Calculator
  const [loanAmount, setLoanAmount] = useState(20000);
  const [durationMonths, setDurationMonths] = useState(6);
  const [selectedSeason, setSelectedSeason] = useState('boro');

  // FAQ Toggle State
  const [openFaq, setOpenFaq] = useState(null);

  // Ask Question State for No Collateral Page
  const [userQuestion, setUserQuestion] = useState('');
  const [submittedQuestions, setSubmittedQuestions] = useState([]);

  const benefits = [
    { icon: '⚡', title: 'ml_benefit1_title', desc: 'ml_benefit1_desc' },
    { icon: '📊', title: 'ml_benefit2_title', desc: 'ml_benefit2_desc' },
    { icon: '📅', title: 'ml_benefit3_title', desc: 'ml_benefit3_desc' },
    { icon: '🛡️', title: 'ml_benefit4_title', desc: 'ml_benefit4_desc' },
  ];

  const steps = [
    { n: 1, title: 'ml_step1_title', desc: 'ml_step1_desc' },
    { n: 2, title: 'ml_step2_title', desc: 'ml_step2_desc' },
    { n: 3, title: 'ml_step3_title', desc: 'ml_step3_desc' },
    { n: 4, title: 'ml_step4_title', desc: 'ml_step4_desc' },
  ];

  const isBn = lang === 'bn';

  const handleCardClick = (index) => {
    if (index === 0) setActivePage('status');
    else if (index === 1) setActivePage('analytics');
    else if (index === 2) setActivePage('repayment');
    else if (index === 3) setActivePage('collateral');
    window.scrollTo({ top: 0, behavior: 'smooth' });
  };

  const handleBack = () => {
    setActivePage(null);
    window.scrollTo({ top: 0, behavior: 'smooth' });
  };

  // Calculations for Repayment Calculator
  const monthlyEmi = Math.round((loanAmount * 1.0533) / durationMonths);
  const totalRepay = Math.round(loanAmount * 1.0533);
  const totalInterest = totalRepay - loanAmount;

  // Monthly breakdown calculations for Repayment Graph
  const monthlyPrincipal = Math.round(loanAmount / durationMonths);
  const monthlyInterestPart = Math.round(totalInterest / durationMonths);

  // Dynamic Y-axis values based on EMI
  const maxAxisVal = Math.ceil((monthlyEmi * 1.05) / 100) * 100 || 3600;
  const midAxisVal = Math.round(maxAxisVal / 2);
  const quarterAxisVal = Math.round(maxAxisVal / 4);

  // Month names translation map
  const monthNames = {
    Jan: isBn ? 'জানু' : 'Jan',
    Feb: isBn ? 'ফেব্রু' : 'Feb',
    Mar: isBn ? 'মার্চ' : 'Mar',
    Apr: isBn ? 'এপ্রিল' : 'Apr',
    May: isBn ? 'মে' : 'May',
    Jun: isBn ? 'জুন' : 'Jun',
  };

  const handleQuestionSubmit = (e) => {
    e.preventDefault();
    if (!userQuestion.trim()) return;
    setSubmittedQuestions([userQuestion, ...submittedQuestions]);
    setUserQuestion('');
  };

  // =========================================================
  // 1. APPROVAL STATUS TRACKER
  // =========================================================
  if (activePage === 'status') {
    const trackerTexts = {
      back: isBn ? '← মাইক্রো-লোন পেজে ফিরে যান' : '← Back to Micro-Loans',
      pageTitle: isBn ? 'অনুমোদন ট্র্যাকিং স্টেটাস' : 'Approval Status Tracker',
      pageSub: isBn
        ? `আপনার ঋণ আবেদনের অগ্রগতি রিয়েল-টাইমে ট্র্যাক করুন — ${toBnNum('100', isBn)}% অনলাইন প্রক্রিয়া।`
        : 'Track your loan application progress in real-time — 100% online decision process.',
      quickBadge: isBn ? 'দ্রুত অনুমোদন' : 'Quick Approval',
      decisionTitle: isBn ? `${toBnNum('48', isBn)} ঘণ্টার মধ্যে সিদ্ধান্ত` : 'Decision within 48 hours',
      decisionDesc: isBn ? 'ব্যাংক পরিদর্শনের প্রয়োজন নেই — সম্পূর্ণ ডিজিটাল যাচাইকরণ' : 'No bank visits required — completely digital verification',
      timelineTitle: isBn ? 'আবেদনের অগ্রগতির টাইমলাইন' : 'Application Progress Timeline',
      simulateTitle: isBn ? 'অগ্রগতি সিমুলেট করুন (স্টেপ ক্লিক করুন)' : 'Simulate Progress',
      done: isBn ? '✓ সম্পন্ন' : '✓ Done',
      pending: isBn ? 'প্রক্রিয়াধীন' : 'Pending',
      step: isBn ? 'ধাপ' : 'Step',
      stepsData: [
        { id: 1, title: isBn ? 'আবেদন জমা দেওয়া হয়েছে' : 'Application Submitted', desc: isBn ? 'আপনার আবেদনপত্র গ্রহণ করা হয়েছে' : 'Your application was received and logged', time: isBn ? `আজ, ${toBnNum('10:45', isBn)} AM` : 'Today, 10:45 AM', icon: '📋' },
        { id: 2, title: isBn ? 'যাচাই করা হচ্ছে' : 'Under Review', desc: isBn ? 'এগ্রোমার্ট ক্রেডিট টিম আপনার তথ্য পরীক্ষা করছে' : 'AgroMart credit team is verifying your sales history', time: isBn ? `আজ, ${toBnNum('11:30', isBn)} AM` : 'Today, 11:30 AM', icon: '🔍' },
        { id: 3, title: isBn ? 'অনুমোদিত' : 'Approved', desc: isBn ? 'ঋণ অনুমোদিত — অর্থ ছাড়ের অপেক্ষায়' : 'Loan approved — awaiting disbursement confirmation', time: isBn ? `আজ, ${toBnNum('02:15', isBn)} PM` : 'Today, 02:15 PM', icon: '☑️' },
        { id: 4, title: isBn ? 'অর্থ প্রদান সম্পন্ন' : 'Disbursed', desc: isBn ? 'আপনার বিকাশ/ব্যাংক অ্যাকাউন্টে টাকা পাঠানো হয়েছে' : 'Money sent to your bKash / bank account', time: isBn ? `আজ, ${toBnNum('04:00', isBn)} PM` : 'Today, 04:00 PM', icon: '💰' },
      ],
    };

    return (
      <div className="bg-gray-50 min-h-screen">
        <section
          className="relative px-6 pt-12 pb-16 text-white"
          style={{
            backgroundImage: `linear-gradient(rgba(10, 35, 20, 0.85), rgba(10, 35, 20, 0.85)), url(${HERO_IMG})`,
            backgroundSize: 'cover',
            backgroundPosition: 'center',
          }}
        >
          <div className="mx-auto max-w-6xl">
            <button
              onClick={handleBack}
              className="inline-flex items-center gap-2 text-sm font-medium text-emerald-200 hover:text-white mb-6 transition cursor-pointer"
            >
              {trackerTexts.back}
            </button>
            <h1 className="text-3xl sm:text-4xl font-extrabold text-white">{trackerTexts.pageTitle}</h1>
            <p className="mt-2 text-emerald-100 text-sm sm:text-base">{trackerTexts.pageSub}</p>
          </div>
        </section>

        <div className="mx-auto max-w-6xl px-6 pt-8 pb-16">
          <div className="bg-white rounded-2xl p-6 shadow-sm border border-gray-100 mb-8">
            <span className="bg-orange-100 text-orange-600 text-[10px] font-bold px-3 py-1 rounded-full uppercase">
              {trackerTexts.quickBadge}
            </span>
            <div className="flex items-center gap-3 mt-3">
              <span className="text-2xl text-orange-500">⚡</span>
              <div>
                <h4 className="font-bold text-gray-900 text-base">{trackerTexts.decisionTitle}</h4>
                <p className="text-xs text-gray-500">{trackerTexts.decisionDesc}</p>
              </div>
            </div>
          </div>

          <div className="bg-white rounded-2xl p-6 sm:p-10 shadow-sm border border-gray-100 mb-8">
            <h3 className="text-lg font-bold text-gray-900 mb-8 pb-4 border-b border-gray-100">
              {trackerTexts.timelineTitle}
            </h3>
            <div className="space-y-8 relative before:absolute before:left-5 before:top-3 before:bottom-3 before:w-0.5 before:bg-gray-200">
              {trackerTexts.stepsData.map((step) => {
                const isDone = step.id <= currentStep;
                return (
                  <div key={step.id} className="flex items-start gap-4 relative z-10">
                    <div className={`w-10 h-10 rounded-full flex items-center justify-center text-lg transition-all ${
                      isDone ? 'bg-emerald-100 text-emerald-600 border border-emerald-300' : 'bg-gray-100 text-gray-400'
                    }`}>
                      {step.icon}
                    </div>
                    <div className="flex-1">
                      <div className="flex justify-between items-center">
                        <h3 className={`font-semibold text-sm sm:text-base ${isDone ? 'text-gray-900' : 'text-gray-400'}`}>
                          {step.title}
                        </h3>
                        {isDone && (
                          <span className="bg-emerald-100 text-emerald-600 text-[10px] sm:text-xs font-bold px-2.5 py-0.5 rounded-full">
                            {trackerTexts.done}
                          </span>
                        )}
                      </div>
                      <p className={`text-xs sm:text-sm mt-1 ${isDone ? 'text-gray-500' : 'text-gray-300'}`}>
                        {step.desc}
                      </p>
                      <p className="text-xs text-gray-400 mt-1 flex items-center gap-1">
                        ⏱ {isDone ? step.time : trackerTexts.pending}
                      </p>
                    </div>
                  </div>
                );
              })}
            </div>
          </div>

          <div className="bg-white rounded-2xl p-6 shadow-sm border border-gray-100">
            <h4 className="text-xs font-bold uppercase tracking-wider text-gray-400 mb-4">
              {trackerTexts.simulateTitle}
            </h4>
            <div className="flex flex-wrap gap-3">
              {[1, 2, 3, 4].map((stepNum) => (
                <button
                  key={stepNum}
                  onClick={() => setCurrentStep(stepNum)}
                  className={`px-5 py-2.5 rounded-xl text-sm font-semibold transition-all cursor-pointer ${
                    currentStep >= stepNum
                      ? 'bg-emerald-700 text-white shadow-sm hover:bg-emerald-800'
                      : 'bg-white border border-gray-200 text-gray-600 hover:bg-gray-50'
                  }`}
                >
                  {trackerTexts.step} {toBnNum(stepNum, isBn)}
                </button>
              ))}
            </div>
          </div>
        </div>
      </div>
    );
  }

  // =========================================================
  // 2. CREDIT & SALES ANALYTICS
  // =========================================================
  if (activePage === 'analytics') {
    const chartData = [
      { monthKey: 'Jan', sales: 12000, credit: 8000 },
      { monthKey: 'Feb', sales: 18000, credit: 12000 },
      { monthKey: 'Mar', sales: 10000, credit: 7000 },
      { monthKey: 'Apr', sales: 22000, credit: 18000 },
      { monthKey: 'May', sales: 30000, credit: 25000 },
      { monthKey: 'Jun', sales: 27000, credit: 22000 },
    ];

    const yAxisTicks = [32000, 24000, 16000, 8000, 0];

    return (
      <div className="bg-gray-50 min-h-screen">
        <section
          className="relative px-6 pt-12 pb-16 text-white"
          style={{
            backgroundImage: `linear-gradient(rgba(10, 35, 20, 0.85), rgba(10, 35, 20, 0.85)), url(${HERO_IMG})`,
            backgroundSize: 'cover',
            backgroundPosition: 'center',
          }}
        >
          <div className="mx-auto max-w-6xl">
            <button
              onClick={handleBack}
              className="inline-flex items-center gap-2 text-sm font-medium text-emerald-200 hover:text-white mb-6 transition cursor-pointer"
            >
              {isBn ? '← মাইক্রো-লোন পেজে ফিরে যান' : '← Back to Micro-Loans'}
            </button>
            
            <div className="flex items-center gap-3">
              <span className="bg-purple-100 text-purple-700 text-xs font-bold px-3 py-1 rounded-full">
                {isBn ? 'লেনদেন ভিত্তিক' : 'Transaction-based'}
              </span>
            </div>
            <h1 className="text-3xl sm:text-4xl font-extrabold text-white mt-2">
              {isBn ? 'ক্রেডিট ও বিক্রয় অ্যানালিটিক্স' : 'Credit & Sales Analytics'}
            </h1>
          </div>
        </section>

        <div className="mx-auto max-w-6xl px-6 pt-8 pb-16">
          <div className="bg-white rounded-2xl p-6 sm:p-8 shadow-sm border border-gray-100">
            {/* Top Stat Cards */}
            <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 mb-8">
              <div className="bg-gray-50 rounded-2xl p-5 text-center flex flex-col items-center justify-center">
                <span className="text-2xl mb-1">💰</span>
                <p className="text-2xl font-black text-emerald-600">৳{toBnNum('1,21,300', isBn)}</p>
                <p className="text-xs text-gray-400 font-medium mt-1">
                  {isBn ? '৬ মাসের মোট বিক্রয়' : '6-Month Sales'}
                </p>
              </div>

              <div className="bg-gray-50 rounded-2xl p-5 text-center flex flex-col items-center justify-center">
                <span className="text-2xl mb-1">📊</span>
                <p className="text-2xl font-black text-blue-600">
                  {toBnNum('782', isBn)} <span className="text-gray-400 text-base font-normal">/ {toBnNum('900', isBn)}</span>
                </p>
                <p className="text-xs text-gray-400 font-medium mt-1">
                  {isBn ? 'ক্রেডিট স্কোর' : 'Credit Score'}
                </p>
              </div>

              <div className="bg-gray-50 rounded-2xl p-5 text-center flex flex-col items-center justify-center">
                <span className="text-2xl mb-1">✅</span>
                <p className="text-2xl font-black text-emerald-600">
                  {isBn ? 'সর্বোচ্চ ৳' : 'Up to ৳'}{toBnNum('50,000', isBn)}
                </p>
                <p className="text-xs text-gray-400 font-medium mt-1">
                  {isBn ? 'ঋণ যোগ্যতা' : 'Eligibility'}
                </p>
              </div>
            </div>

            {/* Sales vs Credit History Graph */}
            <div className="mb-8">
              <h3 className="text-lg font-bold text-gray-800 mb-6">
                {isBn ? 'বিক্রয় বনাম ক্রেডিট ইতিহাস (৳)' : 'Sales vs Credit History (৳)'}
              </h3>
              
              <div className="relative pt-2 pb-2">
                <div className="flex h-64">
                  <div className="flex flex-col justify-between pr-3 text-right text-xs text-gray-400 font-medium select-none pb-6">
                    {yAxisTicks.map((tick) => (
                      <span key={tick}>{toBnNum(tick.toString(), isBn)}</span>
                    ))}
                  </div>

                  <div className="relative flex-1 border-l border-b border-gray-300 pb-6">
                    <div className="absolute inset-0 flex flex-col justify-between pointer-events-none pb-6">
                      {yAxisTicks.map((_, idx) => (
                        <div key={idx} className="border-b border-dashed border-gray-100 w-full h-0"></div>
                      ))}
                    </div>

                    <div className="relative h-full flex items-end justify-around px-2 sm:px-6 z-10">
                      {chartData.map((item, i) => (
                        <div key={i} className="flex-1 flex flex-col items-center h-full justify-end max-w-[80px]">
                          <div className="w-full flex items-end justify-center gap-1 sm:gap-1.5 h-full">
                            <div className="relative group/bar w-1/2 flex justify-center items-end h-full">
                              <div className="absolute -top-10 opacity-0 group-hover/bar:opacity-100 transition-all duration-200 bg-gray-900 text-white text-[11px] font-bold py-1 px-2.5 rounded shadow-xl pointer-events-none whitespace-nowrap z-30">
                                {isBn ? 'বিক্রয়: ৳' : 'Sales: ৳'}{toBnNum(item.sales.toLocaleString(), isBn)}
                              </div>
                              <div 
                                className="bg-[#1b7538] rounded-t w-full transition-all duration-200 group-hover/bar:bg-emerald-600 cursor-pointer"
                                style={{ height: `${(item.sales / 32000) * 100}%` }}
                              />
                            </div>

                            <div className="relative group/bar w-1/2 flex justify-center items-end h-full">
                              <div className="absolute -top-10 opacity-0 group-hover/bar:opacity-100 transition-all duration-200 bg-gray-900 text-white text-[11px] font-bold py-1 px-2.5 rounded shadow-xl pointer-events-none whitespace-nowrap z-30">
                                {isBn ? 'যোগ্য ঋণ: ৳' : 'Credit: ৳'}{toBnNum(item.credit.toLocaleString(), isBn)}
                              </div>
                              <div 
                                className="bg-[#8cc63f] rounded-t w-full transition-all duration-200 group-hover/bar:bg-lime-400 cursor-pointer"
                                style={{ height: `${(item.credit / 32000) * 100}%` }}
                              />
                            </div>
                          </div>

                          <span className="absolute -bottom-6 text-xs text-gray-500 font-medium">
                            {monthNames[item.monthKey]}
                          </span>
                        </div>
                      ))}
                    </div>
                  </div>
                </div>
              </div>

              <div className="flex justify-center items-center gap-6 mt-10">
                <div className="flex items-center gap-2 text-xs font-semibold text-gray-700">
                  <span className="w-3.5 h-3.5 bg-[#1b7538] rounded"></span> 
                  {isBn ? 'বিক্রয়' : 'Sales'}
                </div>
                <div className="flex items-center gap-2 text-xs font-semibold text-gray-700">
                  <span className="w-3.5 h-3.5 bg-[#8cc63f] rounded"></span> 
                  {isBn ? 'যোগ্য ঋণ' : 'Credit Eligible'}
                </div>
              </div>
            </div>

            <div className="bg-blue-50 border border-blue-100 rounded-xl p-5 mb-6">
              <h4 className="font-bold text-blue-900 text-sm">
                {isBn ? 'এটি কেন গুরুত্বপূর্ণ' : 'Why this matters'}
              </h4>
              <p className="text-xs text-blue-700 mt-1 leading-relaxed">
                {isBn
                  ? 'এগ্রোমার্ট আপনার ঋণের যোগ্যতা নির্ধারণে ব্যাংক স্টেটমেন্টের বদলে আসল বিক্রয়ের ইতিহাস ব্যবহার করে। বেশি বিক্রয় = বেশি ঋণের সীমার সুযোগ।'
                  : 'AgroMart uses your real selling history — not bank statements — to determine your loan eligibility. More sales = higher credit limit.'}
              </p>
            </div>

            <button
              onClick={handleBack}
              className="w-full bg-emerald-700 hover:bg-emerald-800 text-white font-bold py-3.5 rounded-xl transition cursor-pointer"
            >
              {isBn ? 'বন্ধ করুন' : 'Close'}
            </button>
          </div>
        </div>
      </div>
    );
  }

  // =========================================================
  // 3. REPAYMENT CALCULATOR
  // =========================================================
  if (activePage === 'repayment') {
    return (
      <div className="bg-gray-50 min-h-screen">
        <section
          className="relative px-6 pt-12 pb-16 text-white"
          style={{
            backgroundImage: `linear-gradient(rgba(10, 35, 20, 0.85), rgba(10, 35, 20, 0.85)), url(${HERO_IMG})`,
            backgroundSize: 'cover',
            backgroundPosition: 'center',
          }}
        >
          <div className="mx-auto max-w-6xl">
            <button
              onClick={handleBack}
              className="inline-flex items-center gap-2 text-sm font-medium text-emerald-200 hover:text-white mb-6 transition cursor-pointer"
            >
              {isBn ? '← মাইক্রো-লোন পেজে ফিরে যান' : '← Back to Micro-Loans'}
            </button>
            <div className="flex items-center gap-3">
              <span className="bg-emerald-100 text-emerald-700 text-xs font-bold px-3 py-1 rounded-full">
                {isBn ? 'নমনীয় পরিশোধ' : 'Flexible Repayment'}
              </span>
            </div>
            <h1 className="text-3xl sm:text-4xl font-extrabold text-white mt-2">
              {isBn ? 'পরিশোধ ক্যালকুলেটর' : 'Repayment Calculator'}
            </h1>
          </div>
        </section>

        <div className="mx-auto max-w-6xl px-6 pt-8 pb-16">
          <div className="bg-white rounded-2xl p-6 sm:p-8 shadow-sm border border-gray-100">
            
            <div className="flex justify-between items-center pb-4 mb-6 border-b border-gray-100">
              <h2 className="text-xl sm:text-2xl font-black text-gray-900 tracking-tight">
                {isBn ? 'পরিশোধ ক্যালকুলেটর' : 'Repayment Calculator'}
              </h2>
              <button
                onClick={handleBack}
                className="w-8 h-8 rounded-full bg-gray-100 text-gray-500 hover:bg-gray-200 flex items-center justify-center font-bold text-lg transition cursor-pointer"
                title={isBn ? 'বন্ধ করুন' : 'Close'}
              >
                ✕
              </button>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-8 mb-8">
              <div>
                <div className="flex items-center gap-1 mb-3">
                  <span className="text-xs font-bold tracking-wider text-gray-600 uppercase">
                    {isBn ? 'ঋণের পরিমাণ:' : 'LOAN AMOUNT:'}
                  </span>
                  <span className="text-xs font-bold text-slate-700">
                    ৳{toBnNum(loanAmount.toLocaleString(), isBn)}
                  </span>
                </div>
                
                <div className="relative flex items-center">
                  <input
                    type="range"
                    min="1000"
                    max="100000"
                    step="1000"
                    value={loanAmount}
                    onChange={(e) => setLoanAmount(Number(e.target.value))}
                    className="w-full h-2.5 bg-gray-700 rounded-lg appearance-none cursor-pointer accent-emerald-500"
                  />
                </div>

                <div className="flex justify-between text-xs text-gray-400 mt-2 font-medium">
                  <span>৳{toBnNum('1,000', isBn)}</span>
                  <span>৳{toBnNum('1,00,000', isBn)}</span>
                </div>
              </div>

              <div>
                <div className="flex items-center gap-1 mb-3">
                  <span className="text-xs font-bold tracking-wider text-gray-600 uppercase">
                    {isBn ? 'সময়সীমা:' : 'DURATION:'}
                  </span>
                  <span className="text-xs font-bold text-slate-700">
                    {toBnNum(durationMonths, isBn)} {isBn ? 'মাস' : 'MONTHS'}
                  </span>
                </div>

                <div className="relative flex items-center">
                  <input
                    type="range"
                    min="1"
                    max="24"
                    value={durationMonths}
                    onChange={(e) => setDurationMonths(Number(e.target.value))}
                    className="w-full h-2.5 bg-gray-700 rounded-lg appearance-none cursor-pointer accent-emerald-500"
                  />
                </div>

                <div className="flex justify-between text-xs text-gray-400 mt-2 font-medium">
                  <span>{toBnNum('1', isBn)}{isBn ? ' মাস' : 'm'}</span>
                  <span>{toBnNum('24', isBn)}{isBn ? ' মাস' : 'm'}</span>
                </div>
              </div>
            </div>

            <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 mb-8">
              <div className="bg-gray-50/70 rounded-2xl p-5 text-center">
                <p className="text-2xl font-black text-emerald-600">৳{toBnNum(monthlyEmi.toLocaleString(), isBn)}</p>
                <p className="text-xs text-gray-400 font-medium mt-1">{isBn ? 'মাসিক কিস্তি (EMI)' : 'Monthly EMI'}</p>
              </div>

              <div className="bg-gray-50/70 rounded-2xl p-5 text-center">
                <p className="text-2xl font-black text-gray-900">৳{toBnNum(totalRepay.toLocaleString(), isBn)}</p>
                <p className="text-xs text-gray-400 font-medium mt-1">{isBn ? 'মোট পরিশোধ' : 'Total Repay'}</p>
              </div>

              <div className="bg-gray-50/70 rounded-2xl p-5 text-center">
                <p className="text-2xl font-black text-orange-500">৳{toBnNum(totalInterest.toLocaleString(), isBn)}</p>
                <p className="text-xs text-gray-400 font-medium mt-1">{isBn ? 'মোট মুনাফা/মুনাফা ফি' : 'Total Interest'}</p>
              </div>
            </div>

            <div className="mb-8">
              <h3 className="text-base font-bold text-gray-800 mb-6">{isBn ? 'মাসিক হিসেব' : 'Monthly Breakdown'}</h3>
              
              <div className="flex h-56 relative">
                <div className="flex flex-col justify-between pr-3 text-right text-xs text-gray-400 font-medium select-none pb-6">
                  <span>{toBnNum(maxAxisVal.toString(), isBn)}</span>
                  <span>{toBnNum(midAxisVal.toString(), isBn)}</span>
                  <span>{toBnNum(quarterAxisVal.toString(), isBn)}</span>
                  <span>{toBnNum('0', isBn)}</span>
                </div>

                <div className="relative flex-1 border-l border-b border-gray-300 pb-6">
                  <div className="absolute inset-0 flex flex-col justify-between pointer-events-none pb-6">
                    <div className="border-b border-dashed border-gray-200 w-full h-0"></div>
                    <div className="border-b border-dashed border-gray-200 w-full h-0"></div>
                    <div className="border-b border-dashed border-gray-200 w-full h-0"></div>
                    <div className="border-b border-dashed border-gray-200 w-full h-0"></div>
                  </div>

                  <div className="relative h-full flex items-end justify-between px-3 sm:px-6 z-10 gap-2 sm:gap-4">
                    {Array.from({ length: durationMonths }).slice(0, 12).map((_, idx) => {
                      const totalBarHeightPercent = Math.min((monthlyEmi / maxAxisVal) * 100, 95);
                      const interestPercent = (monthlyInterestPart / monthlyEmi) * 100;
                      const principalPercent = 100 - interestPercent;

                      return (
                        <div key={idx} className="flex-1 flex flex-col items-center h-full justify-end group relative max-w-[65px]">
                          <div className="absolute -top-12 opacity-0 group-hover:opacity-100 transition duration-200 bg-gray-900 text-white text-[10px] py-1 px-2 rounded shadow-lg pointer-events-none whitespace-nowrap z-20">
                            <div>{isBn ? 'আসল:' : 'Principal:'} ৳{toBnNum(monthlyPrincipal.toLocaleString(), isBn)}</div>
                            <div>{isBn ? 'মুনাফা:' : 'Interest:'} ৳{toBnNum(monthlyInterestPart.toLocaleString(), isBn)}</div>
                          </div>

                          <div 
                            className="w-full rounded-t overflow-hidden flex flex-col cursor-pointer transition-transform group-hover:scale-105"
                            style={{ height: `${totalBarHeightPercent}%` }}
                          >
                            <div 
                              className="w-full bg-[#f8bd16]" 
                              style={{ height: `${interestPercent}%` }}
                            />
                            <div 
                              className="w-full bg-[#1b7538]" 
                              style={{ height: `${principalPercent}%` }}
                            />
                          </div>

                          <span className="absolute -bottom-6 text-xs text-gray-500 font-medium">
                            {isBn ? `মাস ${toBnNum(idx + 1, isBn)}` : `M${idx + 1}`}
                          </span>
                        </div>
                      );
                    })}
                  </div>
                </div>
              </div>
            </div>

            <div className="mb-8 mt-10">
              <h3 className="text-xs font-bold uppercase text-gray-500 mb-3">
                {isBn ? 'ফসল কাটার মৌসুম (পরিশোধের সময়সূচি)' : 'HARVEST SEASON (REPAYMENT WINDOW)'}
              </h3>
              <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
                {[
                  { id: 'boro', label: isBn ? '🌾 বোরো (জানু–মে)' : '🌾 Boro (Jan–May)' },
                  { id: 'aus', label: isBn ? '🌾 আউশ (মে–আগস্ট)' : '🌾 Aus (May–Aug)' },
                  { id: 'aman', label: isBn ? '🌾 আমন (আগস্ট–ডিসেম্বর)' : '🌾 Aman (Aug–Dec)' },
                ].map((s) => (
                  <button
                    key={s.id}
                    onClick={() => setSelectedSeason(s.id)}
                    className={`py-3 px-4 rounded-xl text-xs font-bold transition border cursor-pointer ${
                      selectedSeason === s.id
                        ? 'bg-emerald-700 text-white border-emerald-700 shadow-sm'
                        : 'bg-white text-gray-700 border-gray-200 hover:bg-gray-50'
                    }`}
                  >
                    {s.label}
                  </button>
                ))}
              </div>
              <p className="text-xs text-gray-400 mt-3">
                {isBn
                  ? 'পরিশোধের সময় আপনার নির্বাচিত ফসল কাটার মৌসুমের সাথে সামঞ্জস্যপূর্ণ করা হয় — ফসল ওঠার সময়ে কোনো চাপ থাকবে না।'
                  : 'Repayments are aligned to your selected harvest window — no pressure during growing season.'}
              </p>
            </div>

            <button
              onClick={handleBack}
              className="w-full bg-emerald-700 hover:bg-emerald-800 text-white font-bold py-3.5 rounded-xl transition cursor-pointer shadow-md"
            >
              {isBn ? 'বন্ধ করুন' : 'Close'}
            </button>
          </div>
        </div>
      </div>
    );
  }

  // =========================================================
  // 4. ELIGIBILITY, FAQ & ASK QUESTION
  // =========================================================
  if (activePage === 'collateral') {
    const faqItems = isBn
      ? [
          { q: 'আমার কি জামানত হিসেবে জমি লাগবে?', a: 'না, এগ্রোমার্ট মাইক্রো-লোন সম্পূর্ণ জামানত-মুক্ত। আমরা শুধু প্ল্যাটফর্মে আপনার ডিজিটাল বিক্রয়ের ইতিহাস মূল্যায়ন করি।' },
          { q: 'সর্বোচ্চ কত টাকা পর্যন্ত ঋণ পাওয়া যাবে?', a: 'আপনার ৬ মাসের বিক্রয় পরিমাণ এবং ক্রেডিট স্কোরের ওপর ভিত্তি করে সর্বোচ্চ ৫০,০০০ টাকা পর্যন্ত ঋণ পাওয়া যাবে।' },
          { q: 'অনুমোদনের পর টাকা কত দ্রুত পাওয়া যায়?', a: 'অনুমোদিত হলে, অর্থ তাৎক্ষণিকভাবে বা ৪৮ ঘণ্টার মধ্যে আপনার যুক্ত করা বিকাশ বা ব্যাংক অ্যাকাউন্টে জমা হয়ে যায়।' },
          { q: 'আমি কি সময়মতো কিস্তি পরিশোধ না করলে কি হবে?', a: 'ফসল কাটার পূর্বের দিনগুলোতে আপনি অতিরিক্ত সময় চেয়ে আবেদন করতে পারেন। জরিমানা এড়াতে আমাদের কিস্তি নমনীয় রাখা হয়েছে।' },
          { q: 'আমি কি নির্দিষ্ট সময়ের আগেই ঋণ পরিশোধ করতে পারি?', a: 'হ্যাঁ! নির্দিষ্ট সময়ের আগে পরিশোধ করলে কোনো বাড়তি চার্জ দিতে হবে না, যা ভবিষ্যতে আপনার ঋণের সীমা বাড়াতে সাহায্য করবে।' },
        ]
      : [
          { q: 'Do I need land as collateral?', a: 'No, AgroMart micro-loans are completely collateral-free. We only evaluate your digital sales history on the platform.' },
          { q: 'What is the maximum loan amount?', a: 'The maximum limit is up to ৳50,000 depending on your 6-month sales volume and credit score.' },
          { q: 'How quickly is the money disbursed?', a: 'Once approved, money is transferred instantly or within 48 hours to your linked bKash or bank account.' },
          { q: 'What happens if I miss a payment?', a: 'You can request a grace period during non-harvest months. Our repayment plans are flexible to prevent penalties.' },
          { q: 'Can I repay early?', a: 'Yes! Early repayment carries zero penalty charges and boosts your credit score for future higher loans.' },
        ];

    return (
      <div className="bg-gray-50 min-h-screen">
        <section
          className="relative px-6 pt-12 pb-16 text-white"
          style={{
            backgroundImage: `linear-gradient(rgba(10, 35, 20, 0.85), rgba(10, 35, 20, 0.85)), url(${HERO_IMG})`,
            backgroundSize: 'cover',
            backgroundPosition: 'center',
          }}
        >
          <div className="mx-auto max-w-6xl">
            <button
              onClick={handleBack}
              className="inline-flex items-center gap-2 text-sm font-medium text-emerald-200 hover:text-white mb-6 transition cursor-pointer"
            >
              {isBn ? '← মাইক্রো-লোন পেজে ফিরে যান' : '← Back to Micro-Loans'}
            </button>
            <div className="flex items-center gap-3">
              <span className="bg-blue-100 text-blue-700 text-xs font-bold px-3 py-1 rounded-full">
                {isBn ? 'জামানত মুক্ত' : 'No Collateral'}
              </span>
            </div>
            <h1 className="text-3xl sm:text-4xl font-extrabold text-white mt-2">
              {isBn ? 'যোগ্যতা এবং সাধারণ প্রশ্নাবলী' : 'Eligibility & FAQ'}
            </h1>
          </div>
        </section>

        <div className="mx-auto max-w-6xl px-6 pt-8 pb-16">
          <div className="bg-white rounded-2xl p-6 sm:p-8 shadow-sm border border-gray-100">
            <div className="mb-8">
              <h3 className="text-base font-bold text-gray-800 flex items-center gap-2 mb-4">
                <span className="text-emerald-600">☑</span> {isBn ? 'ঋণ পাওয়ার শর্তাবলী' : 'Eligibility Criteria'}
              </h3>

              <div className="space-y-3">
                <div className="bg-emerald-50/60 border border-emerald-100 rounded-xl p-4 flex items-center justify-between">
                  <div className="flex items-center gap-3">
                    <span className="text-xl">🌾</span>
                    <div>
                      <h4 className="font-bold text-gray-900 text-sm">{isBn ? 'সক্রিয় এগ্রোমার্ট বিক্রেতা' : 'Active AgroMart seller'}</h4>
                      <p className="text-xs text-gray-500">{isBn ? 'কমপক্ষে ৩ মাসের বিক্রয়ের ইতিহাস থাকতে হবে' : 'Must have at least 3 months of sales history'}</p>
                    </div>
                  </div>
                  <span className="text-emerald-600 font-bold">✓</span>
                </div>

                <div className="bg-emerald-50/60 border border-emerald-100 rounded-xl p-4 flex items-center justify-between">
                  <div className="flex items-center gap-3">
                    <span className="text-xl">📱</span>
                    <div>
                      <h4 className="font-bold text-gray-900 text-sm">{isBn ? 'যাচাইকৃত ফোন নম্বর' : 'Verified phone number'}</h4>
                      <p className="text-xs text-gray-500">{isBn ? 'অ্যাকেউন্টে বিকাশ বা ব্যাংক যুক্ত থাকতে হবে' : 'bKash or bank account linked to account'}</p>
                    </div>
                  </div>
                  <span className="text-emerald-600 font-bold">✓</span>
                </div>
              </div>
            </div>

            <div className="mb-8">
              <h3 className="text-base font-bold text-gray-800 mb-4">
                {isBn ? 'সাধারণ প্রশ্নাবলী (FAQ)' : 'Frequently Asked Questions'}
              </h3>
              <div className="space-y-3">
                {faqItems.map((item, idx) => (
                  <div key={idx} className="border border-gray-100 rounded-xl overflow-hidden">
                    <button
                      onClick={() => setOpenFaq(openFaq === idx ? null : idx)}
                      className="w-full text-left p-4 bg-gray-50/50 hover:bg-gray-50 font-semibold text-sm text-gray-800 flex justify-between items-center cursor-pointer"
                    >
                      <span>{item.q}</span>
                      <span className="text-gray-400 font-bold text-lg">{openFaq === idx ? '−' : '+'}</span>
                    </button>
                    {openFaq === idx && (
                      <div className="p-4 bg-white border-t border-gray-100 text-xs text-gray-600 leading-relaxed">
                        {item.a}
                      </div>
                    )}
                  </div>
                ))}
              </div>
            </div>

            <div className="bg-emerald-50/50 border border-emerald-100 rounded-2xl p-6 mb-8">
              <div className="flex items-center gap-2 mb-2">
                <span className="text-xl">💬</span>
                <h3 className="text-base font-bold text-gray-900">
                  {isBn ? 'আপনার কি অন্য কোনো প্রশ্ন আছে?' : 'Have a Question? Ask Us'}
                </h3>
              </div>
              <p className="text-xs text-gray-500 mb-4">
                {isBn
                  ? 'আপনার কোনো প্রশ্ন থাকলে নিচে লিখুন। আমাদের সাপোর্ট টিম দ্রুত উত্তর দেবে।'
                  : 'If you have any questions regarding loans or collateral, ask below.'}
              </p>

              <form onSubmit={handleQuestionSubmit} className="space-y-3">
                <textarea
                  rows="3"
                  value={userQuestion}
                  onChange={(e) => setUserQuestion(e.target.value)}
                  placeholder={isBn ? 'এখানে আপনার প্রশ্নটি লিখুন...' : 'Type your question here...'}
                  className="w-full p-3 bg-white border border-gray-200 rounded-xl text-xs text-gray-800 focus:ring-2 focus:ring-emerald-500 focus:outline-none resize-none"
                />
                <button
                  type="submit"
                  className="bg-emerald-700 hover:bg-emerald-800 text-white font-bold text-xs px-5 py-2.5 rounded-xl transition cursor-pointer shadow-sm"
                >
                  {isBn ? 'প্রশ্ন পাঠান' : 'Submit Question'}
                </button>
              </form>

              {submittedQuestions.length > 0 && (
                <div className="mt-6 pt-4 border-t border-emerald-200/60">
                  <h4 className="text-xs font-bold text-gray-700 mb-3">
                    {isBn ? 'আপনার জমাকৃত প্রশ্নসমূহ:' : 'Your Submitted Questions:'}
                  </h4>
                  <div className="space-y-2">
                    {submittedQuestions.map((q, index) => (
                      <div key={index} className="bg-white p-3 rounded-xl border border-emerald-100 text-xs text-gray-700">
                        <p className="font-medium text-gray-900">Q: {q}</p>
                        <p className="text-[11px] text-emerald-600 mt-1 font-semibold">
                          {isBn ? '⏳ পর্যালোচনার অধীনে আছে (শীঘ্রই উত্তর দেওয়া হবে)' : '⏳ Under review (Will be answered soon)'}
                        </p>
                      </div>
                    ))}
                  </div>
                </div>
              )}
            </div>

            <button
              onClick={handleBack}
              className="w-full bg-emerald-700 hover:bg-emerald-800 text-white font-bold py-3.5 rounded-xl transition cursor-pointer"
            >
              {isBn ? 'বন্ধ করুন' : 'Close'}
            </button>
          </div>
        </div>
      </div>
    );
  }

  // Default Home Page View of MicroLoans
  return (
    <div className="bg-gray-50 min-h-screen">
      <section
        className="relative px-6 pt-16 pb-20 text-white"
        style={{
          backgroundImage: `linear-gradient(rgba(10, 35, 20, 0.85), rgba(10, 35, 20, 0.85)), url(${HERO_IMG})`,
          backgroundSize: 'cover',
          backgroundPosition: 'center',
        }}
      >
        <div className="mx-auto max-w-6xl">
          <Link
            to="/dashboard"
            className="inline-flex items-center gap-2 text-sm font-medium text-emerald-200 hover:text-white mb-6 transition"
          >
            ← {isBn ? 'ড্যাশবোর্ডে ফিরে যান' : 'Back to Dashboard'}
          </Link>
          <div className="max-w-2xl">
            <span className="bg-emerald-500/20 text-emerald-300 text-xs font-bold px-3 py-1 rounded-full border border-emerald-400/30">
              {isBn ? 'ক্ষুদ্র ঋণ সেবা' : 'Micro-Loans Service'}
            </span>
            <h1 className="text-3xl sm:text-5xl font-extrabold text-white mt-4 tracking-tight leading-tight">
              {isBn ? 'আপনার কৃষিজ ব্যবসার জন্য সহজ ও দ্রুত ঋণ' : 'Fast & Easy Credit for Your Farm'}
            </h1>
            <p className="mt-4 text-emerald-100 text-sm sm:text-base leading-relaxed">
              {isBn
                ? 'এগ্রোমার্ট বিক্রেতাদের জন্য কোনো জামানত ছাড়াই সহজ কিস্তিতে ক্ষুদ্র ঋণের সুবিধা।'
                : 'Collateral-free micro-loans with flexible repayment tailored for AgroMart sellers.'}
            </p>
          </div>
        </div>
      </section>

      <div className="mx-auto max-w-6xl px-6 pt-8 pb-20">
        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6 mb-12">
          {benefits.map((item, idx) => (
            <div
              key={idx}
              onClick={() => handleCardClick(idx)}
              className="bg-white rounded-2xl p-6 shadow-sm border border-gray-100 hover:shadow-md transition duration-200 cursor-pointer flex flex-col justify-between group"
            >
              <div>
                <div className="text-3xl mb-4 group-hover:scale-110 transition duration-200">{item.icon}</div>
                <h3 className="font-bold text-gray-900 text-base mb-2">
                  {t(item.title)}
                </h3>
                <p className="text-xs text-gray-500 leading-relaxed">
                  {t(item.desc)}
                </p>
              </div>
              <div className="mt-6 flex items-center text-xs font-bold text-emerald-700 group-hover:translate-x-1 transition">
                {isBn ? 'বিস্তারিত দেখুন' : 'Explore Feature'} →
              </div>
            </div>
          ))}
        </div>

        <div className="bg-white rounded-2xl p-8 shadow-sm border border-gray-100">
          <h2 className="text-xl font-bold text-gray-900 mb-8 text-center">
            {isBn ? 'ঋণ আবেদনের সহজ ৪টি ধাপ' : '4 Easy Steps to Get Your Loan'}
          </h2>
          <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
            {steps.map((st) => (
              <div key={st.n} className="relative bg-gray-50/80 rounded-xl p-5 border border-gray-100">
                <span className="w-7 h-7 rounded-full bg-emerald-700 text-white font-bold text-xs flex items-center justify-center mb-3">
                  {toBnNum(st.n, isBn)}
                </span>
                <h4 className="font-bold text-gray-900 text-sm mb-1">{t(st.title)}</h4>
                <p className="text-xs text-gray-500 leading-relaxed">{t(st.desc)}</p>
              </div>
            ))}
          </div>
        </div>
      </div>
    </div>
  );
}