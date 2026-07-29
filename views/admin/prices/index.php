<?php require __DIR__ . '/../../../includes/header.php'; ?>
<?php require __DIR__ . '/../../../includes/navbar.php'; ?>

<div class="dash-page">
<div class="dash-shell">
    <?php require __DIR__ . '/../../../includes/sidebar.php'; ?>

    <main class="dash-main">
        <div class="dash-header">
            <div>
                <div class="breadcrumb"><a href="<?= BASE_URL ?>/admin/dashboard">ড্যাশবোর্ড</a> <i class="bi bi-chevron-right" style="font-size:10px"></i> মার্কেট প্রাইস</div>
                <h1>মার্কেট প্রাইস ব্যবস্থাপনা 💹</h1>
            </div>
            <a href="<?= BASE_URL ?>/admin/prices/add" class="nav-pill-btn primary" style="background:var(--m4-primary)"><i class="bi bi-plus-lg"></i> নতুন মূল্য যোগ করুন</a>
        </div>

        <div class="dash-card" style="padding: 14px 20px;">
            <form method="GET" style="display:flex; gap:10px; align-items:end; flex-wrap:wrap;">
                <div style="flex:1; min-width: 200px;">
                    <label style="display:block; font-size:12px; font-weight:600; margin-bottom:4px;">ফসলের নাম</label>
                    <input type="text" name="crop_name" value="<?= e($filters['crop_name'] ?? '') ?>" placeholder="যেমন: টমেটো" style="width:100%; padding:9px 12px; border:1.5px solid var(--gray-200); border-radius:8px; box-sizing:border-box;">
                </div>
                <div>
                    <label style="display:block; font-size:12px; font-weight:600; margin-bottom:4px;">জেলা</label>
                    <select name="district_id" style="padding:9px 12px; border:1.5px solid var(--gray-200); border-radius:8px; min-width: 160px;">
                        <option value="">— সব জেলা —</option>
                        <?php foreach ($districts as $d): ?>
                            <option value="<?= (int)$d['district_id'] ?>" <?= ($filters['district_id'] ?? '') == $d['district_id'] ? 'selected' : '' ?>><?= e($d['district_name']) ?></option>
                        <?php endforeach; ?>
                    </select>
                </div>
                <button type="submit" class="nav-pill-btn primary"><i class="bi bi-funnel"></i> ফিল্টার</button>
                <a href="<?= BASE_URL ?>/admin/prices" class="nav-pill-btn ghost">রিসেট</a>
            </form>
        </div>

        <div class="dash-card">
            <?php if (empty($prices)): ?>
                <div class="empty-state">
                    <i class="bi bi-graph-up"></i>
                    <h4>কোনো মূল্য রেকর্ড নেই</h4>
                    <p>প্রথম মূল্য যোগ করুন।</p>
                    <a href="<?= BASE_URL ?>/admin/prices/add" class="nav-pill-btn primary"><i class="bi bi-plus-lg"></i> মূল্য যোগ করুন</a>
                </div>
            <?php else: ?>
            <div style="overflow-x:auto;">
            <table class="table">
                <thead>
                    <tr><th>ফসল</th><th>জেলা</th><th>পাইকারি</th><th>খুচরা</th><th>একক</th><th>তারিখ</th><th>সোর্স</th><th>আপডেট করেছেন</th><th></th></tr>
                </thead>
                <tbody>
                <?php foreach ($prices as $p):
                    $spread = $p['retail_price'] - $p['wholesale_price'];
                    $spreadPct = $p['wholesale_price'] > 0 ? ($spread / $p['wholesale_price']) * 100 : 0;
                ?>
                    <tr>
                        <td><strong><?= e($p['crop_name']) ?></strong></td>
                        <td><?= e($p['district_name']) ?></td>
                        <td class="mono"><?= bdt($p['wholesale_price'], 2) ?></td>
                        <td class="mono" style="color:var(--m3-primary); font-weight:700;"><?= bdt($p['retail_price'], 2) ?> <span style="color:var(--gray-500); font-size:10px; font-weight:400;">(+<?= bn_num(number_format($spreadPct, 0)) ?>%)</span></td>
                        <td><?= e($p['unit']) ?></td>
                        <td style="font-size:12px;"><?= bn_date($p['price_date']) ?></td>
                        <td style="font-size:12px;"><?= e($p['source']) ?></td>
                        <td style="font-size:11px; color:var(--gray-500);"><?= e($p['updated_by_name'] ?? '—') ?></td>
                        <td style="white-space:nowrap;">
                            <a href="<?= BASE_URL ?>/admin/prices/edit/<?= (int)$p['price_id'] ?>" style="margin-right:8px;" title="সম্পাদনা"><i class="bi bi-pencil"></i></a>
                            <form method="POST" action="<?= BASE_URL ?>/admin/prices/delete/<?= (int)$p['price_id'] ?>" style="display:inline;" onsubmit="return confirm('মুছে ফেলবেন?');">
                                <?= Csrf::field() ?>
                                <button type="submit" style="background:none; border:none; color:var(--danger); cursor:pointer;"><i class="bi bi-trash"></i></button>
                            </form>
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
