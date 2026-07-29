<?php require __DIR__ . '/../../../includes/header.php'; ?>
<?php require __DIR__ . '/../../../includes/navbar.php'; ?>

<style>
.f-group { margin-bottom: 16px; }
.f-label { display: block; font-size: 13px; font-weight: 600; margin-bottom: 6px; }
.f-input, .f-select { width: 100%; padding: 11px 14px; border: 1.5px solid var(--gray-200); border-radius: 8px; font-size: 14px; box-sizing: border-box; outline: none; }
.f-input:focus, .f-select:focus { border-color: var(--m4-primary); box-shadow: 0 0 0 3px rgba(123,31,162,0.1); }
.f-row { display: grid; grid-template-columns: 1fr 1fr; gap: 12px; }
</style>

<div class="dash-page">
<div class="dash-shell">
    <?php require __DIR__ . '/../../../includes/sidebar.php'; ?>

    <main class="dash-main">
        <div class="dash-header">
            <div>
                <div class="breadcrumb"><a href="<?= BASE_URL ?>/agent/farmers">আমার কৃষক</a> <i class="bi bi-chevron-right" style="font-size:10px"></i> নতুন নিবন্ধন</div>
                <h1>🆕 নতুন কৃষক নিবন্ধন</h1>
            </div>
        </div>

        <div class="alert alert-info">
            <i class="bi bi-info-circle"></i>
            আপনি একজন কৃষকের পক্ষে রেজিস্ট্রেশন করছেন যিনি নিজে অ্যাকাউন্ট খুলতে পারছেন না।
            <strong>সফল নিবন্ধনের জন্য আপনি ৳৫০ কমিশন পাবেন।</strong>
            অস্থায়ী পাসওয়ার্ড আপনাকে দেখানো হবে — তা কৃষককে জানিয়ে দিন।
        </div>

        <div class="dash-card" style="max-width: 720px;">
            <form method="POST">
                <?= Csrf::field() ?>

                <div class="f-row">
                    <div class="f-group">
                        <label class="f-label">পূর্ণ নাম *</label>
                        <input type="text" name="full_name" class="f-input" placeholder="যেমন: মোঃ রহিম মিয়া" required>
                    </div>
                    <div class="f-group">
                        <label class="f-label">মোবাইল নম্বর *</label>
                        <input type="text" name="phone" class="f-input" placeholder="০১৭XXXXXXXX" required pattern="01[3-9][0-9]{8}">
                        <div style="font-size:11px; color:var(--gray-500); margin-top:4px;">১১ ডিজিটের ফোন নম্বর (০১৩-০১৯ দিয়ে শুরু)</div>
                    </div>
                </div>

                <div class="f-group">
                    <label class="f-label">ইমেল (ঐচ্ছিক)</label>
                    <input type="email" name="email" class="f-input" placeholder="kobir@example.com">
                </div>

                <div class="f-row">
                    <div class="f-group">
                        <label class="f-label">জেলা *</label>
                        <select name="district_id" class="f-select" required>
                            <option value="">— নির্বাচন করুন —</option>
                            <?php foreach ($districts as $d): ?>
                                <option value="<?= (int)$d['district_id'] ?>"><?= e($d['district_name']) ?></option>
                            <?php endforeach; ?>
                        </select>
                    </div>
                    <div class="f-group">
                        <label class="f-label">অস্থায়ী পাসওয়ার্ড</label>
                        <input type="text" name="password" class="f-input" placeholder="ফাঁকা রাখলে স্বয়ংক্রিয় তৈরি হবে">
                        <div style="font-size:11px; color:var(--gray-500); margin-top:4px;">ডিফল্ট: <code>farmer + ফোনের শেষ ৪ ডিজিট</code></div>
                    </div>
                </div>

                <div class="f-group">
                    <label class="f-label">ঠিকানা</label>
                    <textarea name="address" class="f-input" rows="2" style="resize:vertical; font-family:inherit;" placeholder="গ্রাম, ইউনিয়ন, উপজেলা"></textarea>
                </div>

                <div class="alert" style="background: #e8f5e9; border:1px solid #66bb6a; color:#2e7d32; padding:12px 14px; border-radius:8px; margin: 16px 0;">
                    <i class="bi bi-check2-circle"></i>
                    <strong>নিবন্ধনের পর কী ঘটবে:</strong>
                    <ul style="margin: 8px 0 0; padding-left: 20px; font-size:13px;">
                        <li>কৃষকের জন্য একাউন্ট তৈরি হবে (ফোন যাচাইকৃত)</li>
                        <li>আপনার সাথে এসাইনমেন্ট তৈরি হবে</li>
                        <li>আপনার অ্যাকাউন্টে ৳৫০ কমিশন যোগ হবে</li>
                        <li>কৃষক <code>+ফোন</code> দিয়ে লগইন করতে পারবেন</li>
                    </ul>
                </div>

                <div style="display:flex; gap:10px; margin-top: 20px; border-top: 1px solid var(--gray-100); padding-top: 16px;">
                    <button type="submit" class="nav-pill-btn primary" style="background:var(--m4-primary); padding: 11px 24px;"><i class="bi bi-person-plus"></i> কৃষক নিবন্ধন করুন</button>
                    <a href="<?= BASE_URL ?>/agent/farmers" class="nav-pill-btn ghost">বাতিল</a>
                </div>
            </form>
        </div>
    </main>
</div>
</div>

<?php require __DIR__ . '/../../../includes/footer.php'; ?>
