<?php require __DIR__ . '/../../../includes/header.php'; ?>
<?php require __DIR__ . '/../../../includes/navbar.php'; ?>

<?php
$statusMap = ['pending'=>['warning','অপেক্ষমাণ'],'confirmed'=>['info','নিশ্চিত'],'shipped'=>['info','শিপিং'],'delivered'=>['success','সম্পন্ন'],'cancelled'=>['danger','বাতিল']];
?>

<div class="dash-page">
<div class="dash-shell">
    <?php require __DIR__ . '/../../../includes/sidebar.php'; ?>

    <main class="dash-main">
        <div class="dash-header">
            <div>
                <div class="breadcrumb"><a href="<?= BASE_URL ?>/agent/farmers">আমার কৃষক</a> <i class="bi bi-chevron-right" style="font-size:10px"></i> বিস্তারিত</div>
                <h1>👨‍🌾 <?= e($farmer['full_name']) ?></h1>
            </div>
            <div style="display:flex; gap:8px;">
                <a href="<?= BASE_URL ?>/agent/crops/list/<?= (int)$farmer['user_id'] ?>" class="nav-pill-btn primary"><i class="bi bi-plus-lg"></i> ফসল লিস্ট করুন</a>
                <a href="<?= BASE_URL ?>/agent/messages/with/<?= (int)$farmer['user_id'] ?>" class="nav-pill-btn ghost"><i class="bi bi-chat-dots"></i> বার্তা</a>
            </div>
        </div>

        <div style="display:grid; grid-template-columns: 1fr 2fr; gap:20px;">
            <div>
                <div class="dash-card">
                    <h3 style="margin:0 0 14px;"><i class="bi bi-person-vcard"></i> ব্যক্তিগত তথ্য</h3>
                    <div style="display:flex; align-items:center; gap:12px; margin-bottom:14px;">
                        <div style="width:64px; height:64px; border-radius:50%; background:var(--grad-m1); color:#fff; display:flex; align-items:center; justify-content:center; font-weight:700; font-size:28px;"><?= e(mb_substr($farmer['full_name'], 0, 1, 'UTF-8')) ?></div>
                        <div>
                            <strong style="font-size:16px;"><?= e($farmer['full_name']) ?></strong><br>
                            <span style="font-size:12px; color:var(--gray-500);">কৃষক</span>
                        </div>
                    </div>
                    <div style="font-size:13px; line-height:1.9;">
                        <div><i class="bi bi-telephone"></i> <?= e($farmer['phone']) ?></div>
                        <?php if ($farmer['email']): ?><div><i class="bi bi-envelope"></i> <?= e($farmer['email']) ?></div><?php endif; ?>
                        <?php if (!empty($farmer['address'])): ?><div><i class="bi bi-geo-alt"></i> <?= e($farmer['address']) ?></div><?php endif; ?>
                        <div><i class="bi bi-calendar-event"></i> যোগদান: <?= bn_date($farmer['created_at']) ?></div>
                        <div style="margin-top: 8px;">
                            <?php if ($farmer['phone_verified']): ?><span class="badge badge-success">✓ ফোন যাচাইকৃত</span><?php endif; ?>
                            <?php if ($farmer['email_verified']): ?><span class="badge badge-success">✓ ইমেল</span><?php endif; ?>
                            <?php if ($farmer['nid_verified']): ?><span class="badge badge-success">✓ NID</span><?php endif; ?>
                        </div>
                    </div>
                </div>
            </div>

            <div>
                <div class="dash-card">
                    <h3 style="margin:0 0 14px;"><i class="bi bi-basket"></i> ফসল লিস্ট (<?= bn_num(count($crops)) ?>)</h3>
                    <?php if (empty($crops)): ?>
                        <p style="text-align:center; color:var(--gray-500); padding:14px;">এখনো কোনো ফসল লিস্টেড নেই। <a href="<?= BASE_URL ?>/agent/crops/list/<?= (int)$farmer['user_id'] ?>">প্রথম ফসল যোগ করুন →</a></p>
                    <?php else: ?>
                    <table class="table">
                        <thead><tr><th>ফসল</th><th>ক্যাটাগরি</th><th>পরিমাণ</th><th>মূল্য</th><th>অবস্থা</th></tr></thead>
                        <tbody>
                        <?php foreach ($crops as $c): ?>
                            <tr>
                                <td><strong><?= e($c['crop_name']) ?></strong></td>
                                <td><?= e($c['category_name_bn']) ?></td>
                                <td><?= bn_num($c['quantity']) ?> <?= e($c['unit']) ?></td>
                                <td class="mono"><?= bdt($c['price_per_unit'], 0) ?></td>
                                <td><span class="badge badge-<?= $c['status'] === 'available' ? 'success' : 'neutral' ?>"><?= e($c['status']) ?></span></td>
                            </tr>
                        <?php endforeach; ?>
                        </tbody>
                    </table>
                    <?php endif; ?>
                </div>

                <div class="dash-card">
                    <h3 style="margin:0 0 14px;"><i class="bi bi-bag"></i> সাম্প্রতিক অর্ডার</h3>
                    <?php if (empty($orders)): ?>
                        <p style="text-align:center; color:var(--gray-500); padding:14px;">এখনো কোনো অর্ডার নেই।</p>
                    <?php else: ?>
                    <table class="table">
                        <thead><tr><th>অর্ডার</th><th>ফসল</th><th>মোট</th><th>অবস্থা</th><th>তারিখ</th></tr></thead>
                        <tbody>
                        <?php foreach ($orders as $o):
                            $sm = $statusMap[$o['order_status']] ?? ['neutral', $o['order_status']];
                        ?>
                            <tr>
                                <td class="mono" style="font-size:11px;"><?= e($o['order_number']) ?></td>
                                <td><?= e($o['crop_name']) ?></td>
                                <td class="mono"><?= bdt($o['total_amount'], 0) ?></td>
                                <td><span class="badge badge-<?= $sm[0] ?>"><?= $sm[1] ?></span></td>
                                <td style="font-size:11px;"><?= bn_date($o['order_date']) ?></td>
                            </tr>
                        <?php endforeach; ?>
                        </tbody>
                    </table>
                    <?php endif; ?>
                </div>
            </div>
        </div>
    </main>
</div>
</div>

<?php require __DIR__ . '/../../../includes/footer.php'; ?>
