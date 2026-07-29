<?php include __DIR__ . '/../../includes/header.php'; ?>
<?php include __DIR__ . '/../../includes/navbar.php'; ?>

<!-- Bootstrap Icons for iconography -->
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">

<style>
    :root {
        --glass-bg: rgba(255, 255, 255, 0.85);
        --glass-border: rgba(255, 255, 255, 0.4);
        --glass-shadow: 0 10px 30px 0 rgba(46, 125, 50, 0.05);
    }

    .features-page { 
        background: #f0f7ee; 
        min-height: calc(100vh - 72px); 
        font-family: var(--font-bn);
        padding-bottom: 100px;
        overflow-x: hidden;
    }

    /* ── Premium Hero ── */
    .feat-hero {
        background:
            linear-gradient(135deg, rgba(13, 59, 26, 0.98) 0%, rgba(27, 94, 32, 0.94) 48%, rgba(46, 125, 50, 0.98) 100%);
        color: #fff;
        text-align: center;
        min-height: clamp(410px, 58vh, 500px);
        padding: 48px 24px 78px;
        position: relative;
        overflow: hidden;
        display: flex;
        align-items: center;
        justify-content: center;
    }
    .feat-hero::before {
        content: '';
        position: absolute;
        inset: 0;
        background:
            linear-gradient(32deg, rgba(0,0,0,0.16) 0 36%, transparent 36% 100%),
            linear-gradient(210deg, rgba(255,255,255,0.08) 0 28%, transparent 28% 100%);
    }
    .feat-hero::after {
        content: ''; position: absolute; bottom: -2px; left: 0; width: 100%; height: 60px;
        background: url('data:image/svg+xml;utf8,<svg viewBox="0 0 1440 100" preserveAspectRatio="none" xmlns="http://www.w3.org/2000/svg"><path fill="%23f0f7ee" d="M0,100 C320,0 420,100 720,50 C1020,0 1120,100 1440,50 L1440,100 L0,100 Z"/></svg>') center/cover no-repeat;
    }
    .feat-hero-content {
        position: relative;
        z-index: 1;
        max-width: 860px;
        margin: 0 auto;
        transform: translateY(-8px);
    }
    
    .hero-badge {
        display: inline-flex; align-items: center; gap: 8px;
        background: rgba(255,255,255,0.15); border: 1px solid rgba(255,255,255,0.3);
        border-radius: 30px; padding: 6px 16px; font-size: 14px; font-weight: 600;
        margin-bottom: 22px; backdrop-filter: blur(10px);
        animation: fadeInDown 0.8s ease;
    }
    .feat-hero h1 {
        color: #fff;
        font-family: var(--font-bn);
        font-size: clamp(38px, 5.4vw, 62px);
        font-weight: 800;
        margin-bottom: 18px;
        line-height: 1.2;
        animation: fadeInUp 0.8s ease 0.2s both;
    }
    .feat-hero p  {
        max-width: 760px;
        font-size: 18px;
        color: rgba(255,255,255,0.9);
        margin: 0 auto;
        line-height: 1.7;
        animation: fadeInUp 0.8s ease 0.3s both;
    }

    /* ── Module List ── */
    .modules-wrap { 
        max-width: 980px; margin: -46px auto 0; padding: 0 24px; 
        display: flex; flex-direction: column; gap: 24px;
        position: relative; z-index: 10;
    }

    /* ── Premium Accordion Card ── */
    .mod-card { 
        background: var(--glass-bg); border: 1px solid var(--glass-border);
        border-radius: 20px; box-shadow: var(--glass-shadow); backdrop-filter: blur(20px);
        overflow: hidden; transition: all 0.3s cubic-bezier(0.175, 0.885, 0.32, 1.275);
        animation: fadeInUp 0.8s ease 0.5s both;
    }
    .mod-card:hover { transform: translateY(-5px); box-shadow: 0 15px 40px rgba(46, 125, 50, 0.1); border-color: #4caf50; }
    
    .mod-header {
        display: flex; align-items: center; gap: 20px;
        padding: 24px 32px; cursor: pointer; user-select: none;
        transition: background 0.3s;
    }
    .mod-icon {
        width: 56px; height: 56px; border-radius: 16px;
        display: flex; align-items: center; justify-content: center;
        font-size: 24px; flex-shrink: 0; transition: transform 0.3s;
    }
    .mod-card:hover .mod-icon { transform: scale(1.1) rotate(5deg); }
    
    .mod-info { flex: 1; }
    .mod-info h3 { font-size: 20px; font-weight: 800; color: #1f2937; margin: 0 0 6px; }
    .mod-info p  { font-size: 15px; color: #6b7280; margin: 0; line-height: 1.5; }
    
    .mod-chevron { 
        width: 36px; height: 36px; border-radius: 50%; background: #f0f7ee; color: #1a5c28;
        display: flex; align-items: center; justify-content: center; font-size: 16px;
        transition: all 0.4s ease; flex-shrink: 0;
    }
    .mod-card.open .mod-chevron { transform: rotate(180deg); background: #1a5c28; color: #fff; }
    .mod-card.open { border-color: #1a5c28; }

    /* ── Feature Body ── */
    .mod-body { display: none; border-top: 1px solid #f1f1f1; background: #fff; padding-bottom: 12px; }
    .mod-card.open .mod-body { display: block; animation: fadeIn 0.4s ease; }

    .feat-grid {
        display: grid; grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
        gap: 16px; padding: 24px 32px;
    }
    .feat-item {
        display: flex; gap: 14px; align-items: flex-start;
        padding: 16px; border-radius: 12px; background: #fafcfb; border: 1px solid #f1f1f1;
        transition: all 0.3s;
    }
    .feat-item:hover { background: #f0f7ee; border-color: #a5d6a7; transform: translateY(-2px); }
    .feat-item i { font-size: 20px; margin-top: 2px; flex-shrink: 0; }
    .feat-item .ft { font-weight: 700; font-size: 15px; color: #1f2937; margin-bottom: 4px; }
    .feat-item .fd { font-size: 13px; color: #6b7280; line-height: 1.5; }

    @keyframes fadeInDown { from { opacity: 0; transform: translateY(-30px); } to { opacity: 1; transform: translateY(0); } }
    @keyframes fadeInUp { from { opacity: 0; transform: translateY(30px); } to { opacity: 1; transform: translateY(0); } }
    @keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }

    @media (max-width: 768px) {
        .feat-hero { min-height: 440px; padding: 42px 20px 76px; }
        .feat-hero-content { transform: none; }
        .modules-wrap { margin-top: -36px; }
        .mod-header { padding: 20px; }
        .mod-icon { width: 48px; height: 48px; font-size: 20px; }
        .feat-grid { padding: 20px; grid-template-columns: 1fr; }
    }
</style>

<div class="features-page">

    <!-- Premium Hero -->
    <div class="feat-hero">
        <div class="feat-hero-content">
            <div class="hero-badge">
                <span style="width:8px; height:8px; background:#4caf50; border-radius:50%; box-shadow:0 0 10px #4caf50;"></span>
                বাংলাদেশের স্মার্ট কৃষি প্ল্যাটফর্ম
            </div>
            <h1>প্ল্যাটফর্মের সকল <span style="color:#4caf50;">ফিচার ও মডিউল</span></h1>
            <p>AgroFin এর আধুনিক ইকোসিস্টেমের প্রতিটি মডিউলে ক্লিক করে বিস্তারিত ফিচারসমূহ সম্পর্কে জানুন।</p>
        </div>
    </div>

    <!-- Modules -->
    <div class="modules-wrap">

        <!-- ① Marketplace -->
        <div class="mod-card" onclick="toggle(this)">
            <div class="mod-header">
                <div class="mod-icon" style="background:#e8f5e9; color:#2e7d32;"><i class="bi bi-shop"></i></div>
                <div class="mod-info">
                    <h3>মার্কেটপ্লেস ম্যানেজমেন্ট</h3>
                    <p>ফসল তালিকা, অর্ডার এবং ট্রেডিং পরিচালনা</p>
                </div>
                <div class="mod-chevron"><i class="bi bi-chevron-down"></i></div>
            </div>
            <div class="mod-body">
                <div class="feat-grid">
                    <div class="feat-item"><i class="bi bi-list-check" style="color:#2e7d32;"></i><div><div class="ft">ফসল তালিকা</div><div class="fd">ছবি, মূল্য ও পরিমাণসহ ফসল যুক্ত করুন।</div></div></div>
                    <div class="feat-item"><i class="bi bi-cart-check" style="color:#2e7d32;"></i><div><div class="ft">স্মার্ট মার্কেটপ্লেস</div><div class="fd">AI-ম্যাচিংয়ে সেরা ক্রেতা খুঁজুন।</div></div></div>
                    <div class="feat-item"><i class="bi bi-box-seam" style="color:#2e7d32;"></i><div><div class="ft">অর্ডার ম্যানেজমেন্ট</div><div class="fd">অর্ডার গ্রহণ, প্রক্রিয়াকরণ ও ট্র্যাকিং।</div></div></div>
                    <div class="feat-item"><i class="bi bi-clipboard-data" style="color:#2e7d32;"></i><div><div class="ft">ইনভেন্টরি ট্র্যাকিং</div><div class="fd">মজুদ পরিমাণ স্বয়ংক্রিয়ভাবে আপডেট।</div></div></div>
                    <div class="feat-item"><i class="bi bi-translate" style="color:#2e7d32;"></i><div><div class="ft">বহুভাষিক সার্চ</div><div class="fd">বাংলা ও ইংরেজিতে ফসল খুঁজুন।</div></div></div>
                    <div class="feat-item"><i class="bi bi-geo-alt" style="color:#2e7d32;"></i><div><div class="ft">আঞ্চলিক ব্রাউজিং</div><div class="fd">জেলা অনুযায়ী ফসল দেখুন।</div></div></div>
                    <div class="feat-item"><i class="bi bi-arrow-left-right" style="color:#2e7d32;"></i><div><div class="ft">কৃষক ↔ ক্রেতা ট্রেডিং</div><div class="fd">মধ্যস্বত্বভোগী ছাড়া সরাসরি লেনদেন।</div></div></div>
                </div>
            </div>
        </div>

        <!-- ② Market Intelligence -->
        <div class="mod-card" onclick="toggle(this)" style="animation-delay: 0.6s;">
            <div class="mod-header">
                <div class="mod-icon" style="background:#fff3e0; color:#f57c00;"><i class="bi bi-graph-up-arrow"></i></div>
                <div class="mod-info">
                    <h3>মার্কেট ইন্টেলিজেন্স ও বিশ্লেষণ</h3>
                    <p>AI মূল্য পূর্বাভাস ও ডেটা-চালিত কৃষি সিদ্ধান্ত</p>
                </div>
                <div class="mod-chevron"><i class="bi bi-chevron-down"></i></div>
            </div>
            <div class="mod-body">
                <div class="feat-grid">
                    <div class="feat-item"><i class="bi bi-broadcast" style="color:#f57c00;"></i><div><div class="ft">লাইভ বাজার মূল্য</div><div class="fd">রিয়েল-টাইমে সারাদেশের দাম।</div></div></div>
                    <div class="feat-item"><i class="bi bi-cpu" style="color:#f57c00;"></i><div><div class="ft">AI মূল্য পূর্বাভাস</div><div class="fd">ML মডেল দিয়ে ভবিষ্যৎ দাম অনুমান।</div></div></div>
                    <div class="feat-item"><i class="bi bi-clock-history" style="color:#f57c00;"></i><div><div class="ft">ঐতিহাসিক মূল্য ট্র্যাকিং</div><div class="fd">অতীতের দামের তুলনামূলক চার্ট।</div></div></div>
                    <div class="feat-item"><i class="bi bi-calculator" style="color:#f57c00;"></i><div><div class="ft">লাভ/ক্ষতি বিশ্লেষণ</div><div class="fd">প্রতিটি ফসলের আয়-ব্যয়ের হিসাব।</div></div></div>
                    <div class="feat-item"><i class="bi bi-bar-chart-line" style="color:#f57c00;"></i><div><div class="ft">ফসল পারফরম্যান্স</div><div class="fd">কোন ফসল কতটা লাভজনক।</div></div></div>
                    <div class="feat-item"><i class="bi bi-map" style="color:#f57c00;"></i><div><div class="ft">ডিমান্ড হিটম্যাপ</div><div class="fd">কোন অঞ্চলে চাহিদা বেশি।</div></div></div>
                    <div class="feat-item"><i class="bi bi-pin-map" style="color:#f57c00;"></i><div><div class="ft">আঞ্চলিক সুপারিশ</div><div class="fd">আপনার এলাকার জন্য সেরা ফসল।</div></div></div>
                    <div class="feat-item"><i class="bi bi-robot" style="color:#f57c00;"></i><div><div class="ft">AI সিদ্ধান্ত সহায়তা</div><div class="fd">AI দিয়ে সেরা কৃষি সিদ্ধান্ত নিন।</div></div></div>
                </div>
            </div>
        </div>

        <!-- ③ Financial -->
        <div class="mod-card" onclick="toggle(this)" style="animation-delay: 0.7s;">
            <div class="mod-header">
                <div class="mod-icon" style="background:#e3f2fd; color:#1976d2;"><i class="bi bi-bank"></i></div>
                <div class="mod-info">
                    <h3>আর্থিক ও ঋণ ব্যবস্থাপনা</h3>
                    <p>ক্রেডিট স্কোরিং, মাইক্রো-লোন ও স্মার্ট পরিশোধ</p>
                </div>
                <div class="mod-chevron"><i class="bi bi-chevron-down"></i></div>
            </div>
            <div class="mod-body">
                <div class="feat-grid">
                    <div class="feat-item"><i class="bi bi-speedometer2" style="color:#1976d2;"></i><div><div class="ft">ক্রেডিট স্কোরিং ইঞ্জিন</div><div class="fd">AI-ভিত্তিক ঋণ যোগ্যতা মূল্যায়ন।</div></div></div>
                    <div class="feat-item"><i class="bi bi-cash-coin" style="color:#1976d2;"></i><div><div class="ft">তাৎক্ষণিক মাইক্রো-লোন</div><div class="fd">মিনিটের মধ্যে ঋণ অনুমোদন।</div></div></div>
                    <div class="feat-item"><i class="bi bi-patch-check" style="color:#1976d2;"></i><div><div class="ft">ঋণ যোগ্যতা যাচাই</div><div class="fd">আবেদনের আগেই যোগ্যতা জানুন।</div></div></div>
                    <div class="feat-item"><i class="bi bi-arrow-repeat" style="color:#1976d2;"></i><div><div class="ft">স্মার্ট পরিশোধ ব্যবস্থা</div><div class="fd">ফসল বিক্রির সাথে কিস্তি সমন্বয়।</div></div></div>
                    <div class="feat-item"><i class="bi bi-gear-wide-connected" style="color:#1976d2;"></i><div><div class="ft">স্বয়ংক্রিয় ঋণ কর্তন</div><div class="fd">বিক্রি থেকে স্বয়ংক্রিয় কিস্তি কাটা।</div></div></div>
                    <div class="feat-item"><i class="bi bi-eye" style="color:#1976d2;"></i><div><div class="ft">আর্থিক স্বচ্ছতা</div><div class="fd">সকল লেনদেনের সম্পূর্ণ হিসাব।</div></div></div>
                    <div class="feat-item"><i class="bi bi-exclamation-triangle" style="color:#1976d2;"></i><div><div class="ft">ঝুঁকি বিশ্লেষণ</div><div class="fd">ঋণ পরিশোধের ঝুঁকি স্বয়ংক্রিয় মূল্যায়ন।</div></div></div>
                </div>
            </div>
        </div>

        <!-- ④ Communication -->
        <div class="mod-card" onclick="toggle(this)" style="animation-delay: 0.8s;">
            <div class="mod-header">
                <div class="mod-icon" style="background:#f3e5f5; color:#7b1fa2;"><i class="bi bi-chat-dots"></i></div>
                <div class="mod-info">
                    <h3>যোগাযোগ ও স্মার্ট সহায়তা</h3>
                    <p>চ্যাট, ভয়েস অ্যাসিস্ট্যান্ট ও বহুভাষিক সাপোর্ট</p>
                </div>
                <div class="mod-chevron"><i class="bi bi-chevron-down"></i></div>
            </div>
            <div class="mod-body">
                <div class="feat-grid">
                    <div class="feat-item"><i class="bi bi-chat-left-text" style="color:#7b1fa2;"></i><div><div class="ft">কৃষক ↔ ক্রেতা চ্যাট</div><div class="fd">সরাসরি মেসেজে আলোচনা।</div></div></div>
                    <div class="feat-item"><i class="bi bi-currency-exchange" style="color:#7b1fa2;"></i><div><div class="ft">দাম নিয়ে দরকষাকষি</div><div class="fd">চ্যাটেই মূল্য নিয়ে আলোচনা।</div></div></div>
                    <div class="feat-item"><i class="bi bi-receipt" style="color:#7b1fa2;"></i><div><div class="ft">অর্ডার আলোচনা</div><div class="fd">অর্ডার সম্পর্কিত সকল যোগাযোগ।</div></div></div>
                    <div class="feat-item"><i class="bi bi-mic" style="color:#7b1fa2;"></i><div><div class="ft">ভয়েস অ্যাসিস্ট্যান্ট</div><div class="fd">কথা বলে সিস্টেম পরিচালনা।</div></div></div>
                    <div class="feat-item"><i class="bi bi-keyboard" style="color:#7b1fa2;"></i><div><div class="ft">টেক্সট অ্যাসিস্ট্যান্ট</div><div class="fd">টাইপ করে দ্রুত সাহায্য নিন।</div></div></div>
                    <div class="feat-item"><i class="bi bi-translate" style="color:#7b1fa2;"></i><div><div class="ft">বাংলা ও ইংরেজি সাপোর্ট</div><div class="fd">পছন্দের ভাষায় ব্যবহার করুন।</div></div></div>
                    <div class="feat-item"><i class="bi bi-lightbulb" style="color:#7b1fa2;"></i><div><div class="ft">স্মার্ট কৃষি গাইডেন্স</div><div class="fd">বিশেষজ্ঞ পরামর্শ সরাসরি চ্যাটে।</div></div></div>
                </div>
            </div>
        </div>

        <!-- ⑤ Logistics & Trust -->
        <div class="mod-card" onclick="toggle(this)" style="animation-delay: 0.9s;">
            <div class="mod-header">
                <div class="mod-icon" style="background:#eceff1; color:#37474f;"><i class="bi bi-shield-check"></i></div>
                <div class="mod-info">
                    <h3>লজিস্টিক্স, বিশ্বাস ও প্রশাসন</h3>
                    <p>ডেলিভারি, ট্রাস্ট স্কোর এবং অ্যাডমিন মনিটরিং</p>
                </div>
                <div class="mod-chevron"><i class="bi bi-chevron-down"></i></div>
            </div>
            <div class="mod-body">
                <div class="feat-grid">
                    <div class="feat-item"><i class="bi bi-truck" style="color:#37474f;"></i><div><div class="ft">ডেলিভারি ট্র্যাকিং</div><div class="fd">রিয়েল-টাইমে পণ্যের অবস্থান।</div></div></div>
                    <div class="feat-item"><i class="bi bi-signpost-2" style="color:#37474f;"></i><div><div class="ft">পরিবহন বুকিং</div><div class="fd">সহজেই ট্রান্সপোর্ট বুক করুন।</div></div></div>
                    <div class="feat-item"><i class="bi bi-people" style="color:#37474f;"></i><div><div class="ft">সমবায় কৃষি</div><div class="fd">একসাথে মিলে চাষাবাদ করুন।</div></div></div>
                    <div class="feat-item"><i class="bi bi-star" style="color:#37474f;"></i><div><div class="ft">কৃষক রেটিং</div><div class="fd">বিশ্বস্ত কৃষকদের রেটিং দিন।</div></div></div>
                    <div class="feat-item"><i class="bi bi-chat-square-text" style="color:#37474f;"></i><div><div class="ft">ক্রেতা ফিডব্যাক</div><div class="fd">পণ্যের মান সম্পর্কে মতামত।</div></div></div>
                    <div class="feat-item"><i class="bi bi-shield-lock" style="color:#37474f;"></i><div><div class="ft">ট্রাস্ট স্কোর সিস্টেম</div><div class="fd">বিশ্বাসযোগ্যতা পয়েন্ট সিস্টেম।</div></div></div>
                    <div class="feat-item"><i class="bi bi-cloud-sun" style="color:#37474f;"></i><div><div class="ft">আবহাওয়া সতর্কতা</div><div class="fd">গুরুত্বপূর্ণ আবহাওয়া আপডেট।</div></div></div>
                    <div class="feat-item"><i class="bi bi-display" style="color:#37474f;"></i><div><div class="ft">অ্যাডমিন মনিটরিং</div><div class="fd">সম্পূর্ণ প্ল্যাটফর্মের পর্যবেক্ষণ।</div></div></div>
                    <div class="feat-item"><i class="bi bi-bug" style="color:#37474f;"></i><div><div class="ft">প্রতারণা সনাক্তকরণ</div><div class="fd">সন্দেহজনক কার্যকলাপ চিহ্নিত।</div></div></div>
                </div>
            </div>
        </div>

    </div>
</div>

<script>
function toggle(card) {
    card.classList.toggle('open');
}
</script>

<?php include __DIR__ . '/../../includes/footer.php'; ?>
