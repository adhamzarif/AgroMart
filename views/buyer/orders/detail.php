<?php require __DIR__ . '/../../../includes/header.php'; ?>
<?php require __DIR__ . '/../../../includes/navbar.php'; ?>

<?php
$statusMap = [
    'pending'=>['warning','অপেক্ষমাণ'],
    'confirmed'=>['info','নিশ্চিত'],
    'packed'=>['info','প্যাক'],
    'shipped'=>['info','শিপিং'],
    'delivered'=>['success','সম্পন্ন'],
    'cancelled'=>['danger','বাতিল'],
];
$sm = $statusMap[$order['order_status']] ?? ['neutral', $order['order_status']];
$canCancel = in_array($order['order_status'], ['pending','confirmed'], true);
$canReview = $order['order_status'] === 'delivered' && !$rating;
?>

<div class="dash-page">
<div class="dash-shell">
    <?php require __DIR__ . '/../../../includes/sidebar.php'; ?>

    <main class="dash-main">
        <div class="dash-header">
            <div>
                <div class="breadcrumb"><a href="<?= BASE_URL ?>/buyer/orders">আমার অর্ডার</a> <i class="bi bi-chevron-right" style="font-size:10px"></i> বিস্তারিত</div>
                <h1>অর্ডার #<?= e($order['order_number']) ?></h1>
            </div>
            <div><span class="badge badge-<?= $sm[0] ?>" style="font-size:14px; padding:8px 16px;"><?= $sm[1] ?></span></div>
        </div>

        <div style="display:grid; grid-template-columns: 2fr 1fr; gap:20px;">
            <div>
                <div class="dash-card">
                    <h3 style="margin:0 0 14px;"><i class="bi bi-box-seam"></i> অর্ডার সারাংশ</h3>
                    <table class="table" style="margin-bottom:0;">
                        <tbody>
                            <tr><td style="width:40%;"><strong>ফসল</strong></td><td><?= e($order['crop_name']) ?></td></tr>
                            <tr><td><strong>পরিমাণ</strong></td><td><?= bn_num($order['quantity_ordered']) ?> <?= e($order['unit']) ?></td></tr>
                            <tr><td><strong>একক মূল্য</strong></td><td><?= bdt($order['unit_price'], 2) ?></td></tr>
                            <tr><td><strong>সাবটোটাল</strong></td><td><?= bdt($order['subtotal'], 2) ?></td></tr>
                            <tr><td><strong>ডেলিভারি</strong></td><td><?= bdt($order['delivery_charge'], 2) ?></td></tr>
                            <tr style="background:var(--gray-50);"><td><strong>মোট</strong></td><td style="font-weight:700; color:var(--m1-primary); font-size:16px;"><?= bdt($order['total_amount'], 2) ?></td></tr>
                            <tr><td><strong>পেমেন্ট</strong></td><td><span class="badge badge-<?= $order['payment_status'] === 'paid' ? 'success' : 'warning' ?>"><?= $order['payment_status'] === 'paid' ? '✓ পরিশোধিত' : 'অপেক্ষমাণ' ?></span></td></tr>
                        </tbody>
                    </table>
                </div>

                <div class="dash-card">
                    <h3 style="margin:0 0 14px;"><i class="bi bi-geo-alt"></i> ডেলিভারি</h3>
                    <p><strong>প্রকার:</strong> <?= $order['delivery_type'] === 'home_delivery' ? '🏠 হোম ডেলিভারি' : '🚶 সেলফ পিকআপ' ?></p>
                    <?php if ($order['delivery_address']): ?><p><strong>ঠিকানা:</strong> <?= e($order['delivery_address']) ?><?php if ($order['delivery_district_name']): ?>, <?= e($order['delivery_district_name']) ?><?php endif; ?></p><?php endif; ?>
                    <?php if ($order['preferred_delivery_date']): ?><p><strong>পছন্দনীয় তারিখ:</strong> <?= bn_date($order['preferred_delivery_date']) ?></p><?php endif; ?>
                    <?php if ($order['special_instructions']): ?><p><strong>বিশেষ নির্দেশনা:</strong> <?= e($order['special_instructions']) ?></p><?php endif; ?>
                </div>

                <?php if ($canCancel): ?>
                <div class="dash-card" style="border-left: 4px solid var(--danger);">
                    <h3 style="margin:0 0 14px; color:var(--danger);"><i class="bi bi-x-circle"></i> অর্ডার বাতিল করুন</h3>
                    <form method="POST" action="<?= BASE_URL ?>/buyer/orders/cancel/<?= (int)$order['order_id'] ?>" onsubmit="return confirm('আপনি কি নিশ্চিত? অর্ডার বাতিল করলে স্টক ফেরত যাবে।');">
                        <?= Csrf::field() ?>
                        <input type="text" name="reason" placeholder="বাতিলের কারণ (ঐচ্ছিক)" style="width:100%; padding:10px 12px; border:1.5px solid var(--gray-200); border-radius:8px; box-sizing:border-box; margin-bottom:10px;">
                        <button type="submit" class="nav-pill-btn" style="background:var(--danger); color:#fff; border:none;"><i class="bi bi-trash"></i> অর্ডার বাতিল করুন</button>
                    </form>
                </div>
                <?php endif; ?>

                <?php if ($canReview): ?>
                <div class="dash-card" style="border-left: 4px solid #f57c00; background: linear-gradient(135deg, #fff7e0, #fff);">
                    <h3 style="margin:0 0 14px; color:#f57c00;"><i class="bi bi-star-fill"></i> কৃষকের রিভিউ দিন</h3>
                    <form method="POST" action="<?= BASE_URL ?>/buyer/orders/review/<?= (int)$order['order_id'] ?>">
                        <?= Csrf::field() ?>
                        <?php foreach (['overall_rating'=>'সামগ্রিক','quality_rating'=>'মান','delivery_rating'=>'ডেলিভারি','communication_rating'=>'যোগাযোগ'] as $k=>$lbl): ?>
                        <div style="margin-bottom: 10px;">
                            <label style="display:block; font-size:13px; font-weight:600; margin-bottom:4px;"><?= $lbl ?> *</label>
                            <select name="<?= $k ?>" required style="padding:8px 12px; border:1.5px solid var(--gray-200); border-radius:8px;">
                                <?php for ($s = 5; $s >= 1; $s--): ?>
                                    <option value="<?= $s ?>"><?= str_repeat('⭐', $s) ?> (<?= bn_num($s) ?>)</option>
                                <?php endfor; ?>
                            </select>
                        </div>
                        <?php endforeach; ?>
                        <div style="margin-bottom: 10px;">
                            <input type="text" name="review_title" placeholder="সংক্ষিপ্ত শিরোনাম (ঐচ্ছিক)" maxlength="100" style="width:100%; padding:10px 12px; border:1.5px solid var(--gray-200); border-radius:8px; box-sizing:border-box;">
                        </div>
                        <div style="margin-bottom: 10px;">
                            <textarea name="review_text" placeholder="বিস্তারিত মন্তব্য (ঐচ্ছিক)" rows="3" maxlength="1000" style="width:100%; padding:10px 12px; border:1.5px solid var(--gray-200); border-radius:8px; box-sizing:border-box; font-family:inherit;"></textarea>
                        </div>
                        <label style="display:flex; align-items:center; gap:6px; font-size:13px; margin-bottom: 14px;">
                            <input type="checkbox" name="would_recommend" value="1" checked> অন্যদের সুপারিশ করব
                        </label>
                        <button type="submit" class="nav-pill-btn primary"><i class="bi bi-check2"></i> রিভিউ জমা দিন</button>
                    </form>
                </div>
                <?php elseif ($rating): ?>
                <div class="dash-card">
                    <h3 style="margin:0 0 14px; color:#f57c00;"><i class="bi bi-star-fill"></i> আপনার রিভিউ</h3>
                    <div style="font-size:18px; color:#f57c00; margin-bottom:8px;"><?= str_repeat('⭐', (int)$rating['overall_rating']) ?> (<?= bn_num(number_format($rating['overall_rating'], 1)) ?>)</div>
                    <?php if ($rating['review_title']): ?><div style="font-weight:600;"><?= e($rating['review_title']) ?></div><?php endif; ?>
                    <?php if ($rating['review_text']): ?><p style="color:var(--gray-700);"><?= e($rating['review_text']) ?></p><?php endif; ?>
                </div>
                <?php endif; ?>
            </div>

            <div>
                <div class="dash-card">
                    <h3 style="margin:0 0 14px;"><i class="bi bi-person"></i> কৃষক</h3>
                    <div style="display:flex; align-items:center; gap:12px; margin-bottom:12px;">
                        <div style="width:48px; height:48px; border-radius:50%; background:var(--grad-m1); color:#fff; display:flex; align-items:center; justify-content:center; font-weight:700;"><?= e(mb_substr($order['farmer_name'], 0, 1, 'UTF-8')) ?></div>
                        <div>
                            <strong><?= e($order['farmer_name']) ?></strong><br>
                            <span style="font-size:12px; color:var(--gray-500);"><?= e($order['farmer_phone']) ?></span>
                        </div>
                    </div>
                    <a href="<?= BASE_URL ?>/buyer/messages/with/<?= (int)$order['farmer_id'] ?>" class="nav-pill-btn ghost" style="width:100%; justify-content:center;"><i class="bi bi-chat-dots"></i> বার্তা পাঠান</a>
                </div>

                <div class="dash-card">
                    <h3 style="margin:0 0 14px;"><i class="bi bi-clock-history"></i> টাইমলাইন</h3>
                    <ul style="list-style:none; padding:0; margin:0; font-size:13px;">
                        <li style="padding:6px 0;"><i class="bi bi-check-circle-fill" style="color:var(--success)"></i> অর্ডার দেওয়া — <?= bn_date($order['order_date'], true) ?></li>
                        <?php if ($order['confirmed_at']): ?><li style="padding:6px 0;"><i class="bi bi-check-circle-fill" style="color:var(--success)"></i> নিশ্চিত — <?= bn_date($order['confirmed_at'], true) ?></li><?php endif; ?>
                        <?php if ($order['delivered_at']): ?><li style="padding:6px 0;"><i class="bi bi-check-circle-fill" style="color:var(--success)"></i> ডেলিভারি — <?= bn_date($order['delivered_at'], true) ?></li><?php endif; ?>
                    </ul>
                </div>
            </div>
        </div>
    </main>
</div>
</div>

<?php require __DIR__ . '/../../../includes/footer.php'; ?>
