<?php require __DIR__ . '/../../includes/header.php'; ?>
<?php require __DIR__ . '/../../includes/navbar.php'; ?>

<div class="dash-page">
<div class="dash-shell">
    <?php require __DIR__ . '/../../includes/sidebar.php'; ?>

    <main class="dash-main">
        <div class="dash-header">
            <div>
                <div class="breadcrumb"><a href="<?= BASE_URL ?>/">হোম</a> <i class="bi bi-chevron-right" style="font-size:10px"></i> কৃষক ড্যাশবোর্ড</div>
                <h1>স্বাগতম, <?= e($_SESSION['name']) ?> 🌾</h1>
            </div>
            <div>
                <a href="<?= BASE_URL ?>/farmer/crops/add" class="nav-pill-btn primary"><i class="bi bi-plus-lg"></i> নতুন ফসল যোগ করুন</a>
            </div>
        </div>

        <!-- Stat Cards -->
        <div class="stat-grid">
            <div class="stat-tile tile-green">
                <div class="st-label">সক্রিয় ফসল লিস্ট</div>
                <div class="st-value"><?= bn_num($stats['active_crops']) ?></div>
                <div class="st-foot"><i class="bi bi-basket"></i> মোট <?= bn_num($stats['total_crops']) ?> টি</div>
                <div class="st-icon"><i class="bi bi-basket-fill"></i></div>
            </div>
            <div class="stat-tile tile-blue">
                <div class="st-label">এই মাসের বিক্রয়</div>
                <div class="st-value"><?= bdt($stats['this_month_revenue'], 0) ?></div>
                <div class="st-foot"><i class="bi bi-arrow-up-right"></i> মোট <?= bdt($stats['total_revenue'], 0) ?></div>
                <div class="st-icon"><i class="bi bi-cash-coin"></i></div>
            </div>
            <div class="stat-tile tile-orange">
                <div class="st-label">পেন্ডিং অর্ডার</div>
                <div class="st-value"><?= bn_num($stats['pending_orders']) ?></div>
                <div class="st-foot"><i class="bi bi-bag-check"></i> ডেলিভারি বাকি</div>
                <div class="st-icon"><i class="bi bi-bag-check-fill"></i></div>
            </div>
            <div class="stat-tile tile-purple">
                <div class="st-label">গড় রেটিং</div>
                <div class="st-value">
                    <?= bn_num(number_format($stats['avg_rating'], 1)) ?>
                    <span style="font-size:16px; color: var(--warning);"><i class="bi bi-star-fill"></i></span>
                </div>
                <div class="st-foot"><?= bn_num($stats['total_ratings']) ?> জন ক্রেতা থেকে</div>
                <div class="st-icon"><i class="bi bi-shield-check"></i></div>
            </div>
        </div>

        <!-- Secondary stats -->
        <div class="stat-grid">
            <a href="<?= BASE_URL ?>/farmer/wallet" class="stat-tile tile-teal" style="text-decoration:none; color:inherit;">
                <div class="st-label">ওয়ালেট ব্যালেন্স</div>
                <div class="st-value"><?= bdt($stats['wallet_balance'], 0) ?></div>
                <div class="st-foot">ক্লিক করে বিস্তারিত দেখুন</div>
                <div class="st-icon"><i class="bi bi-wallet2"></i></div>
            </a>
            <div class="stat-tile tile-orange">
                <div class="st-label">সক্রিয় লোন</div>
                <div class="st-value"><?= bn_num($stats['active_loans']) ?></div>
                <div class="st-foot">বকেয়া <?= bdt($stats['total_loan_balance'], 0) ?></div>
                <div class="st-icon"><i class="bi bi-bank"></i></div>
            </div>
            <div class="stat-tile tile-blue">
                <div class="st-label">নতুন বার্তা</div>
                <div class="st-value"><?= bn_num($stats['unread_messages']) ?></div>
                <div class="st-foot">পঠনযোগ্য নয়</div>
                <div class="st-icon"><i class="bi bi-chat-dots"></i></div>
            </div>
            <div class="stat-tile tile-purple">
                <div class="st-label">বিজ্ঞপ্তি</div>
                <div class="st-value"><?= bn_num($stats['unread_notifications']) ?></div>
                <div class="st-foot">নতুন আপডেট</div>
                <div class="st-icon"><i class="bi bi-bell"></i></div>
            </div>
        </div>

        <div class="two-col">
            <!-- Left: Active crops + recent orders -->
            <div>
                <div class="dash-card">
                    <div class="dash-card-header">
                        <h3><i class="bi bi-basket"></i> আপনার সক্রিয় ফসল</h3>
                        <a href="<?= BASE_URL ?>/farmer/crops" class="nav-pill-btn ghost">সব দেখুন →</a>
                    </div>
                    <?php if (empty($activeCrops)): ?>
                        <div class="empty-state">
                            <i class="bi bi-basket"></i>
                            <h4>এখনো কোনো ফসল লিস্ট করা হয়নি</h4>
                            <p>প্রথম ফসল যোগ করে মার্কেটপ্লেসে বিক্রি শুরু করুন।</p>
                            <a href="<?= BASE_URL ?>/farmer/crops/add" class="nav-pill-btn primary"><i class="bi bi-plus-lg"></i> ফসল যোগ করুন</a>
                        </div>
                    <?php else: ?>
                        <div style="display:grid; grid-template-columns: repeat(2, 1fr); gap: 12px;">
                            <?php foreach ($activeCrops as $c):
                                $cropImg = first_image_variant($c['images'] ?? null, 'thumb');
                            ?>
                                <div style="display:flex; align-items:center; gap:12px; padding:12px; border:1px solid var(--gray-100); border-radius:10px;">
                                    <div style="width:48px; height:48px; border-radius:8px; background:#f1f8e9; display:flex; align-items:center; justify-content:center; font-size:24px; overflow:hidden; flex-shrink:0;">
                                        <?php if (!empty($cropImg)): ?>
                                            <img src="<?= e($cropImg) ?>" alt="<?= e($c['crop_name']) ?>"
                                                 style="width:100%; height:100%; object-fit:cover;"
                                                 onerror="this.parentElement.innerHTML='🌾';">
                                        <?php else: ?>
                                            🌾
                                        <?php endif; ?>
                                    </div>
                                    <div style="flex:1; min-width:0;">
                                        <div style="font-weight:700; color:var(--gray-900); font-size:14px;"><?= e($c['crop_name']) ?></div>
                                        <div style="font-size:12px; color:var(--gray-500);"><?= e($c['category_name_bn']) ?> • <?= bn_num($c['quantity']) ?> <?= e($c['unit']) ?></div>
                                    </div>
                                    <div style="font-weight:700; color:var(--m1-primary); font-size:13px; font-family: var(--font-bn);"><?= bdt($c['price_per_unit'], 0) ?></div>
                                </div>
                            <?php endforeach; ?>
                        </div>
                    <?php endif; ?>
                </div>

                <div class="dash-card">
                    <div class="dash-card-header">
                        <h3><i class="bi bi-clock-history"></i> সাম্প্রতিক অর্ডার</h3>
                        <a href="<?= BASE_URL ?>/farmer/orders" class="nav-pill-btn ghost">সব দেখুন →</a>
                    </div>
                    <?php if (empty($recentOrders)): ?>
                        <div class="empty-state">
                            <i class="bi bi-bag"></i>
                            <h4>এখনো কোনো অর্ডার আসেনি</h4>
                            <p>আপনার ফসলগুলো মার্কেটপ্লেসে দৃশ্যমান হলে ক্রেতারা অর্ডার করবেন।</p>
                        </div>
                    <?php else: ?>
                    <div style="overflow-x:auto;">
                    <table class="table">
                        <thead>
                            <tr>
                                <th>অর্ডার নম্বর</th><th>ক্রেতা</th><th>ফসল</th>
                                <th>পরিমাণ</th><th>মূল্য</th><th>স্ট্যাটাস</th>
                            </tr>
                        </thead>
                        <tbody>
                        <?php foreach ($recentOrders as $o):
                            $st = $o['order_status'];
                            $stMap = ['pending'=>['warning','অপেক্ষমাণ'],'confirmed'=>['info','নিশ্চিত'],'packed'=>['info','প্যাক'],'shipped'=>['info','শিপিং'],'delivered'=>['success','সম্পন্ন'],'cancelled'=>['danger','বাতিল']];
                            $cls = $stMap[$st][0] ?? 'neutral'; $lbl = $stMap[$st][1] ?? $st;
                        ?>
                            <tr>
                                <td class="mono"><?= e($o['order_number']) ?></td>
                                <td><?= e($o['buyer_name']) ?></td>
                                <td><?= e($o['crop_name']) ?></td>
                                <td><?= bn_num($o['quantity_ordered']) ?></td>
                                <td class="mono"><?= bdt($o['total_amount'], 0) ?></td>
                                <td><span class="badge badge-<?= $cls ?>"><?= $lbl ?></span></td>
                            </tr>
                        <?php endforeach; ?>
                        </tbody>
                    </table>
                    </div>
                    <?php endif; ?>
                </div>
            </div>

            <!-- Right: weather + recommendations -->
            <div>
                <?php if ($weatherAlert): ?>
                <div class="dash-card" style="border-left: 4px solid var(--warning);">
                    <h3 style="color: var(--warning-dark); display:flex; align-items:center; gap:8px; margin-bottom:12px;">
                        <i class="bi bi-cloud-rain-fill"></i> আবহাওয়া সতর্কতা
                    </h3>
                    <div style="font-weight:700; font-size:14px; color:var(--gray-900); margin-bottom:6px;"><?= e($weatherAlert['alert_title']) ?></div>
                    <div style="font-size:13px; color:var(--gray-600); line-height:1.6;"><?= e(mb_substr($weatherAlert['alert_message'], 0, 140, 'UTF-8')) ?></div>
                    <a href="<?= BASE_URL ?>/farmer/weather" class="nav-pill-btn ghost" style="margin-top:12px; font-size:13px;">বিস্তারিত →</a>
                </div>
                <?php else: ?>
                <div class="dash-card">
                    <h3 style="display:flex; align-items:center; gap:8px; margin-bottom:12px;">
                        <i class="bi bi-cloud-sun-fill" style="color: var(--info);"></i> আবহাওয়া
                    </h3>
                    <div style="text-align:center; padding:16px 0;">
                        <div style="font-size:48px;">☀️</div>
                        <div style="font-size:14px; color:var(--gray-600); margin-top:8px;">আজ আপনার এলাকার জন্য কোনো সতর্কতা নেই।</div>
                    </div>
                </div>
                <?php endif; ?>

                <div class="dash-card" style="border-left: 4px solid var(--m4-primary);">
                    <h3 style="color: var(--m4-dark); display:flex; align-items:center; gap:8px; margin-bottom:12px;">
                        <i class="bi bi-cpu-fill"></i> AI ফসল সুপারিশ
                    </h3>
                    <?php if (empty($recommendations)): ?>
                        <p style="font-size:13px; color:var(--gray-500); margin:0;">আপনার এলাকার জন্য এখনো কোনো নির্দিষ্ট সুপারিশ নেই। মৌসুম পরিবর্তনের সাথে নতুন সুপারিশ আসবে।</p>
                    <?php else: ?>
                        <?php foreach ($recommendations as $r): ?>
                            <div style="padding:10px 0; border-bottom:1px solid var(--gray-100);">
                                <div style="display:flex; justify-content:space-between; align-items:center;">
                                    <div style="font-weight:600; font-size:14px; color:var(--gray-900);">🌱 <?= e($r['recommended_crop']) ?></div>
                                    <span class="badge badge-success" style="font-size:11px;"><?= bn_num((int)$r['recommendation_score']) ?>% মিল</span>
                                </div>
                                <div style="font-size:12px; color:var(--gray-500); margin-top:4px;">প্রত্যাশিত মুনাফা: <?= bn_num((int)$r['expected_profit_margin']) ?>% • <?= e($r['difficulty_level']) === 'easy' ? 'সহজ' : (e($r['difficulty_level']) === 'medium' ? 'মাঝারি' : 'কঠিন') ?></div>
                            </div>
                        <?php endforeach; ?>
                    <?php endif; ?>
                </div>

                <div class="dash-card">
                    <h3 style="display:flex; align-items:center; gap:8px; margin-bottom:12px;">
                        <i class="bi bi-lightning-fill" style="color: var(--m3-primary);"></i> দ্রুত কাজ
                    </h3>
                    <div style="display:flex; flex-direction:column; gap:8px;">
                        <a href="<?= BASE_URL ?>/farmer/crops/add" style="display:flex; align-items:center; gap:10px; padding:10px 12px; background:var(--gray-50); border-radius:10px; text-decoration:none; color:var(--gray-800);"><i class="bi bi-plus-circle" style="color:var(--m1-primary)"></i> নতুন ফসল লিস্ট করুন</a>
                        <a href="<?= BASE_URL ?>/farmer/loans/apply" style="display:flex; align-items:center; gap:10px; padding:10px 12px; background:var(--gray-50); border-radius:10px; text-decoration:none; color:var(--gray-800);"><i class="bi bi-cash-stack" style="color:var(--m3-primary)"></i> লোনের জন্য আবেদন</a>
                        <a href="<?= BASE_URL ?>/farmer/expenses/add" style="display:flex; align-items:center; gap:10px; padding:10px 12px; background:var(--gray-50); border-radius:10px; text-decoration:none; color:var(--gray-800);"><i class="bi bi-receipt" style="color:var(--m2-primary)"></i> খরচ রেকর্ড করুন</a>
                        <a href="<?= BASE_URL ?>/farmer/assistant" style="display:flex; align-items:center; gap:10px; padding:10px 12px; background:var(--gray-50); border-radius:10px; text-decoration:none; color:var(--gray-800);"><i class="bi bi-robot" style="color:var(--m4-primary)"></i> স্মার্ট অ্যাসিস্ট্যান্ট</a>
                    </div>
                </div>
            </div>
        </div>
    </main>
</div>
</div>

<?php require __DIR__ . '/../../includes/footer.php'; ?>
