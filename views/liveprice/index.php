<?php include __DIR__ . '/../../includes/header.php'; ?>
<?php include __DIR__ . '/../../includes/navbar.php'; ?>

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap-grid.min.css" rel="stylesheet">

<style>
    .lp-page { background: #f0f7ee; font-family: var(--font-bn); padding-bottom: 64px; min-height: 100vh; }

    /* Hero */
    .lp-hero {
        background: linear-gradient(135deg, #0d3b1a 0%, #1a5c28 50%, #2e7d32 100%);
        color: #fff; text-align: center; padding: 64px 24px 100px;
        position: relative; overflow: hidden;
    }
    .lp-hero::before {
        content: ''; position: absolute; inset: 0;
        background: url("data:image/svg+xml,%3Csvg width='60' height='60' viewBox='0 0 60 60' xmlns='http://www.w3.org/2000/svg'%3E%3Cg fill='none' fill-rule='evenodd'%3E%3Cg fill='%23ffffff' fill-opacity='0.03'%3E%3Cpath d='M36 34v-4h-2v4h-4v2h4v4h2v-4h4v-2h-4zm0-30V0h-2v4h-4v2h4v4h2V6h4V4h-4zM6 34v-4H4v4H0v2h4v4h2v-4h4v-2H6zM6 4V0H4v4H0v2h4v4h2V6h4V4H6z'/%3E%3C/g%3E%3C/g%3E%3C/svg%3E");
    }
    .lp-hero .container { position: relative; z-index: 1; }
    .lp-hero h1 { font-size: clamp(28px, 5vw, 46px); font-weight: 800; margin-bottom: 12px; color: #fff; }
    .lp-hero p { font-size: 17px; color: rgba(255,255,255,0.85); max-width: 640px; margin: 0 auto 24px; }

    /* Live badge */
    .live-badge {
        display: inline-flex; align-items: center; gap: 8px;
        background: rgba(255,255,255,0.15); border: 1px solid rgba(255,255,255,0.25);
        backdrop-filter: blur(8px); padding: 6px 16px; border-radius: 24px;
        font-size: 13px; font-weight: 600; color: #fff; margin-bottom: 20px;
    }
    .live-dot { width: 8px; height: 8px; background: #4caf50; border-radius: 50%;
        box-shadow: 0 0 0 0 rgba(76,175,80,0.6); animation: pulse-dot 1.5s infinite; }
    @keyframes pulse-dot {
        0%   { box-shadow: 0 0 0 0 rgba(76,175,80,0.6); }
        70%  { box-shadow: 0 0 0 8px rgba(76,175,80,0); }
        100% { box-shadow: 0 0 0 0 rgba(76,175,80,0); }
    }

    /* Stats bar */
    .stats-bar {
        background: #fff; border-radius: 16px; padding: 20px 24px;
        box-shadow: 0 8px 32px rgba(0,0,0,0.08); margin-top: -60px;
        position: relative; z-index: 10; margin-bottom: 40px;
    }
    .stat-item { text-align: center; padding: 0 16px; }
    .stat-item:not(:last-child) { border-right: 1px solid var(--gray-100); }
    .stat-val { font-size: 26px; font-weight: 800; color: var(--m1-primary); line-height: 1; }
    .stat-lbl { font-size: 12px; color: var(--gray-500); margin-top: 4px; }

    /* Filter bar */
    .filter-bar {
        background: #fff; border-radius: 12px; padding: 16px 20px;
        box-shadow: 0 4px 16px rgba(0,0,0,0.04); margin-bottom: 28px;
        display: flex; gap: 12px; flex-wrap: wrap; align-items: flex-end;
    }
    .filter-bar select, .filter-bar input {
        padding: 10px 14px; border: 1.5px solid var(--gray-200); border-radius: 8px;
        font-size: 14px; outline: none; transition: border-color 0.2s; flex: 1; min-width: 140px;
    }
    .filter-bar select:focus, .filter-bar input:focus { border-color: var(--m1-primary); }

    /* Price Cards Grid */
    .price-card {
        background: #fff; border-radius: 16px; padding: 20px;
        box-shadow: 0 4px 16px rgba(0,0,0,0.04); border: 1px solid var(--gray-100);
        transition: transform 0.25s, box-shadow 0.25s;
        display: flex; flex-direction: column; gap: 12px;
    }
    .price-card:hover { transform: translateY(-4px); box-shadow: 0 12px 32px rgba(46,125,50,0.1); }
    .pc-top { display: flex; align-items: center; gap: 12px; }
    .pc-emoji { width: 48px; height: 48px; border-radius: 12px; display: flex; align-items: center; justify-content: center; font-size: 24px; flex-shrink: 0; }
    .pc-name { font-size: 17px; font-weight: 700; color: var(--gray-900); }
    .pc-cat  { font-size: 12px; color: var(--gray-500); }
    .pc-prices { display: flex; justify-content: space-between; align-items: flex-end; }
    .pc-agrofin { font-size: 22px; font-weight: 800; color: var(--m1-primary); }
    .pc-market  { font-size: 13px; color: var(--gray-400); text-decoration: line-through; }
    .pc-save { background: #e8f5e9; color: #2e7d32; font-size: 12px; font-weight: 600; padding: 4px 10px; border-radius: 20px; }
    .pc-bottom { display: flex; justify-content: space-between; align-items: center; padding-top: 12px; border-top: 1px dashed var(--gray-200); }
    .pc-trend { font-size: 13px; display: flex; align-items: center; gap: 4px; }
    .trend-up   { color: #e53935; }
    .trend-down { color: #2e7d32; }
    .trend-flat { color: var(--gray-500); }
    .pc-unit { font-size: 12px; color: var(--gray-400); }

    /* Big Table */
    .price-table { width: 100%; background: #fff; border-radius: 16px; overflow: hidden; box-shadow: 0 4px 16px rgba(0,0,0,0.04); }
    .price-table th { background: #f0f7ee; padding: 14px 16px; font-weight: 700; color: var(--gray-700); font-size: 13px; text-transform: uppercase; letter-spacing: 0.5px; }
    .price-table td { padding: 14px 16px; border-top: 1px solid var(--gray-100); vertical-align: middle; font-size: 14px; }
    .price-table tr:hover td { background: #f9fdf9; }

    .section-title { font-size: 24px; font-weight: 800; color: var(--gray-900); margin-bottom: 6px; }
    .section-sub   { font-size: 14px; color: var(--gray-500); margin-bottom: 28px; }
    .view-toggle { display: flex; gap: 6px; }
    .vt-btn { padding: 8px 14px; border: 1.5px solid var(--gray-200); border-radius: 8px; background: #fff; color: var(--gray-600); font-size: 13px; cursor: pointer; transition: all 0.2s; }
    .vt-btn.active { background: var(--m1-primary); color: #fff; border-color: var(--m1-primary); }

    .last-updated { font-size: 12px; color: var(--gray-400); display: flex; align-items: center; gap: 6px; }
</style>

<div class="lp-page">

    <!-- Hero -->
    <section class="lp-hero">
        <div class="container">
            <div class="live-badge"><span class="live-dot"></span> রিয়েল-টাইম আপডেট</div>

            <?php if ($viewMode === 'farmer'): ?>
                <h1>📊 আজকের বাজার নির্দেশিকা</h1>
                <p>অন্যান্য কৃষকদের গড় বিক্রয় মূল্য এবং বাইরের পাইকারি বাজার দরের তুলনা — নিজের মূল্য সঠিকভাবে নির্ধারণে সহায়ক।</p>
            <?php else: ?>
                <h1>📈 লাইভ মার্কেট প্রাইস</h1>
                <p>AgroFin কৃষকের সরাসরি বিক্রয় মূল্য বনাম বাইরের পাইকারি বাজার — সাশ্রয়ী দামে তাজা ফসল কিনুন।</p>
            <?php endif; ?>

            <div class="last-updated" style="justify-content: center; color: rgba(255,255,255,0.65);">
                <i class="bi bi-clock"></i> সর্বশেষ আপডেট:
                <?php if (!empty($lastUpdated)): ?>
                    <?= bn_date($lastUpdated, true) ?>
                <?php else: ?>
                    এখনো আপডেট হয়নি
                <?php endif; ?>
            </div>

            <?php if ($isStaff): ?>
            <div style="margin-top: 14px;">
                <span style="display:inline-block; background:rgba(255,255,255,0.12); color:#fff; font-size:11px; padding:5px 12px; border-radius:20px; border:1px solid rgba(255,255,255,0.25);">
                    <i class="bi bi-eye"></i> অ্যাডমিন প্রিভিউ &middot; ক্রেতাদের দৃশ্য
                </span>
            </div>
            <?php endif; ?>

            <?php if ($canToggle): ?>
            <div style="margin-top: 18px; display:flex; gap:8px; justify-content:center; flex-wrap:wrap;">
                <a href="/AgroFin/liveprice/setView/buyer"
                   style="background:<?= $viewMode==='buyer' ? '#fff' : 'rgba(255,255,255,0.12)' ?>; color:<?= $viewMode==='buyer' ? '#1a5c28' : '#fff' ?>; padding:8px 18px; border-radius:24px; text-decoration:none; font-weight:600; font-size:13px; border:1px solid rgba(255,255,255,0.3);">
                   🛒 ক্রেতা দৃশ্য
                </a>
                <a href="/AgroFin/liveprice/setView/farmer"
                   style="background:<?= $viewMode==='farmer' ? '#fff' : 'rgba(255,255,255,0.12)' ?>; color:<?= $viewMode==='farmer' ? '#1a5c28' : '#fff' ?>; padding:8px 18px; border-radius:24px; text-decoration:none; font-weight:600; font-size:13px; border:1px solid rgba(255,255,255,0.3);">
                   👨‍🌾 কৃষক দৃশ্য
                </a>
            </div>
            <?php endif; ?>
        </div>
    </section>

    <div class="container">

        <!-- Live Stats Bar -->
        <div class="stats-bar">
            <div class="row align-items-center">
                <div class="col-4 stat-item">
                    <div class="stat-val"><?= bn_num($totalProducts ?? 0) ?></div>
                    <div class="stat-lbl">পণ্যের সংখ্যা</div>
                </div>
                <div class="col-4 stat-item">
                    <div class="stat-val"><?= bn_num($totalFarmers ?? 0) ?></div>
                    <div class="stat-lbl">সক্রিয় কৃষক</div>
                </div>
                <div class="col-4 stat-item">
                    <div class="stat-val"><?= bn_num($avgGapPct ?? 0) ?>%</div>
                    <div class="stat-lbl">
                        <?= $viewMode === 'farmer' ? 'গড় মূল্য পার্থক্য' : 'গড় সাশ্রয়' ?>
                    </div>
                </div>
            </div>
        </div>


        <!-- Filter Bar -->
        <div class="filter-bar">
            <input type="text" id="priceSearch" placeholder="🔍  ফসলের নাম লিখুন..." oninput="filterPrices()">

            <select id="catFilter" onchange="filterPrices()">
                <option value="">সব ক্যাটাগরি</option>
                <option value="দানাশস্য">দানাশস্য</option>
                <option value="শাকসবজি">শাকসবজি</option>
                <option value="ফলমূল">ফলমূল</option>
                <option value="মশলা">মশলা</option>
            </select>
            <select id="trendFilter" onchange="filterPrices()">
                <option value="">সব ট্রেন্ড</option>
                <option value="up">ঊর্ধ্বমুখী</option>
                <option value="down">নিম্নমুখী</option>
                <option value="flat">স্থিতিশীল</option>
            </select>
            <div class="view-toggle">
                <button class="vt-btn active" id="btnCard" onclick="setView('card')"><i class="bi bi-grid-3x3-gap"></i></button>
                <button class="vt-btn" id="btnTable" onclick="setView('table')"><i class="bi bi-table"></i></button>
            </div>
        </div>

        <!-- Card View -->
        <div id="cardView">
            <div class="row g-3" id="priceCards">

                <?php
                // $crops is now populated from BOTH the crops table (real farmer prices)
                // and market_prices (external reference). If empty, no farmers have any
                // active listings — show a meaningful message.
                $crops = $crops ?? [];

                if (empty($crops)):
                ?>
                <div class="col-12">
                    <div style="background:#fff; border-radius:16px; padding:48px 24px; text-align:center; box-shadow:0 4px 16px rgba(0,0,0,0.04);">
                        <i class="bi bi-basket" style="font-size:48px; color:#bdbdbd;"></i>
                        <?php if ($viewMode === 'farmer'): ?>
                            <h3 style="font-size:18px; font-weight:700; color:var(--gray-700); margin-top:16px;">এখনো কোনো ফসল তালিকাভুক্ত নেই</h3>
                            <p style="color:var(--gray-500); margin-top:8px; max-width:460px; margin-left:auto; margin-right:auto;">
                                আপনি প্রথম কৃষক হোন! আপনার ফসল যোগ করলে এখানে বাজার দরের সাথে তুলনা দেখা যাবে এবং অন্যান্য কৃষকরাও উপকৃত হবেন।
                            </p>
                            <a href="/AgroFin/farmer/crops/create" class="btn btn-primary" style="margin-top:18px;">নতুন ফসল যোগ করুন</a>
                        <?php else: ?>
                            <h3 style="font-size:18px; font-weight:700; color:var(--gray-700); margin-top:16px;">এখনো কোনো কৃষক পণ্য তালিকাভুক্ত করেননি</h3>
                            <p style="color:var(--gray-500); margin-top:8px; max-width:460px; margin-left:auto; margin-right:auto;">
                                যখন নিবন্ধিত কৃষকরা তাদের ফসল মার্কেটপ্লেসে যোগ করবেন, তখনই এখানে রিয়েল-টাইম মূল্য প্রদর্শিত হবে।
                            </p>
                            <a href="/AgroFin/auth/register" class="btn btn-primary" style="margin-top:18px;">কৃষক হিসেবে যোগ দিন</a>
                        <?php endif; ?>
                    </div>
                </div>
                <?php else: ?>
                <?php
                foreach($crops as $c):
                    // Trend label adapts to audience:
                    //  - For buyers: ↑ = price going up = bad (less savings)
                    //  - For farmers: ↑ = price going up = good (can charge more)
                    if ($viewMode === 'farmer') {
                        $trendIcon  = $c['trend']==='up'   ? '<i class="bi bi-arrow-up trend-down"></i> মূল্য বাড়ছে'
                                    : ($c['trend']==='down' ? '<i class="bi bi-arrow-down trend-up"></i> মূল্য কমছে'
                                    :                         '<i class="bi bi-dash trend-flat"></i> স্থিতিশীল');
                    } else {
                        $trendIcon  = $c['trend']==='up'   ? '<i class="bi bi-arrow-up trend-up"></i> ঊর্ধ্বমুখী'
                                    : ($c['trend']==='down' ? '<i class="bi bi-arrow-down trend-down"></i> নিম্নমুখী'
                                    :                         '<i class="bi bi-dash trend-flat"></i> স্থিতিশীল');
                    }

                    // Farmer count label: subtle tweak so farmer-view doesn't sound like a brag
                    $farmerCountLabel = $viewMode === 'farmer'
                        ? bn_num($c['farmer_count']) . ' কৃষক বিক্রি করছেন'
                        : bn_num($c['farmer_count']) . ' কৃষক';
                ?>
                <div class="col-12 col-sm-6 col-lg-4 price-card-wrap"
                     data-name="<?= e($c['name']) ?>" data-cat="<?= e($c['cat']) ?>" data-trend="<?= e($c['trend']) ?>">
                    <div class="price-card">
                        <div class="pc-top">
                            <div class="pc-emoji" style="background:<?= e($c['bg']) ?>">
                                <?php if (!empty($c['image_url'])): ?>
                                    <img src="<?= e($c['image_url']) ?>" alt="<?= e($c['name']) ?>"
                                         style="width:100%; height:100%; object-fit:cover; border-radius:12px;"
                                         onerror="this.parentElement.innerHTML='<?= addslashes($c['emoji']) ?>';">
                                <?php else: ?>
                                    <?= $c['emoji'] ?>
                                <?php endif; ?>
                            </div>
                            <div style="flex:1;">
                                <div class="pc-name"><?= e($c['name']) ?></div>
                                <div class="pc-cat">
                                    <?= e($c['cat']) ?>
                                    <span style="color:var(--m1-primary); font-weight:600;">
                                        · <?= $farmerCountLabel ?>
                                    </span>
                                </div>
                            </div>
                        </div>
                        <div class="pc-prices">
                            <?php if ($viewMode === 'farmer'): ?>
                                <!-- FARMER VIEW: lead with market price (what they could earn), reference is the AgroFin avg -->
                                <div>
                                    <div style="font-size:11px; color:var(--gray-400); margin-bottom:2px;">বাজার দর (বাইরে)</div>
                                    <div class="pc-agrofin">
                                        <?php if($c['has_market']): ?>৳ <?= $c['market'] ?><?php else: ?><span style="color:#9e9e9e; font-style:italic;">তথ্য নেই</span><?php endif; ?>
                                    </div>
                                    <div class="pc-market" style="text-decoration:none; color:var(--gray-500);">AgroFin গড়: ৳ <?= $c['agrofin'] ?></div>
                                </div>
                                <div style="text-align:right;">
                                    <?php if($c['gap'] !== null && $c['gap_positive']): ?>
                                        <div class="pc-save" style="background:#fff3e0; color:#e65100;">৳ <?= $c['gap'] ?> বেশি</div>
                                    <?php elseif($c['gap'] !== null && !$c['gap_positive']): ?>
                                        <div class="pc-save" style="background:#e8f5e9; color:#2e7d32;">৳ <?= $c['gap'] ?> এগিয়ে</div>
                                    <?php else: ?>
                                        <div class="pc-save" style="background:#f5f5f5; color:#9e9e9e;">তুলনা নেই</div>
                                    <?php endif; ?>
                                    <div class="pc-unit" style="margin-top:6px;">প্রতি <?= e($c['unit']) ?></div>
                                </div>
                            <?php else: ?>
                                <!-- BUYER VIEW: lead with AgroFin price (what they pay), reference is market price -->
                                <div>
                                    <div style="font-size:11px; color:var(--gray-400); margin-bottom:2px;">AgroFin মূল্য</div>
                                    <div class="pc-agrofin">৳ <?= $c['agrofin'] ?></div>
                                    <?php if($c['has_market']): ?>
                                    <div class="pc-market">বাজার দর: ৳ <?= $c['market'] ?></div>
                                    <?php else: ?>
                                    <div class="pc-market" style="text-decoration:none; color:var(--gray-400); font-style:italic;">বাজার দর: তথ্য নেই</div>
                                    <?php endif; ?>
                                </div>
                                <div style="text-align:right;">
                                    <?php if($c['gap'] !== null && $c['gap_positive']): ?>
                                        <div class="pc-save">৳ <?= $c['gap'] ?> সাশ্রয়</div>
                                    <?php else: ?>
                                        <div class="pc-save" style="background:#f5f5f5; color:#9e9e9e;">তুলনা নেই</div>
                                    <?php endif; ?>
                                    <div class="pc-unit" style="margin-top:6px;">প্রতি <?= e($c['unit']) ?></div>
                                </div>
                            <?php endif; ?>
                        </div>
                        <div class="pc-bottom">
                            <div class="pc-trend"><?= $trendIcon ?></div>
                            <?php if ($viewMode === 'farmer'): ?>
                                <a href="/AgroFin/farmer/crops" class="btn btn-primary" style="padding:6px 14px; font-size:13px;">আমার ফসল</a>
                            <?php else: ?>
                                <a href="/AgroFin/marketplace" class="btn btn-primary" style="padding:6px 14px; font-size:13px;">কিনুন</a>
                            <?php endif; ?>
                        </div>
                    </div>
                </div>
                <?php endforeach; ?>
                <?php endif; ?>

            </div>
            <div id="noResults" style="display:none; text-align:center; padding:40px; color:var(--gray-400);">
                <i class="bi bi-search" style="font-size:40px;"></i>
                <p style="margin-top:12px;">কোনো ফলাফল পাওয়া যায়নি।</p>
            </div>
        </div>

        <!-- Table View (hidden by default) -->
        <div id="tableView" style="display:none;">
            <div class="table-responsive">
                <table class="price-table">
                    <thead>
                        <tr>
                            <th>ফসল</th>
                            <th>ক্যাটাগরি</th>
                            <?php if ($viewMode === 'farmer'): ?>
                                <th>বাজার দর</th>
                                <th>AgroFin গড়</th>
                                <th>পার্থক্য</th>
                            <?php else: ?>
                                <th>AgroFin মূল্য</th>
                                <th>বাজার মূল্য</th>
                                <th>সাশ্রয়</th>
                            <?php endif; ?>
                            <th>ট্রেন্ড</th>
                            <th></th>
                        </tr>
                    </thead>
                    <tbody>
                        <?php if (!empty($crops)): ?>
                        <?php foreach($crops as $c):
                            if ($viewMode === 'farmer') {
                                $icon = $c['trend']==='up'   ? '<i class="bi bi-arrow-up" style="color:#2e7d32"></i> বাড়ছে'
                                      : ($c['trend']==='down' ? '<i class="bi bi-arrow-down" style="color:#e53935"></i> কমছে'
                                      :                         '<i class="bi bi-dash" style="color:gray"></i> স্থিতিশীল');
                            } else {
                                $icon = $c['trend']==='up'   ? '<i class="bi bi-arrow-up" style="color:#e53935"></i> ঊর্ধ্বমুখী'
                                      : ($c['trend']==='down' ? '<i class="bi bi-arrow-down" style="color:#2e7d32"></i> নিম্নমুখী'
                                      :                         '<i class="bi bi-dash" style="color:gray"></i> স্থিতিশীল');
                            }
                        ?>
                        <tr>
                            <td>
                                <div style="display:flex; align-items:center; gap:10px;">
                                    <div style="width:36px; height:36px; background:<?= e($c['bg']) ?>; border-radius:8px; display:flex; align-items:center; justify-content:center; font-size:20px; overflow:hidden;">
                                        <?php if (!empty($c['image_url'])): ?>
                                            <img src="<?= e($c['image_url']) ?>" alt="<?= e($c['name']) ?>"
                                                 style="width:100%; height:100%; object-fit:cover;"
                                                 onerror="this.parentElement.innerHTML='<?= addslashes($c['emoji']) ?>';">
                                        <?php else: ?>
                                            <?= $c['emoji'] ?>
                                        <?php endif; ?>
                                    </div>
                                    <div>
                                        <strong><?= e($c['name']) ?></strong>
                                        <div style="font-size:11px; color:var(--gray-500);"><?= bn_num($c['farmer_count']) ?> কৃষক</div>
                                    </div>
                                </div>
                            </td>
                            <td><span style="background:#f0f7ee; color:var(--m1-primary); padding:3px 10px; border-radius:6px; font-size:12px;"><?= e($c['cat']) ?></span></td>

                            <?php if ($viewMode === 'farmer'): ?>
                                <!-- Farmer view: market price first, AgroFin avg second -->
                                <td>
                                    <?php if($c['has_market']): ?>
                                    <strong style="color:#e65100;">৳ <?= $c['market'] ?> / <?= e($c['unit']) ?></strong>
                                    <?php else: ?>
                                    <span style="color:var(--gray-400); font-style:italic; font-size:12px;">তথ্য নেই</span>
                                    <?php endif; ?>
                                </td>
                                <td><span style="color:var(--gray-600);">৳ <?= $c['agrofin'] ?> / <?= e($c['unit']) ?></span></td>
                                <td>
                                    <?php if($c['gap'] !== null && $c['gap_positive']): ?>
                                    <span style="background:#fff3e0; color:#e65100; padding:3px 10px; border-radius:6px; font-size:12px; font-weight:600;">৳ <?= $c['gap'] ?> বেশি</span>
                                    <?php elseif($c['gap'] !== null && !$c['gap_positive']): ?>
                                    <span style="background:#e8f5e9; color:#2e7d32; padding:3px 10px; border-radius:6px; font-size:12px; font-weight:600;">৳ <?= $c['gap'] ?> এগিয়ে</span>
                                    <?php else: ?>
                                    <span style="color:var(--gray-400); font-size:12px;">—</span>
                                    <?php endif; ?>
                                </td>
                            <?php else: ?>
                                <!-- Buyer view: AgroFin first, market second, savings -->
                                <td><strong style="color:var(--m1-primary);">৳ <?= $c['agrofin'] ?> / <?= e($c['unit']) ?></strong></td>
                                <td>
                                    <?php if($c['has_market']): ?>
                                    <del style="color:var(--gray-400);">৳ <?= $c['market'] ?> / <?= e($c['unit']) ?></del>
                                    <?php else: ?>
                                    <span style="color:var(--gray-400); font-style:italic; font-size:12px;">তথ্য নেই</span>
                                    <?php endif; ?>
                                </td>
                                <td>
                                    <?php if($c['gap'] !== null && $c['gap_positive']): ?>
                                    <span style="background:#e8f5e9; color:#2e7d32; padding:3px 10px; border-radius:6px; font-size:12px; font-weight:600;">৳ <?= $c['gap'] ?> কম</span>
                                    <?php else: ?>
                                    <span style="color:var(--gray-400); font-size:12px;">—</span>
                                    <?php endif; ?>
                                </td>
                            <?php endif; ?>

                            <td><?= $icon ?></td>
                            <td>
                                <?php if ($viewMode === 'farmer'): ?>
                                    <a href="/AgroFin/farmer/crops" class="btn btn-primary" style="padding:5px 12px; font-size:12px;">আমার ফসল</a>
                                <?php else: ?>
                                    <a href="/AgroFin/marketplace" class="btn btn-primary" style="padding:5px 12px; font-size:12px;">কিনুন</a>
                                <?php endif; ?>
                            </td>
                        </tr>
                        <?php endforeach; ?>
                        <?php else: ?>
                        <tr>
                            <td colspan="7" style="text-align:center; padding:32px; color:var(--gray-500);">
                                <?php if ($viewMode === 'farmer'): ?>
                                    এখনো কোনো ফসল তালিকাভুক্ত নেই। প্রথম কৃষক হোন!
                                <?php else: ?>
                                    এখনো কোনো পণ্য পাওয়া যায়নি। নিবন্ধিত কৃষকদের নতুন তালিকা শীঘ্রই আসবে।
                                <?php endif; ?>
                            </td>
                        </tr>
                        <?php endif; ?>
                    </tbody>
                </table>
            </div>
        </div>

        <!-- CTA -->
        <div style="text-align:center; margin-top: 48px; padding: 40px; background:#fff; border-radius:16px; box-shadow:0 4px 16px rgba(0,0,0,0.04);">
            <?php if ($viewMode === 'farmer'): ?>
                <h3 style="font-size:22px; font-weight:800; color:var(--gray-900); margin-bottom:8px;">আপনার ফসল AgroFin-এ বিক্রি করুন</h3>
                <p style="color:var(--gray-500); margin-bottom:20px;">মধ্যস্বত্বভোগী ছাড়া সরাসরি ক্রেতার কাছে বিক্রি করে অতিরিক্ত আয় করুন।</p>
                <a href="/AgroFin/farmer/crops/create" class="btn btn-primary" style="padding:12px 32px; font-size:16px;">নতুন ফসল যোগ করুন <i class="bi bi-arrow-right"></i></a>
            <?php else: ?>
                <h3 style="font-size:22px; font-weight:800; color:var(--gray-900); margin-bottom:8px;">সরাসরি কৃষকের কাছ থেকে কিনুন</h3>
                <p style="color:var(--gray-500); margin-bottom:20px;">মধ্যস্বত্বভোগী ছাড়া ন্যায্য মূল্যে সেরা কৃষিপণ্য পান।</p>
                <a href="/AgroFin/marketplace" class="btn btn-primary" style="padding:12px 32px; font-size:16px;">মার্কেটপ্লেসে যান <i class="bi bi-arrow-right"></i></a>
            <?php endif; ?>
        </div>

    </div>
</div>

<script>
function filterPrices() {
    const q        = document.getElementById('priceSearch').value.toLowerCase();
    const cat      = document.getElementById('catFilter').value;
    const trend    = document.getElementById('trendFilter').value;
    const cards    = document.querySelectorAll('.price-card-wrap');
    let visible    = 0;
    cards.forEach(c => {
        const nm = c.dataset.name.toLowerCase();
        const ct = c.dataset.cat;
        const tr = c.dataset.trend;
        const ok = (!q || nm.includes(q)) && (!cat || ct===cat) && (!trend || tr===trend);
        c.style.display = ok ? '' : 'none';
        if (ok) visible++;
    });
    document.getElementById('noResults').style.display = visible ? 'none' : 'block';
}

function setView(v) {
    document.getElementById('cardView').style.display  = v==='card'  ? '' : 'none';
    document.getElementById('tableView').style.display = v==='table' ? '' : 'none';
    document.getElementById('btnCard').classList.toggle('active',  v==='card');
    document.getElementById('btnTable').classList.toggle('active', v==='table');
}
</script>

<?php include __DIR__ . '/../../includes/footer.php'; ?>
