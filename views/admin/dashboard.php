<?php require __DIR__ . '/../../includes/header.php'; ?>
<?php require __DIR__ . '/../../includes/navbar.php'; ?>

<div class="dash-page">
<div class="dash-shell">
    <?php require __DIR__ . '/../../includes/sidebar.php'; ?>

    <main class="dash-main">
        <div class="dash-header">
            <div>
                <div class="breadcrumb"><a href="<?= BASE_URL ?>/">হোম</a> <i class="bi bi-chevron-right" style="font-size:10px"></i> অ্যাডমিন ড্যাশবোর্ড</div>
                <h1>সিস্টেম ওভারভিউ ⚙️</h1>
            </div>
        </div>

        <div class="stat-grid">
            <div class="stat-tile tile-purple">
                <div class="st-label">মোট ব্যবহারকারী</div>
                <div class="st-value"><?= bn_num($stats['total_users']) ?></div>
                <div class="st-foot">কৃষক <?= bn_num($stats['total_farmers']) ?> • ক্রেতা <?= bn_num($stats['total_buyers']) ?> • এজেন্ট <?= bn_num($stats['total_agents']) ?></div>
                <div class="st-icon"><i class="bi bi-people-fill"></i></div>
            </div>
            <div class="stat-tile tile-orange">
                <div class="st-label">পেন্ডিং লোন</div>
                <div class="st-value"><?= bn_num($stats['pending_loans']) ?></div>
                <div class="st-foot">পর্যালোচনা প্রয়োজন</div>
                <div class="st-icon"><i class="bi bi-bank"></i></div>
            </div>
            <div class="stat-tile tile-green">
                <div class="st-label">আজকের বিক্রয়</div>
                <div class="st-value"><?= bdt($stats['today_revenue'], 0) ?></div>
                <div class="st-foot"><?= bn_num($stats['today_orders']) ?> টি অর্ডার</div>
                <div class="st-icon"><i class="bi bi-cash-coin"></i></div>
            </div>
            <div class="stat-tile tile-red">
                <div class="st-label">সিস্টেম সতর্কতা</div>
                <div class="st-value"><?= bn_num($stats['active_alerts'] + $stats['open_tickets']) ?></div>
                <div class="st-foot"><?= bn_num($stats['active_alerts']) ?> আবহাওয়া • <?= bn_num($stats['open_tickets']) ?> টিকেট</div>
                <div class="st-icon"><i class="bi bi-exclamation-triangle"></i></div>
            </div>
        </div>

        <div class="stat-grid">
            <div class="stat-tile tile-blue">
                <div class="st-label">সক্রিয় ফসল</div>
                <div class="st-value"><?= bn_num($stats['active_crops']) ?></div>
                <div class="st-foot">মার্কেটপ্লেসে উপলব্ধ</div>
                <div class="st-icon"><i class="bi bi-basket"></i></div>
            </div>
            <div class="stat-tile tile-orange">
                <div class="st-label">সক্রিয় লোন</div>
                <div class="st-value"><?= bn_num($stats['active_loans']) ?></div>
                <div class="st-foot">চলমান পোর্টফোলিও</div>
                <div class="st-icon"><i class="bi bi-graph-up"></i></div>
            </div>
            <div class="stat-tile tile-teal">
                <div class="st-label">মোট অর্ডার</div>
                <div class="st-value"><?= bn_num($stats['total_orders']) ?></div>
                <div class="st-foot">প্ল্যাটফর্ম জুড়ে</div>
                <div class="st-icon"><i class="bi bi-bag-check-fill"></i></div>
            </div>
            <div class="stat-tile tile-red">
                <div class="st-label">স্থগিত অ্যাকাউন্ট</div>
                <div class="st-value"><?= bn_num($stats['suspended_users']) ?></div>
                <div class="st-foot">যাচাইয়ের অপেক্ষায়</div>
                <div class="st-icon"><i class="bi bi-shield-exclamation"></i></div>
            </div>
        </div>

        <div class="two-col">
            <div>
                <div class="dash-card">
                    <div class="dash-card-header">
                        <h3><i class="bi bi-bank"></i> পেন্ডিং লোন আবেদন</h3>
                        <a href="<?= BASE_URL ?>/admin/loans" class="nav-pill-btn ghost">সব দেখুন →</a>
                    </div>
                    <?php if (empty($pendingLoans)): ?>
                        <p style="font-size:13px; color:var(--gray-500); text-align:center; padding:20px;">দারুণ! এই মুহূর্তে কোনো পেন্ডিং লোন নেই।</p>
                    <?php else: ?>
                    <table class="table">
                        <thead><tr><th>আবেদনকারী</th><th>পরিমাণ</th><th>উদ্দেশ্য</th><th>তারিখ</th></tr></thead>
                        <tbody>
                        <?php foreach ($pendingLoans as $l): ?>
                            <tr>
                                <td><?= e($l['farmer_name']) ?></td>
                                <td class="mono"><?= bdt($l['loan_amount'], 0) ?></td>
                                <td><?= e(mb_substr($l['loan_purpose'], 0, 30, 'UTF-8')) ?></td>
                                <td><?= bn_ago($l['application_date']) ?></td>
                            </tr>
                        <?php endforeach; ?>
                        </tbody>
                    </table>
                    <?php endif; ?>
                </div>

                <div class="dash-card">
                    <div class="dash-card-header">
                        <h3><i class="bi bi-clock-history"></i> সাম্প্রতিক অর্ডার</h3>
                        <a href="<?= BASE_URL ?>/admin/reports" class="nav-pill-btn ghost">রিপোর্ট দেখুন →</a>
                    </div>
                    <?php if (empty($recentOrders)): ?>
                        <p style="font-size:13px; color:var(--gray-500); text-align:center; padding:20px;">এখনো কোনো অর্ডার নেই।</p>
                    <?php else: ?>
                    <table class="table">
                        <thead><tr><th>অর্ডার</th><th>ক্রেতা</th><th>কৃষক</th><th>মূল্য</th><th>স্ট্যাটাস</th></tr></thead>
                        <tbody>
                        <?php foreach ($recentOrders as $o):
                            $stMap = ['pending'=>['warning','অপেক্ষমাণ'],'confirmed'=>['info','নিশ্চিত'],'packed'=>['info','প্যাক'],'shipped'=>['info','শিপিং'],'delivered'=>['success','সম্পন্ন'],'cancelled'=>['danger','বাতিল']];
                            $cls = $stMap[$o['order_status']][0] ?? 'neutral'; $lbl = $stMap[$o['order_status']][1] ?? $o['order_status'];
                        ?>
                            <tr>
                                <td class="mono" style="font-size:12px;"><?= e($o['order_number']) ?></td>
                                <td><?= e($o['buyer_name']) ?></td>
                                <td><?= e($o['farmer_name']) ?></td>
                                <td class="mono"><?= bdt($o['total_amount'], 0) ?></td>
                                <td><span class="badge badge-<?= $cls ?>"><?= $lbl ?></span></td>
                            </tr>
                        <?php endforeach; ?>
                        </tbody>
                    </table>
                    <?php endif; ?>
                </div>
            </div>

            <div>
                <div class="dash-card">
                    <h3 style="display:flex; align-items:center; gap:8px; margin-bottom:12px;">
                        <i class="bi bi-person-plus" style="color: var(--m1-primary);"></i> সাম্প্রতিক নিবন্ধন
                    </h3>
                    <?php if (empty($recentUsers)): ?>
                        <p style="font-size:13px; color:var(--gray-500);">নতুন নিবন্ধন নেই।</p>
                    <?php else: ?>
                        <?php foreach ($recentUsers as $u): ?>
                            <div style="display:flex; align-items:center; gap:10px; padding:8px 0; border-bottom:1px solid var(--gray-100);">
                                <div style="width:34px; height:34px; border-radius:50%; background:var(--grad-m1); color:#fff; display:flex; align-items:center; justify-content:center; font-weight:700; font-size:13px;"><?= e(mb_substr($u['full_name'], 0, 1, 'UTF-8')) ?></div>
                                <div style="flex:1; min-width:0;">
                                    <div style="font-weight:600; font-size:13px; color:var(--gray-900);"><?= e($u['full_name']) ?></div>
                                    <div style="font-size:11px; color:var(--gray-500);"><?= e($u['roles'] ?? '') ?> • <?= bn_ago($u['created_at']) ?></div>
                                </div>
                            </div>
                        <?php endforeach; ?>
                    <?php endif; ?>
                </div>

                <?php if (!empty($alerts)): ?>
                <div class="dash-card" style="border-left: 4px solid var(--warning);">
                    <h3 style="color: var(--warning-dark); display:flex; align-items:center; gap:8px; margin-bottom:12px;">
                        <i class="bi bi-cloud-rain-fill"></i> সক্রিয় আবহাওয়া সতর্কতা
                    </h3>
                    <?php foreach ($alerts as $a): ?>
                        <div style="padding:8px 0; border-bottom:1px solid var(--gray-100);">
                            <div style="font-weight:600; font-size:13px; color:var(--gray-900);"><?= e($a['alert_title']) ?></div>
                            <div style="font-size:11px; color:var(--gray-500); margin-top:2px;">তীব্রতা: <?= e($a['severity']) ?> • <?= bn_ago($a['created_at']) ?></div>
                        </div>
                    <?php endforeach; ?>
                </div>
                <?php endif; ?>

                <div class="dash-card">
                    <h3 style="display:flex; align-items:center; gap:8px; margin-bottom:12px;">
                        <i class="bi bi-lightning-fill" style="color: var(--m3-primary);"></i> দ্রুত কাজ
                    </h3>
                    <div style="display:flex; flex-direction:column; gap:8px;">
                        <a href="<?= BASE_URL ?>/admin/users" style="display:flex; align-items:center; gap:10px; padding:10px 12px; background:var(--gray-50); border-radius:10px; text-decoration:none; color:var(--gray-800);"><i class="bi bi-people-fill" style="color:var(--m4-primary)"></i> ব্যবহারকারী পরিচালনা</a>
                        <a href="<?= BASE_URL ?>/admin/loans" style="display:flex; align-items:center; gap:10px; padding:10px 12px; background:var(--gray-50); border-radius:10px; text-decoration:none; color:var(--gray-800);"><i class="bi bi-bank" style="color:var(--m3-primary)"></i> লোন অনুমোদন</a>
                        <a href="<?= BASE_URL ?>/admin/prices" style="display:flex; align-items:center; gap:10px; padding:10px 12px; background:var(--gray-50); border-radius:10px; text-decoration:none; color:var(--gray-800);"><i class="bi bi-tags" style="color:var(--m2-primary)"></i> মার্কেট প্রাইস আপডেট</a>
                        <a href="<?= BASE_URL ?>/admin/weather" style="display:flex; align-items:center; gap:10px; padding:10px 12px; background:var(--gray-50); border-radius:10px; text-decoration:none; color:var(--gray-800);"><i class="bi bi-cloud-rain" style="color:var(--m1-primary)"></i> আবহাওয়া সতর্কতা</a>
                    </div>
                </div>
            </div>
        </div>
    </main>
</div>
</div>

<?php require __DIR__ . '/../../includes/footer.php'; ?>
