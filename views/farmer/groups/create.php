<?php require __DIR__ . '/../../../includes/header.php'; ?>
<?php require __DIR__ . '/../../../includes/navbar.php'; ?>

<style>
.f-group { margin-bottom: 16px; }
.f-label { display: block; font-size: 13px; font-weight: 600; margin-bottom: 6px; }
.f-input, .f-select, .f-textarea { width: 100%; padding: 11px 14px; border: 1.5px solid var(--gray-200); border-radius: 8px; font-size: 14px; box-sizing: border-box; outline: none; }
.f-input:focus, .f-select:focus { border-color: var(--m1-primary); }
.f-textarea { resize: vertical; min-height: 80px; font-family: inherit; }
.f-row { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; }
</style>

<div class="dash-page">
<div class="dash-shell">
    <?php require __DIR__ . '/../../../includes/sidebar.php'; ?>

    <main class="dash-main">
        <div class="dash-header">
            <div>
                <div class="breadcrumb"><a href="<?= BASE_URL ?>/farmer/groups">গ্রুপ</a> <i class="bi bi-chevron-right" style="font-size:10px"></i> নতুন</div>
                <h1>👥 নতুন কৃষক গ্রুপ তৈরি</h1>
            </div>
        </div>

        <div class="alert alert-info">
            <i class="bi bi-info-circle"></i>
            গ্রুপ তৈরি করার পর আপনি স্বয়ংক্রিয়ভাবে গ্রুপের লিডার হবেন। অন্য কৃষকরা গ্রুপ কোড ব্যবহার করে যোগ দিতে পারবেন।
        </div>

        <div class="dash-card" style="max-width: 720px;">
            <form method="POST">
                <?= Csrf::field() ?>

                <div class="f-group">
                    <label class="f-label">গ্রুপের নাম *</label>
                    <input type="text" name="group_name" class="f-input" required placeholder="যেমন: শ্যামপুর কৃষি সমিতি" maxlength="100">
                </div>

                <div class="f-row">
                    <div class="f-group">
                        <label class="f-label">জেলা *</label>
                        <select name="district_id" class="f-select" required>
                            <?php foreach ($districts as $d): ?>
                                <option value="<?= (int)$d['district_id'] ?>" <?= ($_SESSION['district_id'] ?? 0) == $d['district_id'] ? 'selected' : '' ?>><?= e($d['district_name']) ?></option>
                            <?php endforeach; ?>
                        </select>
                    </div>
                    <div class="f-group">
                        <label class="f-label">আপনার ভূমির অবদান (একর)</label>
                        <input type="number" name="land_contribution" class="f-input" step="0.01" min="0" value="0" placeholder="যেমন: 2.5">
                    </div>
                </div>

                <div class="f-group">
                    <label class="f-label">গঠনের তারিখ</label>
                    <input type="date" name="formation_date" class="f-input" value="<?= date('Y-m-d') ?>">
                </div>

                <div class="f-group">
                    <label class="f-label">বিবরণ</label>
                    <textarea name="description" class="f-textarea" placeholder="গ্রুপের উদ্দেশ্য ও কর্মকাণ্ড সম্পর্কে লিখুন" maxlength="500"></textarea>
                </div>

                <div class="alert" style="background: #e8f5e9; border: 1px solid #66bb6a; color: #2e7d32; padding: 12px 14px; border-radius: 8px; margin: 14px 0;">
                    <i class="bi bi-shield-check"></i>
                    <strong>গ্রুপ লিডার হিসেবে আপনার দায়িত্ব:</strong>
                    <ul style="margin: 6px 0 0; padding-left: 20px; font-size:13px;">
                        <li>নতুন সদস্য অনুমোদন</li>
                        <li>সম্মিলিত সিদ্ধান্ত গ্রহণ</li>
                        <li>বহিরাগতদের সাথে যোগাযোগ</li>
                        <li>গ্রুপের কার্যক্রম তদারকি</li>
                    </ul>
                </div>

                <div style="display:flex; gap:10px; margin-top: 18px; border-top: 1px solid var(--gray-100); padding-top: 16px;">
                    <button type="submit" class="nav-pill-btn primary"><i class="bi bi-people-fill"></i> গ্রুপ তৈরি করুন</button>
                    <a href="<?= BASE_URL ?>/farmer/groups" class="nav-pill-btn ghost">বাতিল</a>
                </div>
            </form>
        </div>
    </main>
</div>
</div>

<?php require __DIR__ . '/../../../includes/footer.php'; ?>
