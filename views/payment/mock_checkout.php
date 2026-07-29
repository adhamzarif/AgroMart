<?php require __DIR__ . '/../../includes/header.php'; ?>
<?php require __DIR__ . '/../../includes/navbar.php'; ?>

<style>
.mock-shell { display: grid; place-items: center; min-height: calc(100vh - 200px); padding: 40px 16px; }
.mock-card { background: #fff; border-radius: 18px; max-width: 540px; width: 100%; box-shadow: 0 12px 48px rgba(0,0,0,0.08); border-top: 5px solid var(--warning); overflow: hidden; }
.mock-header { background: linear-gradient(135deg, #fff3e0, #fff); padding: 24px 28px; border-bottom: 1px solid var(--gray-100); }
.mock-banner { display: inline-block; background: var(--warning); color: #fff; font-size: 11px; font-weight: 700; padding: 4px 10px; border-radius: 4px; letter-spacing: 0.5px; }
.mock-body { padding: 28px; }
.mock-row { display: flex; justify-content: space-between; padding: 8px 0; border-bottom: 1px dashed var(--gray-100); font-size: 14px; }
.mock-row:last-child { border: 0; padding-top: 14px; font-size: 16px; font-weight: 700; color: var(--m1-primary); }
.mock-btn { display: block; width: 100%; padding: 14px 20px; margin-bottom: 10px; border: 0; border-radius: 12px; font-size: 15px; font-weight: 600; cursor: pointer; text-align: center; text-decoration: none; transition: transform 0.15s; }
.mock-btn:hover { transform: translateY(-1px); }
.mock-btn-success { background: linear-gradient(135deg, #2e7d32, #43a047); color: #fff; }
.mock-btn-fail { background: #fff; color: var(--danger); border: 2px solid var(--danger); }
.mock-btn-cancel { background: #fff; color: var(--gray-600); border: 2px solid var(--gray-300); }
</style>

<div class="mock-shell">
    <div class="mock-card">
        <div class="mock-header">
            <span class="mock-banner">🧪 DEV MODE — MOCK GATEWAY</span>
            <h2 style="margin: 10px 0 4px; font-size: 22px;">Payment Checkout</h2>
        </div>

        <div class="mock-body">
            <h3 style="margin: 0 0 14px; font-size: 15px; color: var(--gray-700);">পেমেন্ট বিবরণ</h3>
            <div class="mock-row">
                <span>রেফারেন্স:</span>
                <span style="font-family: monospace; color: var(--gray-700);"><?= e($payment['payment_reference']) ?></span>
            </div>
            <div class="mock-row">
                <span>গেটওয়ে:</span>
                <span style="text-transform: uppercase; font-weight: 600; color: var(--warning);"><?= e($payment['gateway']) ?></span>
            </div>
            <div class="mock-row">
                <span>অর্ডার ID:</span>
                <span>#<?= bn_num((int)($payment['order_id'] ?? 0)) ?></span>
            </div>
            <div class="mock-row">
                <span>পরিমাণ:</span>
                <span><?= bdt($payment['amount'], 2) ?></span>
            </div>

            <h3 style="margin: 22px 0 12px; font-size: 14px; color: var(--gray-700);">পেমেন্ট ফলাফল নির্বাচন করুন:</h3>

            <a href="<?= BASE_URL ?>/payment/callback?ref=<?= urlencode($payment['payment_reference']) ?>&result=success&status=success"
               class="mock-btn mock-btn-success">
                ✓ সফল পেমেন্ট (Simulate Success)
            </a>
            <a href="<?= BASE_URL ?>/payment/callback?ref=<?= urlencode($payment['payment_reference']) ?>&result=failed&status=failed"
               class="mock-btn mock-btn-fail">
                ✗ ব্যর্থ পেমেন্ট (Simulate Failure)
            </a>
            <a href="<?= BASE_URL ?>/payment/callback?ref=<?= urlencode($payment['payment_reference']) ?>&result=cancelled&status=cancelled"
               class="mock-btn mock-btn-cancel">
                ← বাতিল (Cancel)
            </a>
        </div>
    </div>
</div>

<?php require __DIR__ . '/../../includes/footer.php'; ?>
