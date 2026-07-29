<?php require __DIR__ . '/../../../includes/header.php'; ?>
<?php require __DIR__ . '/../../../includes/navbar.php'; ?>

<div class="dash-page">
<div class="dash-shell">
    <?php require __DIR__ . '/../../../includes/sidebar.php'; ?>

    <main class="dash-main">
        <div class="dash-header">
            <div>
                <div class="breadcrumb"><a href="<?= BASE_URL ?>/admin/dashboard">ড্যাশবোর্ড</a> <i class="bi bi-chevron-right" style="font-size:10px"></i> ক্যাটাগরি</div>
                <h1>ক্যাটাগরি ব্যবস্থাপনা 🏷</h1>
            </div>
            <a href="<?= BASE_URL ?>/admin/categories/add" class="nav-pill-btn primary" style="background:var(--m4-primary)"><i class="bi bi-plus-lg"></i> নতুন ক্যাটাগরি</a>
        </div>

        <div class="dash-card">
            <?php if (empty($categories)): ?>
                <div class="empty-state">
                    <i class="bi bi-tags"></i>
                    <h4>কোনো ক্যাটাগরি নেই</h4>
                    <a href="<?= BASE_URL ?>/admin/categories/add" class="nav-pill-btn primary"><i class="bi bi-plus-lg"></i> প্রথম ক্যাটাগরি যোগ করুন</a>
                </div>
            <?php else: ?>
            <div style="overflow-x:auto;">
            <table class="table">
                <thead>
                    <tr><th>আইকন</th><th>বাংলা নাম</th><th>ইংরেজি নাম</th><th>প্যারেন্ট</th><th>বিবরণ</th><th>ফসল সংখ্যা</th><th></th></tr>
                </thead>
                <tbody>
                <?php foreach ($categories as $c): ?>
                    <tr>
                        <td style="font-size:22px; text-align:center;"><?= e($c['icon'] ?? '📌') ?></td>
                        <td><strong><?= e($c['category_name_bn']) ?></strong></td>
                        <td style="color:var(--gray-600);"><?= e($c['category_name']) ?></td>
                        <td style="font-size:12px; color:var(--gray-500);"><?= e($c['parent_name'] ?? '—') ?></td>
                        <td style="font-size:12px;"><?= e(mb_substr($c['description'] ?? '', 0, 50, 'UTF-8')) ?></td>
                        <td><span class="badge badge-info"><?= bn_num($c['crops_count']) ?> ফসল</span></td>
                        <td style="white-space:nowrap;">
                            <a href="<?= BASE_URL ?>/admin/categories/edit/<?= (int)$c['category_id'] ?>" style="margin-right:8px;"><i class="bi bi-pencil"></i></a>
                            <?php if ($c['crops_count'] == 0): ?>
                            <form method="POST" action="<?= BASE_URL ?>/admin/categories/delete/<?= (int)$c['category_id'] ?>" style="display:inline;" onsubmit="return confirm('মুছে ফেলবেন?');">
                                <?= Csrf::field() ?>
                                <button type="submit" style="background:none; border:none; color:var(--danger); cursor:pointer;"><i class="bi bi-trash"></i></button>
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
