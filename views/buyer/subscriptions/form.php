<?php require __DIR__ . '/../../../includes/header.php'; ?>
<?php require __DIR__ . '/../../../includes/navbar.php'; ?>

<style>
.f-group { margin-bottom: 16px; }
.f-label { display: block; font-size: 13px; font-weight: 600; margin-bottom: 6px; }
.f-input, .f-select { width: 100%; padding: 11px 14px; border: 1.5px solid var(--gray-200); border-radius: 8px; font-size: 14px; box-sizing: border-box; outline: none; }
.f-input:focus, .f-select:focus { border-color: var(--m1-primary); }
.f-row { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; }
</style>

<div class="dash-page">
<div class="dash-shell">
    <?php require __DIR__ . '/../../../includes/sidebar.php'; ?>

    <main class="dash-main">
        <div class="dash-header">
            <div>
                <div class="breadcrumb"><a href="<?= BASE_URL ?>/buyer/subscriptions">সাবস্ক্রিপশন</a> <i class="bi bi-chevron-right" style="font-size:10px"></i> নতুন</div>
                <h1>🔁 নতুন সাবস্ক্রিপশন</h1>
            </div>
        </div>

        <?php if (empty($farmers)): ?>
            <div class="alert alert-info">
                <i class="bi bi-info-circle"></i>
                আপনি এখনো কোনো কৃষক থেকে অর্ডার করেননি। সাবস্ক্রিপশন তৈরি করতে আগে কয়েকটি অর্ডার সম্পূর্ণ করুন।
                <br><br>
                <a href="<?= BASE_URL ?>/buyer/browse" class="nav-pill-btn primary"><i class="bi bi-shop"></i> মার্কেটপ্লেসে যান</a>
            </div>
        <?php else: ?>
        <div class="dash-card" style="max-width: 720px;">
            <form method="POST">
                <?= Csrf::field() ?>

                <div class="f-group">
                    <label class="f-label">কৃষক নির্বাচন করুন *</label>
                    <select name="farmer_id" class="f-select" required>
                        <option value="">— পূর্বের কৃষক থেকে নির্বাচন করুন —</option>
                        <?php foreach ($farmers as $f): ?>
                            <option value="<?= (int)$f['user_id'] ?>"><?= e($f['full_name']) ?><?php if ($f['district_name']): ?> — <?= e($f['district_name']) ?><?php endif; ?></option>
                        <?php endforeach; ?>
                    </select>
                    <div style="font-size:11px; color:var(--gray-500); margin-top:4px;">শুধুমাত্র যাদের সাথে আগে অর্ডার করেছেন তাদের তালিকা।</div>
                </div>

                <div class="f-group">
                    <label class="f-label">ফসলের নাম *</label>
                    <input type="text" name="crop_name" class="f-input" placeholder="যেমন: টমেটো" required>
                </div>

                <div class="f-row">
                    <div class="f-group">
                        <label class="f-label">প্রতি ডেলিভারিতে পরিমাণ *</label>
                        <input type="number" name="quantity_per_delivery" class="f-input" step="0.1" min="0.1" required>
                    </div>
                    <div class="f-group">
                        <label class="f-label">একক *</label>
                        <select name="unit" class="f-select" required>
                            <option value="kg">কেজি</option><option value="ton">টন</option><option value="mon">মন</option><option value="piece">পিস</option>
                        </select>
                    </div>
                </div>

                <div class="f-row">
                    <div class="f-group">
                        <label class="f-label">লক করা মূল্য (৳ প্রতি একক) *</label>
                        <input type="number" name="price_locked" class="f-input" step="0.01" min="0.01" required>
                    </div>
                    <div class="f-group">
                        <label class="f-label">ফ্রিকোয়েন্সি *</label>
                        <select name="frequency" class="f-select" required>
                            <option value="weekly">সাপ্তাহিক</option>
                            <option value="biweekly">দ্বি-সাপ্তাহিক</option>
                            <option value="monthly">মাসিক</option>
                            <option value="daily">দৈনিক</option>
                        </select>
                    </div>
                </div>

                <div class="f-row">
                    <div class="f-group">
                        <label class="f-label">শুরুর তারিখ *</label>
                        <input type="date" name="start_date" class="f-input" required value="<?= date('Y-m-d') ?>">
                    </div>
                    <div class="f-group">
                        <label class="f-label">পরবর্তী ডেলিভারি *</label>
                        <input type="date" name="next_delivery_date" class="f-input" required value="<?= date('Y-m-d', strtotime('+7 days')) ?>">
                    </div>
                </div>

                <div class="f-group">
                    <label class="f-label">শেষ তারিখ (ঐচ্ছিক)</label>
                    <input type="date" name="end_date" class="f-input">
                </div>

                <div class="f-group">
                    <label style="display:flex; gap:8px; align-items:center; cursor:pointer;">
                        <input type="checkbox" name="auto_payment" value="1">
                        স্বয়ংক্রিয় পেমেন্ট সক্রিয় করুন
                    </label>
                </div>

                <?php if (!empty($paymentMethods)): ?>
                <div class="f-group">
                    <label class="f-label">পেমেন্ট পদ্ধতি</label>
                    <select name="payment_method_id" class="f-select">
                        <option value="">— বাছাই করুন —</option>
                        <?php foreach ($paymentMethods as $pm): ?>
                            <option value="<?= (int)$pm['method_id'] ?>"><?= e(strtoupper($pm['method_type'])) ?> — <?= e($pm['account_number']) ?></option>
                        <?php endforeach; ?>
                    </select>
                </div>
                <?php endif; ?>

                <div style="display:flex; gap:10px; margin-top: 24px; border-top: 1px solid var(--gray-100); padding-top: 18px;">
                    <button type="submit" class="nav-pill-btn primary"><i class="bi bi-save"></i> সাবস্ক্রিপশন তৈরি করুন</button>
                    <a href="<?= BASE_URL ?>/buyer/subscriptions" class="nav-pill-btn ghost">বাতিল</a>
                </div>
            </form>
        </div>
        <?php endif; ?>
    </main>
</div>
</div>

<?php require __DIR__ . '/../../../includes/footer.php'; ?>
