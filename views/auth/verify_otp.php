<?php require __DIR__ . '/../../includes/header.php'; ?>
<?php require __DIR__ . '/../../includes/navbar.php'; ?>

<style>
.otp-shell { display: grid; place-items: center; min-height: calc(100vh - 200px); padding: 32px 16px; }
.otp-card { background: #fff; border-radius: 18px; padding: 36px 32px; max-width: 460px; width: 100%; box-shadow: 0 10px 40px rgba(0,0,0,0.06); border-top: 5px solid var(--m1-primary); }
.otp-icon { width: 72px; height: 72px; border-radius: 50%; background: linear-gradient(135deg, var(--m1-primary), var(--m4-primary)); color: #fff; display: flex; align-items: center; justify-content: center; font-size: 32px; margin: 0 auto 20px; }
.otp-input { width: 100%; padding: 16px; font-size: 28px; text-align: center; letter-spacing: 12px; font-family: 'Consolas', monospace; border: 2px solid var(--gray-200); border-radius: 12px; box-sizing: border-box; outline: none; font-weight: 700; }
.otp-input:focus { border-color: var(--m1-primary); box-shadow: 0 0 0 4px rgba(46,125,50,0.1); }
.otp-meta { font-size: 13px; color: var(--gray-600); }
.otp-phone { font-weight: 700; color: var(--m1-primary); font-family: 'Consolas', monospace; }
#countdown { font-weight: 700; }
.countdown-warn { color: var(--warning) !important; }
.countdown-danger { color: var(--danger) !important; }
</style>

<div class="otp-shell">
    <div class="otp-card">
        <div class="otp-icon">📱</div>
        <h2 style="text-align: center; margin: 0 0 8px; font-size: 22px;">ফোন যাচাইকরণ</h2>
        <p style="text-align: center; color: var(--gray-600); margin: 0 0 20px; font-size: 14px; line-height: 1.6;">
            <span class="otp-phone"><?= e($phone) ?></span> নম্বরে ৬-অঙ্কের কোড পাঠানো হয়েছে। নিচে কোডটি লিখুন।
        </p>

        <form method="POST" action="<?= BASE_URL ?>/auth/verify-otp">
            <?= Csrf::field() ?>
            <input type="hidden" name="action" value="verify">

            <div style="margin-bottom: 16px;">
                <input type="text"
                       name="otp_code"
                       class="otp-input"
                       placeholder="• • • • • •"
                       maxlength="6"
                       minlength="6"
                       pattern="[0-9]{6}"
                       inputmode="numeric"
                       autocomplete="one-time-code"
                       required
                       autofocus>
            </div>

            <div style="text-align: center; margin-bottom: 18px;">
                <span class="otp-meta">⏱ মেয়াদ শেষ হবে <span id="countdown">--</span></span>
            </div>

            <button type="submit" class="nav-pill-btn primary" style="width: 100%; justify-content: center; padding: 14px; font-size: 15px;">
                <i class="bi bi-check2-circle"></i> যাচাই করুন
            </button>
        </form>

        <div style="margin-top: 22px; padding-top: 18px; border-top: 1px solid var(--gray-100); text-align: center;">
            <span class="otp-meta">কোড পাননি? </span>
            <form method="POST" action="<?= BASE_URL ?>/auth/verify-otp" style="display: inline;">
                <?= Csrf::field() ?>
                <input type="hidden" name="action" value="resend">
                <button type="submit" id="resendBtn"
                        style="background: none; border: none; color: var(--m1-primary); cursor: pointer; padding: 0; font-size: 13px; font-weight: 600; text-decoration: underline;"
                        disabled>
                    নতুন কোড পাঠান (<span id="resendIn">30</span>স)
                </button>
            </form>
        </div>

        <div style="margin-top: 18px; text-align: center;">
            <a href="<?= BASE_URL ?>/auth/register" style="color: var(--gray-500); font-size: 12px; text-decoration: none;">
                <i class="bi bi-arrow-left"></i> ভুল নম্বর? রেজিস্ট্রেশন আবার শুরু করুন
            </a>
        </div>
    </div>
</div>

<script>
// Countdown timer for OTP expiry (5 minutes from now)
(function() {
    const expiresAt = Date.now() + (5 * 60 * 1000); // 5 minutes
    const $cd = document.getElementById('countdown');
    const $resend = document.getElementById('resendBtn');
    const $resendIn = document.getElementById('resendIn');
    const resendUnlockAt = Date.now() + (30 * 1000); // 30s before resend allowed

    function tick() {
        const now = Date.now();
        const ms = expiresAt - now;
        if (ms <= 0) {
            $cd.textContent = 'মেয়াদ শেষ';
            $cd.className = 'countdown-danger';
            return;
        }
        const total = Math.floor(ms / 1000);
        const m = Math.floor(total / 60);
        const s = total % 60;
        const txt = String(m).padStart(2, '0') + ':' + String(s).padStart(2, '0');
        $cd.textContent = txt;
        if (total < 60) $cd.className = 'countdown-danger';
        else if (total < 120) $cd.className = 'countdown-warn';

        // Resend cooldown
        const resendMs = resendUnlockAt - now;
        if (resendMs <= 0) {
            $resend.disabled = false;
            $resendIn.parentElement.innerHTML = 'নতুন কোড পাঠান';
        } else {
            $resendIn.textContent = Math.ceil(resendMs / 1000);
        }
    }
    tick();
    setInterval(tick, 1000);

    // Auto-submit when 6 digits entered
    const $input = document.querySelector('.otp-input');
    $input.addEventListener('input', e => {
        e.target.value = e.target.value.replace(/\D/g, '');
        if (e.target.value.length === 6) {
            setTimeout(() => e.target.closest('form').submit(), 200);
        }
    });
})();
</script>

<?php require __DIR__ . '/../../includes/footer.php'; ?>
