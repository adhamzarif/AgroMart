<?php require __DIR__ . '/../../../includes/header.php'; ?>
<?php require __DIR__ . '/../../../includes/navbar.php'; ?>

<style>
.f-group { margin-bottom: 16px; }
.f-label { display: block; font-size: 13px; font-weight: 600; margin-bottom: 6px; }
.f-input, .f-select, .f-textarea { width: 100%; padding: 11px 14px; border: 1.5px solid var(--gray-200); border-radius: 8px; font-size: 14px; box-sizing: border-box; outline: none; }
.f-input:focus, .f-select:focus { border-color: var(--m4-primary); }
.f-textarea { resize: vertical; min-height: 70px; font-family: inherit; }
.f-row { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; }
</style>

<div class="dash-page">
<div class="dash-shell">
    <?php require __DIR__ . '/../../../includes/sidebar.php'; ?>

    <main class="dash-main">
        <div class="dash-header">
            <div>
                <div class="breadcrumb"><a href="<?= BASE_URL ?>/admin/categories">ক্যাটাগরি</a> <i class="bi bi-chevron-right" style="font-size:10px"></i> <?= $cat ? 'সম্পাদনা' : 'নতুন' ?></div>
                <h1><?= $cat ? '✏ ক্যাটাগরি সম্পাদনা' : '➕ নতুন ক্যাটাগরি' ?></h1>
            </div>
        </div>

        <div class="dash-card" style="max-width: 720px;">
            <form method="POST">
                <?= Csrf::field() ?>

                <div class="f-row">
                    <div class="f-group">
                        <label class="f-label">বাংলা নাম *</label>
                        <input type="text" name="category_name_bn" class="f-input" required value="<?= e($cat['category_name_bn'] ?? '') ?>" placeholder="যেমন: শাক-সবজি">
                    </div>
                    <div class="f-group">
                        <label class="f-label">ইংরেজি নাম *</label>
                        <input type="text" name="category_name" class="f-input" required value="<?= e($cat['category_name'] ?? '') ?>" placeholder="যেমন: vegetables">
                    </div>
                </div>

                <div class="f-row">
                    <div class="f-group">
                        <label class="f-label">আইকন (ইমোজি)</label>
                        <input type="text" name="icon" class="f-input" maxlength="50" value="<?= e($cat['icon'] ?? '') ?>" placeholder="🥬">
                    </div>
                    <div class="f-group">
                        <label class="f-label">প্যারেন্ট ক্যাটাগরি (ঐচ্ছিক)</label>
                        <select name="parent_category_id" class="f-select">
                            <option value="">— শীর্ষ স্তর —</option>
                            <?php foreach ($allForParents as $p):
                                if ($cat && $p['category_id'] == $cat['category_id']) continue; // can't be its own parent
                            ?>
                                <option value="<?= (int)$p['category_id'] ?>" <?= ($cat['parent_category_id'] ?? 0) == $p['category_id'] ? 'selected' : '' ?>><?= e($p['icon'] ?? '') ?> <?= e($p['category_name_bn']) ?></option>
                            <?php endforeach; ?>
                        </select>
                    </div>
                </div>

                <div class="f-group">
                    <label class="f-label">বিবরণ</label>
                    <textarea name="description" class="f-textarea" maxlength="500" placeholder="ক্যাটাগরি সম্পর্কে সংক্ষিপ্ত বিবরণ"><?= e($cat['description'] ?? '') ?></textarea>
                </div>

                <div style="display:flex; gap:10px; margin-top: 18px; border-top: 1px solid var(--gray-100); padding-top: 16px;">
                    <button type="submit" class="nav-pill-btn primary" style="background:var(--m4-primary);"><i class="bi bi-save"></i> <?= $cat ? 'আপডেট' : 'সংরক্ষণ' ?> করুন</button>
                    <a href="<?= BASE_URL ?>/admin/categories" class="nav-pill-btn ghost">বাতিল</a>
                </div>
            </form>
        </div>
    </main>
</div>
</div>

<?php require __DIR__ . '/../../../includes/footer.php'; ?>
