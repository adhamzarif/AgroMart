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
$filters = ['', 'pending', 'confirmed', 'shipped', 'delivered', 'cancelled'];
$labels = ['সব','অপেক্ষমাণ','নিশ্চিত','শিপিং','সম্পন্ন','বাতিল'];
?>

<div class="dash-page">
<div class="dash-shell">
    <?php require __DIR__ . '/../../../includes/sidebar.php'; ?>

    <main class="dash-main">
        <div class="dash-header">
            <div>
                <div class="breadcrumb"><a href="<?= BASE_URL ?>/farmer/dashboard">ড্যাশবোর্ড</a> <i class="bi bi-chevron-right" style="font-size:10px"></i> প্রাপ্ত অর্ডার</div>
                <h1>প্রাপ্ত অর্ডার 📦</h1>
            </div>
        </div>

        <div class="dash-card" style="padding: 14px 20px;">
            <div style="display:flex; gap:8px; align-items:center; flex-wrap:wrap;">
                <span style="font-weight:600; font-size:13px;">স্ট্যাটাস:</span>
                <?php foreach ($filters as $i => $f):
                    $active = ($statusFilter ?? '') === $f;
                ?>
                    <a href="<?= BASE_URL ?>/farmer/orders<?= $f ? '?status=' . $f : '' ?>" class="nav-pill-btn <?= $active ? 'primary' : 'ghost' ?>" style="font-size:13px;"><?= $labels[$i] ?></a>
                <?php endforeach; ?>
            </div>
        </div>

        <div class="dash-card">
            <?php if (empty($orders)): ?>
                <div class="empty-state">
                    <i class="bi bi-bag"></i>
                    <h4>কোনো অর্ডার পাওয়া যায়নি</h4>
                    <p>আপনার ফসলগুলো মার্কেটপ্লেসে দৃশ্যমান থাকলে ক্রেতারা অর্ডার করবেন।</p>
                </div>
            <?php else: ?>
            <div style="overflow-x:auto;">
            <table class="table">
                <thead>
                    <tr>
                        <th>অর্ডার নম্বর</th>
                        <th>ক্রেতা</th>
                        <th>ফসল</th>
                        <th>পরিমাণ</th>
                        <th>মোট মূল্য</th>
                        <th>স্ট্যাটাস</th>
                        <th>তারিখ</th>
                        <th>কাজ</th>
                    </tr>
                </thead>
                <tbody>
                <?php foreach ($orders as $o):
                    $sm = $statusMap[$o['order_status']] ?? ['neutral', $o['order_status']];
                ?>
                    <tr>
                        <td class="mono" style="font-size:12px;"><?= e($o['order_number']) ?></td>
                        <td>
                            <?= e($o['buyer_name']) ?><br>
                            <span style="font-size:11px; color:var(--gray-500);"><?= e($o['buyer_phone']) ?></span>
                        </td>
                        <td><?= e($o['crop_name']) ?></td>
                        <td><?= bn_num($o['quantity_ordered']) ?> <?= e($o['unit']) ?></td>
                        <td class="mono"><?= bdt($o['total_amount'], 0) ?></td>
                        <td><span class="badge badge-<?= $sm[0] ?>"><?= $sm[1] ?></span></td>
                        <td style="font-size:12px;"><?= bn_date($o['order_date']) ?></td>
                        <td>
                            <a href="<?= BASE_URL ?>/farmer/orders/detail/<?= (int)$o['order_id'] ?>" class="nav-pill-btn ghost" style="font-size:12px; padding:5px 10px;">বিস্তারিত →</a>
                        </td>
                    </tr>
                <?php endforeach; ?>
                </tbody>
            </table>
            </div>
            <?php endif; ?>
        </div>
    </main>
</div>
</div>

<?php require __DIR__ . '/../../../includes/footer.php'; ?>
