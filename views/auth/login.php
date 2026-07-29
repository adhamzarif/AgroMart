<?php require __DIR__ . '/../../includes/header.php'; ?>

<style>
    .login-page {
        min-height: 100vh; display: flex; align-items: center; justify-content: center;
        background: linear-gradient(135deg, #f0f7ee 0%, #e8f5e9 50%, #f5f9f4 100%);
        padding: 40px 20px;
    }
    .login-box {
        width: 100%; max-width: 440px; background: #fff;
        border-radius: 20px; box-shadow: 0 8px 40px rgba(0,0,0,0.08);
        padding: 44px 36px;
    }
    .login-box .logo { text-align: center; margin-bottom: 8px; }
    .login-box .logo a { font-family: var(--font-display); font-size: 28px; font-weight: 800; color: var(--m1-primary); text-decoration: none; }
    .login-box .form-title { text-align: center; font-size: 22px; font-weight: 700; color: var(--gray-900); margin: 0 0 4px; }
    .login-box .form-sub { text-align: center; font-size: 13px; color: var(--gray-500); margin: 0 0 30px; }

    .f-group { margin-bottom: 18px; }
    .f-label { display: block; font-size: 13px; font-weight: 600; color: var(--gray-700); margin-bottom: 6px; }
    .f-label .req { color: #e53935; }
    .f-input-wrap { position: relative; }
    .f-input-wrap .f-icon { position: absolute; left: 14px; top: 50%; transform: translateY(-50%); font-size: 16px; color: var(--gray-400); pointer-events: none; }
    .f-input { width: 100%; padding: 12px 14px 12px 40px; border: 1.5px solid var(--gray-200); border-radius: 10px; font-size: 14px; color: var(--gray-800); background: #fff; outline: none; transition: border-color 0.2s, box-shadow 0.2s; box-sizing: border-box; }
    .f-input:focus { border-color: var(--m1-primary); box-shadow: 0 0 0 3px rgba(46,125,50,0.1); }
    .pw-toggle { position: absolute; right: 14px; top: 50%; transform: translateY(-50%); background: none; border: none; cursor: pointer; color: var(--gray-400); font-size: 16px; padding: 0; }
    .pw-toggle:hover { color: var(--gray-600); }
    .login-btn {
        width: 100%; padding: 13px; border: none; border-radius: 12px; font-size: 15px; font-weight: 700;
        color: #fff; background: linear-gradient(135deg, #2e7d32, #1b5e20); cursor: pointer;
        transition: transform 0.2s, box-shadow 0.2s; margin-top: 6px;
    }
    .login-btn:hover { transform: translateY(-1px); box-shadow: 0 6px 20px rgba(46,125,50,0.3); }
    .pw-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 6px; }
    .pw-header .f-label { margin-bottom: 0; }
    .forgot-link { font-size: 12px; color: var(--m1-primary); text-decoration: none; font-weight: 500; }
    .login-divider { display: flex; align-items: center; gap: 12px; margin: 22px 0; color: var(--gray-400); font-size: 12px; }
    .login-divider::before, .login-divider::after { content: ''; flex: 1; height: 1px; background: var(--gray-200); }
    .login-footer { text-align: center; font-size: 13px; color: var(--gray-500); }
    .login-footer a { color: var(--m1-primary); font-weight: 600; text-decoration: none; }
    .demo-box { margin-top: 22px; padding: 14px; background: #f7fbf6; border: 1px dashed #c8e6c9; border-radius: 10px; font-size: 12px; color: var(--gray-600); }
    .demo-box strong { color: var(--m1-dark); }
    .demo-box code { background: #fff; padding: 1px 6px; border-radius: 4px; font-family: var(--font-mono); font-size: 11px; color: var(--m1-primary); }
</style>

<div class="login-page">
    <div class="login-box">
        <div class="logo"><a href="<?= BASE_URL ?>/">🌾 AgroFin</a></div>
        <h2 class="form-title">স্বাগতম, ফিরে এসেছেন</h2>
        <p class="form-sub">আপনার অ্যাকাউন্টে লগইন করুন</p>

        <form action="<?= BASE_URL ?>/auth/login" method="POST" autocomplete="on">
            <?= Csrf::field() ?>

            <div class="f-group">
                <label class="f-label">মোবাইল নম্বর / ইমেইল <span class="req">*</span></label>
                <div class="f-input-wrap">
                    <i class="bi bi-person f-icon"></i>
                    <input type="text" name="identifier" class="f-input" placeholder="01XXXXXXXXX অথবা email@example.com" required autofocus value="<?= e($_POST['identifier'] ?? '') ?>">
                </div>
            </div>

            <div class="f-group">
                <div class="pw-header">
                    <label class="f-label">পাসওয়ার্ড <span class="req">*</span></label>
                    <a href="#" class="forgot-link" onclick="alert('পাসওয়ার্ড রিসেট ফিচার শীঘ্রই আসছে।'); return false;">পাসওয়ার্ড ভুলে গেছেন?</a>
                </div>
                <div class="f-input-wrap">
                    <i class="bi bi-lock f-icon"></i>
                    <input type="password" name="password" id="pwInput" class="f-input" placeholder="আপনার পাসওয়ার্ড" required>
                    <button type="button" class="pw-toggle" onclick="togglePw()" tabindex="-1"><i class="bi bi-eye" id="pwIcon"></i></button>
                </div>
            </div>

            <button type="submit" class="login-btn"><i class="bi bi-box-arrow-in-right"></i>&nbsp; লগইন করুন</button>
        </form>

        <div class="login-divider">অথবা</div>
        <div class="login-footer">
            অ্যাকাউন্ট নেই? <a href="<?= BASE_URL ?>/auth/register">নতুন অ্যাকাউন্ট তৈরি করুন →</a>
        </div>
    </div>
</div>

<script>
function togglePw() {
    var pw = document.getElementById('pwInput'), ic = document.getElementById('pwIcon');
    if (pw.type === 'password') { pw.type = 'text'; ic.className = 'bi bi-eye-slash'; }
    else { pw.type = 'password'; ic.className = 'bi bi-eye'; }
}
</script>

<?php require __DIR__ . '/../../includes/footer.php'; ?>
