<?php
/**
 * OtpModel — generate, send, and verify one-time passwords.
 *
 * Design notes:
 *   - OTPs are stored as bcrypt hashes (never plaintext)
 *   - Rate limit: max 3 OTPs per phone per 30 minutes
 *   - Each OTP expires after 5 minutes
 *   - Max 5 verification attempts per code, then locked
 *   - Phone normalization done in SmsProvider
 */
class OtpModel extends Model {

    const OTP_LENGTH       = 6;
    const OTP_TTL_SECONDS  = 300;   // 5 minutes
    const RATE_LIMIT_COUNT = 3;     // max OTPs per phone
    const RATE_LIMIT_MINS  = 30;    // ...per this many minutes
    const MAX_ATTEMPTS     = 5;

    /**
     * Generate + send an OTP. Returns ['ok','error','otp_id','expires_in',
     * 'cooldown_seconds' (only if rate-limited), 'dev_code' (only if log provider)].
     */
    public function send($phone, $purpose = 'verify_phone', $ip = null) {
        $phone = $this->normalize($phone);
        if (!preg_match('/^01[3-9]\d{8}$/', $phone)) {
            return ['ok' => false, 'error' => 'বৈধ মোবাইল নম্বর দিন (০১XXXXXXXXX)।'];
        }

        // Rate limit
        $since = date('Y-m-d H:i:s', time() - self::RATE_LIMIT_MINS * 60);
        $recent = (int)$this->fetchScalar(
            "SELECT COUNT(*) FROM otp_codes WHERE phone = ? AND purpose = ? AND created_at > ?",
            [$phone, $purpose, $since]
        );
        if ($recent >= self::RATE_LIMIT_COUNT) {
            $oldest = $this->fetchScalar(
                "SELECT created_at FROM otp_codes WHERE phone = ? AND purpose = ? AND created_at > ?
                 ORDER BY created_at ASC LIMIT 1",
                [$phone, $purpose, $since]
            );
            $cooldown = $oldest ? (self::RATE_LIMIT_MINS * 60 - (time() - strtotime($oldest))) : 0;
            return [
                'ok' => false,
                'error' => 'অনেকবার অনুরোধ করা হয়েছে। ' . max(1, (int)ceil($cooldown / 60)) . ' মিনিট পর আবার চেষ্টা করুন।',
                'cooldown_seconds' => max(0, $cooldown),
            ];
        }

        // Generate OTP — secure random
        $code = $this->generateCode();
        $hash = password_hash($code, PASSWORD_BCRYPT);
        $expiresAt = date('Y-m-d H:i:s', time() + self::OTP_TTL_SECONDS);

        // Invalidate any previous unverified OTP for this (phone, purpose) — only the newest is usable
        $this->execute(
            "UPDATE otp_codes SET expires_at = NOW()
             WHERE phone = ? AND purpose = ? AND verified_at IS NULL AND expires_at > NOW()",
            [$phone, $purpose]
        );

        // Compose message
        $appName = Env::get('APP_NAME', 'AgroFin');
        $message = "{$appName}: আপনার OTP কোড {$code}। " . (int)(self::OTP_TTL_SECONDS / 60) . " মিনিটে মেয়াদ শেষ। কখনো কাউকে এই কোড দেবেন না।";

        // Send via SMS provider
        require_once __DIR__ . '/../core/SmsProvider.php';
        $smsResult = SmsProvider::send($phone, $message, "otp_$purpose");
        $sentVia = (Env::get('SMS_PROVIDER', 'log') === 'log' || !$smsResult['ok']) ? 'log' : 'sms';

        // Persist
        $this->execute(
            "INSERT INTO otp_codes (phone, code_hash, purpose, expires_at, max_attempts, request_ip, sent_via, provider_response)
             VALUES (?,?,?,?,?,?,?,?)",
            [
                $phone, $hash, $purpose, $expiresAt, self::MAX_ATTEMPTS,
                $ip ?: ($_SERVER['REMOTE_ADDR'] ?? null),
                $sentVia,
                json_encode($smsResult['raw'] ?? [], JSON_UNESCAPED_UNICODE),
            ]
        );
        $otpId = $this->lastInsertId();

        $result = [
            'ok' => true,
            'error' => null,
            'otp_id' => $otpId,
            'expires_in' => self::OTP_TTL_SECONDS,
        ];

        // In dev / log mode, expose the code so QA can test without a real phone
        if (Env::getBool('APP_DEBUG', false) && $sentVia === 'log') {
            $result['dev_code'] = $code;
        }
        return $result;
    }

