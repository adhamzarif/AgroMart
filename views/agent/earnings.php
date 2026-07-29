<?php require __DIR__ . '/../../includes/header.php'; ?>
<?php require __DIR__ . '/../../includes/navbar.php'; ?>

<?php
$typeMap = [
    'farmer_registration' => ['👨‍🌾', 'কৃষক নিবন্ধন', 'success'],
    'crop_listing'        => ['🌾', 'ফসল লিস্ট', 'info'],
    'order_help'          => ['🛒', 'অর্ডার সহায়তা', 'farmer'],
    'loan_assistance'     => ['💰', 'লোন সহায়তা', 'warning'],
    'message_help'        => ['💬', 'মেসেজ/সহায়তা', 'agent'],
    'training_session'    => ['📚', 'প্রশিক্ষণ', 'admin'],
    'field_visit'         => ['🚶', 'মাঠ পরিদর্শন', 'farmer'],
    'other'               => ['📌', 'অন্যান্য', 'neutral'],
];
?>

<div class="dash-page">
<div class="dash-shell">
    <?php require __DIR__ . '/../../includes/sidebar.php'; ?>

    <main class="dash-main">
        <div class="dash-header">
            <div>
                <div class="breadcrumb"><a href="<?= BASE_URL ?>/agent/dashboard">ড্যাশবোর্ড</a> <i class="bi bi-chevron-right" style="font-size:10px"></i> কমিশন</div>
                <h1>কমিশন ও আয় 💰</h1>
            </div>
        </div>

        <div class="stat-grid">
            <div class="stat-tile tile-green">
                <div class="st-label">মোট আয়</div>
                <div class="st-value"><?= bdt($summary['total'] ?? 0, 0) ?></div>
                <div class="st-foot">সর্বমোট পর্যন্ত</div>
                <div class="st-icon"><i class="bi bi-cash-stack"></i></div>
            </div>
            <div class="stat-tile tile-blue">
                <div class="st-label">এই মাসে</div>
                <div class="st-value"><?= bdt($summary['this_month'] ?? 0, 0) ?></div>
                <div class="st-foot"><?= bn_date(date('Y-m-01')) ?> থেকে</div>
                <div class="st-icon"><i class="bi bi-calendar-month"></i></div>
            </div>
            <div class="stat-tile tile-orange">
                <div class="st-label">আজকের আয়</div>
                <div class="st-value"><?= bdt($summary['today'] ?? 0, 0) ?></div>
                <div class="st-foot">এখন পর্যন্ত</div>
                <div class="st-icon"><i class="bi bi-sun"></i></div>
            </div>
            <div class="stat-tile tile-purple">
                <div class="st-label">কমিশন রেট</div>
                <div class="st-value"><?= bn_num($summary['commission_rate'] ?? 0) ?>%</div>
                <div class="st-foot"><?= bn_num($summary['activity_count'] ?? 0) ?> টি কার্যক্রম</div>
                <div class="st-icon"><i class="bi bi-percent"></i></div>
            </div>
        </div>

        <div class="dash-card" style="padding: 14px 20px;">
            <div style="display:flex; gap:8px; align-items:center; flex-wrap:wrap;">
                <span style="font-weight:600; font-size:13px;">ফিল্টার:</span>
                <a href="<?= BASE_URL ?>/agent/earnings" class="nav-pill-btn <?= !$filter ? 'primary' : 'ghost' ?>" style="font-size:13px;">সব কার্যক্রম</a>
                <?php foreach ($typeMap as $k => $v): ?>
                    <a href="<?= BASE_URL ?>/agent/earnings?type=<?= $k ?>" class="nav-pill-btn <?= $filter === $k ? 'primary' : 'ghost' ?>" style="font-size:12px;"><?= $v[0] ?> <?= $v[1] ?></a>
                <?php endforeach; ?>
            </div>
        </div>

        <div class="dash-card">
            <h3 style="margin:0 0 14px;"><i class="bi bi-list-check"></i> কার্যক্রম ইতিহাস</h3>
            <?php if (empty($activities)): ?>
                <div class="empty-state">
                    <i class="bi bi-receipt"></i>
                    <h4>কোনো কার্যক্রম রেকর্ড নেই</h4>
                    <p>কৃষক নিবন্ধন, ফসল লিস্ট ইত্যাদি করলে এখানে দেখাবে।</p>
                </div>
            <?php else: ?>
            <div style="overflow-x:auto;">
            <table class="table">
                <thead>
                    <tr><th>তারিখ</th><th>কার্যক্রম</th><th>কৃষক</th><th>বিবরণ</th><th>কমিশন</th></tr>
                </thead>
                <tbody>
                <?php foreach ($activities as $a):
                    $t = $typeMap[$a['activity_type']] ?? ['📌', $a['activity_type'], 'neutral'];
                ?>
                    <tr>
                        <td style="font-size:12px;"><?= bn_date($a['activity_date'], true) ?></td>
                        <td><span class="badge badge-<?= $t[2] ?>"><?= $t[0] ?> <?= $t[1] ?></span></td>
                        <td><?= e($a['farmer_name'] ?? '—') ?></td>
                        <td style="font-size:13px;"><?= e($a['description']) ?></td>
                        <td class="mono" style="font-weight:700; color:var(--success-dark);"><?= $a['commission_earned'] > 0 ? '+' . bdt($a['commission_earned'], 0) : '—' ?></td>
                    </tr>
                <?php endforeach; ?>
                </tbody>
            </table>
            </div>
            <?php endif; ?>
        </div>
    </main>
</div>
</div>

<?php require __DIR__ . '/../../includes/footer.php'; ?>
