<?php require __DIR__ . '/../../includes/header.php'; ?>
<?php require __DIR__ . '/../../includes/navbar.php'; ?>

<div class="dash-page">
<div class="dash-shell">
    <?php require __DIR__ . '/../../includes/sidebar.php'; ?>

    <main class="dash-main">
        <div class="dash-header">
            <div>
                <div class="breadcrumb"><a href="<?= BASE_URL ?>/admin/dashboard">ড্যাশবোর্ড</a> <i class="bi bi-chevron-right" style="font-size:10px"></i> <?= e($featureName) ?></div>
                <h1><?= e($featureName) ?></h1>
            </div>
        </div>

        <div class="dash-card" style="text-align:center; padding: 60px 30px; background: linear-gradient(135deg, #f3e5f5, #fff);">
            <div style="font-size: 64px; margin-bottom: 20px;">🚧</div>
            <h2 style="margin: 0 0 14px; color: var(--m4-primary);"><?= e($featureName) ?></h2>
            <p style="color: var(--gray-600); font-size: 15px; margin-bottom: 6px;"><?= e($description) ?></p>
            <p style="color: var(--gray-500); font-size: 13px; margin-bottom: 30px;">এই ফিচারটি Chunk 4-এ অন্তর্ভুক্ত হবে।</p>
            <div style="display:flex; gap:10px; justify-content:center; flex-wrap:wrap;">
                <a href="<?= BASE_URL ?>/admin/dashboard" class="nav-pill-btn primary" style="background:var(--m4-primary)"><i class="bi bi-arrow-left"></i> ড্যাশবোর্ডে ফিরুন</a>
                <a href="<?= BASE_URL ?>/admin/users" class="nav-pill-btn ghost">ব্যবহারকারী ব্যবস্থাপনা</a>
                <a href="<?= BASE_URL ?>/admin/loans" class="nav-pill-btn ghost">লোন অনুমোদন</a>
                <a href="<?= BASE_URL ?>/admin/reports" class="nav-pill-btn ghost">রিপোর্ট দেখুন</a>
            </div>
        </div>

        <div class="dash-card" style="border-left: 4px solid var(--info);">
            <h3 style="margin:0 0 14px;"><i class="bi bi-info-circle"></i> Chunk 4 প্রিভিউ</h3>
            <p style="font-size:13px; color:var(--gray-600);">আসছে চূড়ান্ত চাঙ্কে যা থাকছে:</p>
            <ul style="margin: 8px 0 0 0; padding-left: 20px; line-height: 1.9; font-size: 13px;">
                <li>🤖 স্মার্ট বাংলা সহকারী (AI চ্যাট)</li>
                <li>🌾 ফসল মডারেশন ও ক্যাটাগরি ব্যবস্থাপনা</li>
                <li>🚚 পরিবহন পার্টনার ও ডেলিভারি ব্যবস্থাপনা</li>
                <li>📢 ঘোষণা ব্রডকাস্ট সিস্টেম</li>
                <li>📊 উন্নত অ্যানালিটিক্স চার্ট</li>
                <li>👥 কৃষক গ্রুপ ব্যবস্থাপনা</li>
                <li>🎯 AI ফসল সুপারিশ (পরিপূর্ণ)</li>
            </ul>
        </div>
    </main>
</div>
</div>

<?php require __DIR__ . '/../../includes/footer.php'; ?>
