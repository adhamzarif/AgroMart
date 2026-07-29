<?php require __DIR__ . '/../../../includes/header.php'; ?>
<?php require __DIR__ . '/../../../includes/navbar.php'; ?>

<?php
$statusMap = [
    'pending'   => ['warning','পেন্ডিং'],
    'approved'  => ['info','অনুমোদিত'],
    'disbursed' => ['info','বিতরণ'],
    'active'    => ['success','সক্রিয়'],
    'completed' => ['neutral','সম্পন্ন'],
    'rejected'  => ['danger','বাতিল'],
    'defaulted' => ['danger','খেলাপি'],
];
$sm = $statusMap[$loan['status']] ?? ['neutral', $loan['status']];
$canDecide = $loan['status'] === 'pending';
$progress = $loan['total_payable'] > 0 ? min(100, ($loan['amount_paid'] / $loan['total_payable']) * 100) : 0;
?>

<div class="dash-page">
<div class="dash-shell">
    <?php require __DIR__ . '/../../../includes/sidebar.php'; ?>

    <main class="dash-main">
        <div class="dash-header">
            <div>
                <div class="breadcrumb"><a href="<?= BASE_URL ?>/admin/loans">লোন</a> <i class="bi bi-chevron-right" style="font-size:10px"></i> বিস্তারিত</div>
                <h1>লোন আবেদন #<?= bn_num($loan['loan_id']) ?></h1>
            </div>
            <span class="badge badge-<?= $sm[0] ?>" style="font-size:14px; padding:8px 16px;"><?= $sm[1] ?></span>
        </div>

        <div style="display:grid; grid-template-columns: 2fr 1fr; gap: 20px;">
            <div>
                <div class="dash-card">
                    <h3 style="margin:0 0 14px;"><i class="bi bi-person-vcard"></i> আবেদনকারী কৃষক</h3>
                    <div style="display:flex; align-items:center; gap:14px; margin-bottom:12px;">
                        <div style="width:56px; height:56px; border-radius:50%; background:var(--grad-m1); color:#fff; display:flex; align-items:center; justify-content:center; font-weight:700; font-size:22px;"><?= e(mb_substr($farmer['full_name'], 0, 1, 'UTF-8')) ?></div>
                        <div>
                            <strong style="font-size:16px;"><?= e($farmer['full_name']) ?></strong>
                            <div style="font-size:13px; color:var(--gray-500);"><i class="bi bi-telephone"></i> <?= e($farmer['phone']) ?> <?php if ($farmer['email']): ?>• <i class="bi bi-envelope"></i> <?= e($farmer['email']) ?><?php endif; ?></div>
                        </div>
                    </div>
                </div>

                <div class="dash-card">
                    <h3 style="margin:0 0 14px;"><i class="bi bi-cash-coin"></i> লোন বিবরণ</h3>
                    <div style="display:grid; grid-template-columns: repeat(2,1fr); gap:14px; margin-bottom:14px;">
                        <div><div style="font-size:11px; color:var(--gray-500);">আবেদনকৃত পরিমাণ</div><div style="font-size:22px; font-weight:700; color:var(--m3-primary); font-family:var(--font-bn);"><?= bdt($loan['loan_amount'], 0) ?></div></div>
                        <div><div style="font-size:11px; color:var(--gray-500);">সুদের হার</div><div style="font-size:22px; font-weight:700;"><?= bn_num($loan['interest_rate']) ?>%</div></div>
                        <div><div style="font-size:11px; color:var(--gray-500);">মেয়াদ</div><div style="font-size:22px; font-weight:700;"><?= bn_num($loan['tenure_months']) ?> মাস</div></div>
                        <div><div style="font-size:11px; color:var(--gray-500);">মাসিক কিস্তি</div><div style="font-size:22px; font-weight:700;"><?= bdt($loan['monthly_installment'], 0) ?></div></div>
                        <div><div style="font-size:11px; color:var(--gray-500);">মোট পরিশোধযোগ্য</div><div style="font-size:22px; font-weight:700;"><?= bdt($loan['total_payable'], 0) ?></div></div>
                        <div><div style="font-size:11px; color:var(--gray-500);">আবেদনের সময়ে স্কোর</div><div style="font-size:22px; font-weight:700;"><?= bn_num($loan['credit_score_at_application']) ?></div></div>
                    </div>

                    <?php if (in_array($loan['status'], ['active','disbursed','completed'], true)): ?>
                    <div style="margin-bottom:6px; display:flex; justify-content:space-between; font-size:13px;">
                        <span>পরিশোধের অগ্রগতি (<?= bdt($loan['amount_paid'], 0) ?> / <?= bdt($loan['total_payable'], 0) ?>)</span>
                        <strong><?= bn_num(number_format($progress, 1)) ?>%</strong>
                    </div>
                    <div style="height:12px; background:var(--gray-100); border-radius:6px; overflow:hidden;">
                        <div style="height:100%; background: linear-gradient(90deg, var(--m1-primary), var(--m1-light)); width: <?= $progress ?>%;"></div>
                    </div>
                    <?php endif; ?>

                    <div style="margin-top:14px; padding-top:14px; border-top:1px solid var(--gray-100);">
                        <strong>উদ্দেশ্য:</strong> <?= e($loan['loan_purpose']) ?><br>
                        <strong>আবেদনের তারিখ:</strong> <?= bn_date($loan['application_date'], true) ?>
                        <?php if ($loan['approval_date']): ?><br><strong>অনুমোদন:</strong> <?= bn_date($loan['approval_date'], true) ?><?php endif; ?>
                        <?php if ($loan['rejection_reason']): ?><br><strong style="color:var(--danger);">বাতিলের কারণ:</strong> <?= e($loan['rejection_reason']) ?><?php endif; ?>
                    </div>
                </div>

                <?php if ($canDecide): ?>
                <div class="dash-card" style="border-left:4px solid var(--success);">
                    <h3 style="margin:0 0 14px; color:var(--success-dark);"><i class="bi bi-check2-circle"></i> অনুমোদন করুন</h3>
                    <p style="font-size:13px; color:var(--gray-600);">লোন অনুমোদন করলে কৃষক স্বয়ংক্রিয়ভাবে নোটিফিকেশন পাবেন এবং পরবর্তী কিস্তির তারিখ ১ মাস পরে সেট হবে।</p>
                    <form method="POST" action="<?= BASE_URL ?>/admin/loans/approve/<?= (int)$loan['loan_id'] ?>" onsubmit="return confirm('আপনি কি নিশ্চিত? এই লোন অনুমোদিত করবেন?');">
                        <?= Csrf::field() ?>
                        <button class="nav-pill-btn primary" style="background:var(--success);"><i class="bi bi-check-circle"></i> অনুমোদন এবং বিতরণ করুন</button>
                    </form>
                </div>

                <div class="dash-card" style="border-left:4px solid var(--danger);">
                    <h3 style="margin:0 0 14px; color:var(--danger);"><i class="bi bi-x-circle"></i> বাতিল করুন</h3>
                    <form method="POST" action="<?= BASE_URL ?>/admin/loans/reject/<?= (int)$loan['loan_id'] ?>" onsubmit="return confirm('আপনি কি নিশ্চিত? এই লোন বাতিল করবেন?');">
                        <?= Csrf::field() ?>
                        <div style="margin-bottom: 10px;">
                            <label style="display:block; font-size:13px; font-weight:600; margin-bottom:4px;">বাতিলের কারণ *</label>
                            <textarea name="reason" required rows="3" style="width:100%; padding:10px 12px; border:1.5px solid var(--gray-200); border-radius:8px; resize:vertical; font-family:inherit;" placeholder="যেমন: ক্রেডিট স্কোর পর্যাপ্ত নয়, বা ডকুমেন্টেশন ঘাটতি"></textarea>
                        </div>
                        <button class="nav-pill-btn" style="background:var(--danger); color:#fff; border:none;"><i class="bi bi-x"></i> বাতিল করুন</button>
                    </form>
                </div>
                <?php endif; ?>

                <?php if (!empty($repayments)): ?>
                <div class="dash-card">
                    <h3 style="margin:0 0 14px;"><i class="bi bi-receipt-cutoff"></i> পরিশোধের ইতিহাস</h3>
                    <table class="table">
                        <thead><tr><th>তারিখ</th><th>পরিমাণ</th><th>পদ্ধতি</th><th>বকেয়া</th></tr></thead>
                        <tbody>
                        <?php foreach ($repayments as $r): ?>
                            <tr>
                                <td style="font-size:12px;"><?= bn_date($r['payment_date'], true) ?></td>
                                <td class="mono"><?= bdt($r['payment_amount'], 0) ?></td>
                                <td><?= e($r['payment_method']) ?></td>
                                <td class="mono"><?= bdt($r['remaining_after_payment'], 0) ?></td>
                            </tr>
                        <?php endforeach; ?>
                        </tbody>
                    </table>
                </div>
                <?php endif; ?>
            </div>

            <div>
                <div class="dash-card" style="background: linear-gradient(135deg, #fff7e0, #fff); border-left:4px solid var(--m3-primary);">
                    <h3 style="margin:0 0 14px;"><i class="bi bi-bar-chart"></i> ক্রেডিট অ্যাসেসমেন্ট</h3>
                    <div style="text-align:center; padding: 10px 0;">
                        <div style="font-size:42px; font-weight:800; color:var(--m3-primary); line-height:1; font-family:var(--font-bn);"><?= bn_num($cs['score']) ?></div>
                        <div style="font-size:13px; color:var(--gray-500); margin-top:4px;">গ্রেড <strong><?= e($cs['grade']) ?></strong> • সর্বোচ্চ লোন <?= bdt($cs['max_loan'], 0) ?></div>
                    </div>

                    <table class="table" style="margin-top:14px;">
                        <tbody>
                        <?php foreach ($cs['factors'] as $f):
                            $neg = strpos($f['impact'], '-') !== false;
                        ?>
                            <tr>
                                <td style="font-size:12px; padding: 6px 4px;"><?= e($f['name']) ?></td>
                                <td style="font-size:12px; padding: 6px 4px; text-align:right;"><?= e($f['value']) ?></td>
                                <td style="font-size:12px; padding: 6px 4px; text-align:right; font-weight:700; color: <?= $neg ? 'var(--danger)' : 'var(--success-dark)' ?>;"><?= e($f['impact']) ?></td>
                            </tr>
                        <?php endforeach; ?>
                        </tbody>
                    </table>

                    <?php if (!$cs['is_eligible']): ?>
                        <div style="margin-top:14px; padding:10px; background:#ffebee; border-radius:8px; color:var(--danger); font-size:12px;">
                            ⚠ এই কৃষকের ক্রেডিট স্কোর লোনের জন্য পর্যাপ্ত নয় (ন্যূনতম ৫৫ প্রয়োজন)।
                        </div>
                    <?php else: ?>
                        <div style="margin-top:14px; padding:10px; background:#e8f5e9; border-radius:8px; color:var(--success-dark); font-size:12px;">
                            ✓ কৃষক লোনের জন্য যোগ্য।
                        </div>
                    <?php endif; ?>
                </div>
            </div>
        </div>
    </main>
</div>
</div>

<?php require __DIR__ . '/../../../includes/footer.php'; ?>
