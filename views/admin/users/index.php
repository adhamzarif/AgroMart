<?php require __DIR__ . '/../../../includes/header.php'; ?>
<?php require __DIR__ . '/../../../includes/navbar.php'; ?>

<?php
$roleIcons = ['farmer'=>'👨‍🌾','buyer'=>'🛒','agent'=>'🤝','admin'=>'👑'];
$statusBadge = ['active'=>['success','সক্রিয়'],'suspended'=>['danger','স্থগিত'],'deleted'=>['neutral','মুছে ফেলা'],'pending_verification'=>['warning','যাচাই বাকি']];
?>

<div class="dash-page">
<div class="dash-shell">
    <?php require __DIR__ . '/../../../includes/sidebar.php'; ?>

    <main class="dash-main">
        <div class="dash-header">
            <div>
                <div class="breadcrumb"><a href="<?= BASE_URL ?>/admin/dashboard">ড্যাশবোর্ড</a> <i class="bi bi-chevron-right" style="font-size:10px"></i> ব্যবহারকারী</div>
                <h1>ব্যবহারকারী ব্যবস্থাপনা 👥</h1>
            </div>
            <div style="font-size:13px; color:var(--gray-500);">মোট <strong><?= bn_num($total) ?></strong> জন</div>
        </div>

        <div class="dash-card" style="padding: 14px 20px;">
            <form method="GET" style="display:flex; gap:10px; align-items:end; flex-wrap:wrap;">
                <div style="flex:1; min-width: 200px;">
                    <label style="display:block; font-size:12px; font-weight:600; margin-bottom:4px;">খুঁজুন</label>
                    <input type="text" name="q" value="<?= e($filters['q'] ?? '') ?>" placeholder="নাম, ফোন, ইমেল" style="width:100%; padding:9px 12px; border:1.5px solid var(--gray-200); border-radius:8px; box-sizing:border-box;">
                </div>
                <div>
                    <label style="display:block; font-size:12px; font-weight:600; margin-bottom:4px;">ভূমিকা</label>
                    <select name="role" style="padding:9px 12px; border:1.5px solid var(--gray-200); border-radius:8px;">
                        <option value="">— সব —</option>
                        <option value="farmer" <?= ($filters['role'] ?? '') === 'farmer' ? 'selected' : '' ?>>কৃষক</option>
                        <option value="buyer" <?= ($filters['role'] ?? '') === 'buyer' ? 'selected' : '' ?>>ক্রেতা</option>
                        <option value="agent" <?= ($filters['role'] ?? '') === 'agent' ? 'selected' : '' ?>>এজেন্ট</option>
                        <option value="admin" <?= ($filters['role'] ?? '') === 'admin' ? 'selected' : '' ?>>অ্যাডমিন</option>
                    </select>
                </div>
                <div>
                    <label style="display:block; font-size:12px; font-weight:600; margin-bottom:4px;">অবস্থা</label>
                    <select name="status" style="padding:9px 12px; border:1.5px solid var(--gray-200); border-radius:8px;">
                        <option value="">— সব —</option>
                        <option value="active" <?= ($filters['status'] ?? '') === 'active' ? 'selected' : '' ?>>সক্রিয়</option>
                        <option value="suspended" <?= ($filters['status'] ?? '') === 'suspended' ? 'selected' : '' ?>>স্থগিত</option>
                        <option value="deleted" <?= ($filters['status'] ?? '') === 'deleted' ? 'selected' : '' ?>>মুছে ফেলা</option>
                    </select>
                </div>
                <button type="submit" class="nav-pill-btn primary"><i class="bi bi-funnel"></i> ফিল্টার</button>
                <a href="<?= BASE_URL ?>/admin/users" class="nav-pill-btn ghost">রিসেট</a>
            </form>
        </div>

        <div class="dash-card">
            <?php if (empty($users)): ?>
                <div class="empty-state"><i class="bi bi-search"></i><h4>কোনো ব্যবহারকারী পাওয়া যায়নি</h4></div>
            <?php else: ?>
            <div style="overflow-x:auto;">
            <table class="table">
                <thead>
                    <tr><th>নাম</th><th>যোগাযোগ</th><th>ভূমিকা</th><th>জেলা</th><th>যাচাই</th><th>অবস্থা</th><th>যোগদান</th><th></th></tr>
                </thead>
                <tbody>
                <?php foreach ($users as $u):
                    $sb = $statusBadge[$u['status']] ?? ['neutral', $u['status']];
                    $userRoles = array_filter(explode(',', $u['roles'] ?? ''));
                ?>
                    <tr>
                        <td>
                            <div style="display:flex; align-items:center; gap:10px;">
                                <div style="width:36px; height:36px; border-radius:50%; background: var(--grad-m1); color:#fff; display:flex; align-items:center; justify-content:center; font-weight:700;"><?= e(mb_substr($u['full_name'], 0, 1, 'UTF-8')) ?></div>
                                <strong><?= e($u['full_name']) ?></strong>
                            </div>
                        </td>
                        <td style="font-size:12px;">
                            <?= e($u['phone']) ?><br>
                            <?php if ($u['email']): ?><span style="color:var(--gray-500);"><?= e($u['email']) ?></span><?php endif; ?>
                        </td>
                        <td>
                            <?php foreach ($userRoles as $r): ?>
                                <span style="font-size:18px; margin-right:2px;" title="<?= e($r) ?>"><?= $roleIcons[$r] ?? '👤' ?></span>
                            <?php endforeach; ?>
                        </td>
                        <td style="font-size:12px;"><?= e($u['district_name'] ?? '—') ?></td>
                        <td style="font-size:11px;">
                            <?php if ($u['phone_verified']): ?>📱<?php endif; ?>
                            <?php if ($u['email_verified']): ?>📧<?php endif; ?>
                            <?php if ($u['nid_verified']): ?>🪪<?php endif; ?>
                        </td>
                        <td><span class="badge badge-<?= $sb[0] ?>"><?= $sb[1] ?></span></td>
                        <td style="font-size:11px;"><?= bn_date($u['created_at']) ?></td>
                        <td><a href="<?= BASE_URL ?>/admin/users/detail/<?= (int)$u['user_id'] ?>" class="nav-pill-btn ghost" style="font-size:12px; padding:5px 10px;">বিস্তারিত →</a></td>
                    </tr>
                <?php endforeach; ?>
                </tbody>
            </table>
            </div>

            <?php if ($totalPages > 1):
                $q = $_GET; unset($q['page']);
                $base = http_build_query($q);
            ?>
            <div style="display:flex; gap:6px; justify-content:center; margin-top: 18px;">
                <?php for ($p = max(1, $page-3); $p <= min($totalPages, $page+3); $p++): ?>
                    <a href="?<?= $base ? $base . '&' : '' ?>page=<?= $p ?>" class="nav-pill-btn <?= $p === $page ? 'primary' : 'ghost' ?>" style="font-size:13px; padding:6px 12px;"><?= bn_num($p) ?></a>
                <?php endfor; ?>
            </div>
            <?php endif; ?>
            <?php endif; ?>
        </div>
    </main>
</div>
</div>

<?php require __DIR__ . '/../../../includes/footer.php'; ?>
