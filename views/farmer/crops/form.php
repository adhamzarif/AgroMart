<?php require __DIR__ . '/../../../includes/header.php'; ?>
<?php require __DIR__ . '/../../../includes/navbar.php'; ?>

<style>
.f-group { margin-bottom: 16px; }
.f-label { display: block; font-size: 13px; font-weight: 600; color: var(--gray-700); margin-bottom: 6px; }
.f-label .req { color: #e53935; }
.f-input, .f-select, .f-textarea { width: 100%; padding: 10px 12px; border: 1.5px solid var(--gray-200); border-radius: 8px; font-size: 14px; box-sizing: border-box; outline: none; transition: border 0.2s; background: #fff; }
.f-input:focus, .f-select:focus, .f-textarea:focus { border-color: var(--m1-primary); box-shadow: 0 0 0 3px rgba(46,125,50,0.1); }
.f-textarea { resize: vertical; min-height: 90px; font-family: inherit; }
.f-row { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; }
.f-row-3 { display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 12px; }
.image-preview { width: 90px; height: 90px; border-radius: 8px; object-fit: cover; border: 1.5px solid var(--gray-200); }
.image-preview-wrap { position: relative; display: inline-block; margin: 6px; }
.image-remove-btn { position: absolute; top: -8px; right: -8px; background: var(--danger); color: #fff; border: 2px solid #fff; width: 22px; height: 22px; border-radius: 50%; cursor: pointer; font-size: 10px; line-height: 0; }
@media(max-width: 700px) { .f-row, .f-row-3 { grid-template-columns: 1fr; } }
</style>

<div class="dash-page">
<div class="dash-shell">
    <?php require __DIR__ . '/../../../includes/sidebar.php'; ?>

    <main class="dash-main">
        <div class="dash-header">
            <div>
                <div class="breadcrumb"><a href="<?= BASE_URL ?>/farmer/crops">আমার ফসল</a> <i class="bi bi-chevron-right" style="font-size:10px"></i> <?= $crop ? 'সম্পাদনা' : 'নতুন যোগ' ?></div>
                <h1><?= $crop ? '✏ ফসল সম্পাদনা' : '➕ নতুন ফসল যোগ করুন' ?></h1>
            </div>
        </div>

        <div class="dash-card">
            <form method="POST" enctype="multipart/form-data" id="cropForm">
                <?= Csrf::field() ?>

                <div class="f-row">
                    <div class="f-group">
                        <label class="f-label">ফসলের নাম <span class="req">*</span></label>
                        <input type="text" name="crop_name" class="f-input" placeholder="যেমন: বোরো ধান" required value="<?= e($crop['crop_name'] ?? '') ?>">
                    </div>
                    <div class="f-group">
                        <label class="f-label">জাত (ভেরাইটি)</label>
                        <input type="text" name="crop_variety" class="f-input" placeholder="যেমন: BRRI Dhan-28" value="<?= e($crop['crop_variety'] ?? '') ?>">
                    </div>
                </div>

                <div class="f-group">
                    <label class="f-label">ক্যাটাগরি <span class="req">*</span></label>
                    <select name="category_id" class="f-select" required>
                        <option value="">— নির্বাচন করুন —</option>
                        <?php foreach ($categories as $cat): ?>
                            <option value="<?= (int)$cat['category_id'] ?>" <?= ($crop['category_id'] ?? 0) == $cat['category_id'] ? 'selected' : '' ?>><?= e($cat['icon']) ?> <?= e($cat['category_name_bn']) ?></option>
                        <?php endforeach; ?>
                    </select>
                </div>

                <div class="f-row-3">
                    <div class="f-group">
                        <label class="f-label">পরিমাণ <span class="req">*</span></label>
                        <input type="number" name="quantity" class="f-input" step="0.01" min="0.01" required value="<?= e($crop['quantity'] ?? '') ?>">
                    </div>
                    <div class="f-group">
                        <label class="f-label">একক <span class="req">*</span></label>
                        <select name="unit" class="f-select" required>
                            <?php foreach (['kg'=>'কেজি','ton'=>'টন','mon'=>'মন','piece'=>'পিস'] as $k => $v): ?>
                                <option value="<?= $k ?>" <?= ($crop['unit'] ?? 'kg') === $k ? 'selected' : '' ?>><?= $v ?></option>
                            <?php endforeach; ?>
                        </select>
                    </div>
                    <div class="f-group">
                        <label class="f-label">প্রতি এককের মূল্য (৳) <span class="req">*</span></label>
                        <input type="number" name="price_per_unit" class="f-input" step="0.01" min="0.01" required value="<?= e($crop['price_per_unit'] ?? '') ?>">
                    </div>
                </div>

                <div class="f-row-3">
                    <div class="f-group">
                        <label class="f-label">মান গ্রেড</label>
                        <select name="quality_grade" class="f-select">
                            <?php foreach (['A'=>'A - প্রিমিয়াম','B'=>'B - সাধারণ','C'=>'C - সীমিত'] as $k => $v): ?>
                                <option value="<?= $k ?>" <?= ($crop['quality_grade'] ?? 'B') === $k ? 'selected' : '' ?>><?= $v ?></option>
                            <?php endforeach; ?>
                        </select>
                    </div>
                    <div class="f-group" style="display:flex; align-items:end; padding-bottom: 10px;">
                        <label style="display:flex; align-items:center; gap:8px; cursor:pointer; font-size:14px; color:var(--gray-800);">
                            <input type="checkbox" name="is_organic" value="1" <?= ($crop['is_organic'] ?? 0) ? 'checked' : '' ?>>
                            🍃 জৈব পদ্ধতিতে চাষ
                        </label>
                    </div>
                    <div class="f-group">
                        <label class="f-label">ফসল কাটার তারিখ</label>
                        <input type="date" name="harvest_date" class="f-input" value="<?= e($crop['harvest_date'] ?? '') ?>">
                    </div>
                </div>

                <div class="f-row">
                    <div class="f-group">
                        <label class="f-label">উপলব্ধ হবে যখন থেকে <span class="req">*</span></label>
                        <input type="date" name="available_from" class="f-input" required value="<?= e($crop['available_from'] ?? date('Y-m-d')) ?>">
                    </div>
                    <div class="f-group">
                        <label class="f-label">উপলব্ধ থাকবে যতদিন</label>
                        <input type="date" name="available_until" class="f-input" value="<?= e($crop['available_until'] ?? '') ?>">
                    </div>
                </div>

                <div class="f-group">
                    <label class="f-label">বিবরণ</label>
                    <textarea name="description" class="f-textarea" placeholder="ফসলটি সম্পর্কে আরো তথ্য (চাষের পদ্ধতি, মান, প্যাকেজিং ইত্যাদি)"><?= e($crop['description'] ?? '') ?></textarea>
                </div>

                <div class="f-group">
                    <label class="f-label">ছবি (সর্বোচ্চ ৫টি, JPG/PNG/WEBP, প্রতিটি ৩MB পর্যন্ত)</label>
                    <?php if (!empty($images)): ?>
                        <div style="margin-bottom: 10px;">
                            <?php foreach ($images as $img): ?>
                                <span class="image-preview-wrap">
                                    <img src="<?= e(upload_url('crops/' . $img)) ?>" class="image-preview">
                                    <input type="hidden" name="keep_image[]" value="<?= e($img) ?>" data-img="<?= e($img) ?>">
                                    <button type="button" class="image-remove-btn" onclick="this.parentElement.querySelector('input').remove(); this.parentElement.remove();">×</button>
                                </span>
                            <?php endforeach; ?>
                        </div>
                    <?php endif; ?>
                    <input type="file" name="images[]" class="f-input" accept="image/jpeg,image/png,image/webp" multiple>
                </div>

                <div style="display:flex; gap:10px; margin-top: 24px; border-top: 1px solid var(--gray-100); padding-top:18px;">
                    <button type="submit" class="nav-pill-btn primary" style="padding: 10px 28px;"><i class="bi bi-save"></i> <?= $crop ? 'আপডেট করুন' : 'সংরক্ষণ করুন' ?></button>
                    <a href="<?= BASE_URL ?>/farmer/crops" class="nav-pill-btn ghost">বাতিল</a>
                </div>
            </form>
        </div>
    </main>
</div>
</div>

<?php require __DIR__ . '/../../../includes/footer.php'; ?>
