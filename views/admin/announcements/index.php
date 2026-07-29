<?php require __DIR__ . '/../../../includes/header.php'; ?>
<?php require __DIR__ . '/../../../includes/navbar.php'; ?>

<style>
.f-group { margin-bottom: 16px; }
.f-label { display: block; font-size: 13px; font-weight: 600; margin-bottom: 6px; }
.f-input, .f-select, .f-textarea { width: 100%; padding: 11px 14px; border: 1.5px solid var(--gray-200); border-radius: 8px; font-size: 14px; box-sizing: border-box; outline: none; }
.f-input:focus, .f-select:focus, .f-textarea:focus { border-color: var(--m4-primary); }
.f-textarea { resize: vertical; min-height: 110px; font-family: inherit; }
.role-chips, .district-chips { display: flex; gap: 8px; flex-wrap: wrap; }
.role-chips label { display: flex; gap: 6px; align-items: center; padding: 10px 16px; border: 1.5px solid var(--gray-200); border-radius: 99px; cursor: pointer; font-size: 14px; }
.role-chips label:has(input:checked) { background: var(--m4-primary); color: #fff; border-color: var(--m4-primary); }
.district-grid { display:grid; grid-template-columns: repeat(auto-fill, minmax(160px,1fr)); gap: 6px; max-height: 220px; overflow-y: auto; padding: 12px; border: 1.5px solid var(--gray-200); border-radius: 8px; }
.district-grid label { display:flex; gap:6px; align-items:center; font-size:13px; padding:6px 8px; border-radius:6px; cursor:pointer; }
</style>

<div class="dash-page">
<div class="dash-shell">
    <?php require __DIR__ . '/../../../includes/sidebar.php'; ?>

    <main class="dash-main">
        <div class="dash-header">
            <div>
                <div class="breadcrumb"><a href="<?= BASE_URL ?>/admin/dashboard">ড্যাশবোর্ড</a> <i class="bi bi-chevron-right" style="font-size:10px"></i> ঘোষণা</div>
                <h1>ঘোষণা ও ব্রডকাস্ট 📢</h1>
            </div>
        </div>

        <div class="alert alert-info">
            <i class="bi bi-info-circle"></i>
            ঘোষণা পাঠালে নির্বাচিত ব্যবহারকারীদের নোটিফিকেশন ইনবক্সে বার্তা চলে যাবে। কোনো ভূমিকা/জেলা নির্বাচন না করলে <strong>সকল সক্রিয় ব্যবহারকারীর</strong> কাছে যাবে।
        </div>

        <div style="display:grid; grid-template-columns: 2fr 1fr; gap: 20px;">
            <div>
                <div class="dash-card">
                    <h3 style="margin:0 0 14px;"><i class="bi bi-megaphone"></i> নতুন ঘোষণা পাঠান</h3>
                    <form method="POST" action="<?= BASE_URL ?>/admin/announcements/send">
                        <?= Csrf::field() ?>

                        <div class="f-group">
                            <label class="f-label">শিরোনাম *</label>
                            <input type="text" name="title" class="f-input" required maxlength="200" placeholder="যেমন: AgroFin সাইট রক্ষণাবেক্ষণ — ২৫ মে রাত ৯টা">
                        </div>

                        <div class="f-group">
                            <label class="f-label">বার্তা *</label>
                            <textarea name="message" class="f-textarea" required minlength="10" maxlength="2000" placeholder="বিস্তারিত বার্তা লিখুন"></textarea>
                        </div>

                        <div class="f-group">
                            <label class="f-label">অগ্রাধিকার</label>
                            <select name="priority" class="f-select">
                                <option value="low">নিম্ন</option>
                                <option value="medium" selected>মাঝারি</option>
                                <option value="high">উচ্চ</option>
                                <option value="urgent">জরুরি</option>
                            </select>
                        </div>

                        <div class="f-group">
                            <label class="f-label">লক্ষ্য ভূমিকা <span style="color:var(--gray-500); font-weight:400; font-size:11px;">(ফাঁকা = সবাই)</span></label>
                            <div class="role-chips">
                                <?php foreach (['farmer'=>'👨‍🌾 কৃষক','buyer'=>'🛒 ক্রেতা','agent'=>'🤝 এজেন্ট'] as $k=>$v): ?>
                                    <label>
                                        <input type="checkbox" name="roles[]" value="<?= $k ?>">
                                        <?= $v ?>
                                    </label>
                                <?php endforeach; ?>
                            </div>
                        </div>

                        <div class="f-group">
                            <label class="f-label">লক্ষ্য জেলা <span style="color:var(--gray-500); font-weight:400; font-size:11px;">(ফাঁকা = সব জেলা)</span></label>
                            <div style="margin-bottom: 6px;">
                                <button type="button" onclick="document.querySelectorAll('input[name=\'districts[]\']').forEach(c=>c.checked=true);" class="nav-pill-btn ghost" style="font-size:11px; padding:4px 10px;">সব নির্বাচন</button>
                                <button type="button" onclick="document.querySelectorAll('input[name=\'districts[]\']').forEach(c=>c.checked=false);" class="nav-pill-btn ghost" style="font-size:11px; padding:4px 10px;">সব মুছুন</button>
                            </div>
                            <div class="district-grid">
                                <?php foreach ($districts as $d): ?>
                                    <label>
                                        <input type="checkbox" name="districts[]" value="<?= (int)$d['district_id'] ?>">
                                        <?= e($d['district_name']) ?>
                                    </label>
                                <?php endforeach; ?>
                            </div>
                        </div>

                        <div style="display:flex; gap:10px; margin-top: 18px; border-top: 1px solid var(--gray-100); padding-top: 16px;">
                            <button type="submit" class="nav-pill-btn primary" style="background:var(--m4-primary);" onclick="return confirm('ঘোষণা পাঠাতে চান?');"><i class="bi bi-send"></i> ঘোষণা পাঠান</button>
                        </div>
                    </form>
                </div>
            </div>

            <div>
                <div class="dash-card">
                    <h3 style="margin:0 0 14px;"><i class="bi bi-clock-history"></i> পূর্বের ঘোষণা</h3>
                    <?php if (empty($broadcasts)): ?>
                        <p style="text-align:center; color:var(--gray-500); font-size:13px; padding: 14px;">এখনো কোনো ঘোষণা পাঠানো হয়নি।</p>
                    <?php else: foreach (array_slice($broadcasts, 0, 8) as $b):
                        $readPct = $b['recipient_count'] > 0 ? ($b['read_count'] / $b['recipient_count']) * 100 : 0;
                    ?>
                        <div style="padding: 12px; border-bottom: 1px solid var(--gray-100); margin-bottom: 8px;">
                            <strong style="font-size:13px; display:block;"><?= e(str_replace('📢 ', '', $b['title'])) ?></strong>
                            <div style="font-size:11px; color:var(--gray-500); margin: 4px 0;"><?= e(mb_substr($b['message'], 0, 70, 'UTF-8')) ?>...</div>
                            <div style="font-size:11px; color:var(--gray-500); display:flex; justify-content:space-between;">
                                <span><?= bn_date($b['sent_at'], true) ?></span>
                                <span>📨 <?= bn_num($b['recipient_count']) ?> | 👁 <?= bn_num((int)$readPct) ?>%</span>
                            </div>
                        </div>
                    <?php endforeach; endif; ?>
                </div>
            </div>
        </div>
    </main>
</div>
</div>

<?php require __DIR__ . '/../../../includes/footer.php'; ?>
