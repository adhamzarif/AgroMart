<?php require __DIR__ . '/../../../includes/header.php'; ?>
<?php require __DIR__ . '/../../../includes/navbar.php'; ?>

<style>
.f-group { margin-bottom: 16px; }
.f-label { display: block; font-size: 13px; font-weight: 600; margin-bottom: 6px; }
.f-input, .f-select, .f-textarea { width: 100%; padding: 11px 14px; border: 1.5px solid var(--gray-200); border-radius: 8px; font-size: 14px; box-sizing: border-box; outline: none; }
.f-input:focus, .f-select:focus, .f-textarea:focus { border-color: var(--m4-primary); }
.f-textarea { resize: vertical; min-height: 90px; font-family: inherit; }
.f-row { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; }
.district-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(160px, 1fr)); gap: 6px; max-height: 250px; overflow-y: auto; padding: 12px; border: 1.5px solid var(--gray-200); border-radius: 8px; }
.district-chip label { display: flex; gap: 6px; align-items: center; font-size: 13px; padding: 6px 8px; border-radius: 6px; cursor: pointer; transition: background 0.15s; }
.district-chip label:hover { background: var(--gray-50); }
</style>

<div class="dash-page">
<div class="dash-shell">
    <?php require __DIR__ . '/../../../includes/sidebar.php'; ?>

    <main class="dash-main">
        <div class="dash-header">
            <div>
                <div class="breadcrumb"><a href="<?= BASE_URL ?>/admin/weather">আবহাওয়া</a> <i class="bi bi-chevron-right" style="font-size:10px"></i> নতুন সতর্কতা</div>
                <h1>⛈ নতুন আবহাওয়া সতর্কতা</h1>
            </div>
        </div>

        <div class="alert alert-info">
            <i class="bi bi-info-circle"></i>
            সতর্কতা প্রকাশ করলে সংশ্লিষ্ট জেলার সকল সক্রিয় কৃষক স্বয়ংক্রিয়ভাবে নোটিফিকেশন পাবেন।
        </div>

        <div class="dash-card">
            <form method="POST">
                <?= Csrf::field() ?>

                <div class="f-row">
                    <div class="f-group">
                        <label class="f-label">দুর্যোগের ধরন *</label>
                        <select name="alert_type" class="f-select" required>
                            <option value="flood">🌊 বন্যা</option>
                            <option value="cyclone">🌀 ঘূর্ণিঝড়</option>
                            <option value="drought">☀ খরা</option>
                            <option value="heavy_rain">🌧 ভারী বর্ষণ</option>
                            <option value="heatwave">🔥 তাপদাহ</option>
                            <option value="cold_wave">❄ শৈত্যপ্রবাহ</option>
                            <option value="storm" selected>⛈ ঝড়</option>
                        </select>
                    </div>
                    <div class="f-group">
                        <label class="f-label">তীব্রতা *</label>
                        <select name="severity" class="f-select" required>
                            <option value="low">নিম্ন</option>
                            <option value="medium" selected>মাঝারি</option>
                            <option value="high">উচ্চ</option>
                            <option value="severe">গুরুতর</option>
                        </select>
                    </div>
                </div>

                <div class="f-group">
                    <label class="f-label">শিরোনাম *</label>
                    <input type="text" name="alert_title" class="f-input" required placeholder="যেমন: পরবর্তী ৭২ ঘণ্টায় ভারী বর্ষণের সম্ভাবনা" maxlength="200">
                </div>

                <div class="f-group">
                    <label class="f-label">প্রভাবিত জেলা * (একাধিক নির্বাচন করুন)</label>
                    <div style="margin-bottom: 6px;">
                        <button type="button" onclick="document.querySelectorAll('input[name=\'affected_districts[]\']').forEach(c=>c.checked=true);" class="nav-pill-btn ghost" style="font-size:11px; padding:4px 10px;">সব নির্বাচন</button>
                        <button type="button" onclick="document.querySelectorAll('input[name=\'affected_districts[]\']').forEach(c=>c.checked=false);" class="nav-pill-btn ghost" style="font-size:11px; padding:4px 10px;">সব মুছুন</button>
                    </div>
                    <div class="district-grid">
                        <?php foreach ($districts as $d): ?>
                            <div class="district-chip">
                                <label>
                                    <input type="checkbox" name="affected_districts[]" value="<?= (int)$d['district_id'] ?>">
                                    <?= e($d['district_name']) ?>
                                </label>
                            </div>
                        <?php endforeach; ?>
                    </div>
                </div>

                <div class="f-group">
                    <label class="f-label">বার্তা *</label>
                    <textarea name="alert_message" class="f-textarea" required placeholder="সতর্কতার বিস্তারিত বার্তা" maxlength="2000"></textarea>
                </div>

                <div class="f-group">
                    <label class="f-label">কৃষকদের জন্য সুপারিশ</label>
                    <textarea name="recommendations" class="f-textarea" placeholder="যেমন: ফসল কর্তন এগিয়ে আনুন, সেচ বন্ধ রাখুন, পশুসম্পদ সরিয়ে রাখুন" maxlength="2000"></textarea>
                </div>

                <div class="f-group">
                    <label class="f-label">প্রভাবিত ফসল (কমা দিয়ে আলাদা)</label>
                    <input type="text" name="affected_crops" class="f-input" placeholder="যেমন: ধান, পাট, সবজি">
                </div>

                <div class="f-row">
                    <div class="f-group">
                        <label class="f-label">শুরুর সময় *</label>
                        <input type="datetime-local" name="start_time" class="f-input" required value="<?= date('Y-m-d\TH:i') ?>">
                    </div>
                    <div class="f-group">
                        <label class="f-label">শেষ হওয়ার সময়</label>
                        <input type="datetime-local" name="end_time" class="f-input">
                    </div>
                </div>

                <div class="f-group">
                    <label class="f-label">সূত্র</label>
                    <input type="text" name="issued_by" class="f-input" value="BMD" placeholder="যেমন: BMD, FFWC, ICAR">
                </div>

                <div style="display:flex; gap:10px; margin-top: 20px; border-top: 1px solid var(--gray-100); padding-top: 16px;">
                    <button type="submit" class="nav-pill-btn primary" style="background:var(--m4-primary);"><i class="bi bi-megaphone"></i> প্রকাশ করুন ও কৃষকদের জানান</button>
                    <a href="<?= BASE_URL ?>/admin/weather" class="nav-pill-btn ghost">বাতিল</a>
                </div>
            </form>
        </div>
    </main>
</div>
</div>

<?php require __DIR__ . '/../../../includes/footer.php'; ?>
