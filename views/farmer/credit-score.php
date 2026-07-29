<?php require __DIR__ . '/../../includes/header.php'; ?>
<?php require __DIR__ . '/../../includes/navbar.php'; ?>

<?php
$gradeColors = ['A+'=>'#2e7d32','A'=>'#43a047','B'=>'#fb8c00','C'=>'#e53935','D'=>'#b71c1c'];
$gColor = $gradeColors[$cs['grade']] ?? '#666';
?>

<div class="dash-page">
<div class="dash-shell">
    <?php require __DIR__ . '/../../includes/sidebar.php'; ?>

    <main class="dash-main">
        <div class="dash-header">
            <div>
                <div class="breadcrumb"><a href="<?= BASE_URL ?>/farmer/dashboard">ড্যাশবোর্ড</a> <i class="bi bi-chevron-right" style="font-size:10px"></i> ক্রেডিট স্কোর</div>
                <h1>আপনার ক্রেডিট স্কোর 📊</h1>
            </div>
        </div>

        <div style="display:grid; grid-template-columns: 1fr 2fr; gap: 20px;">
            <div class="dash-card" style="text-align:center; background: linear-gradient(135deg, #fff7e0, #fff);">
                <div style="font-size:13px; color:var(--gray-600); margin-bottom:6px;">আপনার স্কোর</div>
                <div style="font-size:72px; font-weight:800; color:<?= $gColor ?>; line-height:1; font-family: var(--font-bn);"><?= bn_num($cs['score']) ?></div>
                <div style="font-size:13px; color:var(--gray-500); margin-top:4px;">/ ১০০</div>
                <div style="margin-top:14px;">
                    <span style="display:inline-block; padding:8px 24px; border-radius:99px; background: <?= $gColor ?>; color:#fff; font-weight:700; font-size:18px;">গ্রেড <?= e($cs['grade']) ?></span>
                </div>
                <div style="margin-top:18px; padding:14px; background: rgba(245,124,0,0.08); border-radius:10px;">
                    <div style="font-size:12px; color:var(--gray-600);">সর্বোচ্চ লোন উপলব্ধ</div>
                    <div style="font-size:24px; font-weight:800; color:var(--m1-primary);"><?= bdt($cs['max_loan'], 0) ?></div>
                </div>
                <?php if ($cs['is_eligible']): ?>
                    <a href="<?= BASE_URL ?>/farmer/loans/apply" class="nav-pill-btn primary" style="background:var(--m3-primary); margin-top:14px; justify-content:center; width:100%;"><i class="bi bi-cash"></i> লোনের জন্য আবেদন</a>
                <?php endif; ?>
            </div>

            <div class="dash-card">
                <h3 style="margin:0 0 14px;"><i class="bi bi-bar-chart"></i> স্কোরের কারণসমূহ</h3>
                <table class="table">
                    <thead><tr><th>উপাদান</th><th>মান</th><th>স্কোরে প্রভাব</th></tr></thead>
                    <tbody>
                    <?php foreach ($cs['factors'] as $f):
                        $impact = $f['impact'];
                        $negative = strpos($impact, '-') !== false;
                        $zero = $impact === '0';
                    ?>
                        <tr>
                            <td><?= e($f['name']) ?></td>
                            <td style="font-weight:600;"><?= e($f['value']) ?></td>
                            <td style="font-weight:700; color: <?= $negative ? 'var(--danger)' : ($zero ? 'var(--gray-500)' : 'var(--success-dark)') ?>;"><?= e($impact) ?></td>
                        </tr>
                    <?php endforeach; ?>
                    </tbody>
                </table>
            </div>
        </div>

        <div class="dash-card" style="border-left: 4px solid var(--m2-primary);">
            <h3 style="margin:0 0 14px;"><i class="bi bi-lightbulb"></i> স্কোর বাড়ানোর উপায়</h3>
            <ul style="margin:0; padding-left:20px; line-height:1.9; font-size:14px;">
                <li>সময়মতো লোনের কিস্তি পরিশোধ করুন (+৩ স্কোর প্রতি কিস্তি)</li>
                <li>অর্ডার সফলভাবে ডেলিভারি দিন (প্রতি ২ অর্ডারে +১ স্কোর)</li>
                <li>উচ্চ গুণমান বজায় রাখুন - ৪.৫+ রেটিং পেলে +১০ পর্যন্ত যোগ হয়</li>
                <li>ফোন, ইমেল ও NID যাচাই করান (প্রতিটিতে +৩ স্কোর)</li>
                <li>অ্যাকাউন্ট নিয়মিতভাবে ব্যবহার করুন</li>
                <li>লোন খেলাপি এড়িয়ে চলুন (প্রতি খেলাপিতে -২৫ স্কোর)</li>
            </ul>
        </div>
    </main>
</div>
</div>

<?php require __DIR__ . '/../../includes/footer.php'; ?>
