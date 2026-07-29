<?php require __DIR__ . '/../../includes/header.php'; ?>
<?php require __DIR__ . '/../../includes/navbar.php'; ?>

<?php
$isSuccess = ($outcome ?? 'success') === 'success';
?>

<style>
.pr-shell { display: grid; place-items: center; min-height: calc(100vh - 200px); padding: 40px 16px; }
.pr-card { background: #fff; border-radius: 18px; max-width: 480px; width: 100%; box-shadow: 0 10px 40px rgba(0,0,0,0.08); padding: 40px 32px; text-align: center; }
.pr-icon { width: 88px; height: 88px; border-radius: 50%; display: grid; place-items: center; margin: 0 auto 18px; font-size: 44px; color: #fff; }
.pr-success .pr-icon { background: linear-gradient(135deg, #2e7d32, #43a047); }
.pr-failed  .pr-icon { background: linear-gradient(135deg, #c62828, #e53935); }
.pr-card h1 { margin: 0 0 8px; font-size: 26px; }
.pr-card p  { color: var(--gray-600); margin: 6px 0; line-height: 1.6; }
</style>

<div class="pr-shell">
    <div class="pr-card pr-<?= $isSuccess ? 'success' : 'failed' ?>">
        <div class="pr-icon"><?= $isSuccess ? '✓' : '✗' ?></div>
        <h1><?= $isSuccess ? 'পেমেন্ট সফল!' : 'পেমেন্ট ব্যর্থ' ?></h1>
        <p>
            অর্ডার <strong><?= e($order['order_number']) ?></strong>
        </p>
        <p style="font-size: 18px; color: var(--m1-primary); font-weight: 700;">
            <?= bdt($order['total_amount'], 0) ?>
        </p>

        <?php if ($isSuccess): ?>
            <p style="margin-top: 18px;">
                আপনার পেমেন্ট সফলভাবে প্রক্রিয়া হয়েছে। কৃষক শীঘ্রই আপনার অর্ডার প্রস্তুত করবেন।
            </p>
        <?php else: ?>
            <p style="margin-top: 18px;">
                পেমেন্ট সম্পন্ন হয়নি — অর্ডার বাতিল করা হয়েছে এবং স্টক ফেরত দেওয়া হয়েছে। আপনি আবার চেষ্টা করতে পারেন।
            </p>
        <?php endif; ?>

        <div style="margin-top: 28px; display: flex; gap: 10px; justify-content: center; flex-wrap: wrap;">
            <a href="<?= BASE_URL ?>/buyer/orders/detail/<?= (int)$order['order_id'] ?>"
               class="nav-pill-btn primary">
                অর্ডার বিস্তারিত দেখুন
            </a>
            <?php if (!$isSuccess): ?>
                <a href="<?= BASE_URL ?>/buyer/browse" class="nav-pill-btn ghost">
                    আরো ফসল দেখুন
                </a>
            <?php else: ?>
                <a href="<?= BASE_URL ?>/buyer/orders" class="nav-pill-btn ghost">
                    সকল অর্ডার দেখুন
                </a>
            <?php endif; ?>
        </div>
    </div>
</div>

<?php require __DIR__ . '/../../includes/footer.php'; ?>
