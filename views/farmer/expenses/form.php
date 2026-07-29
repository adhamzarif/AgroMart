<?php require __DIR__ . '/../../../includes/header.php'; ?>
<?php require __DIR__ . '/../../../includes/navbar.php'; ?>

<style>
.f-group { margin-bottom: 16px; }
.f-label { display: block; font-size: 13px; font-weight: 600; margin-bottom: 6px; }
.f-input, .f-select, .f-textarea { width: 100%; padding: 11px 14px; border: 1.5px solid var(--gray-200); border-radius: 8px; font-size: 14px; box-sizing: border-box; }
.f-input:focus, .f-select:focus, .f-textarea:focus { outline: none; border-color: var(--m1-primary); }
.f-textarea { resize: vertical; min-height: 80px; font-family: inherit; }
.f-row { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; }
</style>

<div class="dash-page">
<div class="dash-shell">
    <?php require __DIR__ . '/../../../includes/sidebar.php'; ?>

    <main class="dash-main">
        <div class="dash-header">
            <div>
                <div class="breadcrumb"><a href="<?= BASE_URL ?>/farmer/expenses">খরচ</a> <i class="bi bi-chevron-right" style="font-size:10px"></i> <?= $expense ? 'সম্পাদনা' : 'নতুন' ?></div>
                <h1><?= $expense ? '✏ খরচ সম্পাদনা' : '➕ নতুন খরচ যোগ করুন' ?></h1>
            </div>
        </div>

        <div class="dash-card" style="max-width: 720px;">
            <form method="POST" enctype="multipart/form-data">
                <?= Csrf::field() ?>

                <div class="f-row">
                    <div class="f-group">
                        <label class="f-label">ক্যাটাগরি *</label>
                        <select name="expense_category" class="f-select" required>
                            <?php foreach (['seeds'=>'🌱 বীজ','fertilizer'=>'🌿 সার','pesticide'=>'🧴 কীটনাশক','labor'=>'👷 শ্রমিক','irrigation'=>'💧 সেচ','equipment'=>'🛠 সরঞ্জাম','transport'=>'🚚 পরিবহন','other'=>'📌 অন্যান্য'] as $k=>$v): ?>
                                <option value="<?= $k ?>" <?= ($expense['expense_category'] ?? '') === $k ? 'selected' : '' ?>><?= $v ?></option>
                            <?php endforeach; ?>
                        </select>
                    </div>
                    <div class="f-group">
                        <label class="f-label">পরিমাণ (৳) *</label>
                        <input type="number" name="expense_amount" class="f-input" step="0.01" min="0.01" required value="<?= e($expense['expense_amount'] ?? '') ?>">
                    </div>
                </div>

                <div class="f-row">
                    <div class="f-group">
                        <label class="f-label">তারিখ *</label>
                        <input type="date" name="expense_date" class="f-input" required value="<?= e($expense['expense_date'] ?? date('Y-m-d')) ?>">
                    </div>
                    <div class="f-group">
                        <label class="f-label">সংশ্লিষ্ট ফসল (ঐচ্ছিক)</label>
                        <select name="crop_id" class="f-select">
                            <option value="">— কোনোটি নয় —</option>
                            <?php foreach ($crops as $c): ?>
                                <option value="<?= (int)$c['crop_id'] ?>" <?= ($expense['crop_id'] ?? 0) == $c['crop_id'] ? 'selected' : '' ?>><?= e($c['crop_name']) ?></option>
                            <?php endforeach; ?>
                        </select>
                    </div>
                </div>

                <div class="f-group">
                    <label class="f-label">বিবরণ</label>
                    <textarea name="expense_description" class="f-textarea" placeholder="যেমন: ৫০ কেজি ইউরিয়া সার ক্রয়"><?= e($expense['expense_description'] ?? '') ?></textarea>
                </div>

                <div class="f-group">
                    <label class="f-label">রসিদ (JPG/PNG, সর্বোচ্চ ২MB) — ঐচ্ছিক</label>
                    <input type="file" name="receipt" class="f-input" accept="image/jpeg,image/png,image/webp">
                    <?php if ($expense && !empty($expense['receipt_url'])): ?>
                        <div style="margin-top:8px; font-size:12px;">বর্তমান রসিদ: <a href="<?= e(upload_url('receipts/' . $expense['receipt_url'])) ?>" target="_blank">দেখুন</a></div>
                    <?php endif; ?>
                </div>

                <div style="display:flex; gap:10px; margin-top: 24px; border-top: 1px solid var(--gray-100); padding-top: 18px;">
                    <button type="submit" class="nav-pill-btn primary"><i class="bi bi-save"></i> <?= $expense ? 'আপডেট' : 'সংরক্ষণ' ?> করুন</button>
                    <a href="<?= BASE_URL ?>/farmer/expenses" class="nav-pill-btn ghost">বাতিল</a>
                </div>
            </form>
        </div>
    </main>
</div>
</div>

<?php require __DIR__ . '/../../../includes/footer.php'; ?>
