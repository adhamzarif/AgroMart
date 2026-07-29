<?php
$districts = [
    'ঢাকা', 'ফরিদপুর', 'গাজীপুর', 'গোপালগঞ্জ', 'কিশোরগঞ্জ', 'মাদারীপুর', 'মানিকগঞ্জ', 'মুন্সীগঞ্জ', 'নারায়ণগঞ্জ', 'নরসিংদী', 'রাজবাড়ী', 'শরীয়তপুর', 'টাঙ্গাইল',
    'চট্টগ্রাম', 'বান্দরবান', 'ব্রাহ্মণবাড়িয়া', 'চাঁদপুর', 'কুমিল্লা', 'কক্সবাজার', 'ফেনী', 'খাগড়াছড়ি', 'লক্ষ্মীপুর', 'নোয়াখালী', 'রাঙ্গামাটি',
    'রাজশাহী', 'বগুড়া', 'চাঁপাইনবাবগঞ্জ', 'জয়পুরহাট', 'নওগাঁ', 'নাটোর', 'পাবনা', 'সিরাজগঞ্জ',
    'খুলনা', 'বাগেরহাট', 'চুয়াডাঙ্গা', 'যশোর', 'ঝিনাইদহ', 'কুষ্টিয়া', 'মাগুরা', 'মেহেরপুর', 'নড়াইল', 'সাতক্ষীরা',
    'বরিশাল', 'বরগুনা', 'ভোলা', 'ঝালকাঠি', 'পটুয়াখালী', 'পিরোজপুর',
    'সিলেট', 'হবিগঞ্জ', 'মৌলভীবাজার', 'সুনামগঞ্জ',
    'রংপুর', 'দিনাজপুর', 'গাইবান্ধা', 'কুড়িগ্রাম', 'লালমনিরহাট', 'নীলফামারী', 'পঞ্চগড়', 'ঠাকুরগাঁও',
    'ময়মনসিংহ', 'জামালপুর', 'নেত্রকোণা', 'শেরপুর'
];
$categories = ['সব ক্যাটাগরি', 'দানাশস্য', 'শাকসবজি', 'ফলমূল', 'মশলা'];
include __DIR__ . '/../../includes/header.php';
?>
<?php include __DIR__ . '/../../includes/navbar.php'; ?>

<!-- Include Bootstrap 5 Grid System only -->
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap-grid.min.css" rel="stylesheet">
<link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">

