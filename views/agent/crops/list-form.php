<?php require __DIR__ . '/../../../includes/header.php'; ?>
<?php require __DIR__ . '/../../../includes/navbar.php'; ?>

<style>
.f-group { margin-bottom: 16px; }
.f-label { display: block; font-size: 13px; font-weight: 600; margin-bottom: 6px; }
.f-input, .f-select, .f-textarea { width: 100%; padding: 11px 14px; border: 1.5px solid var(--gray-200); border-radius: 8px; font-size: 14px; box-sizing: border-box; outline: none; }
.f-input:focus, .f-select:focus { border-color: var(--m1-primary); }
.f-textarea { resize: vertical; min-height: 80px; font-family: inherit; }
.f-row { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; }
.f-row-3 { display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 12px; }
@media(max-width:700px) { .f-row, .f-row-3 { grid-template-columns: 1fr; } }
</style>

<div class="dash-page">
<div class="dash-shell">
    <?php require __DIR__ . '/../../../includes/sidebar.php'; ?>

    <main class="dash-main">
        <div class="dash-header">
            <div>
                <div class="breadcrumb"><a href="<?= BASE_URL ?>/agent/crops">ফসল লিস্ট</a> <i class="bi bi-chevron-right" style="font-size:10px"></i> ফরম</div>
                <h1>🌾 <?= e($farmer['full_name']) ?> এর পক্ষে ফসল লিস্ট</h1>
            </div>
        </div>

        <div class="alert" style="background:#e8f5e9; border:1px solid #66bb6a; padding:10px 14px; border-radius:8px;">
            <i class="bi bi-info-circle"></i>
            আপনি <strong><?= e($farmer['full_name']) ?></strong> ({<?= e($farmer['phone']) ?>}) এর পক্ষে নতুন ফসল লিস্ট করছেন। সফলভাবে লিস্ট হলে ৳২০ কমিশন পাবেন।
        </div>

        <div class="dash-card">
            <form method="POST" enctype="multipart/form-data">
                <?= Csrf::field() ?>

                <div class="f-row">
                    <div class="f-group">
                        <label class="f-label">ফসলের নাম *</label>
                        <input type="text" name="crop_name" class="f-input" required placeholder="যেমন: টমেটো">
                    </div>
                    <div class="f-group">
                        <label class="f-label">জাত</label>
                        <input type="text" name="crop_variety" class="f-input" placeholder="যেমন: BARI Tomato-7">
                    </div>
                </div>

                <div class="f-group">
                    <label class="f-label">ক্যাটাগরি *</label>
                    <select name="category_id" class="f-select" required>
                        <option value="">— নির্বাচন করুন —</option>
                        <?php foreach ($categories as $c): ?>
                            <option value="<?= (int)$c['category_id'] ?>"><?= e($c['icon']) ?> <?= e($c['category_name_bn']) ?></option>
                        <?php endforeach; ?>
                    </select>
                </div>

                <div class="f-row-3">
                    <div class="f-group">
                        <label class="f-label">পরিমাণ *</label>
                        <input type="number" name="quantity" class="f-input" step="0.01" min="0.01" required>
                    </div>
                    <div class="f-group">
                        <label class="f-label">একক *</label>
                        <select name="unit" class="f-select" required>
                            <option value="kg">কেজি</option><option value="ton">টন</option><option value="mon">মন</option><option value="piece">পিস</option>
                        </select>
                    </div>
                    <div class="f-group">
                        <label class="f-label">প্রতি এককের মূল্য (৳) *</label>
                        <input type="number" name="price_per_unit" class="f-input" step="0.01" min="0.01" required>
                    </div>
                </div>

                <div class="f-row-3">
                    <div class="f-group">
                        <label class="f-label">গ্রেড</label>
                        <select name="quality_grade" class="f-select">
                            <option value="A">A - প্রিমিয়াম</option>
                            <option value="B" selected>B - সাধারণ</option>
                            <option value="C">C - সীমিত</option>
                        </select>
                    </div>
                    <div class="f-group" style="display:flex; align-items:end; padding-bottom: 10px;">
                        <label style="display:flex; gap:8px; align-items:center; cursor:pointer; font-size:14px;">
                            <input type="checkbox" name="is_organic" value="1"> 🍃 জৈব
                        </label>
                    </div>
                    <div class="f-group">
                        <label class="f-label">ফসল কাটার তারিখ</label>
                        <input type="date" name="harvest_date" class="f-input">
                    </div>
                </div>

                <div class="f-row">
                    <div class="f-group">
                        <label class="f-label">উপলব্ধ হবে *</label>
                        <input type="date" name="available_from" class="f-input" required value="<?= date('Y-m-d') ?>">
                    </div>
                    <div class="f-group">
                        <label class="f-label">উপলব্ধ থাকবে যতদিন</label>
                        <input type="date" name="available_until" class="f-input">
                    </div>
                </div>

                <div class="f-group">
                    <label class="f-label">বিবরণ</label>
                    <textarea name="description" class="f-textarea" placeholder="ফসলের গুণমান, চাষের পদ্ধতি ইত্যাদি"></textarea>
                </div>

                <div class="f-group">
                    <label class="f-label">ছবি (সর্বোচ্চ ৫টি)</label>
                    <input type="file" name="images[]" class="f-input" accept="image/jpeg,image/png,image/webp" multiple>
                </div>

                <div style="display:flex; gap:10px; margin-top: 20px; border-top: 1px solid var(--gray-100); padding-top: 16px;">
                    <button type="submit" class="nav-pill-btn primary"><i class="bi bi-save"></i> লিস্ট করুন (৳২০ কমিশন)</button>
                    <a href="<?= BASE_URL ?>/agent/crops" class="nav-pill-btn ghost">বাতিল</a>
                </div>
            </form>
        </div>
    </main>
</div>
</div>

<?php require __DIR__ . '/../../../includes/footer.php'; ?>
