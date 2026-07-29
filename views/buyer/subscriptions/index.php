<?php require __DIR__ . '/../../../includes/header.php'; ?>
<?php require __DIR__ . '/../../../includes/navbar.php'; ?>

<?php
$freqLabels = ['daily'=>'দৈনিক','weekly'=>'সাপ্তাহিক','biweekly'=>'দ্বি-সাপ্তাহিক','monthly'=>'মাসিক'];
$statusMap  = ['active'=>['success','সক্রিয়'],'paused'=>['warning','স্থগিত'],'cancelled'=>['neutral','বাতিল']];
?>

<div class="dash-page">
<div class="dash-shell">
    <?php require __DIR__ . '/../../../includes/sidebar.php'; ?>

    <main class="dash-main">
        <div class="dash-header">
            <div>
                <div class="breadcrumb"><a href="<?= BASE_URL ?>/buyer/dashboard">ড্যাশবোর্ড</a> <i class="bi bi-chevron-right" style="font-size:10px"></i> সাবস্ক্রিপশন</div>
                <h1>সাবস্ক্রিপশন 🔁</h1>
            </div>
            <a href="<?= BASE_URL ?>/buyer/subscriptions/add" class="nav-pill-btn primary"><i class="bi bi-plus-lg"></i> নতুন সাবস্ক্রিপশন</a>
        </div>

        <?php if (empty($subs)): ?>
            <div class="dash-card">
                <div class="empty-state">
                    <i class="bi bi-arrow-repeat"></i>
                    <h4>কোনো সাবস্ক্রিপশন নেই</h4>
                    <p>নিয়মিত প্রয়োজনীয় ফসলের জন্য সাবস্ক্রিপশন তৈরি করুন - কৃষক জানবেন আপনি কখন চান।</p>
                    <a href="<?= BASE_URL ?>/buyer/subscriptions/add" class="nav-pill-btn primary"><i class="bi bi-plus-lg"></i> প্রথম সাবস্ক্রিপশন তৈরি করুন</a>
                </div>
            </div>
        <?php else: ?>
        <div style="display:grid; gap:14px;">
            <?php foreach ($subs as $s):
                $sm = $statusMap[$s['status']] ?? ['neutral', $s['status']];
            ?>
                <div class="dash-card" style="margin:0; display:grid; grid-template-columns: 1fr auto; gap:18px; align-items:center;">
                    <div>
                        <div style="display:flex; align-items:center; gap:8px; margin-bottom:6px;">
                            <strong style="font-size:16px;"><?= e($s['crop_name']) ?></strong>
                            <span class="badge badge-<?= $sm[0] ?>"><?= $sm[1] ?></span>
                            <span class="badge badge-info"><?= e($freqLabels[$s['frequency']] ?? $s['frequency']) ?></span>
                        </div>
                        <div style="font-size:13px; color:var(--gray-600);">
                            <i class="bi bi-person"></i> <?= e($s['farmer_name']) ?>
                            <?php if ($s['district_name']): ?>• <?= e($s['district_name']) ?><?php endif; ?>
                        </div>
                        <div style="font-size:13px; color:var(--gray-700); margin-top:6px;">
                            <span style="margin-right:14px;"><strong><?= bn_num($s['quantity_per_delivery']) ?> <?= e($s['unit']) ?></strong> প্রতি ডেলিভারি</span>
                            <span style="margin-right:14px;"><strong><?= bdt($s['price_locked'], 0) ?></strong> লক করা মূল্য</span>
                            <span><i class="bi bi-calendar-event"></i> পরবর্তী: <?= bn_date($s['next_delivery_date']) ?></span>
                        </div>
                        <div style="font-size:11px; color:var(--gray-400); margin-top:4px;">
                            শুরু: <?= bn_date($s['start_date']) ?>
                            <?php if ($s['end_date']): ?>• শেষ: <?= bn_date($s['end_date']) ?><?php endif; ?>
                        </div>
                    </div>
                    <div style="display:flex; flex-direction: column; gap:6px;">
                        <?php if ($s['status'] === 'active'): ?>
                            <form method="POST" action="<?= BASE_URL ?>/buyer/subscriptions/pause/<?= (int)$s['subscription_id'] ?>">
                                <?= Csrf::field() ?>
                                <button class="nav-pill-btn ghost" style="font-size:12px; white-space:nowrap;"><i class="bi bi-pause"></i> স্থগিত</button>
                            </form>
                        <?php elseif ($s['status'] === 'paused'): ?>
                            <form method="POST" action="<?= BASE_URL ?>/buyer/subscriptions/resume/<?= (int)$s['subscription_id'] ?>">
                                <?= Csrf::field() ?>
                                <button class="nav-pill-btn primary" style="font-size:12px; white-space:nowrap;"><i class="bi bi-play"></i> পুনরায় চালু</button>
                            </form>
                        <?php endif; ?>
                        <?php if ($s['status'] !== 'cancelled'): ?>
                            <form method="POST" action="<?= BASE_URL ?>/buyer/subscriptions/cancel/<?= (int)$s['subscription_id'] ?>" onsubmit="return confirm('আপনি কি নিশ্চিত? সাবস্ক্রিপশন বাতিল করা হবে।');">
                                <?= Csrf::field() ?>
                                <button class="nav-pill-btn ghost" style="font-size:12px; white-space:nowrap; color:var(--danger);"><i class="bi bi-x"></i> বাতিল</button>
                            </form>
                        <?php endif; ?>
                    </div>
                </div>
            <?php endforeach; ?>
        </div>
        <?php endif; ?>
    </main>
</div>
</div>

<?php require __DIR__ . '/../../../includes/footer.php'; ?>
