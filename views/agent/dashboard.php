<?php require __DIR__ . '/../../includes/header.php'; ?>
<?php require __DIR__ . '/../../includes/navbar.php'; ?>

<div class="dash-page">
<div class="dash-shell">
    <?php require __DIR__ . '/../../includes/sidebar.php'; ?>

    <main class="dash-main">
        <div class="dash-header">
            <div>
                <div class="breadcrumb"><a href="<?= BASE_URL ?>/">হোম</a> <i class="bi bi-chevron-right" style="font-size:10px"></i> এজেন্ট ড্যাশবোর্ড</div>
                <h1>স্বাগতম, <?= e($_SESSION['name']) ?> 🤝</h1>
                <div style="font-size:13px; color:var(--gray-500); margin-top:4px;">এজেন্ট কোড: <span class="mono" style="color:var(--m3-primary); font-weight:600;"><?= e($stats['agent_code']) ?></span></div>
            </div>
            <div>
                <a href="<?= BASE_URL ?>/agent/register-farmer" class="nav-pill-btn primary" style="background:var(--m3-primary)"><i class="bi bi-person-plus"></i> কৃষক নিবন্ধন</a>
            </div>
        </div>

        <div class="stat-grid">
            <div class="stat-tile tile-orange">
                <div class="st-label">আমার কৃষকরা</div>
                <div class="st-value"><?= bn_num($stats['assigned_farmers']) ?></div>
                <div class="st-foot">সক্রিয় সদস্য</div>
                <div class="st-icon"><i class="bi bi-people-fill"></i></div>
            </div>
            <div class="stat-tile tile-green">
                <div class="st-label">এই মাসের কমিশন</div>
                <div class="st-value"><?= bdt($stats['this_month_commission'], 0) ?></div>
                <div class="st-foot">মোট আয় <?= bdt($stats['total_commission'], 0) ?></div>
                <div class="st-icon"><i class="bi bi-wallet2"></i></div>
            </div>
            <div class="stat-tile tile-blue">
                <div class="st-label">খোলা টিকেট</div>
                <div class="st-value"><?= bn_num($stats['open_tickets']) ?></div>
                <div class="st-foot">সহায়তা প্রয়োজন</div>
                <div class="st-icon"><i class="bi bi-life-preserver"></i></div>
            </div>
            <div class="stat-tile tile-purple">
                <div class="st-label">কার্যক্রম মোট</div>
                <div class="st-value"><?= bn_num($stats['activities_total']) ?></div>
                <div class="st-foot">রেটিং: <?= bn_num(number_format($stats['rating'], 1)) ?> ★</div>
                <div class="st-icon"><i class="bi bi-list-check"></i></div>
            </div>
        </div>

        <div class="two-col">
            <div>
                <div class="dash-card">
                    <div class="dash-card-header">
                        <h3><i class="bi bi-people"></i> আমার অ্যাসাইন করা কৃষকরা</h3>
                        <a href="<?= BASE_URL ?>/agent/farmers" class="nav-pill-btn ghost">সব দেখুন →</a>
                    </div>
                    <?php if (empty($assignedFarmers)): ?>
                        <div class="empty-state">
                            <i class="bi bi-people"></i>
                            <h4>কোনো কৃষক অ্যাসাইন হয়নি</h4>
                            <p>নতুন কৃষকদের নিবন্ধন করুন বা অ্যাডমিনের অপেক্ষায় থাকুন।</p>
                            <a href="<?= BASE_URL ?>/agent/register-farmer" class="nav-pill-btn primary" style="background:var(--m3-primary)">নতুন কৃষক নিবন্ধন</a>
                        </div>
                    <?php else: ?>
                    <div style="display:grid; gap:10px;">
                        <?php foreach ($assignedFarmers as $f): ?>
                        <div style="display:flex; align-items:center; gap:12px; padding:12px; border:1px solid var(--gray-100); border-radius:10px;">
                            <div style="width:42px; height:42px; border-radius:50%; background:var(--grad-m1); color:#fff; display:flex; align-items:center; justify-content:center; font-weight:700;"><?= e(mb_substr($f['full_name'], 0, 1, 'UTF-8')) ?></div>
                            <div style="flex:1; min-width:0;">
                                <div style="font-weight:600; color:var(--gray-900); font-size:14px;"><?= e($f['full_name']) ?></div>
                                <div style="font-size:12px; color:var(--gray-500);"><?= e($f['phone']) ?> • <?= e($f['district_name'] ?? '') ?></div>
                            </div>
                            <div style="font-size:11px; color:var(--gray-500); text-align:right;">
                                <?= bn_num($f['help_count']) ?> বার সাহায্য<br>
                                <?= $f['last_interaction'] ? bn_ago($f['last_interaction']) : 'নতুন' ?>
                            </div>
                        </div>
                        <?php endforeach; ?>
                    </div>
                    <?php endif; ?>
                </div>

                <div class="dash-card">
                    <div class="dash-card-header">
                        <h3><i class="bi bi-list-check"></i> সাম্প্রতিক কার্যক্রম</h3>
                    </div>
                    <?php if (empty($recentActivities)): ?>
                        <p style="font-size:13px; color:var(--gray-500); text-align:center; padding:20px;">এখনো কোনো কার্যক্রম রেকর্ড হয়নি।</p>
                    <?php else: ?>
                    <div style="display:flex; flex-direction:column; gap:0;">
                        <?php foreach ($recentActivities as $a):
                            $aMap = [
                                'farmer_registration'=>['person-plus','কৃষক নিবন্ধন','m1-primary'],
                                'crop_listing'=>['basket','ফসল লিস্টিং','m1-primary'],
                                'order_help'=>['bag-check','অর্ডার সহায়তা','m2-primary'],
                                'loan_assistance'=>['cash-stack','লোন সহায়তা','m3-primary'],
                                'message_help'=>['chat','বার্তা সহায়তা','m4-primary'],
                                'training_session'=>['mortarboard','প্রশিক্ষণ','m5-primary'],
                                'field_visit'=>['geo-alt','মাঠ পরিদর্শন','m1-dark'],
                                'other'=>['three-dots','অন্যান্য','gray-600'],
                            ];
                            $am = $aMap[$a['activity_type']] ?? ['three-dots','অন্যান্য','gray-600'];
                        ?>
                            <div style="display:flex; align-items:flex-start; gap:12px; padding:12px 0; border-bottom:1px solid var(--gray-100);">
                                <div style="width:34px; height:34px; border-radius:50%; background:var(--<?= $am[2] ?>)20; color: var(--<?= $am[2] ?>); display:flex; align-items:center; justify-content:center; flex-shrink:0;"><i class="bi bi-<?= $am[0] ?>"></i></div>
                                <div style="flex:1; min-width:0;">
                                    <div style="font-size:13px; color:var(--gray-900);"><strong><?= $am[1] ?></strong> <?= $a['farmer_name'] ? '— ' . e($a['farmer_name']) : '' ?></div>
                                    <div style="font-size:12px; color:var(--gray-500);"><?= e(mb_substr($a['description'] ?? '', 0, 80, 'UTF-8')) ?></div>
                                    <div style="font-size:11px; color:var(--gray-400); margin-top:2px;"><?= bn_ago($a['activity_date']) ?> • কমিশন: <?= bdt($a['commission_earned'], 0) ?></div>
                                </div>
                            </div>
                        <?php endforeach; ?>
                    </div>
                    <?php endif; ?>
                </div>
            </div>

            <div>
                <div class="dash-card" style="border-left: 4px solid var(--danger);">
                    <h3 style="color: var(--danger-dark); display:flex; align-items:center; gap:8px; margin-bottom:12px;">
                        <i class="bi bi-life-preserver"></i> খোলা সাপোর্ট টিকেট
                    </h3>
                    <?php if (empty($openTickets)): ?>
                        <p style="font-size:13px; color:var(--gray-500); margin:0;">দারুণ! এই মুহূর্তে কোনো খোলা টিকেট নেই।</p>
                    <?php else: ?>
                        <?php foreach ($openTickets as $t):
                            $pMap = ['low'=>'badge-neutral','medium'=>'badge-info','high'=>'badge-warning','urgent'=>'badge-danger'];
                            $pLabel = ['low'=>'কম','medium'=>'মাঝারি','high'=>'উচ্চ','urgent'=>'জরুরি'];
                        ?>
                            <div style="padding:10px 0; border-bottom:1px solid var(--gray-100);">
                                <div style="display:flex; justify-content:space-between; align-items:flex-start;">
                                    <div style="font-weight:600; font-size:13px; color:var(--gray-900);"><?= e($t['subject']) ?></div>
                                    <span class="badge <?= $pMap[$t['priority']] ?>" style="font-size:10px;"><?= $pLabel[$t['priority']] ?></span>
                                </div>
                                <div style="font-size:12px; color:var(--gray-500); margin-top:2px;"><?= e($t['farmer_name']) ?> • <?= bn_ago($t['created_at']) ?></div>
                            </div>
                        <?php endforeach; ?>
                    <?php endif; ?>
                </div>

                <div class="dash-card">
                    <h3 style="display:flex; align-items:center; gap:8px; margin-bottom:12px;">
                        <i class="bi bi-lightning-fill" style="color: var(--m3-primary);"></i> দ্রুত কাজ
                    </h3>
                    <div style="display:flex; flex-direction:column; gap:8px;">
                        <a href="<?= BASE_URL ?>/agent/register-farmer" style="display:flex; align-items:center; gap:10px; padding:10px 12px; background:var(--gray-50); border-radius:10px; text-decoration:none; color:var(--gray-800);"><i class="bi bi-person-plus" style="color:var(--m1-primary)"></i> নতুন কৃষক নিবন্ধন</a>
                        <a href="<?= BASE_URL ?>/agent/list-crop" style="display:flex; align-items:center; gap:10px; padding:10px 12px; background:var(--gray-50); border-radius:10px; text-decoration:none; color:var(--gray-800);"><i class="bi bi-basket" style="color:var(--m1-primary)"></i> ফসল লিস্ট করুন</a>
                        <a href="<?= BASE_URL ?>/agent/earnings" style="display:flex; align-items:center; gap:10px; padding:10px 12px; background:var(--gray-50); border-radius:10px; text-decoration:none; color:var(--gray-800);"><i class="bi bi-wallet2" style="color:var(--m3-primary)"></i> কমিশন বিবরণ</a>
                        <a href="<?= BASE_URL ?>/agent/activities" style="display:flex; align-items:center; gap:10px; padding:10px 12px; background:var(--gray-50); border-radius:10px; text-decoration:none; color:var(--gray-800);"><i class="bi bi-clipboard-data" style="color:var(--m2-primary)"></i> কার্যক্রম লগ</a>
                    </div>
                </div>
            </div>
        </div>
    </main>
</div>
</div>

<?php require __DIR__ . '/../../includes/footer.php'; ?>
