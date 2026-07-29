<?php require __DIR__ . '/../../../includes/header.php'; ?>
<?php require __DIR__ . '/../../../includes/navbar.php'; ?>

<?php
$typeIcons = ['flood'=>'🌊','cyclone'=>'🌀','drought'=>'☀','heavy_rain'=>'🌧','heatwave'=>'🔥','cold_wave'=>'❄','storm'=>'⛈'];
$typeLabels = ['flood'=>'বন্যা','cyclone'=>'ঘূর্ণিঝড়','drought'=>'খরা','heavy_rain'=>'ভারী বর্ষণ','heatwave'=>'তাপদাহ','cold_wave'=>'শৈত্যপ্রবাহ','storm'=>'ঝড়'];
$severityMap = ['low'=>['neutral','নিম্ন'],'medium'=>['info','মাঝারি'],'high'=>['warning','উচ্চ'],'severe'=>['danger','গুরুতর']];
?>

<div class="dash-page">
<div class="dash-shell">
    <?php require __DIR__ . '/../../../includes/sidebar.php'; ?>

    <main class="dash-main">
        <div class="dash-header">
            <div>
                <div class="breadcrumb"><a href="<?= BASE_URL ?>/admin/dashboard">ড্যাশবোর্ড</a> <i class="bi bi-chevron-right" style="font-size:10px"></i> আবহাওয়া</div>
                <h1>আবহাওয়া সতর্কতা ⛈</h1>
            </div>
            <a href="<?= BASE_URL ?>/admin/weather/add" class="nav-pill-btn primary" style="background:var(--m4-primary)"><i class="bi bi-plus-lg"></i> নতুন সতর্কতা প্রকাশ করুন</a>
        </div>

        <?php if (empty($alerts)): ?>
            <div class="dash-card">
                <div class="empty-state">
                    <i class="bi bi-cloud-sun"></i>
                    <h4>কোনো সতর্কতা প্রকাশ করা হয়নি</h4>
                    <p>আবহাওয়া বিভাগের পূর্বাভাস অনুযায়ী সতর্কতা প্রকাশ করুন।</p>
                    <a href="<?= BASE_URL ?>/admin/weather/add" class="nav-pill-btn primary"><i class="bi bi-plus-lg"></i> প্রথম সতর্কতা প্রকাশ করুন</a>
                </div>
            </div>
        <?php else: ?>
        <div style="display:grid; gap:14px;">
            <?php foreach ($alerts as $a):
                $svm = $severityMap[$a['severity']] ?? ['neutral', $a['severity']];
                $districts = is_array($a['affected_districts']) ? $a['affected_districts'] : (json_decode($a['affected_districts'], true) ?: []);
                $crops = is_array($a['affected_crops']) ? $a['affected_crops'] : (json_decode($a['affected_crops'], true) ?: []);
            ?>
                <div class="dash-card" style="margin:0; border-left: 4px solid <?= $svm[0] === 'danger' ? 'var(--danger)' : ($svm[0] === 'warning' ? 'var(--warning)' : 'var(--info)') ?>; <?= !$a['is_active'] ? 'opacity:0.6;' : '' ?>">
                    <div style="display:flex; justify-content:space-between; align-items:start; gap: 18px;">
                        <div style="flex:1;">
                            <div style="display:flex; align-items:center; gap:10px; margin-bottom:8px; flex-wrap:wrap;">
                                <span style="font-size:24px;"><?= $typeIcons[$a['alert_type']] ?? '⚠' ?></span>
                                <strong style="font-size:16px;"><?= e($a['alert_title']) ?></strong>
                                <span class="badge badge-<?= $svm[0] ?>"><?= $svm[1] ?></span>
                                <span class="badge badge-info"><?= e($typeLabels[$a['alert_type']] ?? $a['alert_type']) ?></span>
                                <?php if (!$a['is_active']): ?><span class="badge badge-neutral">নিষ্ক্রিয়</span><?php endif; ?>
                            </div>
                            <p style="margin: 4px 0; font-size:14px; color:var(--gray-700);"><?= e($a['alert_message']) ?></p>
                            <?php if ($a['recommendations']): ?>
                                <div style="margin-top:8px; padding: 10px; background:var(--gray-50); border-radius:8px; font-size:13px;"><strong>সুপারিশ:</strong> <?= nl2br(e($a['recommendations'])) ?></div>
                            <?php endif; ?>
                            <div style="margin-top:10px; font-size:11px; color:var(--gray-500);">
                                📍 <?= bn_num(count($districts)) ?> টি জেলা প্রভাবিত
                                <?php if (!empty($crops)): ?>• 🌾 ফসল: <?= e(implode(', ', $crops)) ?><?php endif; ?>
                                • শুরু: <?= bn_date($a['start_time'], true) ?>
                                <?php if ($a['end_time']): ?>• শেষ: <?= bn_date($a['end_time'], true) ?><?php endif; ?>
                                • সূত্র: <?= e($a['issued_by']) ?>
                                <?php if ($a['created_by_name']): ?>• ✍ <?= e($a['created_by_name']) ?><?php endif; ?>
                            </div>
                        </div>
                        <div style="display:flex; flex-direction:column; gap:6px;">
                            <form method="POST" action="<?= BASE_URL ?>/admin/weather/toggle/<?= (int)$a['alert_id'] ?>">
                                <?= Csrf::field() ?>
                                <button class="nav-pill-btn <?= $a['is_active'] ? 'ghost' : 'primary' ?>" style="font-size:11px; padding:6px 12px; white-space:nowrap;"><?= $a['is_active'] ? 'নিষ্ক্রিয় করুন' : 'সক্রিয় করুন' ?></button>
                            </form>
                            <form method="POST" action="<?= BASE_URL ?>/admin/weather/delete/<?= (int)$a['alert_id'] ?>" onsubmit="return confirm('মুছে ফেলবেন?');">
                                <?= Csrf::field() ?>
                                <button class="nav-pill-btn ghost" style="font-size:11px; padding:6px 12px; color:var(--danger); white-space:nowrap;"><i class="bi bi-trash"></i> মুছুন</button>
                            </form>
                        </div>
                    </div>
                </div>
            <?php endforeach; ?>
        </div>
        <?php endif; ?>
    </main>
</div>
</div>

<?php require __DIR__ . '/../../../includes/footer.php'; ?>
