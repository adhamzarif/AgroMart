<?php require __DIR__ . '/../../includes/header.php'; ?>
<?php require __DIR__ . '/../../includes/navbar.php'; ?>

<?php
$typeIcons = ['flood'=>'🌊','cyclone'=>'🌀','drought'=>'☀','heavy_rain'=>'🌧','heatwave'=>'🔥','cold_wave'=>'❄','storm'=>'⛈'];
$typeLabels = ['flood'=>'বন্যা','cyclone'=>'ঘূর্ণিঝড়','drought'=>'খরা','heavy_rain'=>'ভারী বর্ষণ','heatwave'=>'তাপদাহ','cold_wave'=>'শৈত্যপ্রবাহ','storm'=>'ঝড়'];
$severityMap = ['low'=>['neutral','নিম্ন', '#9e9e9e'],'medium'=>['info','মাঝারি', '#0288d1'],'high'=>['warning','উচ্চ', '#f57c00'],'severe'=>['danger','গুরুতর', '#c62828']];
?>

<div class="dash-page">
<div class="dash-shell">
    <?php require __DIR__ . '/../../includes/sidebar.php'; ?>

    <main class="dash-main">
        <div class="dash-header">
            <div>
                <div class="breadcrumb"><a href="<?= BASE_URL ?>/farmer/dashboard">ড্যাশবোর্ড</a> <i class="bi bi-chevron-right" style="font-size:10px"></i> আবহাওয়া</div>
                <h1>আবহাওয়া সতর্কতা ⛈</h1>
            </div>
        </div>

        <?php if (empty($alerts)): ?>
            <div class="dash-card" style="background: linear-gradient(135deg, #e8f5e9, #fff); border-left: 4px solid var(--success);">
                <div style="text-align:center; padding: 40px 20px;">
                    <div style="font-size:64px;">☀</div>
                    <h2 style="margin: 14px 0 6px; color: var(--success-dark);">আবহাওয়া স্বাভাবিক</h2>
                    <p style="color:var(--gray-600);">আপনার এলাকায় বর্তমানে কোনো সক্রিয় আবহাওয়া সতর্কতা নেই। নিয়মিত খেতের কাজ চালিয়ে যেতে পারেন।</p>
                </div>
            </div>
        <?php else: ?>
        <div style="display:grid; gap: 16px;">
            <?php foreach ($alerts as $a):
                $svm = $severityMap[$a['severity']] ?? ['neutral', $a['severity'], '#666'];
                $color = $svm[2];
            ?>
                <div class="dash-card" style="margin: 0; border-left: 6px solid <?= $color ?>; background: linear-gradient(135deg, <?= $color ?>11, #fff);">
                    <div style="display:flex; gap: 18px; align-items:start;">
                        <div style="font-size:48px; line-height:1;"><?= $typeIcons[$a['alert_type']] ?? '⚠' ?></div>
                        <div style="flex:1;">
                            <div style="display:flex; align-items:center; gap:8px; flex-wrap:wrap; margin-bottom:8px;">
                                <h2 style="margin:0; font-size:18px;"><?= e($a['alert_title']) ?></h2>
                                <span class="badge badge-<?= $svm[0] ?>" style="font-size:11px;"><?= $svm[1] ?> তীব্রতা</span>
                                <span class="badge badge-info" style="font-size:11px;"><?= e($typeLabels[$a['alert_type']] ?? $a['alert_type']) ?></span>
                            </div>
                            <p style="margin: 8px 0; font-size:15px; line-height:1.7; color:var(--gray-700);"><?= nl2br(e($a['alert_message'])) ?></p>
                            <?php if ($a['recommendations']): ?>
                                <div style="margin-top: 14px; padding: 14px 16px; background: #fff; border-radius: 10px; border-left: 4px solid <?= $color ?>;">
                                    <strong style="display:block; margin-bottom:6px; color:<?= $color ?>;">📋 কৃষকদের জন্য পরামর্শ:</strong>
                                    <div style="white-space: pre-line; line-height:1.7; font-size:14px;"><?= e($a['recommendations']) ?></div>
                                </div>
                            <?php endif; ?>
                            <div style="margin-top:12px; font-size:11px; color:var(--gray-500);">
                                <i class="bi bi-clock"></i> শুরু: <?= bn_date($a['start_time'], true) ?>
                                <?php if ($a['end_time']): ?> • শেষ: <?= bn_date($a['end_time'], true) ?><?php endif; ?>
                                 • সূত্র: <strong><?= e($a['issued_by']) ?></strong>
                            </div>
                        </div>
                    </div>
                </div>
            <?php endforeach; ?>
        </div>
        <?php endif; ?>

        <?php if (!empty($history)): ?>
        <div class="dash-card">
            <h3 style="margin:0 0 14px;"><i class="bi bi-clock-history"></i> পূর্বের সতর্কতা (নিষ্ক্রিয়)</h3>
            <div style="display:grid; grid-template-columns: repeat(auto-fill, minmax(280px,1fr)); gap: 12px;">
                <?php foreach ($history as $h):
                    $sm = $severityMap[$h['severity']] ?? ['neutral', $h['severity'], '#666'];
                ?>
                    <div style="padding: 14px; background: var(--gray-50); border-radius: 10px; opacity: 0.85;">
                        <div style="display:flex; align-items:center; gap:8px; margin-bottom:6px;">
                            <span style="font-size:24px;"><?= $typeIcons[$h['alert_type']] ?? '⚠' ?></span>
                            <strong style="font-size:13px;"><?= e($h['alert_title']) ?></strong>
                        </div>
                        <p style="font-size:12px; color:var(--gray-600); margin: 4px 0; line-height:1.5;"><?= e(mb_substr($h['alert_message'], 0, 100, 'UTF-8')) ?>...</p>
                        <div style="font-size:11px; color:var(--gray-400);"><?= bn_date($h['start_time']) ?></div>
                    </div>
                <?php endforeach; ?>
            </div>
        </div>
        <?php endif; ?>
    </main>
</div>
</div>

<?php require __DIR__ . '/../../includes/footer.php'; ?>
