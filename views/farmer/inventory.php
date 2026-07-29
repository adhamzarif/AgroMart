<?php require __DIR__ . '/../../includes/header.php'; ?>
<?php require __DIR__ . '/../../includes/navbar.php'; ?>

<?php
$typeMap = [
    'listed'   => ['📥', 'লিস্ট', 'success'],
    'sold'     => ['📤', 'বিক্রি', 'info'],
    'adjusted' => ['🔧', 'সংশোধন', 'warning'],
    'expired'  => ['⏰', 'মেয়াদ শেষ', 'danger'],
    'restocked'=> ['🔄', 'পুনঃস্টক', 'success'],
];
?>

<div class="dash-page">
<div class="dash-shell">
    <?php require __DIR__ . '/../../includes/sidebar.php'; ?>

    <main class="dash-main">
        <div class="dash-header">
            <div>
                <div class="breadcrumb"><a href="<?= BASE_URL ?>/farmer/dashboard">ড্যাশবোর্ড</a> <i class="bi bi-chevron-right" style="font-size:10px"></i> ইনভেন্টরি</div>
                <h1>ইনভেন্টরি লগ 📋</h1>
            </div>
        </div>

        <div class="dash-card">
            <?php if (empty($logs)): ?>
                <div class="empty-state">
                    <i class="bi bi-clipboard"></i>
                    <h4>কোনো লগ নেই</h4>
                    <p>ফসল যোগ করলে এখানে স্বয়ংক্রিয়ভাবে রেকর্ড তৈরি হবে।</p>
                </div>
            <?php else: ?>
            <div style="overflow-x:auto;">
            <table class="table">
                <thead>
                    <tr>
                        <th>সময়</th>
                        <th>ফসল</th>
                        <th>ধরন</th>
                        <th>পূর্বে</th>
                        <th>পরে</th>
                        <th>পরিবর্তন</th>
                        <th>কারণ</th>
                    </tr>
                </thead>
                <tbody>
                <?php foreach ($logs as $l):
                    $t = $typeMap[$l['change_type']] ?? ['•', $l['change_type'], 'neutral'];
                    $diff = (float)$l['quantity_after'] - (float)$l['quantity_before'];
                ?>
                    <tr>
                        <td style="font-size:12px;"><?= bn_date($l['logged_at'], true) ?></td>
                        <td><?= e($l['crop_name']) ?></td>
                        <td><span class="badge badge-<?= $t[2] ?>"><?= $t[0] ?> <?= $t[1] ?></span></td>
                        <td><?= bn_num($l['quantity_before']) ?></td>
                        <td><?= bn_num($l['quantity_after']) ?></td>
                        <td style="font-weight:700; color: <?= $diff >= 0 ? 'var(--success)' : 'var(--danger)' ?>;"><?= $diff >= 0 ? '+' : '' ?><?= bn_num($diff) ?></td>
                        <td style="font-size:13px;"><?= e($l['change_reason']) ?></td>
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
