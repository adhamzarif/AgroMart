<?php require __DIR__ . '/../../../includes/header.php'; ?>
<?php require __DIR__ . '/../../../includes/navbar.php'; ?>

<?php
$roleLabels = ['leader'=>['👑 লিডার','farmer'], 'treasurer'=>['💰 কোষাধ্যক্ষ','warning'], 'member'=>['👤 সদস্য','info']];
$me = $_SESSION['user_id'] ?? 0;
$myMembership = null;
foreach ($members as $m) {
    if ((int)$m['farmer_id'] === (int)$me) { $myMembership = $m; break; }
}
?>

<div class="dash-page">
<div class="dash-shell">
    <?php require __DIR__ . '/../../../includes/sidebar.php'; ?>

    <main class="dash-main">
        <div class="dash-header">
            <div>
                <div class="breadcrumb"><a href="<?= BASE_URL ?>/farmer/groups">গ্রুপ</a> <i class="bi bi-chevron-right" style="font-size:10px"></i> বিস্তারিত</div>
                <h1>👥 <?= e($group['group_name']) ?></h1>
            </div>
        </div>

        <div style="display:grid; grid-template-columns: 1fr 2fr; gap: 20px;">
            <div>
                <div class="dash-card" style="text-align:center;">
                    <div style="font-size:64px; margin-bottom: 10px;">👥</div>
                    <h2 style="margin: 0 0 8px; font-size: 18px;"><?= e($group['group_name']) ?></h2>
                    <div style="font-size:12px; color:var(--gray-500); margin-bottom: 14px;">
                        <code style="background:var(--gray-50); padding: 4px 8px; border-radius: 6px;"><?= e($group['group_code']) ?></code>
                    </div>

                    <div style="text-align:left; font-size:13px; line-height:1.9; padding-top: 14px; border-top: 1px solid var(--gray-100);">
                        <div><i class="bi bi-person-fill"></i> লিডার: <strong><?= e($group['leader_name']) ?></strong></div>
                        <div><i class="bi bi-telephone"></i> <?= e($group['leader_phone']) ?></div>
                        <div><i class="bi bi-geo-alt"></i> <?= e($group['district_name']) ?></div>
                        <div><i class="bi bi-people"></i> <strong><?= bn_num($group['total_members']) ?></strong> সদস্য</div>
                        <div><i class="bi bi-grid-3x3"></i> মোট জমি: <strong><?= bn_num($group['total_land_acres']) ?></strong> একর</div>
                        <div><i class="bi bi-calendar-event"></i> গঠিত: <?= bn_date($group['formation_date']) ?></div>
                    </div>

                    <?php if ($group['group_description']): ?>
                        <div style="margin-top: 14px; padding: 12px; background: var(--gray-50); border-radius: 8px; text-align:left; font-size:13px; line-height:1.6;">
                            <?= nl2br(e($group['group_description'])) ?>
                        </div>
                    <?php endif; ?>

                    <?php if ($isMember && $myMembership && $myMembership['member_role'] !== 'leader'): ?>
                        <form method="POST" action="<?= BASE_URL ?>/farmer/groups/leave/<?= (int)$group['group_id'] ?>" style="margin-top: 16px;" onsubmit="return confirm('আপনি কি নিশ্চিত? গ্রুপ ত্যাগ করতে চান?');">
                            <?= Csrf::field() ?>
                            <button class="nav-pill-btn ghost" style="width:100%; justify-content:center; color:var(--danger);"><i class="bi bi-box-arrow-right"></i> গ্রুপ ত্যাগ করুন</button>
                        </form>
                    <?php elseif (!$isMember): ?>
                        <form method="POST" action="<?= BASE_URL ?>/farmer/groups/join/<?= (int)$group['group_id'] ?>" style="margin-top: 16px;">
                            <?= Csrf::field() ?>
                            <label style="display:block; font-size:12px; margin-bottom:4px; text-align:left;">আপনার ভূমির অবদান (একর)</label>
                            <input type="number" name="land_contribution_acres" step="0.01" min="0" value="0" style="width:100%; padding:9px 12px; border:1.5px solid var(--gray-200); border-radius:8px; box-sizing:border-box; margin-bottom: 8px;">
                            <button class="nav-pill-btn primary" style="width:100%; justify-content:center;"><i class="bi bi-person-plus"></i> এই গ্রুপে যোগ দিন</button>
                        </form>
                    <?php endif; ?>
                </div>
            </div>

            <div>
                <div class="dash-card">
                    <h3 style="margin:0 0 14px;"><i class="bi bi-people-fill"></i> সদস্য তালিকা (<?= bn_num(count($members)) ?>)</h3>
                    <?php if (empty($members)): ?>
                        <p style="text-align:center; color:var(--gray-500);">কোনো সদস্য নেই।</p>
                    <?php else: ?>
                    <div style="display:grid; grid-template-columns: repeat(auto-fill, minmax(250px,1fr)); gap: 10px;">
                        <?php foreach ($members as $m):
                            $rl = $roleLabels[$m['member_role']] ?? ['👤 সদস্য','info'];
                        ?>
                            <div style="display:flex; align-items:center; gap:10px; padding:12px; background:var(--gray-50); border-radius:10px;">
                                <div style="width:40px; height:40px; border-radius:50%; background: var(--grad-m1); color:#fff; display:flex; align-items:center; justify-content:center; font-weight:700; flex-shrink:0;"><?= e(mb_substr($m['full_name'], 0, 1, 'UTF-8')) ?></div>
                                <div style="flex:1; min-width:0;">
                                    <div style="display:flex; justify-content:space-between; align-items:center; gap:6px;">
                                        <strong style="font-size:13px;"><?= e($m['full_name']) ?></strong>
                                    </div>
                                    <div style="font-size:11px; color:var(--gray-500);"><?= e($m['phone']) ?></div>
                                    <div style="font-size:11px; color:var(--gray-500); margin-top: 2px;">
                                        <span class="badge badge-<?= $rl[1] ?>" style="font-size:9px;"><?= $rl[0] ?></span>
                                        • <?= bn_num($m['land_contribution_acres']) ?> একর
                                    </div>
                                </div>
                            </div>
                        <?php endforeach; ?>
                    </div>
                    <?php endif; ?>
                </div>
            </div>
        </div>
    </main>
</div>
</div>

<?php require __DIR__ . '/../../../includes/footer.php'; ?>
