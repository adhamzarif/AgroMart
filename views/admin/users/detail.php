<?php require __DIR__ . '/../../../includes/header.php'; ?>
<?php require __DIR__ . '/../../../includes/navbar.php'; ?>

<?php
$roleIcons = ['farmer'=>'👨‍🌾 কৃষক','buyer'=>'🛒 ক্রেতা','agent'=>'🤝 এজেন্ট','admin'=>'👑 অ্যাডমিন'];
$statusBadge = ['active'=>['success','সক্রিয়'],'suspended'=>['danger','স্থগিত'],'deleted'=>['neutral','মুছে ফেলা'],'pending_verification'=>['warning','যাচাই বাকি']];
$sb = $statusBadge[$user['status']] ?? ['neutral', $user['status']];
?>

<div class="dash-page">
<div class="dash-shell">
    <?php require __DIR__ . '/../../../includes/sidebar.php'; ?>

    <main class="dash-main">
        <div class="dash-header">
            <div>
                <div class="breadcrumb"><a href="<?= BASE_URL ?>/admin/users">ব্যবহারকারী</a> <i class="bi bi-chevron-right" style="font-size:10px"></i> বিস্তারিত</div>
                <h1><?= e($user['full_name']) ?></h1>
            </div>
            <div><span class="badge badge-<?= $sb[0] ?>" style="font-size:14px; padding:8px 16px;"><?= $sb[1] ?></span></div>
        </div>

        <div style="display:grid; grid-template-columns: 1fr 2fr; gap:20px;">
            <div>
                <div class="dash-card" style="text-align:center;">
                    <?php if ($user['profile_picture']): ?>
                        <img src="<?= e(image_variant_url('profiles/' . $user['profile_picture'], 'thumb')) ?>" style="width:96px; height:96px; border-radius:50%; object-fit:cover; margin-bottom:10px;">
                    <?php else: ?>
                        <div style="width:96px; height:96px; border-radius:50%; background:var(--grad-m1); color:#fff; display:flex; align-items:center; justify-content:center; font-weight:700; font-size:36px; margin: 0 auto 12px;"><?= e(mb_substr($user['full_name'], 0, 1, 'UTF-8')) ?></div>
                    <?php endif; ?>
                    <h3 style="margin: 0 0 6px;"><?= e($user['full_name']) ?></h3>
                    <div style="font-size:13px; color:var(--gray-500); margin-bottom: 12px;">
                        <?php foreach ($roles as $r): ?>
                            <span class="badge badge-info" style="margin: 2px;"><?= $roleIcons[$r] ?? $r ?></span>
                        <?php endforeach; ?>
                    </div>

                    <div style="text-align:left; font-size:13px; line-height:1.9; margin-top:14px; padding-top:14px; border-top:1px solid var(--gray-100);">
                        <div><i class="bi bi-telephone"></i> <?= e($user['phone']) ?> <?= $user['phone_verified'] ? '<span class="badge badge-success" style="font-size:10px;">✓</span>' : '' ?></div>
                        <?php if ($user['email']): ?>
                            <div><i class="bi bi-envelope"></i> <?= e($user['email']) ?> <?= $user['email_verified'] ? '<span class="badge badge-success" style="font-size:10px;">✓</span>' : '' ?></div>
                        <?php endif; ?>
                        <?php if (!empty($user['nid_number'])): ?>
                            <div><i class="bi bi-card-text"></i> NID: <?= e($user['nid_number']) ?> <?= $user['nid_verified'] ? '<span class="badge badge-success" style="font-size:10px;">✓</span>' : '' ?></div>
                        <?php endif; ?>
                        <?php if (!empty($user['address'])): ?>
                            <div><i class="bi bi-geo-alt"></i> <?= e($user['address']) ?></div>
                        <?php endif; ?>
                        <div><i class="bi bi-calendar-event"></i> যোগদান: <?= bn_date($user['created_at']) ?></div>
                        <?php if (!empty($user['last_login'])): ?>
                            <div><i class="bi bi-clock"></i> সর্বশেষ লগইন: <?= bn_date($user['last_login'], true) ?></div>
                        <?php endif; ?>
                        <?php if (!empty($user['last_seen_at'])):
                            $secsAgo = time() - strtotime($user['last_seen_at']);
                            $isOnline = $secsAgo < 600; // within 10 min
                        ?>
                            <div>
                                <i class="bi bi-circle-fill" style="font-size:8px; color:<?= $isOnline ? 'var(--success)' : 'var(--gray-400)' ?>;"></i>
                                সর্বশেষ অ্যাক্টিভিটি: <?= bn_date($user['last_seen_at'], true) ?>
                                <?php if ($isOnline): ?><span class="badge badge-success" style="font-size:10px; margin-left:4px;">এখন অনলাইন</span><?php endif; ?>
                            </div>
                        <?php endif; ?>
                    </div>
                </div>

                <!-- Admin Actions -->
                <div class="dash-card" style="border-left:4px solid var(--m4-primary);">
                    <h3 style="margin:0 0 14px;"><i class="bi bi-shield-lock"></i> অ্যাডমিন অ্যাকশন</h3>

                    <?php if (!$user['phone_verified'] || !$user['email_verified'] || !$user['nid_verified']): ?>
                    <form method="POST" action="<?= BASE_URL ?>/admin/users/verify/<?= (int)$user['user_id'] ?>" style="margin-bottom:8px;">
                        <?= Csrf::field() ?>
                        <button class="nav-pill-btn primary" style="width:100%; justify-content:center;"><i class="bi bi-check2-circle"></i> ম্যানুয়ালি যাচাই করুন</button>
                    </form>
                    <?php endif; ?>

                    <?php if ($user['status'] === 'active'): ?>
                    <form method="POST" action="<?= BASE_URL ?>/admin/users/ban/<?= (int)$user['user_id'] ?>" onsubmit="return confirm('আপনি কি নিশ্চিত? ব্যবহারকারী লগইন করতে পারবেন না।');">
                        <?= Csrf::field() ?>
                        <button class="nav-pill-btn ghost" style="width:100%; justify-content:center; color:var(--danger);"><i class="bi bi-slash-circle"></i> স্থগিত করুন</button>
                    </form>
                    <?php elseif ($user['status'] === 'suspended'): ?>
                    <form method="POST" action="<?= BASE_URL ?>/admin/users/unban/<?= (int)$user['user_id'] ?>">
                        <?= Csrf::field() ?>
                        <button class="nav-pill-btn primary" style="width:100%; justify-content:center; background:var(--success);"><i class="bi bi-check2"></i> পুনঃসক্রিয় করুন</button>
                    </form>
                    <?php endif; ?>
                </div>
            </div>

            <div>
                <div class="dash-card">
                    <h3 style="margin:0 0 14px;"><i class="bi bi-bar-chart"></i> কার্যক্রম পরিসংখ্যান</h3>
                    <div style="display:grid; grid-template-columns: repeat(2,1fr); gap:14px;">
                        <div style="padding:14px; background:var(--gray-50); border-radius:10px;">
                            <div style="font-size:11px; color:var(--gray-500);">ফসল লিস্ট</div>
                            <div style="font-size:28px; font-weight:700; color:var(--m1-primary);"><?= bn_num($activity['crops_count'] ?? 0) ?></div>
                        </div>
                        <div style="padding:14px; background:var(--gray-50); border-radius:10px;">
                            <div style="font-size:11px; color:var(--gray-500);">অর্ডার</div>
                            <div style="font-size:28px; font-weight:700; color:var(--m2-primary);"><?= bn_num($activity['orders_count'] ?? 0) ?></div>
                        </div>
                        <div style="padding:14px; background:var(--gray-50); border-radius:10px;">
                            <div style="font-size:11px; color:var(--gray-500);">লোন আবেদন</div>
                            <div style="font-size:28px; font-weight:700; color:var(--m3-primary);"><?= bn_num($activity['loans_count'] ?? 0) ?></div>
                        </div>
                        <div style="padding:14px; background:var(--gray-50); border-radius:10px;">
                            <div style="font-size:11px; color:var(--gray-500);">খরচ এন্ট্রি</div>
                            <div style="font-size:28px; font-weight:700; color:var(--m4-primary);"><?= bn_num($activity['expenses_count'] ?? 0) ?></div>
                        </div>
                    </div>
                </div>

                <div class="dash-card">
                    <h3 style="margin:0 0 14px;"><i class="bi bi-info-circle"></i> অতিরিক্ত তথ্য</h3>
                    <table class="table" style="margin-bottom:0;">
                        <tbody>
                            <tr><td style="width:35%;"><strong>ভাষা</strong></td><td><?= $user['language'] === 'bn' ? 'বাংলা' : 'English' ?></td></tr>
                            <tr><td><strong>পেশা</strong></td><td><?= e($user['occupation'] ?? '—') ?></td></tr>
                            <tr><td><strong>জন্ম তারিখ</strong></td><td><?= !empty($user['date_of_birth']) ? bn_date($user['date_of_birth']) : '—' ?></td></tr>
                            <tr><td><strong>লিঙ্গ</strong></td><td><?= !empty($user['gender']) ? e($user['gender']) : '—' ?></td></tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </main>
</div>
</div>

<?php require __DIR__ . '/../../../includes/footer.php'; ?>
