<?php require __DIR__ . '/../../../includes/header.php'; ?>
<?php require __DIR__ . '/../../../includes/navbar.php'; ?>

<style>
.f-group { margin-bottom: 16px; }
.f-label { display: block; font-size: 13px; font-weight: 600; margin-bottom: 6px; }
.f-input, .f-select { width: 100%; padding: 11px 14px; border: 1.5px solid var(--gray-200); border-radius: 8px; font-size: 14px; box-sizing: border-box; outline: none; }
.f-input:focus, .f-select:focus { border-color: var(--m4-primary); }
.f-row { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; }
</style>

<div class="dash-page">
<div class="dash-shell">
    <?php require __DIR__ . '/../../../includes/sidebar.php'; ?>

    <main class="dash-main">
        <div class="dash-header">
            <div>
                <div class="breadcrumb"><a href="<?= BASE_URL ?>/admin/prices">মূল্য</a> <i class="bi bi-chevron-right" style="font-size:10px"></i> <?= $price ? 'সম্পাদনা' : 'নতুন' ?></div>
                <h1><?= $price ? '✏ মূল্য সম্পাদনা' : '➕ নতুন মূল্য যোগ করুন' ?></h1>
            </div>
        </div>

        <div class="dash-card" style="max-width: 720px;">
            <?php if ($price): ?>
                <div class="alert alert-info" style="margin-bottom: 16px;">
                    <i class="bi bi-info-circle"></i>
                    মূল্য পরিবর্তন করলে পুরোনো মান <strong>price_history</strong> টেবিলে সংরক্ষিত হবে।
                </div>
            <?php endif; ?>

            <form method="POST">
                <?= Csrf::field() ?>

                <div class="f-row">
                    <div class="f-group">
                        <label class="f-label">ফসলের নাম *</label>
                        <input type="text" name="crop_name" class="f-input" required placeholder="যেমন: ধান (BRRI-28)" value="<?= e($price['crop_name'] ?? '') ?>" <?= $price ? 'readonly' : '' ?>>
                    </div>
                    <div class="f-group">
                        <label class="f-label">জেলা *</label>
                        <select name="district_id" class="f-select" required <?= $price ? 'disabled' : '' ?>>
                            <option value="">— নির্বাচন করুন —</option>
                            <?php foreach ($districts as $d): ?>
                                <option value="<?= (int)$d['district_id'] ?>" <?= ($price['district_id'] ?? 0) == $d['district_id'] ? 'selected' : '' ?>><?= e($d['district_name']) ?></option>
                            <?php endforeach; ?>
                        </select>
                        <?php if ($price): ?>
                            <input type="hidden" name="district_id" value="<?= (int)$price['district_id'] ?>">
                        <?php endif; ?>
                    </div>
                </div>

                <div class="f-row">
                    <div class="f-group">
                        <label class="f-label">পাইকারি মূল্য (৳) *</label>
                        <input type="number" name="wholesale_price" class="f-input" step="0.01" min="0.01" required value="<?= e($price['wholesale_price'] ?? '') ?>">
                    </div>
                    <div class="f-group">
                        <label class="f-label">খুচরা মূল্য (৳) *</label>
                        <input type="number" name="retail_price" class="f-input" step="0.01" min="0.01" required value="<?= e($price['retail_price'] ?? '') ?>">
                    </div>
                </div>

                <div class="f-row">
                    <div class="f-group">
                        <label class="f-label">একক</label>
                        <select name="unit" class="f-select">
                            <?php foreach (['kg'=>'কেজি','ton'=>'টন','mon'=>'মন','piece'=>'পিস'] as $k=>$v): ?>
                                <option value="<?= $k ?>" <?= ($price['unit'] ?? 'kg') === $k ? 'selected' : '' ?>><?= $v ?></option>
                            <?php endforeach; ?>
                        </select>
                    </div>
                    <div class="f-group">
                        <label class="f-label">তারিখ *</label>
                        <input type="date" name="price_date" class="f-input" required value="<?= e($price['price_date'] ?? date('Y-m-d')) ?>" <?= $price ? 'readonly' : '' ?>>
                    </div>
                </div>

                <div class="f-group">
                    <label class="f-label">সূত্র</label>
                    <input type="text" name="source" class="f-input" placeholder="যেমন: DAM, TCB, BBS" value="<?= e($price['source'] ?? 'DAM') ?>">
                </div>

                <div style="display:flex; gap:10px; margin-top: 20px; border-top: 1px solid var(--gray-100); padding-top: 16px;">
                    <button type="submit" class="nav-pill-btn primary" style="background:var(--m4-primary)"><i class="bi bi-save"></i> <?= $price ? 'আপডেট' : 'সংরক্ষণ' ?> করুন</button>
                    <a href="<?= BASE_URL ?>/admin/prices" class="nav-pill-btn ghost">বাতিল</a>
                </div>
            </form>
        </div>
    </main>
</div>
</div>

<?php require __DIR__ . '/../../../includes/footer.php'; ?>