<style>
    :root {
        --glass-bg: rgba(255, 255, 255, 0.85);
        --glass-border: rgba(255, 255, 255, 0.4);
        --glass-shadow: 0 8px 32px 0 rgba(46, 125, 50, 0.05);
    }

    .marketplace-page { background: #f0f7ee; font-family: var(--font-bn); padding-bottom: 80px; overflow-x: hidden; }
    
    /* ── Premium Hero ── */
    .mp-hero {
        background: linear-gradient(135deg, #0d3b1a 0%, #1a5c28 50%, #2e7d32 100%);
        color: #fff; text-align: center; padding: 88px 24px 132px;
        position: relative; overflow: hidden;
    }
    .mp-hero::before {
        content: ''; position: absolute; top: -50%; left: -50%;
        width: 200%; height: 200%;
        background: radial-gradient(circle, rgba(255,255,255,0.08) 0%, transparent 60%);
        transform: rotate(30deg);
    }
    .mp-hero::after {
        content: ''; position: absolute; bottom: -2px; left: 0; width: 100%; height: 60px;
        background: url('data:image/svg+xml;utf8,<svg viewBox="0 0 1440 100" preserveAspectRatio="none" xmlns="http://www.w3.org/2000/svg"><path fill="%23f0f7ee" d="M0,100 C320,0 420,100 720,50 C1020,0 1120,100 1440,50 L1440,100 L0,100 Z"/></svg>') center/cover no-repeat;
    }
    .mp-hero .container { position: relative; z-index: 1; }
    .mp-hero h1 { font-size: clamp(36px, 5vw, 56px); font-weight: 800; margin-bottom: 16px; color: #fff; animation: fadeInDown 0.8s ease; }
    .mp-hero p { font-size: 18px; color: rgba(255,255,255,0.9); max-width: 760px; margin: 0 auto 26px; animation: fadeInUp 0.8s ease 0.2s both; line-height: 1.6; }
    .mp-hero-actions {
        display: flex; align-items: center; justify-content: center; gap: 14px; flex-wrap: wrap;
        animation: fadeInUp 0.8s ease 0.35s both;
    }
    .mp-hero-btn {
        min-width: 164px; display: inline-flex; align-items: center; justify-content: center; gap: 9px;
        padding: 13px 24px; border-radius: 14px; font-size: 15px; font-weight: 800;
        text-decoration: none; transition: all 0.25s ease;
    }
    .mp-hero-btn.primary { background: #fff; color: #1a5c28; box-shadow: 0 12px 28px rgba(0,0,0,0.18); }
    .mp-hero-btn.secondary { color: #fff; border: 1.5px solid rgba(255,255,255,0.45); background: rgba(255,255,255,0.12); backdrop-filter: blur(10px); }
    .mp-hero-btn:hover { transform: translateY(-2px); }
    .mp-hero-btn.primary:hover { color: #0d3b1a; box-shadow: 0 16px 34px rgba(0,0,0,0.22); }
    .mp-hero-btn.secondary:hover { background: rgba(255,255,255,0.2); color: #fff; }
    
    /* ── Filters Glassmorphism ── */
    .mp-filters {
        background: var(--glass-bg); backdrop-filter: blur(20px);
        border: 1px solid var(--glass-border); border-radius: 20px; padding: 24px 32px;
        box-shadow: 0 15px 35px rgba(0,0,0,0.08); margin-top: -80px;
        position: relative; z-index: 10; margin-bottom: clamp(100px, 14vh, 150px);
        animation: fadeInUp 0.8s ease 0.4s both;
    }
    .mp-filters label { font-size:13px; font-weight:600; color:var(--gray-700); margin-bottom:8px; display:block; }
    .mp-filters input {
        width: 100%; padding: 14px 20px; border: 1.5px solid #e9ecef; background: #f8f9fa;
        border-radius: 12px; font-size: 15px; outline: none; transition: all 0.3s;
    }
    .mp-filters input:focus { border-color: #1a5c28; background: #fff; box-shadow: 0 0 0 4px rgba(26,92,40,0.1); }
    .mp-custom-dd { position: relative; }
    .mp-dd-trigger {
        width: 100%; padding: 14px 20px; border: 1.5px solid #e9ecef; background: #f8f9fa;
        border-radius: 12px; font-size: 15px; color: #1f2937; cursor: pointer; outline: none;
        display: flex; align-items: center; justify-content: space-between; gap: 12px;
        transition: all 0.3s; user-select: none;
    }
    .mp-dd-trigger.placeholder { color: #6b7280; }
    .mp-dd-trigger:hover { border-color: #d1d5db; background: #fff; }
    .mp-dd-trigger.open { border-color: #1a5c28; background: #fff; box-shadow: 0 0 0 4px rgba(26,92,40,0.1); }
    .mp-dd-arrow { color: #1a5c28; font-size: 13px; line-height: 1; transition: transform 0.25s; }
    .mp-dd-trigger.open .mp-dd-arrow { transform: rotate(180deg); }
    .mp-dd-panel {
        display: none; position: absolute; bottom: calc(100% + 8px); left: 0; right: 0; z-index: 120;
        background: #fff; border: 1.5px solid #e9ecef; border-radius: 12px;
        box-shadow: 0 16px 34px rgba(0,0,0,0.12); overflow: hidden;
    }
    .mp-dd-panel.show { display: block; }
    .mp-dd-search-wrap { padding: 10px 12px; border-bottom: 1px solid #eef2ee; background: #fafafa; }
    .mp-dd-search { padding: 10px 12px !important; border-radius: 10px !important; font-size: 14px !important; }
    .mp-dd-options { max-height: 180px; overflow-y: auto; padding: 4px 0; }
    .mp-dd-opt {
        padding: 8px 16px; font-size: 14px; color: #374151; cursor: pointer;
        transition: background 0.18s, color 0.18s;
    }
    .mp-dd-opt:hover { background: #f0f9f0; color: #1a5c28; }
    .mp-dd-opt.selected { background: #e8f5e9; color: #1a5c28; font-weight: 700; }
    .mp-dd-empty { padding: 12px 16px; font-size: 14px; color: #6b7280; }
    .btn-search {
        background: #1a5c28; color: #fff; font-weight: 700; padding: 14px; border-radius: 12px; border: none; width: 100%; transition: all 0.3s;
    }
    .btn-search:hover { background: #0d3b1a; transform: translateY(-2px); box-shadow: 0 8px 20px rgba(26,92,40,0.2); }

    /* ── Premium Crop Cards ── */
    .section-title { font-size: 32px; font-weight: 800; color: #0d3b1a; margin-bottom: 8px; text-align: center; }
    .section-sub { font-size: 16px; color: #6c757d; text-align: center; margin-bottom: 30px; }

    .crop-card {
        background: #fff; border-radius: 20px; overflow: hidden;
        box-shadow: 0 10px 30px rgba(0,0,0,0.04); transition: all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
        height: 100%; display: flex; flex-direction: column; border: 1px solid #f1f1f1; position: relative;
    }
    .crop-card:hover { transform: translateY(-10px); box-shadow: 0 20px 40px rgba(46,125,50,0.12); border-color: #4caf50; }
    .crop-img { width: 100%; height: 170px; object-fit: cover; }
    .crop-badge {
        position: absolute; top: 16px; right: 16px; background: rgba(255,255,255,0.9); backdrop-filter: blur(5px);
        color: #d32f2f; padding: 6px 14px; border-radius: 30px; font-size: 12px; font-weight: 700; box-shadow: 0 4px 10px rgba(0,0,0,0.1);
    }
    .crop-body { padding: 18px 20px; flex-grow: 1; display: flex; flex-direction: column; }
    .crop-title { font-size: 20px; font-weight: 800; color: #1f2937; margin-bottom: 6px; }
    .crop-farmer { font-size: 13px; color: #6b7280; margin-bottom: 12px; display: flex; align-items: center; gap: 8px; }
    
    .crop-meta { display: flex; flex-wrap: wrap; gap: 8px; margin-bottom: 12px; }
    .meta-tag { background: #f0f7ee; color: #1a5c28; font-size: 12px; padding: 5px 10px; border-radius: 8px; font-weight: 600; display: inline-flex; align-items: center; gap: 6px; }
    .crop-body > p {
        display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical;
        overflow: hidden;
    }
    
    .crop-price-box {
        margin-top: 12px; padding-top: 14px; border-top: 1px solid #f1f1f1;
        display: flex; justify-content: space-between; align-items: center;
    }
    .price-val { font-size: 24px; font-weight: 800; color: #1a5c28; line-height: 1; margin-bottom: 3px; }
    .price-unit { font-size: 13px; color: #6b7280; font-weight: 500; }
    .btn-buy {
        background: #e8f5e9; color: #1a5c28; font-weight: 700; padding: 9px 20px; border-radius: 12px; font-size: 14px; transition: all 0.3s; border: none; text-decoration: none;
    }
    .btn-buy:hover { background: #1a5c28; color: #fff; transform: translateY(-2px); box-shadow: 0 5px 15px rgba(26,92,40,0.2); }

    /* ── How it works ── */
    .step-card {
        background: var(--glass-bg); border-radius: 20px; padding: 32px 24px; text-align: center;
        box-shadow: var(--glass-shadow); border: 1px solid var(--glass-border); position: relative; height: 100%; transition: all 0.3s;
    }
    .step-card:hover { transform: translateY(-5px); border-color: #4caf50; }
    .step-icon {
        width: 72px; height: 72px; background: #f0f7ee; color: #1a5c28;
        border-radius: 20px; display: flex; align-items: center; justify-content: center;
        font-size: 32px; margin: 0 auto 20px; transition: all 0.3s;
    }
    .step-card:hover .step-icon { background: #1a5c28; color: #fff; transform: rotate(10deg); }
    .step-num {
        position: absolute; top: -16px; left: 50%; transform: translateX(-50%);
        width: 32px; height: 32px; background: #1a5c28; color: #fff;
        border-radius: 50%; font-size: 14px; font-weight: 800;
        display: flex; align-items: center; justify-content: center; border: 4px solid #f0f7ee;
    }

    /* Animations */
    @keyframes fadeInDown { from { opacity: 0; transform: translateY(-30px); } to { opacity: 1; transform: translateY(0); } }
    @keyframes fadeInUp { from { opacity: 0; transform: translateY(30px); } to { opacity: 1; transform: translateY(0); } }
    .reveal { opacity: 0; transform: translateY(30px); transition: all 0.8s ease-out; }
    .reveal.active { opacity: 1; transform: translateY(0); }

    @media (max-width: 768px) {
        .mp-hero { padding: 70px 18px 118px; }
        .mp-hero p { font-size: 16px; }
        .mp-hero-actions { gap: 10px; }
        .mp-hero-btn { width: 100%; max-width: 280px; }
        .mp-filters { padding: 22px 18px; margin-bottom: 76px; }
        .crop-img { height: 190px; }
    }
</style>

<div class="marketplace-page">
    
    <!-- Hero Section -->
    <section class="mp-hero">
        <div class="container">
            <h1>🌾 স্মার্ট ক্রপ মার্কেটপ্লেস</h1>
            <p>বাংলাদেশের বিশ্বস্ত কৃষকদের কাছ থেকে সরাসরি তাজা কৃষিপণ্য কিনুন। মধ্যস্বত্বভোগী ছাড়া ন্যায্য মূল্যে সেরা ফসল। স্মার্ট ফিল্টারিং দিয়ে খুঁজে নিন আপনার পছন্দের পণ্য।</p>
            <div class="mp-hero-actions">
                <a href="#browse" class="mp-hero-btn primary"><i class="bi bi-basket2"></i> ফসল দেখুন</a>
                <a href="/AgroFin/liveprice" class="mp-hero-btn secondary"><i class="bi bi-graph-up-arrow"></i> লাইভ মার্কেট প্রাইস</a>
            </div>
        </div>
    </section>

    <div class="container">
        <!-- Search & Filter -->
        <div class="mp-filters">
            <div class="row g-3 align-items-end">
                <div class="col-md-4">
                    <label>সার্চ করুন</label>
                    <input type="text" placeholder="ফসলের নাম (যেমন: আলু, ধান)...">
                </div>
                <div class="col-md-3">
                    <label>ক্যাটাগরি</label>
                    <input type="hidden" name="category" id="marketCategoryVal" value="">
                    <div class="mp-custom-dd" data-dd="category">
                        <div class="mp-dd-trigger placeholder" data-dd-trigger>
                            <span data-dd-label>সব ক্যাটাগরি</span>
                            <span class="mp-dd-arrow">⌄</span>
                        </div>
                        <div class="mp-dd-panel" data-dd-panel>
                            <div class="mp-dd-options" data-dd-options></div>
                        </div>
                    </div>
                </div>
                <div class="col-md-3">
                    <label>জেলা</label>
                    <input type="hidden" name="district" id="marketDistrictVal" value="">
                    <div class="mp-custom-dd" data-dd="district">
                        <div class="mp-dd-trigger placeholder" data-dd-trigger>
                            <span data-dd-label>সব জেলা</span>
                            <span class="mp-dd-arrow">⌄</span>
                        </div>
                        <div class="mp-dd-panel" data-dd-panel>
                            <div class="mp-dd-search-wrap">
                                <input type="text" class="mp-dd-search" data-dd-search placeholder="জেলা খুঁজুন...">
                            </div>
                            <div class="mp-dd-options" data-dd-options></div>
                        </div>
                    </div>
                </div>
                <div class="col-md-2">
                    <button class="btn-search"><i class="bi bi-search me-2"></i> খুঁজুন</button>
                </div>
            </div>
        </div>

        <!-- Featured/Trending Crops -->
        <div class="mb-5 reveal" id="browse">
            <h2 class="section-title">🔥 নতুন ফসল ও পণ্য</h2>
            <p class="section-sub"><?php if(!empty($crops)): ?>নিবন্ধিত কৃষকদের সর্বশেষ পণ্য সরাসরি মাঠ থেকে<?php else: ?>এখনো কোনো কৃষক পণ্য যোগ করেননি। নতুন তালিকা শীঘ্রই আসবে।<?php endif; ?></p>

            <?php if(!empty($crops)): ?>
            <div class="row g-4">
                <?php foreach($crops as $crop): ?>
                <div class="col-12 col-md-6 col-lg-4">
                    <div class="crop-card">
                        <?php if($crop['status'] === 'limited'): ?>
                        <span class="crop-badge"><i class="bi bi-fire"></i> সীমিত স্টক</span>
                        <?php else: ?>
                        <span class="crop-badge" style="color:#0277bd; background:#e1f5fe;"><i class="bi bi-stars"></i> নতুন</span>
                        <?php endif; ?>
                        <?php
                            // Resolve the first uploaded image via the proper helper.
                            // first_image_variant() reads the JSON array, builds the correct
                            // /uploads/crops/... URL, and falls back to original if no thumb exists.
                            $img = first_image_variant($crop['images'] ?? null, 'medium');
                            if (empty($img)) $img = 'https://images.unsplash.com/photo-1599599810694-b5ac4dd33c1f?w=500&q=80';
                        ?>
                        <img src="<?= e($img) ?>" alt="<?= e($crop['crop_name']) ?>" class="crop-img" onerror="this.src='https://images.unsplash.com/photo-1599599810694-b5ac4dd33c1f?w=500&q=80'">
                        <div class="crop-body">
                            <h3 class="crop-title"><?= e($crop['crop_name']) ?> <?= !empty($crop['crop_variety']) ? '(' . e($crop['crop_variety']) . ')' : '' ?></h3>
                            <div class="crop-farmer">
                                <i class="bi bi-person-circle"></i> <?= e($crop['farmer_name'] ?? 'অজানা') ?> • <i class="bi bi-geo-alt-fill text-danger"></i> <?= e($crop['district_name'] ?? 'জেলা') ?>
                            </div>
                            <div class="crop-meta">
                                <span class="meta-tag"><i class="bi bi-box-seam"></i> <?= e($crop['quantity']) ?> <?= e($crop['unit'] ?? 'ইউনিট') ?></span>
                                <?php if($crop['farmer_rating']): ?>
                                <span class="meta-tag" style="background:#fff8e1; color:#f57c00;"><i class="bi bi-star-fill"></i> <?= number_format($crop['farmer_rating'], 1) ?> (<?= $crop['farmer_rating_count'] ?>)</span>
                                <?php endif; ?>
                            </div>
                            <p style="font-size:14px; color:#6b7280; margin-bottom:0; line-height:1.5;"><?= e(substr($crop['description'] ?? '', 0, 80)) ?><?= !empty($crop['description']) ? '...' : '' ?></p>
                            <div class="crop-price-box">
                                <div>
                                    <div class="price-val">৳ <?= e($crop['price_per_unit']) ?></div>
                                    <div class="price-unit">প্রতি <?= e($crop['unit'] ?? 'ইউনিট') ?></div>
                                </div>
                                <a href="/AgroFin/buyer/crop/<?= $crop['crop_id'] ?>" class="btn-buy">বিস্তারিত</a>
                            </div>
                        </div>
                    </div>
                </div>
                <?php endforeach; ?>
            </div>

            <div class="text-center mt-4">
                <a href="/AgroFin/marketplace/all" class="btn btn-outline-glow" style="border: 2px solid #1a5c28; color:#1a5c28; background:transparent; padding:10px 30px; border-radius:30px; font-weight:700; text-decoration:none; display:inline-flex; align-items:center; gap:8px;">আরও ফসল দেখুন <i class="bi bi-arrow-right"></i></a>
            </div>
            <?php else: ?>
            <div style="text-align:center; padding:48px 20px; background:#f0f9f0; border-radius:16px;">
                <p style="color:#6b7280; font-weight:700; margin-bottom:20px;">এখনো কোনো কৃষক তাদের পণ্য তালিকাভুক্ত করেননি। শীঘ্রই নতুন তালিকা আসবে।</p>
                <a href="/AgroFin" class="btn btn-outline-glow" style="border: 2px solid #1a5c28; color:#1a5c28; background:transparent; padding:10px 30px; border-radius:30px; font-weight:700; text-decoration:none; display:inline-flex; align-items:center; gap:8px;">হোমে ফিরুন <i class="bi bi-arrow-right"></i></a>
            </div>
            <?php endif; ?>
        </div>

        <!-- Live Price CTA -->
        <div class="mb-5 reveal" style="background: linear-gradient(135deg, #0d3b1a, #2e7d32); border-radius: 24px; padding: 48px 40px; text-align: center; color: #fff; position: relative; overflow: hidden; box-shadow: 0 20px 40px rgba(13,59,26,0.2);">
            <div style="position:absolute; right:-40px; top:-40px; width:200px; height:200px; border-radius:50%; background:rgba(255,255,255,0.05);"></div>
            <div style="position:absolute; left:-30px; bottom:-30px; width:150px; height:150px; border-radius:50%; background:rgba(255,255,255,0.04);"></div>
            <div style="position:relative; z-index:1;">
                <div style="display:inline-flex; align-items:center; gap:8px; background:rgba(255,255,255,0.15); border:1px solid rgba(255,255,255,0.2); padding:6px 16px; border-radius:30px; font-size:14px; font-weight:600; margin-bottom:20px; backdrop-filter:blur(5px);">
                    <span style="width:8px;height:8px;background:#4caf50;border-radius:50%;display:inline-block;box-shadow:0 0 10px #4caf50;"></span> রিয়েল-টাইম মার্কেট ডেটা
                </div>
                <h2 style="font-size:32px; font-weight:800; margin-bottom:12px; color:#fff;">📈 লাইভ মার্কেট প্রাইস দেখুন</h2>
                <p style="color:rgba(255,255,255,0.9); max-width:600px; margin:0 auto 32px; font-size:16px; line-height:1.6;">AgroFin কৃষকের দাম বনাম পাইকারি বাজারের তুলনা। ৩২+ ফসলের রিয়েল-টাইম মূল্য তালিকা বিশ্লেষণ করে সঠিক দামে কেনাবেচা করুন।</p>
                <a href="/AgroFin/liveprice" class="btn" style="background:#fff; color:#1a5c28; font-weight:700; font-size:16px; padding:16px 36px; border-radius:30px; text-decoration:none; display:inline-flex; align-items:center; gap:10px; box-shadow:0 10px 20px rgba(0,0,0,0.1); transition:all 0.3s;">
                    <i class="bi bi-graph-up-arrow"></i> লাইভ প্রাইস খুঁজুন
                </a>
            </div>
        </div>

        <!-- How it works -->
        <div class="mb-5 reveal">
            <h2 class="section-title">💡 কিভাবে কেনাকাটা করবেন?</h2>
            <p class="section-sub">AgroFin থেকে সরাসরি কৃষকের পণ্য কেনার সহজ ৪টি ধাপ</p>
            
            <div class="row g-4">
                <div class="col-12 col-md-6 col-lg-3">
                    <div class="step-card">
                        <div class="step-num">১</div>
                        <div class="step-icon"><i class="bi bi-search"></i></div>
                        <h4 style="font-size:18px; font-weight:800; color:#1f2937; margin-bottom:8px;">ফসল খুঁজুন</h4>
                        <p style="font-size:14px; color:#6b7280; line-height:1.6; margin:0;">মার্কেটপ্লেস থেকে ফিল্টার করে আপনার প্রয়োজনীয় ফসলটি নির্বাচন করুন।</p>
                    </div>
                </div>
                <div class="col-12 col-md-6 col-lg-3">
                    <div class="step-card">
                        <div class="step-num">২</div>
                        <div class="step-icon"><i class="bi bi-bar-chart"></i></div>
                        <h4 style="font-size:18px; font-weight:800; color:#1f2937; margin-bottom:8px;">দাম তুলনা করুন</h4>
                        <p style="font-size:14px; color:#6b7280; line-height:1.6; margin:0;">অন্যান্য কৃষক এবং সাধারণ বাজারের দামের সাথে তুলনা করে যাচাই করুন।</p>
                    </div>
                </div>
                <div class="col-12 col-md-6 col-lg-3">
                    <div class="step-card">
                        <div class="step-num">৩</div>
                        <div class="step-icon"><i class="bi bi-person-check"></i></div>
                        <h4 style="font-size:18px; font-weight:800; color:#1f2937; margin-bottom:8px;">যোগাযোগ করুন</h4>
                        <p style="font-size:14px; color:#6b7280; line-height:1.6; margin:0;">কৃষকের সাথে সরাসরি চ্যাট বা কল করে দাম ও শর্ত ঠিক করুন।</p>
                    </div>
                </div>
                <div class="col-12 col-md-6 col-lg-3">
                    <div class="step-card">
                        <div class="step-num">৪</div>
                        <div class="step-icon"><i class="bi bi-cart-check"></i></div>
                        <h4 style="font-size:18px; font-weight:800; color:#1f2937; margin-bottom:8px;">অর্ডার করুন</h4>
                        <p style="font-size:14px; color:#6b7280; line-height:1.6; margin:0;">অর্ডার প্লেস করুন এবং আমাদের নিরাপদ পেমেন্ট ও ডেলিভারি সেবা নিন।</p>
                    </div>
                </div>
            </div>
        </div>

    </div>
</div>

<script>
    document.addEventListener("DOMContentLoaded", function() {
        const dropdownData = {
            category: {
                items: <?= json_encode($categories, JSON_UNESCAPED_UNICODE) ?>,
                hiddenId: 'marketCategoryVal',
                defaultLabel: 'সব ক্যাটাগরি'
            },
            district: {
                items: ['সব জেলা', ...<?= json_encode($districts, JSON_UNESCAPED_UNICODE) ?>],
                hiddenId: 'marketDistrictVal',
                defaultLabel: 'সব জেলা'
            }
        };

        function closeMarketplaceDropdowns(except = null) {
            document.querySelectorAll('.mp-custom-dd').forEach(dropdown => {
                if (dropdown === except) return;
                dropdown.querySelector('[data-dd-panel]')?.classList.remove('show');
                dropdown.querySelector('[data-dd-trigger]')?.classList.remove('open');
            });
        }

        function initMarketplaceDropdown(dropdown) {
            const type = dropdown.dataset.dd;
            const config = dropdownData[type];
            if (!config) return;

            const trigger = dropdown.querySelector('[data-dd-trigger]');
            const label = dropdown.querySelector('[data-dd-label]');
            const panel = dropdown.querySelector('[data-dd-panel]');
            const search = dropdown.querySelector('[data-dd-search]');
            const options = dropdown.querySelector('[data-dd-options]');
            const hiddenInput = document.getElementById(config.hiddenId);

            function renderOptions(keyword = '') {
                const query = keyword.trim().toLowerCase();
                const filtered = config.items.filter(item => item.toLowerCase().includes(query));
                options.innerHTML = filtered.length
                    ? filtered.map(item => `<div class="mp-dd-opt" data-value="${item}">${item}</div>`).join('')
                    : '<div class="mp-dd-empty">কোনো ফলাফল পাওয়া যায়নি</div>';
            }

            renderOptions();

            trigger.addEventListener('click', () => {
                const isOpen = panel.classList.contains('show');
                closeMarketplaceDropdowns(dropdown);
                panel.classList.toggle('show', !isOpen);
                trigger.classList.toggle('open', !isOpen);
                if (!isOpen && search) {
                    search.value = '';
                    renderOptions();
                    setTimeout(() => search.focus(), 30);
                }
            });

            if (search) {
                search.addEventListener('input', () => renderOptions(search.value));
            }

            options.addEventListener('click', event => {
                const option = event.target.closest('.mp-dd-opt');
                if (!option) return;

                const value = option.dataset.value;
                label.textContent = value;
                hiddenInput.value = value === config.defaultLabel ? '' : value;
                trigger.classList.toggle('placeholder', value === config.defaultLabel);
                options.querySelectorAll('.mp-dd-opt').forEach(opt => opt.classList.toggle('selected', opt === option));
                panel.classList.remove('show');
                trigger.classList.remove('open');
            });
        }

        document.querySelectorAll('.mp-custom-dd').forEach(initMarketplaceDropdown);
        document.addEventListener('click', event => {
            if (!event.target.closest('.mp-custom-dd')) closeMarketplaceDropdowns();
        });

        const observer = new IntersectionObserver((entries) => {
            entries.forEach(entry => {
                if (entry.isIntersecting) {
                    entry.target.classList.add('active');
                }
            });
        }, { threshold: 0.1 });

        document.querySelectorAll('.reveal').forEach(el => observer.observe(el));
    });
</script>

<?php include __DIR__ . '/../../includes/footer.php'; ?>
