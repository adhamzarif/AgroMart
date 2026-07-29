<?php require __DIR__ . '/../../../includes/header.php'; ?>
<?php require __DIR__ . '/../../../includes/navbar.php'; ?>

<?php
$statusMap = [
    'pending'    => ['warning', 'পেন্ডিং'],
    'approved'   => ['info', 'অনুমোদিত'],
    'rejected'   => ['danger', 'বাতিল'],
    'disbursed'  => ['info', 'বিতরণ'],
    'active'     => ['success', 'সক্রিয়'],
    'completed'  => ['neutral', 'সম্পন্ন'],
    'defaulted'  => ['danger', 'খেলাপি'],
];
?>

<div class="dash-page">
<div class="dash-shell">
    <?php require __DIR__ . '/../../../includes/sidebar.php'; ?>

    <main class="dash-main">
        <div class="dash-header">
            <div>
                <div class="breadcrumb"><a href="<?= BASE_URL ?>/farmer/dashboard">ড্যাশবোর্ড</a> <i class="bi bi-chevron-right" style="font-size:10px"></i> লোন</div>
                <h1>মাইক্রো-লোন 💰</h1>
            </div>
            <a href="<?= BASE_URL ?>/farmer/loans/apply" class="nav-pill-btn primary" style="background:var(--m3-primary)"><i class="bi bi-plus-lg"></i> নতুন লোনের জন্য আবেদন</a>
        </div>

        <!-- Credit Score Summary -->
        <div class="dash-card" style="background: linear-gradient(135deg, #fff7e0, #fff); border-left: 4px solid var(--m3-primary);">
            <div style="display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap: 16px;">
                <div>
                    <div style="font-size:13px; color:var(--gray-600); margin-bottom:4px;">আপনার ক্রেডিট স্কোর</div>
                    <div style="font-size:42px; font-weight:800; color:var(--m3-primary); font-family: var(--font-bn);"><?= bn_num($creditScore['score']) ?></div>
                    <div style="font-size:14px; color:var(--gray-700);">গ্রেড: <strong><?= e($creditScore['grade']) ?></strong></div>
                </div>
                <div style="text-align:right;">
                    <div style="font-size:13px; color:var(--gray-600); margin-bottom:4px;">সর্বোচ্চ লোন উপলব্ধ</div>
                    <div style="font-size:28px; font-weight:700; color:var(--m1-primary);"><?= bdt($creditScore['max_loan'], 0) ?></div>
                    <a href="<?= BASE_URL ?>/farmer/credit-score" style="font-size:13px; color:var(--m2-primary); text-decoration:none;">কীভাবে স্কোর বাড়ানো যায়? →</a>
                </div>
            </div>
        </div>

        <div class="dash-card">
            <div class="dash-card-header">
                <h3><i class="bi bi-bank"></i> আমার লোন</h3>
            </div>
            <?php if (empty($loans)): ?>
                <div class="empty-state">
                    <i class="bi bi-cash-stack"></i>
                    <h4>এখনো কোনো লোন আবেদন করেননি</h4>
                    <p>আপনি ৳<?= bn_num(number_format($creditScore['max_loan'])) ?> পর্যন্ত লোনের জন্য যোগ্য।</p>
                    <a href="<?= BASE_URL ?>/farmer/loans/apply" class="nav-pill-btn primary" style="background:var(--m3-primary)"><i class="bi bi-cash"></i> এখনই আবেদন করুন</a>
                </div>
            <?php else: ?>
            <div style="overflow-x:auto;">
            <table class="table">
                <thead>
                    <tr>
                        <th>আবেদন তারিখ</th>
                        <th>পরিমাণ</th>
                        <th>মেয়াদ</th>
                        <th>মাসিক কিস্তি</th>
                        <th>বকেয়া</th>
                        <th>স্ট্যাটাস</th>
                        <th>কাজ</th>
                    </tr>
                </thead>
                <tbody>
                <?php foreach ($loans as $l):
                    $sm = $statusMap[$l['status']] ?? ['neutral', $l['status']];
                ?>
                    <tr>
                        <td style="font-size:12px;"><?= bn_date($l['application_date']) ?></td>
                        <td class="mono"><?= bdt($l['loan_amount'], 0) ?></td>
                        <td><?= bn_num($l['tenure_months']) ?> মাস</td>
                        <td class="mono"><?= bdt($l['monthly_installment'], 0) ?></td>
                        <td class="mono"><?= bdt($l['remaining_balance'], 0) ?></td>
                        <td><span class="badge badge-<?= $sm[0] ?>"><?= $sm[1] ?></span></td>
                        <td><a href="<?= BASE_URL ?>/farmer/loans/detail/<?= (int)$l['loan_id'] ?>" class="nav-pill-btn ghost" style="font-size:12px; padding:5px 10px;">বিস্তারিত →</a></td>
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
