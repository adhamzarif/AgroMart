<?php require __DIR__ . '/../../../includes/header.php'; ?>
<?php require __DIR__ . '/../../../includes/navbar.php'; ?>

<div class="dash-page">
<div class="dash-shell">
    <?php require __DIR__ . '/../../../includes/sidebar.php'; ?>

    <main class="dash-main">
        <div class="dash-header">
            <div>
                <div class="breadcrumb"><a href="<?= BASE_URL ?>/admin/dashboard">ড্যাশবোর্ড</a> <i class="bi bi-chevron-right" style="font-size:10px"></i> পরিবহন</div>
                <h1>পরিবহন পার্টনার 🚚</h1>
            </div>
            <a href="<?= BASE_URL ?>/admin/transport/add" class="nav-pill-btn primary" style="background:var(--m4-primary)"><i class="bi bi-plus-lg"></i> নতুন পার্টনার</a>
        </div>

        <?php if (empty($partners)): ?>
            <div class="dash-card">
                <div class="empty-state">
                    <i class="bi bi-truck"></i>
                    <h4>কোনো পরিবহন পার্টনার নেই</h4>
                    <p>ফসল ডেলিভারির জন্য পরিবহন পার্টনার যোগ করুন।</p>
                    <a href="<?= BASE_URL ?>/admin/transport/add" class="nav-pill-btn primary" style="background:var(--m4-primary)"><i class="bi bi-plus-lg"></i> প্রথম পার্টনার যোগ করুন</a>
                </div>
            </div>
        <?php else: ?>
        <div style="display:grid; grid-template-columns: repeat(auto-fill, minmax(360px, 1fr)); gap: 14px;">
            <?php foreach ($partners as $p):
                $districts = is_array($p['service_districts']) ? $p['service_districts'] : (json_decode($p['service_districts'], true) ?: []);
                $vehicles = is_array($p['vehicle_types']) ? $p['vehicle_types'] : (json_decode($p['vehicle_types'], true) ?: []);
            ?>
                <div class="dash-card" style="margin:0; padding:18px; <?= !$p['is_active'] ? 'opacity:0.6;' : '' ?>">
                    <div style="display:flex; justify-content:space-between; align-items:start; margin-bottom: 10px;">
                        <div>
                            <strong style="font-size:16px;"><?= e($p['partner_name']) ?></strong>
                            <div style="font-size:12px; color:var(--gray-500); margin-top: 2px;"><?= e($p['contact_person'] ?? '') ?></div>
                        </div>
                        <?php if ($p['is_active']): ?>
                            <span class="badge badge-success">সক্রিয়</span>
                        <?php else: ?>
                            <span class="badge badge-neutral">নিষ্ক্রিয়</span>
                        <?php endif; ?>
                    </div>

                    <div style="font-size:13px; line-height:1.8; margin-bottom: 12px;">
                        <div><i class="bi bi-telephone"></i> <?= e($p['contact_phone']) ?></div>
                        <?php if ($p['contact_email']): ?><div><i class="bi bi-envelope"></i> <?= e($p['contact_email']) ?></div><?php endif; ?>
                        <div><i class="bi bi-cash"></i> ৳<?= bn_num($p['base_rate_per_km']) ?>/কিমি (ন্যূনতম ৳<?= bn_num($p['min_charge']) ?>)</div>
                        <div><i class="bi bi-truck"></i> <?= e(implode(', ', $vehicles)) ?></div>
                        <div><i class="bi bi-geo-alt"></i> <?= bn_num(count($districts)) ?> টি জেলায় সেবা</div>
                    </div>

                    <div style="display:flex; gap:10px; font-size:12px; padding-top: 12px; border-top: 1px solid var(--gray-100);">
                        <span><strong style="color:#f57c00;">⭐ <?= bn_num(number_format($p['rating'], 1)) ?></strong> রেটিং</span>
                        <span>📦 <strong><?= bn_num($p['total_deliveries']) ?></strong> ডেলিভারি</span>
                    </div>

                    <div style="display:flex; gap:6px; margin-top: 12px;">
                        <a href="<?= BASE_URL ?>/admin/transport/edit/<?= (int)$p['partner_id'] ?>" class="nav-pill-btn ghost" style="flex:1; justify-content:center; font-size:12px;"><i class="bi bi-pencil"></i> সম্পাদনা</a>
                        <form method="POST" action="<?= BASE_URL ?>/admin/transport/toggle/<?= (int)$p['partner_id'] ?>" style="flex:1;">
                            <?= Csrf::field() ?>
                            <button class="nav-pill-btn <?= $p['is_active'] ? 'ghost' : 'primary' ?>" style="width:100%; justify-content:center; font-size:12px;"><?= $p['is_active'] ? 'নিষ্ক্রিয়' : 'সক্রিয়' ?></button>
                        </form>
                        <form method="POST" action="<?= BASE_URL ?>/admin/transport/delete/<?= (int)$p['partner_id'] ?>" onsubmit="return confirm('মুছে ফেলবেন?');">
                            <?= Csrf::field() ?>
                            <button class="nav-pill-btn ghost" style="font-size:12px; color:var(--danger); border:none;"><i class="bi bi-trash"></i></button>
                        </form>
                    </div>
                </div>
            <?php endforeach; ?>
        </div>
        <?php endif; ?>
    </main>
</div>
</div>

<?php require __DIR__ . '/../../../includes/footer.php'; ?>
