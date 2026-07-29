<?php require __DIR__ . '/../../../includes/header.php'; ?>
<?php require __DIR__ . '/../../../includes/navbar.php'; ?>

<?php
$statusMap = [
    'available' => ['success', 'সক্রিয়'],
    'sold'      => ['neutral', 'বিক্রিত'],
    'expired'   => ['warning', 'মেয়াদ শেষ'],
    'removed'   => ['danger', 'মুছে ফেলা'],
];
?>

<div class="dash-page">
<div class="dash-shell">
    <?php require __DIR__ . '/../../../includes/sidebar.php'; ?>

    <main class="dash-main">
        <div class="dash-header">
            <div>
                <div class="breadcrumb"><a href="<?= BASE_URL ?>/admin/dashboard">ড্যাশবোর্ড</a> <i class="bi bi-chevron-right" style="font-size:10px"></i> ফসল মডারেশন</div>
                <h1>ফসল মডারেশন 🌾</h1>
            </div>
        </div>

        <div class="dash-card" style="padding: 14px 20px;">
            <form method="GET" style="display:flex; gap:10px; align-items:end; flex-wrap:wrap;">
                <div style="flex:1; min-width: 200px;">
                    <label style="display:block; font-size:12px; font-weight:600; margin-bottom:4px;">খুঁজুন</label>
                    <input type="text" name="q" value="<?= e($q ?? '') ?>" placeholder="ফসলের নাম বা কৃষকের নাম" style="width:100%; padding:9px 12px; border:1.5px solid var(--gray-200); border-radius:8px; box-sizing:border-box;">
                </div>
                <div>
                    <label style="display:block; font-size:12px; font-weight:600; margin-bottom:4px;">অবস্থা</label>
                    <select name="status" style="padding:9px 12px; border:1.5px solid var(--gray-200); border-radius:8px;">
                        <option value="available" <?= $filter === 'available' ? 'selected' : '' ?>>সক্রিয়</option>
                        <option value="sold" <?= $filter === 'sold' ? 'selected' : '' ?>>বিক্রিত</option>
                        <option value="expired" <?= $filter === 'expired' ? 'selected' : '' ?>>মেয়াদ শেষ</option>
                        <option value="removed" <?= $filter === 'removed' ? 'selected' : '' ?>>মুছে ফেলা</option>
                        <option value="all" <?= $filter === 'all' ? 'selected' : '' ?>>সব</option>
                    </select>
                </div>
                <button type="submit" class="nav-pill-btn primary"><i class="bi bi-funnel"></i> ফিল্টার</button>
                <a href="<?= BASE_URL ?>/admin/crops" class="nav-pill-btn ghost">রিসেট</a>
            </form>
        </div>

        <div class="dash-card">
            <?php if (empty($crops)): ?>
                <div class="empty-state"><i class="bi bi-search"></i><h4>কোনো ফসল পাওয়া যায়নি</h4></div>
            <?php else: ?>
            <div style="overflow-x:auto;">
            <table class="table">
                <thead>
                    <tr><th>ফসল</th><th>কৃষক</th><th>জেলা</th><th>পরিমাণ</th><th>মূল্য</th><th>গ্রেড</th><th>অবস্থা</th><th>👁</th><th>তারিখ</th><th></th></tr>
                </thead>
                <tbody>
                <?php foreach ($crops as $c):
                    $sm = $statusMap[$c['status']] ?? ['neutral', $c['status']];
                ?>
                    <tr>
                        <td>
                            <strong><?= e($c['crop_name']) ?></strong>
                            <?php if ($c['is_organic']): ?><span style="font-size:14px;" title="জৈব">🍃</span><?php endif; ?>
                            <div style="font-size:11px; color:var(--gray-500);"><?= e($c['category_name_bn']) ?><?php if ($c['crop_variety']): ?> • <?= e($c['crop_variety']) ?><?php endif; ?></div>
                        </td>
                        <td style="font-size:12px;">
                            <?= e($c['farmer_name']) ?><br>
                            <span style="color:var(--gray-500);"><?= e($c['farmer_phone']) ?></span>
                        </td>
                        <td style="font-size:12px;"><?= e($c['district_name'] ?? '—') ?></td>
                        <td><?= bn_num($c['quantity']) ?> <?= e($c['unit']) ?></td>
                        <td class="mono"><?= bdt($c['price_per_unit'], 0) ?></td>
                        <td><span class="badge badge-info"><?= e($c['quality_grade']) ?></span></td>
                        <td><span class="badge badge-<?= $sm[0] ?>"><?= $sm[1] ?></span></td>
                        <td class="mono" style="font-size:11px;"><?= bn_num($c['views_count']) ?></td>
                        <td style="font-size:11px;"><?= bn_date($c['created_at']) ?></td>
                        <td>
                            <?php if ($c['status'] === 'available'): ?>
                                <form method="POST" action="<?= BASE_URL ?>/admin/crops/remove/<?= (int)$c['crop_id'] ?>" onsubmit="var r=prompt('সরানোর কারণ (ঐচ্ছিক):'); if(r === null) return false; this.elements.reason.value=r||''; return true;">
                                    <?= Csrf::field() ?>
                                    <input type="hidden" name="reason" value="">
                                    <button type="submit" class="nav-pill-btn ghost" style="font-size:11px; padding:4px 10px; color:var(--danger);"><i class="bi bi-eye-slash"></i> সরান</button>
                                </form>
                            <?php endif; ?>
                        </td>
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
