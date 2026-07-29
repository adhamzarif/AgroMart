<?php require __DIR__ . '/../../includes/header.php'; ?>
<?php require __DIR__ . '/../../includes/navbar.php'; ?>

<div class="dash-page">
<div class="dash-shell">
    <?php require __DIR__ . '/../../includes/sidebar.php'; ?>

    <main class="dash-main">
        <div class="dash-header">
            <div>
                <div class="breadcrumb"><a href="<?= BASE_URL ?>/">হোম</a> <i class="bi bi-chevron-right" style="font-size:10px"></i> ক্রেতা ড্যাশবোর্ড</div>
                <h1>স্বাগতম, <?= e($_SESSION['name']) ?> 🛒</h1>
            </div>
            <div>
                <a href="<?= BASE_URL ?>/buyer/browse" class="nav-pill-btn primary"><i class="bi bi-search"></i> ফসল খুঁজুন</a>
            </div>
        </div>

        <div class="stat-grid">
            <div class="stat-tile tile-blue">
                <div class="st-label">মোট অর্ডার</div>
                <div class="st-value"><?= bn_num($stats['total_orders']) ?></div>
                <div class="st-foot"><?= bn_num($stats['delivered_orders']) ?> টি সম্পন্ন</div>
                <div class="st-icon"><i class="bi bi-bag-check-fill"></i></div>
            </div>
            <div class="stat-tile tile-purple">
                <div class="st-label">এই মাসের খরচ</div>
                <div class="st-value"><?= bdt($stats['this_month_spent'], 0) ?></div>
                <div class="st-foot">মোট খরচ <?= bdt($stats['total_spent'], 0) ?></div>
                <div class="st-icon"><i class="bi bi-cash-stack"></i></div>
            </div>
            <div class="stat-tile tile-orange">
                <div class="st-label">চলমান অর্ডার</div>
                <div class="st-value"><?= bn_num($stats['pending_orders']) ?></div>
                <div class="st-foot">ডেলিভারির অপেক্ষায়</div>
                <div class="st-icon"><i class="bi bi-truck"></i></div>
            </div>
            <div class="stat-tile tile-teal">
                <div class="st-label">প্রিয় তালিকা</div>
                <div class="st-value"><?= bn_num($stats['favorite_crops']) ?></div>
                <div class="st-foot"><?= bn_num($stats['favorite_farmers']) ?> জন প্রিয় কৃষক</div>
                <div class="st-icon"><i class="bi bi-heart-fill"></i></div>
            </div>
        </div>

        <div class="two-col">
            <div>
                <div class="dash-card">
                    <div class="dash-card-header">
                        <h3><i class="bi bi-clock-history"></i> সাম্প্রতিক অর্ডার</h3>
                        <a href="<?= BASE_URL ?>/buyer/orders" class="nav-pill-btn ghost">সব দেখুন →</a>
                    </div>
                    <?php if (empty($recentOrders)): ?>
                        <div class="empty-state">
                            <i class="bi bi-bag"></i>
                            <h4>এখনো কোনো অর্ডার করেননি</h4>
                            <p>মার্কেটপ্লেস থেকে ফসল ব্রাউজ করে অর্ডার দিন।</p>
                            <a href="<?= BASE_URL ?>/buyer/browse" class="nav-pill-btn primary">ফসল ব্রাউজ করুন</a>
                        </div>
                    <?php else: ?>
                    <div style="overflow-x:auto;">
                    <table class="table">
                        <thead><tr><th>অর্ডার</th><th>কৃষক</th><th>ফসল</th><th>মূল্য</th><th>স্ট্যাটাস</th></tr></thead>
                        <tbody>
                        <?php foreach ($recentOrders as $o):
                            $st = $o['order_status'];
                            $stMap = ['pending'=>['warning','অপেক্ষমাণ'],'confirmed'=>['info','নিশ্চিত'],'packed'=>['info','প্যাক'],'shipped'=>['info','শিপিং'],'delivered'=>['success','সম্পন্ন'],'cancelled'=>['danger','বাতিল']];
                            $cls = $stMap[$st][0] ?? 'neutral'; $lbl = $stMap[$st][1] ?? $st;
                        ?>
                            <tr>
                                <td class="mono"><?= e($o['order_number']) ?></td>
                                <td><?= e($o['farmer_name']) ?><br><span style="font-size:11px; color:var(--gray-500);"><?= e($o['district_name'] ?? '') ?></span></td>
                                <td><?= e($o['crop_name']) ?></td>
                                <td class="mono"><?= bdt($o['total_amount'], 0) ?></td>
                                <td><span class="badge badge-<?= $cls ?>"><?= $lbl ?></span></td>
                            </tr>
                        <?php endforeach; ?>
                        </tbody>
                    </table>
                    </div>
                    <?php endif; ?>
                </div>

                <div class="dash-card">
                    <div class="dash-card-header">
                        <h3><i class="bi bi-star-fill" style="color:var(--m3-primary)"></i> বাছাই করা ফসল</h3>
                        <a href="<?= BASE_URL ?>/buyer/browse" class="nav-pill-btn ghost">সব দেখুন →</a>
                    </div>
                    <?php if (empty($featured)): ?>
                        <p style="color:var(--gray-500); font-size:14px; text-align:center; padding:20px;">এই মুহূর্তে কোনো ফসল উপলব্ধ নেই।</p>
                    <?php else: ?>
                    <div style="display:grid; grid-template-columns: repeat(auto-fill, minmax(220px, 1fr)); gap: 14px;">
                        <?php foreach ($featured as $c):
                            $img = first_image_variant($c['images'] ?? null, 'medium');
                            if (empty($img)) $img = 'https://images.unsplash.com/photo-1599599810694-b5ac4dd33c1f?w=500&q=80';
                        ?>
                        <div style="border:1px solid var(--gray-100); border-radius:12px; padding:14px; transition:all 0.2s;" onmouseover="this.style.boxShadow='0 6px 18px rgba(0,0,0,0.08)'" onmouseout="this.style.boxShadow='none'">
                            <div style="height:140px; background:var(--gray-50); border-radius:8px; overflow:hidden; margin-bottom:10px;">
                                <img src="<?= e($img) ?>" alt="<?= e($c['crop_name']) ?>"
                                     style="width:100%; height:100%; object-fit:cover;"
                                     onerror="this.src='https://images.unsplash.com/photo-1599599810694-b5ac4dd33c1f?w=500&q=80'">
                            </div>
                            <div style="font-weight:700; color:var(--gray-900); font-size:14px;"><?= e($c['crop_name']) ?></div>
                            <div style="font-size:11px; color:var(--gray-500); margin:2px 0;"><?= e($c['farmer_name']) ?> • <?= e($c['district_name'] ?? '') ?></div>
                            <div style="display:flex; justify-content:space-between; align-items:center; margin-top:8px;">
                                <span style="font-weight:700; color:var(--m1-primary); font-size:14px;"><?= bdt($c['price_per_unit'], 0) ?>/<?= e($c['unit']) ?></span>
                                <a href="<?= BASE_URL ?>/buyer/crop/<?= (int)$c['crop_id'] ?>" style="font-size:12px; color:var(--m1-primary); text-decoration:none; font-weight:600;">দেখুন →</a>
                            </div>
                        </div>
                        <?php endforeach; ?>
                    </div>
                    <?php endif; ?>
                </div>
            </div>

            <div>
                <div class="dash-card" style="border-left: 4px solid var(--m1-primary);">
                    <h3 style="display:flex; align-items:center; gap:8px; margin-bottom:12px;">
                        <i class="bi bi-heart-fill" style="color: var(--danger);"></i> প্রিয় ফসল
                    </h3>
                    <?php if (empty($favorites)): ?>
                        <p style="font-size:13px; color:var(--gray-500); margin:0;">এখনো প্রিয় তালিকায় কোনো ফসল নেই।</p>
                    <?php else: ?>
                        <?php foreach ($favorites as $f): ?>
                            <div style="display:flex; justify-content:space-between; align-items:center; padding:8px 0; border-bottom:1px solid var(--gray-100);">
                                <div>
                                    <div style="font-weight:600; font-size:13px; color:var(--gray-900);"><?= e($f['crop_name'] ?? 'মুছে ফেলা') ?></div>
                                    <div style="font-size:11px; color:var(--gray-500);"><?= bdt($f['price_per_unit'] ?? 0, 0) ?>/<?= e($f['unit'] ?? '') ?></div>
                                </div>
                            </div>
                        <?php endforeach; ?>
                        <a href="<?= BASE_URL ?>/buyer/favorites" class="nav-pill-btn ghost" style="margin-top:12px; font-size:13px; width:100%;">সব প্রিয় তালিকা →</a>
                    <?php endif; ?>
                </div>

                <div class="dash-card">
                    <h3 style="display:flex; align-items:center; gap:8px; margin-bottom:12px;">
                        <i class="bi bi-lightning-fill" style="color: var(--m3-primary);"></i> দ্রুত কাজ
                    </h3>
                    <div style="display:flex; flex-direction:column; gap:8px;">
                        <a href="<?= BASE_URL ?>/buyer/browse" style="display:flex; align-items:center; gap:10px; padding:10px 12px; background:var(--gray-50); border-radius:10px; text-decoration:none; color:var(--gray-800);"><i class="bi bi-search" style="color:var(--m1-primary)"></i> ফসল ব্রাউজ করুন</a>
                        <a href="<?= BASE_URL ?>/buyer/orders" style="display:flex; align-items:center; gap:10px; padding:10px 12px; background:var(--gray-50); border-radius:10px; text-decoration:none; color:var(--gray-800);"><i class="bi bi-truck" style="color:var(--m3-primary)"></i> অর্ডার ট্র্যাক করুন</a>
                        <a href="<?= BASE_URL ?>/buyer/subscriptions" style="display:flex; align-items:center; gap:10px; padding:10px 12px; background:var(--gray-50); border-radius:10px; text-decoration:none; color:var(--gray-800);"><i class="bi bi-arrow-repeat" style="color:var(--m4-primary)"></i> সাবস্ক্রিপশন</a>
                        <a href="<?= BASE_URL ?>/liveprice" style="display:flex; align-items:center; gap:10px; padding:10px 12px; background:var(--gray-50); border-radius:10px; text-decoration:none; color:var(--gray-800);"><i class="bi bi-graph-up" style="color:var(--m2-primary)"></i> লাইভ মূল্য</a>
                    </div>
                </div>
            </div>
        </div>
    </main>
</div>
</div>

<?php require __DIR__ . '/../../includes/footer.php'; ?>
