<?php require __DIR__ . '/../../includes/header.php'; ?>
<?php require __DIR__ . '/../../includes/navbar.php'; ?>

<?php
$mtIcons = [
    'bkash' => ['bKash', '#e2136e'],
    'nagad' => ['Nagad', '#ed1c24'],
    'rocket'=> ['Rocket', '#8f288d'],
    'bank_transfer' => ['ব্যাংক', '#3949ab'],
    'wallet'=> ['ওয়ালেট', '#43a047'],
];
?>

<div class="dash-page">
<div class="dash-shell">
    <?php require __DIR__ . '/../../includes/sidebar.php'; ?>

    <main class="dash-main">
        <div class="dash-header">
            <div>
                <div class="breadcrumb"><a href="<?= BASE_URL ?>/buyer/dashboard">ড্যাশবোর্ড</a> <i class="bi bi-chevron-right" style="font-size:10px"></i> পেমেন্ট পদ্ধতি</div>
                <h1>পেমেন্ট পদ্ধতি 💳</h1>
            </div>
        </div>

        <div style="display:grid; grid-template-columns: 1fr 1.4fr; gap: 20px;">
            <!-- Add new -->
            <div class="dash-card">
                <h3 style="margin:0 0 14px;"><i class="bi bi-plus-circle"></i> নতুন পেমেন্ট পদ্ধতি যোগ করুন</h3>
                <form method="POST" action="<?= BASE_URL ?>/buyer/payment-methods/add">
                    <?= Csrf::field() ?>

                    <div style="margin-bottom: 12px;">
                        <label style="display:block; font-size:13px; font-weight:600; margin-bottom:4px;">পদ্ধতি *</label>
                        <select name="method_type" required style="width:100%; padding:10px 12px; border:1.5px solid var(--gray-200); border-radius:8px; box-sizing:border-box;">
                            <option value="bkash">bKash</option>
                            <option value="nagad">Nagad</option>
                            <option value="rocket">Rocket</option>
                            <option value="bank_transfer">ব্যাংক ট্রান্সফার</option>
                            <option value="wallet">ওয়ালেট</option>
                        </select>
                    </div>

                    <div style="margin-bottom: 12px;">
                        <label style="display:block; font-size:13px; font-weight:600; margin-bottom:4px;">অ্যাকাউন্ট নম্বর *</label>
                        <input type="text" name="account_number" placeholder="01XXXXXXXXX" required style="width:100%; padding:10px 12px; border:1.5px solid var(--gray-200); border-radius:8px; box-sizing:border-box;">
                    </div>

                    <div style="margin-bottom: 12px;">
                        <label style="display:block; font-size:13px; font-weight:600; margin-bottom:4px;">অ্যাকাউন্টধারীর নাম</label>
                        <input type="text" name="account_name" placeholder="পূর্ণ নাম" style="width:100%; padding:10px 12px; border:1.5px solid var(--gray-200); border-radius:8px; box-sizing:border-box;">
                    </div>

                    <div style="margin-bottom: 12px;">
                        <label style="display:block; font-size:13px; font-weight:600; margin-bottom:4px;">ব্যাংকের নাম (ঐচ্ছিক)</label>
                        <input type="text" name="bank_name" placeholder="যেমন: ডাচ-বাংলা ব্যাংক" style="width:100%; padding:10px 12px; border:1.5px solid var(--gray-200); border-radius:8px; box-sizing:border-box;">
                    </div>

                    <label style="display:flex; align-items:center; gap:6px; font-size:13px; margin-bottom: 14px;">
                        <input type="checkbox" name="is_default" value="1"> ডিফল্ট হিসেবে সেট করুন
                    </label>

                    <button type="submit" class="nav-pill-btn primary" style="width:100%; justify-content:center;"><i class="bi bi-plus-lg"></i> যোগ করুন</button>
                </form>
            </div>

            <!-- List -->
            <div>
                <h3 style="margin:0 0 14px; font-size:16px;"><i class="bi bi-card-list"></i> সংরক্ষিত পদ্ধতিসমূহ (<?= bn_num(count($methods)) ?>)</h3>
                <?php if (empty($methods)): ?>
                    <div class="dash-card">
                        <div class="empty-state">
                            <i class="bi bi-credit-card"></i>
                            <h4>কোনো পেমেন্ট পদ্ধতি নেই</h4>
                            <p>সহজ অর্ডারের জন্য পেমেন্ট পদ্ধতি যোগ করুন।</p>
                        </div>
                    </div>
                <?php else: foreach ($methods as $m):
                    $mt = $mtIcons[$m['method_type']] ?? [$m['method_type'], '#666'];
                ?>
                    <div class="dash-card" style="margin:0 0 12px; display:flex; align-items:center; gap:14px; padding:16px;">
                        <div style="width:48px; height:48px; border-radius:10px; background: <?= $mt[1] ?>; color:#fff; display:flex; align-items:center; justify-content:center; font-weight:700; font-size:12px;"><?= e($mt[0]) ?></div>
                        <div style="flex:1; min-width:0;">
                            <div style="display:flex; align-items:center; gap:8px;">
                                <strong><?= e($mt[0]) ?></strong>
                                <?php if ($m['is_default']): ?><span class="badge badge-success" style="font-size:10px;">★ ডিফল্ট</span><?php endif; ?>
                                <?php if ($m['is_verified']): ?><span class="badge badge-info" style="font-size:10px;">✓ যাচাইকৃত</span><?php endif; ?>
                            </div>
                            <div style="font-size:13px; color:var(--gray-600); margin-top:2px;"><?= e($m['account_number']) ?></div>
                            <?php if ($m['account_name']): ?><div style="font-size:11px; color:var(--gray-500);"><?= e($m['account_name']) ?></div><?php endif; ?>
                            <?php if ($m['bank_name']): ?><div style="font-size:11px; color:var(--gray-500);"><?= e($m['bank_name']) ?></div><?php endif; ?>
                        </div>
                        <div style="display:flex; flex-direction:column; gap:4px;">
                            <?php if (!$m['is_default']): ?>
                            <form method="POST" action="<?= BASE_URL ?>/buyer/payment-methods/default/<?= (int)$m['method_id'] ?>">
                                <?= Csrf::field() ?>
                                <button class="nav-pill-btn ghost" style="font-size:11px; padding:4px 10px;">ডিফল্ট</button>
                            </form>
                            <?php endif; ?>
                            <form method="POST" action="<?= BASE_URL ?>/buyer/payment-methods/delete/<?= (int)$m['method_id'] ?>" onsubmit="return confirm('মুছে ফেলবেন?');">
                                <?= Csrf::field() ?>
                                <button class="nav-pill-btn ghost" style="font-size:11px; padding:4px 10px; color:var(--danger);"><i class="bi bi-trash"></i></button>
                            </form>
                        </div>
                    </div>
                <?php endforeach; endif; ?>
            </div>
        </div>
    </main>
</div>
</div>

<?php require __DIR__ . '/../../includes/footer.php'; ?>
