<?php require __DIR__ . '/../../../includes/header.php'; ?>
<?php require __DIR__ . '/../../../includes/navbar.php'; ?>

<div class="dash-page">
<div class="dash-shell">
    <?php require __DIR__ . '/../../../includes/sidebar.php'; ?>

    <main class="dash-main">
        <div class="dash-header">
            <div>
                <div class="breadcrumb"><a href="<?= BASE_URL ?>/agent/dashboard">ড্যাশবোর্ড</a> <i class="bi bi-chevron-right" style="font-size:10px"></i> আমার কৃষক</div>
                <h1>আমার কৃষক 👨‍🌾</h1>
            </div>
            <a href="<?= BASE_URL ?>/agent/farmers/register" class="nav-pill-btn primary" style="background:var(--m4-primary)"><i class="bi bi-person-plus"></i> নতুন কৃষক নিবন্ধন</a>
        </div>

        <div class="dash-card" style="background: linear-gradient(135deg, #f3e5f5, #fff); border-left: 4px solid var(--m4-primary);">
            <div style="display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:10px;">
                <div>
                    <strong>মোট এসাইন্ড কৃষক:</strong> <?= bn_num(count($farmers)) ?> জন <br>
                    <span style="font-size:13px; color:var(--gray-600);">এজেন্ট কোড: <strong><?= e($agent['agent_code']) ?></strong> • কমিশন রেট: <?= bn_num($agent['commission_rate']) ?>%</span>
                </div>
                <div>
                    <a href="<?= BASE_URL ?>/agent/crops" class="nav-pill-btn ghost"><i class="bi bi-basket"></i> ফসল লিস্ট করুন</a>
                    <a href="<?= BASE_URL ?>/agent/earnings" class="nav-pill-btn ghost"><i class="bi bi-wallet2"></i> কমিশন দেখুন</a>
                </div>
            </div>
        </div>

        <?php if (empty($farmers)): ?>
            <div class="dash-card">
                <div class="empty-state">
                    <i class="bi bi-people"></i>
                    <h4>এখনো কোনো কৃষক এসাইন্ড নেই</h4>
                    <p>নতুন কৃষক নিবন্ধন করুন এবং তাদের জন্য সেবা প্রদান শুরু করুন।</p>
                    <a href="<?= BASE_URL ?>/agent/farmers/register" class="nav-pill-btn primary" style="background:var(--m4-primary)"><i class="bi bi-person-plus"></i> প্রথম কৃষক নিবন্ধন করুন</a>
                </div>
            </div>
        <?php else: ?>
        <div style="display:grid; grid-template-columns: repeat(auto-fill, minmax(320px, 1fr)); gap: 14px;">
            <?php foreach ($farmers as $f): ?>
                <div class="dash-card" style="margin:0; padding:18px;">
                    <div style="display:flex; gap:14px; align-items:center; margin-bottom:12px;">
                        <div style="width:54px; height:54px; border-radius:50%; background: var(--grad-m1); color:#fff; display:flex; align-items:center; justify-content:center; font-weight:700; font-size:22px; flex-shrink:0;"><?= e(mb_substr($f['full_name'], 0, 1, 'UTF-8')) ?></div>
                        <div style="flex:1; min-width:0;">
                            <strong style="font-size:15px;"><?= e($f['full_name']) ?></strong>
                            <div style="font-size:12px; color:var(--gray-500);"><i class="bi bi-telephone"></i> <?= e($f['phone']) ?></div>
                            <?php if ($f['district_name']): ?>
                                <div style="font-size:12px; color:var(--gray-500);"><i class="bi bi-geo-alt"></i> <?= e($f['district_name']) ?></div>
                            <?php endif; ?>
                        </div>
                    </div>
                    <div style="display:grid; grid-template-columns: 1fr 1fr 1fr; gap:6px; font-size:12px; margin-bottom: 12px; padding: 10px; background: var(--gray-50); border-radius: 8px;">
                        <div style="text-align:center;">
                            <div style="font-weight:700; color:var(--m1-primary); font-size:16px;"><?= bn_num($f['crops_count']) ?></div>
                            <div style="color:var(--gray-500);">ফসল</div>
                        </div>
                        <div style="text-align:center;">
                            <div style="font-weight:700; color:var(--m2-primary); font-size:16px;"><?= bn_num($f['completed_orders']) ?></div>
                            <div style="color:var(--gray-500);">অর্ডার</div>
                        </div>
                        <div style="text-align:center;">
                            <div style="font-weight:700; color:var(--m4-primary); font-size:16px;"><?= bn_num($f['help_count']) ?></div>
                            <div style="color:var(--gray-500);">সহায়তা</div>
                        </div>
                    </div>
                    <div style="display:flex; gap:6px;">
                        <a href="<?= BASE_URL ?>/agent/farmers/detail/<?= (int)$f['user_id'] ?>" class="nav-pill-btn ghost" style="flex:1; justify-content:center; font-size:12px;"><i class="bi bi-person-vcard"></i> বিস্তারিত</a>
                        <a href="<?= BASE_URL ?>/agent/messages/with/<?= (int)$f['user_id'] ?>" class="nav-pill-btn ghost" style="font-size:12px;"><i class="bi bi-chat-dots"></i></a>
                    </div>
                    <div style="font-size:11px; color:var(--gray-400); margin-top:8px; text-align:right;">এসাইন্ড: <?= bn_date($f['assigned_date']) ?></div>
                </div>
            <?php endforeach; ?>
        </div>
        <?php endif; ?>
    </main>
</div>
</div>

<?php require __DIR__ . '/../../../includes/footer.php'; ?>
