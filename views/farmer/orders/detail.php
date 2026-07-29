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
    'refunded'=>['neutral','ফেরত'],
];
$sm = $statusMap[$order['order_status']] ?? ['neutral', $order['order_status']];

// Next-allowed transitions for the farmer
$nextStatuses = [
    'pending'   => [['confirmed','নিশ্চিত করুন'], ['cancelled','বাতিল করুন']],
    'confirmed' => [['packed','প্যাক করা হয়েছে'], ['cancelled','বাতিল করুন']],
    'packed'    => [['shipped','শিপিং শুরু']],
    'shipped'   => [['delivered','ডেলিভারি সম্পন্ন']],
];
$transitions = $nextStatuses[$order['order_status']] ?? [];
?>

<div class="dash-page">
<div class="dash-shell">
    <?php require __DIR__ . '/../../../includes/sidebar.php'; ?>

    <main class="dash-main">
        <div class="dash-header">
            <div>
                <div class="breadcrumb"><a href="<?= BASE_URL ?>/farmer/orders">প্রাপ্ত অর্ডার</a> <i class="bi bi-chevron-right" style="font-size:10px"></i> বিস্তারিত</div>
                <h1>অর্ডার #<?= e($order['order_number']) ?></h1>
            </div>
            <div><span class="badge badge-<?= $sm[0] ?>" style="font-size:14px; padding:8px 16px;"><?= $sm[1] ?></span></div>
        </div>

        <div style="display:grid; grid-template-columns: 2fr 1fr; gap: 20px;">
            <div>
                <div class="dash-card">
                    <h3 style="margin:0 0 14px;"><i class="bi bi-box-seam" style="color:var(--m1-primary)"></i> অর্ডার সারাংশ</h3>
                    <table class="table" style="margin-bottom:0;">
                        <tbody>
                            <tr><td style="width:40%;"><strong>ফসল</strong></td><td><?= e($order['crop_name']) ?></td></tr>
                            <tr><td><strong>পরিমাণ</strong></td><td><?= bn_num($order['quantity_ordered']) ?> <?= e($order['unit']) ?></td></tr>
                            <tr><td><strong>একক মূল্য</strong></td><td><?= bdt($order['unit_price'], 2) ?></td></tr>
                            <tr><td><strong>সাবটোটাল</strong></td><td><?= bdt($order['subtotal'], 2) ?></td></tr>
                            <tr><td><strong>ডেলিভারি চার্জ</strong></td><td><?= bdt($order['delivery_charge'], 2) ?></td></tr>
                            <tr style="background:var(--gray-50);"><td><strong>মোট</strong></td><td style="font-weight:700; color:var(--m1-primary); font-size:16px;"><?= bdt($order['total_amount'], 2) ?></td></tr>
                            <tr><td><strong>পেমেন্ট অবস্থা</strong></td><td><span class="badge badge-<?= $order['payment_status'] === 'paid' ? 'success' : 'warning' ?>"><?= $order['payment_status'] === 'paid' ? '✓ পরিশোধিত' : 'অপেক্ষমাণ' ?></span></td></tr>
                        </tbody>
                    </table>
                </div>

                <div class="dash-card">
                    <h3 style="margin:0 0 14px;"><i class="bi bi-geo-alt" style="color:var(--m2-primary)"></i> ডেলিভারি তথ্য</h3>
                    <p style="margin:4px 0;"><strong>প্রকার:</strong> <?= $order['delivery_type'] === 'home_delivery' ? '🏠 হোম ডেলিভারি' : '🚶 সেলফ পিকআপ' ?></p>
                    <?php if ($order['delivery_address']): ?>
                        <p style="margin:4px 0;"><strong>ঠিকানা:</strong> <?= e($order['delivery_address']) ?><?php if ($order['delivery_district_name']): ?>, <?= e($order['delivery_district_name']) ?><?php endif; ?></p>
                    <?php endif; ?>
                    <?php if ($order['preferred_delivery_date']): ?>
                        <p style="margin:4px 0;"><strong>পছন্দনীয় তারিখ:</strong> <?= bn_date($order['preferred_delivery_date']) ?></p>
                    <?php endif; ?>
                    <?php if ($order['special_instructions']): ?>
                        <p style="margin:4px 0;"><strong>বিশেষ নির্দেশনা:</strong> <?= e($order['special_instructions']) ?></p>
                    <?php endif; ?>
                </div>

                <?php if (!empty($transitions) && !in_array($order['order_status'], ['delivered','cancelled','refunded'], true)): ?>
                <div class="dash-card" style="border-left: 4px solid var(--m1-primary);">
                    <h3 style="margin:0 0 14px;"><i class="bi bi-arrow-right-circle"></i> অর্ডার অগ্রসর করুন</h3>
                    <div style="display:flex; gap:10px; flex-wrap:wrap;">
                        <?php foreach ($transitions as $t): ?>
                            <form method="POST" action="<?= BASE_URL ?>/farmer/orders/update-status/<?= (int)$order['order_id'] ?>" style="display:inline;" onsubmit="<?php if ($t[0]==='cancelled'): ?>return confirm('আপনি কি নিশ্চিত? অর্ডার বাতিল করলে স্টক পুনরায় যোগ হবে।');<?php endif; ?>">
                                <?= Csrf::field() ?>
                                <input type="hidden" name="new_status" value="<?= e($t[0]) ?>">
                                <?php if ($t[0] === 'cancelled'): ?>
                                    <input type="text" name="reason" placeholder="বাতিলের কারণ" required style="padding:8px 12px; border-radius:8px; border:1.5px solid var(--gray-200); margin-right:6px;">
                                <?php endif; ?>
                                <button type="submit" class="nav-pill-btn <?= $t[0] === 'cancelled' ? 'ghost' : 'primary' ?>" style="<?= $t[0] === 'cancelled' ? 'color:var(--danger)' : '' ?>"><?= e($t[1]) ?></button>
                            </form>
                        <?php endforeach; ?>
                    </div>
                </div>
                <?php endif; ?>

                <?php if ($order['cancellation_reason']): ?>
                <div class="alert alert-danger">
                    <strong>বাতিলের কারণ:</strong> <?= e($order['cancellation_reason']) ?>
                </div>
                <?php endif; ?>
            </div>

            <div>
                <div class="dash-card">
                    <h3 style="margin:0 0 14px;"><i class="bi bi-person" style="color:var(--m4-primary)"></i> ক্রেতার তথ্য</h3>
                    <div style="display:flex; align-items:center; gap:12px; margin-bottom:12px;">
                        <div style="width:48px; height:48px; border-radius:50%; background:var(--grad-m2); color:#fff; display:flex; align-items:center; justify-content:center; font-weight:700;"><?= e(mb_substr($order['buyer_name'], 0, 1, 'UTF-8')) ?></div>
                        <div>
                            <div style="font-weight:700;"><?= e($order['buyer_name']) ?></div>
                            <div style="font-size:12px; color:var(--gray-500);"><?= e($order['buyer_phone']) ?></div>
                        </div>
                    </div>
                    <a href="<?= BASE_URL ?>/farmer/messages/with/<?= (int)$order['buyer_id'] ?>" class="nav-pill-btn ghost" style="width:100%; justify-content:center;"><i class="bi bi-chat-dots"></i> বার্তা পাঠান</a>
                </div>

                <div class="dash-card">
                    <h3 style="margin:0 0 14px;"><i class="bi bi-clock-history" style="color:var(--m2-primary)"></i> টাইমলাইন</h3>
                    <ul style="list-style:none; padding:0; margin:0; font-size:13px;">
                        <li style="padding:6px 0;"><i class="bi bi-check-circle-fill" style="color:var(--success)"></i> অর্ডার দেওয়া হয়েছে — <?= bn_date($order['order_date'], true) ?></li>
                        <?php if ($order['confirmed_at']): ?>
                            <li style="padding:6px 0;"><i class="bi bi-check-circle-fill" style="color:var(--success)"></i> নিশ্চিত — <?= bn_date($order['confirmed_at'], true) ?></li>
                        <?php endif; ?>
                        <?php if ($order['delivered_at']): ?>
                            <li style="padding:6px 0;"><i class="bi bi-check-circle-fill" style="color:var(--success)"></i> ডেলিভারি — <?= bn_date($order['delivered_at'], true) ?></li>
                        <?php endif; ?>
                    </ul>
                </div>
            </div>
        </div>
    </main>
</div>
</div>

<?php require __DIR__ . '/../../../includes/footer.php'; ?>
