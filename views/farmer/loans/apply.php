<?php require __DIR__ . '/../../../includes/header.php'; ?>
<?php require __DIR__ . '/../../../includes/navbar.php'; ?>

<style>
.f-group { margin-bottom: 16px; }
.f-label { display: block; font-size: 13px; font-weight: 600; color: var(--gray-700); margin-bottom: 6px; }
.f-input, .f-select, .f-textarea { width: 100%; padding: 11px 14px; border: 1.5px solid var(--gray-200); border-radius: 8px; font-size: 14px; box-sizing: border-box; outline: none; background: #fff; }
.f-input:focus, .f-select:focus, .f-textarea:focus { border-color: var(--m3-primary); box-shadow: 0 0 0 3px rgba(245,124,0,0.1); }
.f-textarea { resize: vertical; min-height: 80px; font-family: inherit; }
</style>

<div class="dash-page">
<div class="dash-shell">
    <?php require __DIR__ . '/../../../includes/sidebar.php'; ?>

    <main class="dash-main">
        <div class="dash-header">
            <div>
                <div class="breadcrumb"><a href="<?= BASE_URL ?>/farmer/loans">লোন</a> <i class="bi bi-chevron-right" style="font-size:10px"></i> নতুন আবেদন</div>
                <h1>💰 নতুন লোনের আবেদন</h1>
            </div>
        </div>

        <?php if (!$cs['is_eligible']): ?>
            <div class="alert alert-danger">
                <i class="bi bi-exclamation-octagon"></i>
                দুঃখিত, আপনার বর্তমান ক্রেডিট স্কোর (<?= bn_num($cs['score']) ?>) লোনের জন্য পর্যাপ্ত নয়। ন্যূনতম ৫৫ স্কোর প্রয়োজন। <a href="<?= BASE_URL ?>/farmer/credit-score">কীভাবে স্কোর বাড়াবেন →</a>
            </div>
        <?php endif; ?>

        <div style="display:grid; grid-template-columns: 2fr 1fr; gap:20px;">
            <div>
                <div class="dash-card">
                    <form method="POST" id="loanForm">
                        <?= Csrf::field() ?>

                        <div class="f-group">
                            <label class="f-label">লোনের পরিমাণ (৳) <span style="color:#e53935">*</span></label>
                            <input type="number" name="loan_amount" id="loan_amount" class="f-input" min="500" max="<?= $cs['max_loan'] ?>" step="100" required placeholder="<?= bn_num($cs['max_loan']) ?> পর্যন্ত">
                            <div style="font-size:11px; color:var(--gray-500); margin-top:4px;">সর্বোচ্চ: ৳<?= bn_num(number_format($cs['max_loan'])) ?></div>
                        </div>

                        <div class="f-group">
                            <label class="f-label">মেয়াদ (মাস) <span style="color:#e53935">*</span></label>
                            <select name="tenure_months" id="tenure_months" class="f-select" required>
                                <option value="">— নির্বাচন করুন —</option>
                                <option value="3">৩ মাস</option>
                                <option value="6" selected>৬ মাস</option>
                                <option value="9">৯ মাস</option>
                                <option value="12">১২ মাস</option>
                                <option value="18">১৮ মাস</option>
                                <option value="24">২৪ মাস</option>
                            </select>
                        </div>

                        <div class="f-group">
                            <label class="f-label">লোনের উদ্দেশ্য <span style="color:#e53935">*</span></label>
                            <textarea name="loan_purpose" class="f-textarea" required placeholder="যেমন: বীজ ও সার ক্রয়, কৃষি সরঞ্জাম, সেচ যন্ত্র"></textarea>
                        </div>

                        <div class="f-group">
                            <div style="padding:14px; background: #fff7e0; border: 1px solid #ffcc80; border-radius: 8px;">
                                <strong>সুদের হার:</strong> ৮% প্রতি বছর (স্থায়ী)<br>
                                <strong>আনুমানিক মাসিক কিস্তি:</strong> <span id="emiPreview" style="color: var(--m3-primary); font-weight:700;">— ৳০</span><br>
                                <strong>মোট পরিশোধযোগ্য:</strong> <span id="totalPreview" style="color: var(--gray-700); font-weight:700;">— ৳০</span>
                            </div>
                        </div>

                        <div style="display:flex; gap:10px; margin-top: 24px;">
                            <button type="submit" class="nav-pill-btn primary" style="background:var(--m3-primary); padding:12px 32px;" <?= !$cs['is_eligible'] ? 'disabled' : '' ?>><i class="bi bi-cash"></i> আবেদন জমা দিন</button>
                            <a href="<?= BASE_URL ?>/farmer/loans" class="nav-pill-btn ghost">বাতিল</a>
                        </div>
                    </form>
                </div>
            </div>

            <div>
                <div class="dash-card" style="border-left: 4px solid var(--m3-primary);">
                    <h3 style="margin:0 0 14px; font-size:16px;"><i class="bi bi-info-circle"></i> লোন সম্পর্কে</h3>
                    <ul style="margin:0; padding-left:18px; font-size:13px; line-height:1.7;">
                        <li>সুদের হার: ৮% (বার্ষিক, সরল)</li>
                        <li>মেয়াদ: ৩ থেকে ২৪ মাস</li>
                        <li>সর্বোচ্চ পরিমাণ: ৳৫০,০০০</li>
                        <li>অনুমোদন সময়: ২-৪ কার্যদিবস</li>
                        <li>কোনো জামানত প্রয়োজন নেই</li>
                        <li>সরাসরি ওয়ালেটে বিতরণ</li>
                    </ul>
                </div>
                <div class="dash-card">
                    <h3 style="margin:0 0 14px; font-size:16px;"><i class="bi bi-shield-check"></i> আপনার যোগ্যতা</h3>
                    <div style="font-size:13px; line-height:1.8;">
                        <strong>ক্রেডিট স্কোর:</strong> <?= bn_num($cs['score']) ?> (<?= e($cs['grade']) ?>)<br>
                        <strong>সর্বোচ্চ লোন:</strong> ৳<?= bn_num(number_format($cs['max_loan'])) ?><br>
                        <strong>অবস্থা:</strong> <?= $cs['is_eligible'] ? '<span class="badge badge-success">যোগ্য</span>' : '<span class="badge badge-danger">অযোগ্য</span>' ?>
                    </div>
                </div>
            </div>
        </div>
    </main>
</div>
</div>

<script>
function calcEmi() {
    var amt = parseFloat(document.getElementById('loan_amount').value) || 0;
    var months = parseInt(document.getElementById('tenure_months').value) || 0;
    if (amt > 0 && months > 0) {
        var rate = 8;
        var interest = amt * (rate / 100) * (months / 12);
        var total = amt + interest;
        var monthly = total / months;
        var fmt = function(n) { return '৳' + n.toFixed(0).replace(/\B(?=(\d{3})+(?!\d))/g, ','); };
        document.getElementById('emiPreview').textContent = fmt(monthly);
        document.getElementById('totalPreview').textContent = fmt(total);
    }
}
document.getElementById('loan_amount').addEventListener('input', calcEmi);
document.getElementById('tenure_months').addEventListener('change', calcEmi);
</script>

<?php require __DIR__ . '/../../../includes/footer.php'; ?>
