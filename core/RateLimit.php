<?php
/**
 * RateLimit — sliding-window rate limiting backed by the Cache layer.
 *
 * Why this matters:
 *   - Login: prevents brute-force password guessing
 *   - OTP send: prevents SMS spam (already has its own check at 3/30min, this is
 *               an outer layer at the controller level catching IP-level abuse)
 *   - Password reset: same as login
 *   - Registration: prevents account-creation spam
 *   - API endpoints: prevents scraping
 *
 * Usage:
 *   $check = RateLimit::check('login:' . $ip, 5, 300);  // max 5 / 5 min
 *   if (!$check['ok']) {
 *       Flash::set('danger', 'অনেকবার চেষ্টা — ' . $check['retry_after'] . 'সে পরে চেষ্টা করুন');
 *       $this->redirect('/login');
 *   }
 *   // ... process request ...
 *   RateLimit::hit('login:' . $ip);
 *
 * Or check + hit in one call:
 *   $check = RateLimit::attempt('login:' . $ip, 5, 300);
 */
class RateLimit {

    /**
     * Inspect current state without consuming an attempt.
     * Returns ['ok' => bool, 'attempts' => N, 'remaining' => N, 'retry_after' => seconds-until-reset]
     */
    public static function check($key, $maxAttempts, $windowSeconds) {
        $cacheKey = 'ratelimit:' . $key;
        $entry = Cache::get($cacheKey);
        $now = time();

        // No record yet
        if (!is_array($entry) || empty($entry['hits'])) {
            return [
                'ok' => true,
                'attempts' => 0,
                'remaining' => $maxAttempts,
                'retry_after' => 0,
            ];
        }

        // Filter out hits outside the window
        $threshold = $now - $windowSeconds;
        $hits = array_filter($entry['hits'], fn($t) => $t > $threshold);
        $count = count($hits);
        $remaining = max(0, $maxAttempts - $count);
        $earliest = $count > 0 ? min($hits) : $now;
        $retryAfter = $count >= $maxAttempts ? max(1, $earliest + $windowSeconds - $now) : 0;

        return [
            'ok' => $count < $maxAttempts,
            'attempts' => $count,
            'remaining' => $remaining,
            'retry_after' => $retryAfter,
        ];
    }

    /**
     * Record one attempt. Call AFTER processing (so failed lookups don't count
     * unless the action was actually performed).
     */
    public static function hit($key, $windowSeconds = 3600) {
        $cacheKey = 'ratelimit:' . $key;
        $entry = Cache::get($cacheKey) ?: ['hits' => []];
        $now = time();
        // Prune old hits + add the new one
        $threshold = $now - $windowSeconds;
        $entry['hits'] = array_filter($entry['hits'], fn($t) => $t > $threshold);
        $entry['hits'][] = $now;
        Cache::set($cacheKey, $entry, $windowSeconds);
        return count($entry['hits']);
    }

    /**
     * Convenience: check + hit. If allowed, records the attempt and returns ok.
     * If blocked, returns false WITHOUT incrementing.
     */
    public static function attempt($key, $maxAttempts, $windowSeconds) {
        $check = self::check($key, $maxAttempts, $windowSeconds);
        if (!$check['ok']) return $check;
        self::hit($key, $windowSeconds);
        $check['attempts']++;
        $check['remaining']--;
        return $check;
    }

    /** Manually clear all attempts for a key (e.g., on successful login). */
    public static function clear($key) {
        return Cache::forget('ratelimit:' . $key);
    }

    /** Get the requesting client IP, respecting common proxy headers. */
    public static function clientIp() {
        $candidates = [
            $_SERVER['HTTP_CF_CONNECTING_IP'] ?? null,   // Cloudflare
            $_SERVER['HTTP_X_FORWARDED_FOR'] ?? null,    // Reverse proxy
            $_SERVER['HTTP_X_REAL_IP'] ?? null,
            $_SERVER['REMOTE_ADDR'] ?? null,
        ];
        foreach ($candidates as $ip) {
            if (!$ip) continue;
            // X-Forwarded-For may be a comma-separated list
            $ip = trim(explode(',', $ip)[0]);
            if (filter_var($ip, FILTER_VALIDATE_IP)) return $ip;
        }
        return '0.0.0.0';
    }

    /** Format retry_after seconds into a Bangla friendly string. */
    public static function formatRetry($seconds) {
        $seconds = (int)$seconds;
        if ($seconds < 60) return bn_num($seconds) . ' সেকেন্ড';
        if ($seconds < 3600) return bn_num((int)ceil($seconds / 60)) . ' মিনিট';
        return bn_num((int)ceil($seconds / 3600)) . ' ঘণ্টা';
    }
}
