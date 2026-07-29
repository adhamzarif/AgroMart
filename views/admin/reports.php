<?php require __DIR__ . '/../../includes/header.php'; ?>
<?php require __DIR__ . '/../../includes/navbar.php'; ?>

<?php
$roleLabels = ['farmer'=>'👨‍🌾 কৃষক','buyer'=>'🛒 ক্রেতা','agent'=>'🤝 এজেন্ট','admin'=>'👑 অ্যাডমিন'];

// Find max for bar normalization
$catMax = !empty($topCategories) ? max(array_map(fn($r) => (float)$r['gmv'], $topCategories)) : 0;
?>

<div class="dash-page">
<div class="dash-shell">
    <?php require __DIR__ . '/../../includes/sidebar.php'; ?>

    <main class="dash-main">
        <div class="dash-header">
            <div>
                <div class="breadcrumb"><a href="<?= BASE_URL ?>/admin/dashboard">ড্যাশবোর্ড</a> <i class="bi bi-chevron-right" style="font-size:10px"></i> রিপোর্ট</div>
                <h1>রিপোর্ট ও অ্যানালিটিক্স 📊</h1>
            </div>
        </div>

        <div class="dash-card" style="padding: 14px 20px;">
            <form method="GET" style="display:flex; gap:12px; align-items:end; flex-wrap:wrap;">
                <div>
                    <label style="display:block; font-size:12px; font-weight:600; margin-bottom:4px;">শুরুর তারিখ</label>
                    <input type="date" name="from" value="<?= e($from) ?>" style="padding:9px 12px; border:1.5px solid var(--gray-200); border-radius:8px;">
                </div>
                <div>
                    <label style="display:block; font-size:12px; font-weight:600; margin-bottom:4px;">শেষ তারিখ</label>
                    <input type="date" name="to" value="<?= e($to) ?>" style="padding:9px 12px; border:1.5px solid var(--gray-200); border-radius:8px;">
                </div>
                <button type="submit" class="nav-pill-btn primary" style="background:var(--m4-primary)"><i class="bi bi-funnel"></i> রিপোর্ট তৈরি করুন</button>
                <span style="font-size:12px; color:var(--gray-500);">সময়কাল: <strong><?= bn_date($from) ?></strong> — <strong><?= bn_date($to) ?></strong></span>
            </form>
        </div>

        <!-- Order Stats -->
        <div class="stat-grid">
            <div class="stat-tile tile-purple">
                <div class="st-label">মোট অর্ডার</div>
                <div class="st-value"><?= bn_num($orderStats['order_count']) ?></div>
                <div class="st-foot"><?= bn_num($orderStats['delivered_count']) ?> সম্পন্ন</div>
                <div class="st-icon"><i class="bi bi-bag"></i></div>
            </div>
            <div class="stat-tile tile-green">
                <div class="st-label">মোট বিক্রি (GMV)</div>
                <div class="st-value" style="font-size: 18px;"><?= bdt($orderStats['gmv'], 0) ?></div>
                <div class="st-foot">সম্পন্ন: <?= bdt($orderStats['delivered_gmv'], 0) ?></div>
                <div class="st-icon"><i class="bi bi-cash-stack"></i></div>
            </div>
            <div class="stat-tile tile-red">
                <div class="st-label">বাতিল</div>
                <div class="st-value"><?= bn_num($orderStats['cancelled_count']) ?></div>
                <div class="st-foot"><?= $orderStats['order_count'] > 0 ? bn_num(number_format(($orderStats['cancelled_count'] / max($orderStats['order_count'], 1)) * 100, 1)) : 0 ?>% হার</div>
                <div class="st-icon"><i class="bi bi-x-circle"></i></div>
            </div>
            <div class="stat-tile tile-orange">
                <div class="st-label">গড় অর্ডার মূল্য</div>
                <div class="st-value" style="font-size: 18px;"><?= bdt($orderStats['order_count'] > 0 ? $orderStats['gmv'] / $orderStats['order_count'] : 0, 0) ?></div>
                <div class="st-foot">প্রতি অর্ডার</div>
                <div class="st-icon"><i class="bi bi-calculator"></i></div>
            </div>
        </div>

        <!-- User Growth + Top Categories -->
        <div style="display:grid; grid-template-columns: 1fr 1.5fr; gap: 20px;">
            <div class="dash-card">
                <h3 style="margin:0 0 14px;"><i class="bi bi-people"></i> নতুন ব্যবহারকারী (ভূমিকা অনুযায়ী)</h3>
                <?php if (empty($userGrowth)): ?>
                    <p style="color:var(--gray-500); text-align:center; padding: 14px;">এই সময়ে কোনো নতুন ব্যবহারকারী নেই।</p>
                <?php else:
                    $total = array_sum(array_column($userGrowth, 'cnt'));
                ?>
                    <?php foreach ($userGrowth as $g):
                        $pct = $total > 0 ? ($g['cnt'] / $total) * 100 : 0;
                    ?>
                        <div style="margin-bottom: 12px;">
                            <div style="display:flex; justify-content:space-between; font-size:13px; margin-bottom:4px;">
                                <span><?= $roleLabels[$g['role']] ?? $g['role'] ?></span>
                                <strong><?= bn_num($g['cnt']) ?> জন</strong>
                            </div>
                            <div style="height:12px; background:var(--gray-100); border-radius:6px; overflow:hidden;">
                                <div style="height:100%; background: var(--grad-m4); width: <?= $pct ?>%; transition: width 0.5s;"></div>
                            </div>
                        </div>
                    <?php endforeach; ?>
                    <div style="margin-top: 14px; padding-top: 14px; border-top: 1px solid var(--gray-100); font-size:13px;">
                        মোট নতুন ব্যবহারকারী: <strong style="color:var(--m1-primary); font-size:18px;"><?= bn_num($total) ?></strong>
                    </div>
                <?php endif; ?>
            </div>

            <div class="dash-card">
                <h3 style="margin:0 0 14px;"><i class="bi bi-pie-chart"></i> জনপ্রিয় ক্যাটাগরি (GMV)</h3>
                <?php if (empty($topCategories)): ?>
                    <p style="color:var(--gray-500); text-align:center; padding: 14px;">এই সময়ে কোনো সম্পন্ন অর্ডার নেই।</p>
                <?php else: foreach ($topCategories as $c):
                    $w = $catMax > 0 ? ($c['gmv'] / $catMax) * 100 : 0;
                ?>
                    <div style="margin-bottom: 12px;">
                        <div style="display:flex; justify-content:space-between; font-size:13px; margin-bottom:4px;">
                            <span><strong><?= e($c['category_name_bn']) ?></strong> <span style="color:var(--gray-500); font-size:11px;">(<?= bn_num($c['order_count']) ?> অর্ডার)</span></span>
                            <strong style="font-family:var(--font-bn); color:var(--m1-primary);"><?= bdt($c['gmv'], 0) ?></strong>
                        </div>
                        <div style="height:12px; background:var(--gray-100); border-radius:6px; overflow:hidden;">
                            <div style="height:100%; background: var(--grad-m1); width: <?= $w ?>%; transition: width 0.5s;"></div>
                        </div>
                    </div>
                <?php endforeach; endif; ?>
            </div>
        </div>

        <!-- Loan Stats -->
        <div class="dash-card">
            <h3 style="margin:0 0 14px;"><i class="bi bi-bank"></i> লোন পরিসংখ্যান</h3>
            <div style="display:grid; grid-template-columns: repeat(auto-fit, minmax(160px, 1fr)); gap: 14px;">
                <div style="padding:14px; background:var(--gray-50); border-radius:10px;">
                    <div style="font-size:11px; color:var(--gray-500);">মোট আবেদন</div>
                    <div style="font-size:24px; font-weight:700;"><?= bn_num($loanStats['total_loans']) ?></div>
                </div>
                <div style="padding:14px; background:linear-gradient(135deg,#fff7e0,#fff); border-radius:10px;">
                    <div style="font-size:11px; color:var(--gray-500);">বিতরণকৃত</div>
                    <div style="font-size:24px; font-weight:700; color:var(--m3-primary);"><?= bdt($loanStats['total_disbursed'], 0) ?></div>
                </div>
                <div style="padding:14px; background:linear-gradient(135deg,#e8f5e9,#fff); border-radius:10px;">
                    <div style="font-size:11px; color:var(--gray-500);">পরিশোধিত</div>
                    <div style="font-size:24px; font-weight:700; color:var(--success-dark);"><?= bdt($loanStats['total_repaid'], 0) ?></div>
                </div>
                <div style="padding:14px; background:var(--gray-50); border-radius:10px;">
                    <div style="font-size:11px; color:var(--gray-500);">সক্রিয়</div>
                    <div style="font-size:24px; font-weight:700;"><?= bn_num($loanStats['active_count']) ?></div>
                </div>
                <div style="padding:14px; background:var(--gray-50); border-radius:10px;">
                    <div style="font-size:11px; color:var(--gray-500);">সম্পন্ন</div>
                    <div style="font-size:24px; font-weight:700; color:var(--m1-primary);"><?= bn_num($loanStats['completed_count']) ?></div>
                </div>
                <div style="padding:14px; background:#ffebee; border-radius:10px;">
                    <div style="font-size:11px; color:var(--danger);">খেলাপি</div>
                    <div style="font-size:24px; font-weight:700; color:var(--danger);"><?= bn_num($loanStats['defaulted_count']) ?></div>
                </div>
            </div>
        </div>

        <!-- Top Farmers -->
        <div class="dash-card">
            <h3 style="margin:0 0 14px;"><i class="bi bi-trophy"></i> শীর্ষ কৃষক (রাজস্ব অনুযায়ী)</h3>
            <?php if (empty($topFarmers)): ?>
                <p style="color:var(--gray-500); text-align:center; padding: 14px;">এই সময়ে কোনো ডেলিভারি নেই।</p>
            <?php else: ?>
            <table class="table">
                <thead><tr><th>#</th><th>কৃষক</th><th>জেলা</th><th>অর্ডার</th><th>রাজস্ব</th><th>রেটিং</th></tr></thead>
                <tbody>
                <?php foreach ($topFarmers as $i => $f): ?>
                    <tr>
                        <td><span style="font-size:18px;"><?= ['🥇','🥈','🥉'][$i] ?? '#' . bn_num($i+1) ?></span></td>
                        <td><strong><?= e($f['full_name']) ?></strong></td>
                        <td><?= e($f['district_name'] ?? '—') ?></td>
                        <td><?= bn_num($f['orders']) ?></td>
                        <td class="mono" style="font-weight:700; color:var(--m1-primary);"><?= bdt($f['revenue'], 0) ?></td>
                        <td><?= $f['rating'] > 0 ? '⭐ ' . bn_num(number_format($f['rating'], 1)) : '—' ?></td>
                    </tr>
                <?php endforeach; ?>
                </tbody>
            </table>
            <?php endif; ?>
        </div>
    </main>
</div>
</div>

<?php require __DIR__ . '/../../includes/footer.php'; ?>
