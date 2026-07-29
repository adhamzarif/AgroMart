<?php require __DIR__ . '/../../../includes/header.php'; ?>
<?php require __DIR__ . '/../../../includes/navbar.php'; ?>

<div class="dash-page">
<div class="dash-shell">
    <?php require __DIR__ . '/../../../includes/sidebar.php'; ?>

    <main class="dash-main">
        <div class="dash-header">
            <div>
                <div class="breadcrumb">
                    <a href="<?= BASE_URL ?>/">হোম</a>
                    <i class="bi bi-chevron-right" style="font-size:10px"></i>
                    <a href="<?= BASE_URL ?>/farmer/wallet">আমার ওয়ালেট</a>
                    <i class="bi bi-chevron-right" style="font-size:10px"></i>
                    উত্তোলন
                </div>
                <h1><i class="bi bi-arrow-up-circle"></i> ওয়ালেট থেকে উত্তোলন</h1>
            </div>
            <div>
                <a href="<?= BASE_URL ?>/farmer/wallet" class="nav-pill-btn">
                    <i class="bi bi-arrow-left"></i> ফিরে যান
                </a>
            </div>
        </div>

        <?php /* Flash messages auto-render in header.php */ ?>

        <div style="display:grid; grid-template-columns: 1fr 1fr; gap: 20px;">

            <!-- Withdraw form -->
            <div class="content-card">
                <div class="card-head">
                    <h3><i class="bi bi-cash-stack"></i> উত্তোলনের বিবরণ</h3>
                </div>

                <form method="POST" action="<?= BASE_URL ?>/farmer/wallet/withdraw" id="withdrawForm">
                    <input type="hidden" name="csrf_token" value="<?= Csrf::token() ?>">

                    <div class="form-group">
                        <label>উপলব্ধ ব্যালেন্স</label>
                        <div style="font-size:28px; font-weight:800; color:#1B5E20; font-family:monospace;">
                            <?= bdt($user['wallet_balance'] ?? 0, 2) ?>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="amount">উত্তোলনের পরিমাণ (BDT) *</label>
                        <input type="number" name="amount" id="amount"
                               min="100" step="0.01"
                               max="<?= (float)($user['wallet_balance'] ?? 0) ?>"
                               required class="form-input"
                               placeholder="সর্বনিম্ন ১০০ টাকা">
                        <small class="form-hint">সর্বনিম্ন ১০০ টাকা · সর্বোচ্চ <?= bdt($user['wallet_balance'] ?? 0, 0) ?></small>
                    </div>

                    <div class="form-group">
                        <label for="method">উত্তোলনের মাধ্যম *</label>
                        <select name="method" id="method" required class="form-input">
                            <option value="">— নির্বাচন করুন —</option>
                            <option value="bkash">bKash</option>
                            <option value="nagad">Nagad</option>
                            <option value="rocket">Rocket</option>
                            <option value="bank_transfer">ব্যাংক ট্রান্সফার</option>
                        </select>
                    </div>

                    <div class="form-group">
                        <label for="account_number">অ্যাকাউন্ট নম্বর *</label>
                        <input type="text" name="account_number" id="account_number"
                               required class="form-input" maxlength="50"
                               placeholder="০১৭xxxxxxxx বা ব্যাংক অ্যাকাউন্ট নং">
                    </div>

                    <div class="form-group">
                        <label for="account_name">অ্যাকাউন্টের নাম *</label>
                        <input type="text" name="account_name" id="account_name"
                               required class="form-input" maxlength="100"
                               value="<?= e($user['full_name'] ?? '') ?>"
                               placeholder="যেমনটি ব্যাংক/মোবাইল ওয়ালেটে নিবন্ধিত">
                    </div>

                    <button type="submit" class="nav-pill-btn primary" style="width:100%; margin-top:10px;">
                        <i class="bi bi-arrow-up-circle"></i> উত্তোলনের অনুরোধ জমা দিন
                    </button>
                </form>
            </div>

            <!-- Info panel -->
            <div class="content-card" style="background:#FFF8E1; border-left:4px solid #F57C00;">
                <div class="card-head" style="border-bottom-color:#FFE0B2;">
                    <h3 style="color:#E65100;"><i class="bi bi-info-circle-fill"></i> গুরুত্বপূর্ণ তথ্য</h3>
                </div>

                <div style="font-size:13.5px; line-height:1.9; color:#5D4037;">
                    <p><strong>১. অনুমোদন প্রক্রিয়া</strong><br>
                    উত্তোলনের অনুরোধ জমা দেওয়ার পর AgroFin অ্যাডমিন ২৪-৪৮ ঘণ্টার মধ্যে যাচাই করে অনুমোদন দেবেন।</p>

                    <p><strong>২. ব্যালেন্স কর্তন</strong><br>
                    অনুরোধ <strong>অপেক্ষমাণ</strong> থাকা অবস্থায় ব্যালেন্স কাটা হবে না।</p>

                    <p><strong>৩. টাকা পৌঁছানোর সময়</strong><br>
                    অনুমোদনের পর মোবাইল ব্যাংকিং (bKash/Nagad/Rocket) — ২-৬ ঘণ্টা।<br>
                    ব্যাংক ট্রান্সফার — ১-৩ কর্মদিবস।</p>

                    <p><strong>৪. ফি</strong><br>
                    AgroFin কোনো অতিরিক্ত ফি কাটে না। তবে আপনার মোবাইল ব্যাংকিং প্রোভাইডার তাদের নিজস্ব ক্যাশ-আউট ফি কাটতে পারে।</p>

                    <!-- Security note removed as requested -->
                </div>
            </div>

        </div>
    </main>
</div>
</div>

<style>
    .form-group { margin-bottom: 16px; }
    .form-group label { display: block; font-size: 13px; font-weight: 600; color: #455A64; margin-bottom: 6px; }
    .form-input { width: 100%; padding: 10px 14px; font-size: 14px; border: 1.5px solid #CFD8DC; border-radius: 8px; transition: border-color 0.15s; font-family: inherit; }
    .form-input:focus { outline: none; border-color: #2E7D32; box-shadow: 0 0 0 3px rgba(46,125,50,0.1); }
    .form-hint { display: block; margin-top: 4px; font-size: 11px; color: #90A4AE; }
    .content-card { background: white; border-radius: 12px; padding: 20px; box-shadow: 0 2px 8px rgba(0,0,0,0.04); }
    .card-head { padding-bottom: 12px; border-bottom: 1px solid #ECEFF1; margin-bottom: 16px; }
    .card-head h3 { margin: 0; font-size: 16px; color: #263238; }
    @media (max-width: 900px) { div[style*="grid-template-columns: 1fr 1fr"] { grid-template-columns: 1fr !important; } }
</style>

<script>
    // Client-side check before submitting
    document.getElementById('withdrawForm').addEventListener('submit', function(e) {
        const amount = parseFloat(document.getElementById('amount').value);
        const balance = <?= (float)($user['wallet_balance'] ?? 0) ?>;
        if (amount < 100) {
            e.preventDefault();
            alert('সর্বনিম্ন উত্তোলনের পরিমাণ ১০০ টাকা।');
        } else if (amount > balance) {
            e.preventDefault();
            alert('আপনার ব্যালেন্সে এত টাকা নেই।');
        } else if (!confirm('আপনি কি ' + amount.toFixed(2) + ' টাকা উত্তোলনের জন্য অনুরোধ পাঠাতে চান?')) {
            e.preventDefault();
        }
    });
</script>

<?php require __DIR__ . '/../../../includes/footer.php'; ?>
