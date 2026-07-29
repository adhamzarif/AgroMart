<?php require __DIR__ . '/../../includes/header.php'; ?>
<?php require __DIR__ . '/../../includes/navbar.php'; ?>

<div class="dash-page">
<div class="dash-shell">
    <?php require __DIR__ . '/../../includes/sidebar.php'; ?>

    <main class="dash-main">
        <div class="dash-header">
            <div>
                <div class="breadcrumb"><a href="<?= BASE_URL ?>/buyer/dashboard">ড্যাশবোর্ড</a> <i class="bi bi-chevron-right" style="font-size:10px"></i> প্রিয় তালিকা</div>
                <h1>প্রিয় তালিকা ❤️</h1>
            </div>
        </div>

        <!-- Favorite Crops -->
        <div class="dash-card">
            <div class="dash-card-header">
                <h3><i class="bi bi-basket"></i> প্রিয় ফসল (<?= bn_num(count($cropFavorites)) ?>)</h3>
            </div>
            <?php if (empty($cropFavorites)): ?>
                <div class="empty-state"><i class="bi bi-heart"></i><h4>কোনো প্রিয় ফসল নেই</h4><p>ফসল দেখার সময় ❤ আইকনে ক্লিক করুন।</p></div>
            <?php else: ?>
            <div style="display:grid; grid-template-columns: repeat(auto-fill, minmax(220px,1fr)); gap:14px;">
                <?php foreach ($cropFavorites as $f):
                    $img = first_image($f['images']);
                ?>
                    <div style="background:#fff; border:1px solid var(--gray-100); border-radius:14px; overflow:hidden;">
                        <a href="<?= BASE_URL ?>/buyer/crop/<?= (int)$f['crop_id'] ?>" style="text-decoration:none; color:inherit;">
                            <div style="height:140px; background: linear-gradient(135deg, #c8e6c9, #e8f5e9); display:flex; align-items:center; justify-content:center; font-size:60px;">
                                <?php if ($img): ?><img src="<?= e($img) ?>" alt="" style="width:100%; height:100%; object-fit:cover;"><?php else: ?>🌾<?php endif; ?>
                            </div>
                            <div style="padding:12px 14px;">
                                <div style="font-weight:700;"><?= e($f['crop_name']) ?></div>
                                <div style="font-size:12px; color:var(--gray-500);"><?= e($f['farmer_name']) ?><?php if ($f['district_name']): ?> • <?= e($f['district_name']) ?><?php endif; ?></div>
                                <div style="margin-top:6px; display:flex; justify-content:space-between;">
                                    <span style="font-weight:800; color:var(--m1-primary);"><?= bdt($f['price_per_unit'], 0) ?></span>
                                    <span class="badge badge-<?= $f['status'] === 'available' ? 'success' : 'neutral' ?>" style="font-size:10px;"><?= $f['status'] === 'available' ? 'উপলব্ধ' : 'অনুপলব্ধ' ?></span>
                                </div>
                            </div>
                        </a>
                        <div style="padding: 0 14px 14px;">
                            <form method="POST" action="<?= BASE_URL ?>/buyer/favorites/toggle-crop/<?= (int)$f['crop_id'] ?>">
                                <?= Csrf::field() ?>
                                <button type="submit" class="nav-pill-btn ghost" style="width:100%; justify-content:center; font-size:12px; color:var(--danger);"><i class="bi bi-heart-fill"></i> সরান</button>
                            </form>
                        </div>
                    </div>
                <?php endforeach; ?>
            </div>
            <?php endif; ?>
        </div>

        <!-- Favorite Farmers -->
        <div class="dash-card">
            <div class="dash-card-header">
                <h3><i class="bi bi-person-hearts"></i> প্রিয় কৃষক (<?= bn_num(count($farmerFavorites)) ?>)</h3>
            </div>
            <?php if (empty($farmerFavorites)): ?>
                <div class="empty-state"><i class="bi bi-person"></i><h4>কোনো প্রিয় কৃষক নেই</h4></div>
            <?php else: ?>
            <div style="display:grid; grid-template-columns: repeat(auto-fill, minmax(280px,1fr)); gap:14px;">
                <?php foreach ($farmerFavorites as $f): ?>
                    <div style="background:#fff; border:1px solid var(--gray-100); border-radius:14px; padding:16px; display:flex; gap:12px; align-items:center;">
                        <div style="width:56px; height:56px; border-radius:50%; background:var(--grad-m1); color:#fff; display:flex; align-items:center; justify-content:center; font-weight:700; font-size:22px; flex-shrink:0;"><?= e(mb_substr($f['farmer_name'], 0, 1, 'UTF-8')) ?></div>
                        <div style="flex:1; min-width:0;">
                            <strong><?= e($f['farmer_name']) ?></strong>
                            <?php if ($f['district_name']): ?><div style="font-size:12px; color:var(--gray-500);"><?= e($f['district_name']) ?></div><?php endif; ?>
                            <div style="font-size:12px; color:#f57c00; margin-top:2px;">⭐ <?= bn_num(number_format($f['rating'], 1)) ?> • <?= bn_num($f['active_crops']) ?> সক্রিয় ফসল</div>
                            <div style="margin-top:8px; display:flex; gap:6px;">
                                <a href="<?= BASE_URL ?>/buyer/messages/with/<?= (int)$f['farmer_id'] ?>" class="nav-pill-btn ghost" style="font-size:11px; padding:4px 10px;"><i class="bi bi-chat"></i></a>
                                <form method="POST" action="<?= BASE_URL ?>/buyer/favorites/toggle-farmer/<?= (int)$f['farmer_id'] ?>" style="display:inline;">
                                    <?= Csrf::field() ?>
                                    <button type="submit" class="nav-pill-btn ghost" style="font-size:11px; padding:4px 10px; color:var(--danger); border:none;"><i class="bi bi-heart-fill"></i></button>
                                </form>
                            </div>
                        </div>
                    </div>
                <?php endforeach; ?>
            </div>
            <?php endif; ?>
        </div>
    </main>
</div>
</div>

<?php require __DIR__ . '/../../includes/footer.php'; ?>
