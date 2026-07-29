<?php require __DIR__ . '/../../includes/header.php'; ?>
<?php require __DIR__ . '/../../includes/navbar.php'; ?>

<?php
$catLabels = [
    'seeds'=>['🌱','বীজ'],'fertilizer'=>['🌿','সার'],'pesticide'=>['🧴','কীটনাশক'],
    'labor'=>['👷','শ্রমিক'],'irrigation'=>['💧','সেচ'],'equipment'=>['🛠','সরঞ্জাম'],
    'transport'=>['🚚','পরিবহন'],'other'=>['📌','অন্যান্য'],
];
$max = !empty($byCategory) ? max(array_map(fn($r) => (float)$r['total'], $byCategory)) : 0;
$isProfit = $pl['profit'] >= 0;
?>

<div class="dash-page">
<div class="dash-shell">
    <?php require __DIR__ . '/../../includes/sidebar.php'; ?>

    <main class="dash-main">
        <div class="dash-header">
            <div>
                <div class="breadcrumb"><a href="<?= BASE_URL ?>/farmer/dashboard">ড্যাশবোর্ড</a> <i class="bi bi-chevron-right" style="font-size:10px"></i> লাভ-ক্ষতি</div>
                <h1>লাভ-ক্ষতি রিপোর্ট 📈</h1>
            </div>
        </div>

        <div class="dash-card" style="padding: 14px 20px;">
            <form method="GET" style="display:flex; gap:12px; align-items:end; flex-wrap:wrap;">
                <div>
                    <label style="display:block; font-size:12px; font-weight:600; margin-bottom:4px;">শুরুর তারিখ</label>
                    <input type="date" name="from" value="<?= e($from) ?>" style="padding:9px 12px; border:1.5px solid var(--gray-200); border-radius:8px;">
                </div>
                <div>
                    <label style="display:block; font-size:12px; font-weight:600; margin-bottom:4px;">শেষ তারিখ</label>
                    <input type="date" name="to" value="<?= e($to) ?>" style="padding:9px 12px; border:1.5px solid var(--gray-200); border-radius:8px;">
                </div>
                <button type="submit" class="nav-pill-btn primary"><i class="bi bi-funnel"></i> রিপোর্ট তৈরি করুন</button>
            </form>
        </div>

        <div class="stat-grid">
            <div class="stat-tile tile-green">
                <div class="st-label">মোট রাজস্ব</div>
                <div class="st-value"><?= bdt($pl['revenue'], 0) ?></div>
                <div class="st-foot"><?= bn_num($pl['orders_completed']) ?> টি সম্পন্ন অর্ডার</div>
                <div class="st-icon"><i class="bi bi-cash-coin"></i></div>
            </div>
            <div class="stat-tile tile-red">
                <div class="st-label">মোট খরচ</div>
                <div class="st-value"><?= bdt($pl['expenses'], 0) ?></div>
                <div class="st-foot">সব ক্যাটাগরি মিলিয়ে</div>
                <div class="st-icon"><i class="bi bi-cash-stack"></i></div>
            </div>
            <div class="stat-tile <?= $isProfit ? 'tile-green' : 'tile-red' ?>">
                <div class="st-label">নিট <?= $isProfit ? 'লাভ' : 'ক্ষতি' ?></div>
                <div class="st-value" style="color: <?= $isProfit ? 'var(--success-dark)' : 'var(--danger)' ?> !important;"><?= bdt(abs($pl['profit']), 0) ?></div>
                <div class="st-foot">মার্জিন: <?= bn_num(number_format($pl['margin'], 1)) ?>%</div>
                <div class="st-icon"><i class="bi bi-<?= $isProfit ? 'trophy' : 'exclamation-triangle' ?>"></i></div>
            </div>
            <div class="stat-tile tile-purple">
                <div class="st-label">সময়কাল</div>
                <div class="st-value" style="font-size:14px;"><?= bn_date($from) ?></div>
                <div class="st-foot">থেকে <?= bn_date($to) ?></div>
                <div class="st-icon"><i class="bi bi-calendar-range"></i></div>
            </div>
        </div>

        <div class="dash-card">
            <h3 style="margin:0 0 16px;"><i class="bi bi-pie-chart" style="color:var(--m4-primary)"></i> ক্যাটাগরি অনুযায়ী খরচ বিভাজন</h3>
            <?php if (empty($byCategory)): ?>
                <p style="color:var(--gray-500); text-align:center; padding:20px;">এই সময়ের মধ্যে কোনো খরচ নেই।</p>
            <?php else: ?>
                <?php foreach ($byCategory as $c):
                    $cl = $catLabels[$c['expense_category']] ?? ['📌', $c['expense_category']];
                    $width = $max > 0 ? ($c['total'] / $max) * 100 : 0;
                    $pct = $pl['expenses'] > 0 ? ($c['total'] / $pl['expenses']) * 100 : 0;
                ?>
                    <div style="margin-bottom: 14px;">
                        <div style="display:flex; justify-content:space-between; margin-bottom:4px; font-size:13px;">
                            <span><?= $cl[0] ?> <strong><?= $cl[1] ?></strong> <span style="color:var(--gray-500);">(<?= bn_num($c['cnt']) ?> এন্ট্রি)</span></span>
                            <span style="font-weight:700; font-family:var(--font-bn);"><?= bdt($c['total'], 0) ?> <span style="color:var(--gray-500); font-weight:400;">(<?= bn_num(number_format($pct, 1)) ?>%)</span></span>
                        </div>
                        <div style="height:14px; background:var(--gray-100); border-radius:7px; overflow:hidden;">
                            <div style="height:100%; background: linear-gradient(90deg, var(--m1-primary), var(--m1-light)); width: <?= $width ?>%; transition: width 0.5s;"></div>
                        </div>
                    </div>
                <?php endforeach; ?>
            <?php endif; ?>
        </div>
    </main>
</div>
</div>

<?php require __DIR__ . '/../../includes/footer.php'; ?>
