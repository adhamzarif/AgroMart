<?php require __DIR__ . '/../../../includes/header.php'; ?>
<?php require __DIR__ . '/../../../includes/navbar.php'; ?>

<?php
$statusMap = [
    'pending'    => ['warning', 'পেন্ডিং'],
    'approved'   => ['info', 'অনুমোদিত'],
    'rejected'   => ['danger', 'বাতিল'],
    'disbursed'  => ['info', 'বিতরণ'],
    'active'     => ['success', 'সক্রিয়'],
    'completed'  => ['neutral', 'সম্পন্ন'],
    'defaulted'  => ['danger', 'খেলাপি'],
];
$sm = $statusMap[$loan['status']] ?? ['neutral', $loan['status']];
$progress = $loan['total_payable'] > 0 ? min(100, ($loan['amount_paid'] / $loan['total_payable']) * 100) : 0;
?>

<div class="dash-page">
<div class="dash-shell">
    <?php require __DIR__ . '/../../../includes/sidebar.php'; ?>

    <main class="dash-main">
        <div class="dash-header">
            <div>
                <div class="breadcrumb"><a href="<?= BASE_URL ?>/farmer/loans">লোন</a> <i class="bi bi-chevron-right" style="font-size:10px"></i> বিস্তারিত</div>
                <h1>লোন #<?= bn_num($loan['loan_id']) ?></h1>
            </div>
            <div><span class="badge badge-<?= $sm[0] ?>" style="font-size:14px; padding:8px 16px;"><?= $sm[1] ?></span></div>
        </div>

        <div style="display:grid; grid-template-columns: 2fr 1fr; gap:20px;">
            <div>
                <div class="dash-card">
                    <h3 style="margin:0 0 18px;"><i class="bi bi-bank" style="color:var(--m3-primary)"></i> লোন সারাংশ</h3>
                    <div style="display:grid; grid-template-columns: repeat(2,1fr); gap:14px; margin-bottom:18px;">
                        <div><div style="font-size:12px; color:var(--gray-500);">প্রাথমিক পরিমাণ</div><div style="font-size:20px; font-weight:700; color:var(--m1-primary); font-family:var(--font-bn);"><?= bdt($loan['loan_amount'], 0) ?></div></div>
                        <div><div style="font-size:12px; color:var(--gray-500);">সুদের হার</div><div style="font-size:20px; font-weight:700;"><?= bn_num($loan['interest_rate']) ?>% / বছর</div></div>
                        <div><div style="font-size:12px; color:var(--gray-500);">মাসিক কিস্তি</div><div style="font-size:20px; font-weight:700;"><?= bdt($loan['monthly_installment'], 0) ?></div></div>
                        <div><div style="font-size:12px; color:var(--gray-500);">মেয়াদ</div><div style="font-size:20px; font-weight:700;"><?= bn_num($loan['tenure_months']) ?> মাস</div></div>
                        <div><div style="font-size:12px; color:var(--gray-500);">মোট পরিশোধযোগ্য</div><div style="font-size:20px; font-weight:700;"><?= bdt($loan['total_payable'], 0) ?></div></div>
                        <div><div style="font-size:12px; color:var(--gray-500);">পরিশোধিত</div><div style="font-size:20px; font-weight:700; color:var(--success);"><?= bdt($loan['amount_paid'], 0) ?></div></div>
                        <div><div style="font-size:12px; color:var(--gray-500);">বকেয়া</div><div style="font-size:24px; font-weight:800; color:var(--danger); font-family:var(--font-bn);"><?= bdt($loan['remaining_balance'], 0) ?></div></div>
                        <div><div style="font-size:12px; color:var(--gray-500);">পরবর্তী কিস্তির তারিখ</div><div style="font-size:16px; font-weight:600;"><?= $loan['next_payment_date'] ? bn_date($loan['next_payment_date']) : '—' ?></div></div>
                    </div>

                    <div style="margin-bottom:6px; display:flex; justify-content:space-between; font-size:13px;">
                        <span>পরিশোধের অগ্রগতি</span>
                        <strong><?= bn_num(number_format($progress, 1)) ?>%</strong>
                    </div>
                    <div style="height:12px; background:var(--gray-100); border-radius:6px; overflow:hidden;">
                        <div style="height:100%; background: linear-gradient(90deg, var(--m1-primary), var(--m1-light)); width: <?= $progress ?>%; transition: width 0.5s;"></div>
                    </div>

                    <div style="margin-top:18px; padding-top:14px; border-top:1px solid var(--gray-100);">
                        <strong>উদ্দেশ্য:</strong> <?= e($loan['loan_purpose']) ?><br>
                        <strong>আবেদনের তারিখ:</strong> <?= bn_date($loan['application_date'], true) ?>
                        <?php if ($loan['approval_date']): ?>
                            <br><strong>অনুমোদনের তারিখ:</strong> <?= bn_date($loan['approval_date'], true) ?>
                        <?php endif; ?>
                        <?php if ($loan['rejection_reason']): ?>
                            <br><strong style="color:var(--danger);">বাতিলের কারণ:</strong> <?= e($loan['rejection_reason']) ?>
                        <?php endif; ?>
                    </div>
                </div>

                <div class="dash-card">
                    <h3 style="margin:0 0 14px;"><i class="bi bi-receipt-cutoff"></i> কিস্তি পরিশোধের ইতিহাস</h3>
                    <?php if (empty($repayments)): ?>
                        <p style="color:var(--gray-500); font-size:13px; text-align:center; padding:20px;">এখনো কোনো কিস্তি জমা হয়নি।</p>
                    <?php else: ?>
                    <table class="table">
                        <thead><tr><th>তারিখ</th><th>পরিমাণ</th><th>পদ্ধতি</th><th>রেফারেন্স</th><th>বকেয়া</th></tr></thead>
                        <tbody>
                        <?php foreach ($repayments as $r):
                            $mLabels = ['auto_deduction'=>'স্বয়ংক্রিয়','manual'=>'ম্যানুয়াল','cash'=>'নগদ','mobile_banking'=>'মোবাইল ব্যাংকিং'];
                        ?>
                            <tr>
                                <td style="font-size:12px;"><?= bn_date($r['payment_date'], true) ?></td>
                                <td class="mono"><?= bdt($r['payment_amount'], 0) ?></td>
                                <td><?= e($mLabels[$r['payment_method']] ?? $r['payment_method']) ?></td>
                                <td class="mono" style="font-size:11px;"><?= e($r['transaction_reference'] ?? '—') ?></td>
                                <td class="mono"><?= bdt($r['remaining_after_payment'], 0) ?></td>
                            </tr>
                        <?php endforeach; ?>
                        </tbody>
                    </table>
                    <?php endif; ?>
                </div>
            </div>

            <div>
                <?php if (in_array($loan['status'], ['active','disbursed'], true) && $loan['remaining_balance'] > 0): ?>
                <div class="dash-card" style="border-left:4px solid var(--m1-primary);">
                    <h3 style="margin:0 0 14px;"><i class="bi bi-cash-coin"></i> কিস্তি জমা দিন</h3>
                    <form method="POST" action="<?= BASE_URL ?>/farmer/loans/repay/<?= (int)$loan['loan_id'] ?>">
                        <?= Csrf::field() ?>
                        <div style="margin-bottom: 14px;">
                            <label style="display:block; font-size:13px; font-weight:600; margin-bottom:6px;">পরিমাণ (৳)</label>
                            <input type="number" name="amount" step="0.01" min="1" max="<?= $loan['remaining_balance'] ?>" value="<?= $loan['monthly_installment'] ?>" required style="width:100%; padding:10px 12px; border:1.5px solid var(--gray-200); border-radius:8px; box-sizing:border-box;">
                        </div>
                        <div style="margin-bottom: 14px;">
                            <label style="display:block; font-size:13px; font-weight:600; margin-bottom:6px;">ট্রান্সঅ্যাকশন রেফারেন্স</label>
                            <input type="text" name="transaction_reference" placeholder="bKash/Nagad রেফ" style="width:100%; padding:10px 12px; border:1.5px solid var(--gray-200); border-radius:8px; box-sizing:border-box;">
                        </div>
                        <button type="submit" class="nav-pill-btn primary" style="width:100%; justify-content:center;"><i class="bi bi-check2-circle"></i> জমা দিন</button>
                    </form>
                </div>
                <?php endif; ?>

                <div class="dash-card">
                    <h3 style="margin:0 0 14px;"><i class="bi bi-shield-check"></i> ক্রেডিট স্কোর</h3>
                    <p style="font-size:13px; color:var(--gray-600);">আবেদনের সময় স্কোর: <strong style="font-size:18px;"><?= bn_num($loan['credit_score_at_application']) ?></strong></p>
                </div>
            </div>
        </div>
    </main>
</div>
</div>

<?php require __DIR__ . '/../../../includes/footer.php'; ?>
