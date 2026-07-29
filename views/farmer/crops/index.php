<?php require __DIR__ . '/../../../includes/header.php'; ?>
<?php require __DIR__ . '/../../../includes/navbar.php'; ?>

<div class="dash-page">
<div class="dash-shell">
    <?php require __DIR__ . '/../../../includes/sidebar.php'; ?>

    <main class="dash-main">
        <div class="dash-header">
            <div>
                <div class="breadcrumb"><a href="<?= BASE_URL ?>/farmer/dashboard">ড্যাশবোর্ড</a> <i class="bi bi-chevron-right" style="font-size:10px"></i> আমার ফসল</div>
                <h1>আমার ফসল 🌾</h1>
            </div>
            <a href="<?= BASE_URL ?>/farmer/crops/add" class="nav-pill-btn primary"><i class="bi bi-plus-lg"></i> নতুন ফসল যোগ করুন</a>
        </div>

        <!-- Filters -->
        <div class="dash-card" style="padding: 14px 20px;">
            <form method="GET" style="display:flex; gap:10px; align-items:center; flex-wrap:wrap;">
                <span style="font-weight:600; font-size:13px;">ফিল্টার:</span>
                <?php $st = $statusFilter ?? ''; ?>
                <a href="<?= BASE_URL ?>/farmer/crops" class="nav-pill-btn <?= !$st ? 'primary' : 'ghost' ?>" style="font-size:13px;">সব</a>
                <a href="<?= BASE_URL ?>/farmer/crops?status=available" class="nav-pill-btn <?= $st === 'available' ? 'primary' : 'ghost' ?>" style="font-size:13px;">সক্রিয়</a>
                <a href="<?= BASE_URL ?>/farmer/crops?status=sold" class="nav-pill-btn <?= $st === 'sold' ? 'primary' : 'ghost' ?>" style="font-size:13px;">বিক্রিত</a>
                <a href="<?= BASE_URL ?>/farmer/crops?status=removed" class="nav-pill-btn <?= $st === 'removed' ? 'primary' : 'ghost' ?>" style="font-size:13px;">মুছে ফেলা</a>
            </form>
        </div>

        <?php if (empty($crops)): ?>
            <div class="dash-card">
                <div class="empty-state">
                    <i class="bi bi-basket"></i>
                    <h4>এই ক্যাটাগরিতে এখনো কোনো ফসল নেই</h4>
                    <p>প্রথম ফসল যোগ করে মার্কেটপ্লেসে বিক্রি শুরু করুন।</p>
                    <a href="<?= BASE_URL ?>/farmer/crops/add" class="nav-pill-btn primary"><i class="bi bi-plus-lg"></i> ফসল যোগ করুন</a>
                </div>
            </div>
        <?php else: ?>
        <div style="display:grid; grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); gap: 16px;">
            <?php foreach ($crops as $c):
                $img = first_image($c['images']);
                $statusMap = [
                    'available' => ['success','সক্রিয়'],
                    'sold' => ['neutral','বিক্রিত'],
                    'expired' => ['warning','মেয়াদ শেষ'],
                    'removed' => ['danger','মুছে ফেলা'],
                ];
                $sm = $statusMap[$c['status']] ?? ['neutral', $c['status']];
            ?>
                <div class="dash-card" style="padding: 0; overflow: hidden; margin: 0;">
                    <div style="height: 140px; background: linear-gradient(135deg, #c8e6c9, #e8f5e9); display:flex; align-items:center; justify-content:center; font-size:60px; position:relative;">
                        <?php if ($img): ?>
                            <img src="<?= e($img) ?>" alt="" style="width:100%; height:100%; object-fit:cover;">
                        <?php else: ?>
                            🌾
                        <?php endif; ?>
                        <div style="position:absolute; top:10px; right:10px;">
                            <span class="badge badge-<?= $sm[0] ?>"><?= $sm[1] ?></span>
                        </div>
                        <?php if ($c['is_organic']): ?>
                            <div style="position:absolute; top:10px; left:10px;">
                                <span class="badge badge-success"><i class="bi bi-leaf"></i> জৈব</span>
                            </div>
                        <?php endif; ?>
                    </div>
                    <div style="padding: 16px;">
                        <div style="display:flex; justify-content:space-between; align-items:start; margin-bottom:8px;">
                            <div style="flex:1; min-width:0;">
                                <div style="font-weight:700; font-size:16px; color:var(--gray-900);"><?= e($c['crop_name']) ?></div>
                                <div style="font-size:12px; color:var(--gray-500);"><?= e($c['category_name_bn']) ?> <?php if ($c['crop_variety']): ?>• <?= e($c['crop_variety']) ?><?php endif; ?></div>
                            </div>
                            <span class="badge badge-info" style="font-size:11px;">Grade <?= e($c['quality_grade']) ?></span>
                        </div>
                        <div style="display:flex; justify-content:space-between; font-size:13px; color:var(--gray-700); margin-bottom: 10px;">
                            <span><i class="bi bi-box"></i> <?= bn_num($c['quantity']) ?> <?= e($c['unit']) ?></span>
                            <span style="font-weight:700; color:var(--m1-primary);"><?= bdt($c['price_per_unit'], 0) ?>/<?= e($c['unit']) ?></span>
                        </div>
                        <div style="display:flex; gap:6px;">
                            <a href="<?= BASE_URL ?>/farmer/crops/edit/<?= (int)$c['crop_id'] ?>" class="nav-pill-btn ghost" style="flex:1; font-size:12px; justify-content:center;"><i class="bi bi-pencil"></i> সম্পাদনা</a>
                            <?php if ($c['status'] !== 'removed'): ?>
                            <form method="POST" action="<?= BASE_URL ?>/farmer/crops/delete/<?= (int)$c['crop_id'] ?>" style="flex:1;" onsubmit="return confirm('আপনি কি নিশ্চিত? এই ফসলটি মুছে ফেলা হবে।');">
                                <?= Csrf::field() ?>
                                <button type="submit" class="nav-pill-btn ghost" style="width:100%; font-size:12px; justify-content:center; color:var(--danger); border:none;"><i class="bi bi-trash"></i> মুছুন</button>
                            </form>
                            <?php endif; ?>
                        </div>
                        <div style="font-size:11px; color:var(--gray-400); margin-top:10px; display:flex; justify-content:space-between;">
                            <span><i class="bi bi-eye"></i> <?= bn_num($c['views_count']) ?> বার দেখা হয়েছে</span>
                            <span><?= bn_date($c['created_at']) ?></span>
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