    /**
     * Verify a submitted code. Returns ['ok','error','phone','purpose'].
     * On success, marks the OTP as verified and returns the phone+purpose.
     */
    public function verify($phone, $submittedCode) {
        $phone = $this->normalize($phone);
        $submittedCode = preg_replace('/\D/', '', $submittedCode);

        // Find the most recent unverified OTP for this phone
        $otp = $this->fetchOne(
            "SELECT * FROM otp_codes
             WHERE phone = ? AND verified_at IS NULL
             ORDER BY created_at DESC LIMIT 1",
            [$phone]
        );

        if (!$otp) {
            return ['ok' => false, 'error' => 'কোনো OTP পাঠানো হয়নি। আগে OTP রিকোয়েস্ট করুন।'];
        }

        // Expired?
        if (strtotime($otp['expires_at']) < time()) {
            return ['ok' => false, 'error' => 'OTP-এর মেয়াদ শেষ। নতুন OTP রিকোয়েস্ট করুন।'];
        }

        // Too many attempts?
        if ((int)$otp['attempts'] >= (int)$otp['max_attempts']) {
            return ['ok' => false, 'error' => 'অনেকবার ভুল চেষ্টা হয়েছে। নতুন OTP রিকোয়েস্ট করুন।'];
        }

        // Increment attempts BEFORE checking — so brute force attempts are counted
        $this->execute("UPDATE otp_codes SET attempts = attempts + 1 WHERE otp_id = ?", [$otp['otp_id']]);

        if (!password_verify($submittedCode, $otp['code_hash'])) {
            $remaining = max(0, (int)$otp['max_attempts'] - (int)$otp['attempts'] - 1);
            return ['ok' => false, 'error' => 'OTP ভুল। ' . bn_num($remaining) . ' বার চেষ্টা বাকি।'];
        }

        // Success — mark verified
        $this->execute("UPDATE otp_codes SET verified_at = NOW() WHERE otp_id = ?", [$otp['otp_id']]);
        return [
            'ok' => true,
            'error' => null,
            'phone' => $phone,
            'purpose' => $otp['purpose'],
            'otp_id' => $otp['otp_id'],
        ];
    }

    /** Check if a phone was OTP-verified within the last N seconds (for register flow). */
    public function recentlyVerified($phone, $purpose, $windowSeconds = 600) {
        $phone = $this->normalize($phone);
        $since = date('Y-m-d H:i:s', time() - $windowSeconds);
        return (bool)$this->fetchScalar(
            "SELECT 1 FROM otp_codes
             WHERE phone = ? AND purpose = ? AND verified_at IS NOT NULL AND verified_at > ?
             ORDER BY verified_at DESC LIMIT 1",
            [$phone, $purpose, $since]
        );
    }

    /** Generate a numeric OTP using cryptographically secure RNG. */
    private function generateCode() {
        $max = (int)str_repeat('9', self::OTP_LENGTH);
        $min = (int)('1' . str_repeat('0', self::OTP_LENGTH - 1));
        $n = random_int($min, $max);
        return (string)$n;
    }

    private function normalize($phone) {
        $phone = preg_replace('/\D/', '', $phone);
        if (strpos($phone, '88') === 0 && strlen($phone) === 13) $phone = substr($phone, 2);
        if (strpos($phone, '0') !== 0 && strlen($phone) === 10) $phone = '0' . $phone;
        return $phone;
    }

    /** Cleanup expired/old OTPs — called by cron. */
    public function purgeOld() {
        $stmt = $this->pdo()->prepare(
            "DELETE FROM otp_codes
             WHERE (verified_at IS NOT NULL AND verified_at < DATE_SUB(NOW(), INTERVAL 7 DAY))
                OR (verified_at IS NULL AND expires_at < DATE_SUB(NOW(), INTERVAL 1 DAY))"
        );
        $stmt->execute();
        return $stmt->rowCount();
    }
}
