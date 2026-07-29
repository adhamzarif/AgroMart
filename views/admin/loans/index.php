<?php require __DIR__ . '/../../../includes/header.php'; ?>
<?php require __DIR__ . '/../../../includes/navbar.php'; ?>

<?php
$statusMap = [
    'pending'   => ['warning','পেন্ডিং'],
    'approved'  => ['info','অনুমোদিত'],
    'disbursed' => ['info','বিতরণ'],
    'active'    => ['success','সক্রিয়'],
    'completed' => ['neutral','সম্পন্ন'],
    'rejected'  => ['danger','বাতিল'],
    'defaulted' => ['danger','খেলাপি'],
];
?>

<div class="dash-page">
<div class="dash-shell">
    <?php require __DIR__ . '/../../../includes/sidebar.php'; ?>

    <main class="dash-main">
        <div class="dash-header">
            <div>
                <div class="breadcrumb"><a href="<?= BASE_URL ?>/admin/dashboard">ড্যাশবোর্ড</a> <i class="bi bi-chevron-right" style="font-size:10px"></i> লোন অনুমোদন</div>
                <h1>লোন ব্যবস্থাপনা 🏦</h1>
            </div>
        </div>

        <div class="dash-card" style="padding: 14px 20px;">
            <div style="display:flex; gap:8px; align-items:center; flex-wrap:wrap;">
                <span style="font-weight:600; font-size:13px;">স্ট্যাটাস:</span>
                <?php foreach (['pending'=>'পেন্ডিং','approved'=>'অনুমোদিত','active'=>'সক্রিয়','completed'=>'সম্পন্ন','rejected'=>'বাতিল','all'=>'সব'] as $k => $v): ?>
                    <a href="<?= BASE_URL ?>/admin/loans?status=<?= $k ?>" class="nav-pill-btn <?= $statusFilter === $k ? 'primary' : 'ghost' ?>" style="font-size:13px; <?= $k === 'pending' ? 'background:var(--m3-primary)' : '' ?>"><?= $v ?></a>
                <?php endforeach; ?>
            </div>
        </div>

        <div class="dash-card">
            <?php if (empty($loans)): ?>
                <div class="empty-state">
                    <i class="bi bi-bank"></i>
                    <h4>এই ফিল্টারে কোনো লোন নেই</h4>
                </div>
            <?php else: ?>
            <div style="overflow-x:auto;">
            <table class="table">
                <thead>
                    <tr><th>কৃষক</th><th>পরিমাণ</th><th>উদ্দেশ্য</th><th>মেয়াদ</th><th>মাসিক</th><th>স্ট্যাটাস</th><th>আবেদনের তারিখ</th><th></th></tr>
                </thead>
                <tbody>
                <?php foreach ($loans as $l):
                    $sm = $statusMap[$l['status']] ?? ['neutral', $l['status']];
                ?>
                    <tr>
                        <td>
                            <strong><?= e($l['farmer_name']) ?></strong><br>
                            <span style="font-size:11px; color:var(--gray-500);"><?= e($l['farmer_phone']) ?><?= $l['district_name'] ? ' • ' . e($l['district_name']) : '' ?></span>
                        </td>
                        <td class="mono" style="font-weight:700; color:var(--m3-primary);"><?= bdt($l['loan_amount'], 0) ?></td>
                        <td style="font-size:12px;"><?= e(mb_substr($l['loan_purpose'], 0, 40, 'UTF-8')) ?></td>
                        <td><?= bn_num($l['tenure_months']) ?> মাস</td>
                        <td class="mono"><?= bdt($l['monthly_installment'], 0) ?></td>
                        <td><span class="badge badge-<?= $sm[0] ?>"><?= $sm[1] ?></span></td>
                        <td style="font-size:12px;"><?= bn_date($l['application_date']) ?></td>
                        <td><a href="<?= BASE_URL ?>/admin/loans/detail/<?= (int)$l['loan_id'] ?>" class="nav-pill-btn <?= $l['status'] === 'pending' ? 'primary' : 'ghost' ?>" style="font-size:12px; padding:5px 10px; <?= $l['status'] === 'pending' ? 'background:var(--m3-primary)' : '' ?>">পর্যালোচনা →</a></td>
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

<?php require __DIR__ . '/../../../includes/footer.php'; ?>
