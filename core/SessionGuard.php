<?php
/**
 * SessionGuard
 * ─────────────────────────────────────────────────────────────
 * Hardens PHP sessions beyond the cookie params set in index.php:
 *
 *   - Fingerprint binding: ties session to a hash of IP class +
 *     User-Agent. If either changes drastically (different network class,
 *     different browser), the session is invalidated. Stops cookie theft.
 *
 *   - Idle timeout: forces re-login after IDLE_TIMEOUT_MINUTES of inactivity
 *     (default 60). Hard cap independent of cookie lifetime.
 *
 *   - Absolute timeout: forces re-login after ABS_TIMEOUT_HOURS hours since
 *     login (default 24), even if the user is active.
 *
 *   - Post-login regeneration: tied to AuthController::establishSession.
 *
 *   - Privilege-escalation regen: call regenerateAfterPrivilegeChange()
 *     after role-switch / 2FA-completion / similar.
 *
 * Configure via .env:
 *   SESSION_IDLE_TIMEOUT_MIN=60
 *   SESSION_ABS_TIMEOUT_HOURS=24
 *   SESSION_FINGERPRINT=true
 * ─────────────────────────────────────────────────────────────
 */
class SessionGuard {

    /** Run after session_start() in bootstrap. */
    public static function enforce() {
        if (session_status() !== PHP_SESSION_ACTIVE) return;
        // Public/anonymous sessions are still subject to fingerprint check
        // but not timeouts (no login).

        if (Env::getBool('SESSION_FINGERPRINT', true)) {
            self::enforceFingerprint();
        }

        if (!empty($_SESSION['user_id'])) {
            self::enforceTimeouts();
        }
    }

    /** Compare the current request fingerprint against the stored one. */
    private static function enforceFingerprint() {
        $fp = self::computeFingerprint();
        if (!isset($_SESSION['_fingerprint'])) {
            $_SESSION['_fingerprint'] = $fp;
            return;
        }
        if (!hash_equals($_SESSION['_fingerprint'], $fp)) {
            Logger::warning('Session fingerprint mismatch — invalidating', [
                'user_id' => $_SESSION['user_id'] ?? null,
                'stored' => substr($_SESSION['_fingerprint'], 0, 8),
                'current' => substr($fp, 0, 8),
            ]);
            self::destroy();
        }
    }

    /** Compute the per-request fingerprint. */
    private static function computeFingerprint() {
        // IP class (first 2 octets for IPv4, first 4 hexgroups for IPv6) so a
        // mobile user moving between cells doesn't lose their session
        $ip = $_SERVER['REMOTE_ADDR'] ?? '';
        $ipClass = self::ipClass($ip);
        $ua = $_SERVER['HTTP_USER_AGENT'] ?? '';
        $salt = Env::get('APP_KEY', 'agrofin-default-salt');
        return hash('sha256', $ipClass . '|' . $ua . '|' . $salt);
    }

    private static function ipClass($ip) {
        if (strpos($ip, ':') !== false) {
            // IPv6: keep first 4 groups (/64 subnet)
            $parts = explode(':', $ip);
            return implode(':', array_slice($parts, 0, 4));
        }
        // IPv4: keep first 2 octets (/16)
        $parts = explode('.', $ip);
        return implode('.', array_slice($parts, 0, 2));
    }

    /** Enforce idle + absolute timeouts. */
    private static function enforceTimeouts() {
        $now = time();
        $idleMax = Env::getInt('SESSION_IDLE_TIMEOUT_MIN', 60) * 60;
        $absMax  = Env::getInt('SESSION_ABS_TIMEOUT_HOURS', 24) * 3600;

        $lastActivity = (int)($_SESSION['_last_activity'] ?? $now);
        $loginAt      = (int)($_SESSION['_login_at']      ?? $now);

        if ($idleMax > 0 && ($now - $lastActivity) > $idleMax) {
            Logger::info('Session idle timeout', [
                'user_id' => $_SESSION['user_id'] ?? null,
                'idle_seconds' => $now - $lastActivity,
            ]);
            self::destroy();
            return;
        }
        if ($absMax > 0 && ($now - $loginAt) > $absMax) {
            Logger::info('Session absolute timeout', [
                'user_id' => $_SESSION['user_id'] ?? null,
                'age_seconds' => $now - $loginAt,
            ]);
            self::destroy();
            return;
        }

        $_SESSION['_last_activity'] = $now;
    }

    /**
     * Mark the session as just-authenticated.
     * Regenerates session id (prevents fixation), records login timestamp + fingerprint.
     * Call from AuthController::establishSession.
     */
    public static function markLogin($userId) {
        session_regenerate_id(true);
        $_SESSION['_login_at']      = time();
        $_SESSION['_last_activity'] = time();
        $_SESSION['_fingerprint']   = self::computeFingerprint();
        $_SESSION['_created']       = time();
    }

    /** Regenerate after a privilege-affecting action (role switch, 2FA, password change). */
    public static function regenerateAfterPrivilegeChange() {
        session_regenerate_id(true);
        $_SESSION['_last_activity'] = time();
    }

    /** Destroy the session entirely and end the request with a redirect. */
    public static function destroy() {
        // Clear server-side
        $_SESSION = [];
        if (ini_get('session.use_cookies')) {
            $params = session_get_cookie_params();
            setcookie(session_name(), '', time() - 42000,
                $params['path'], $params['domain'], $params['secure'], $params['httponly']);
        }
        @session_destroy();

        // Avoid an infinite redirect loop if /auth/login is the page that triggered destroy
        $isLoginPage = strpos($_SERVER['REQUEST_URI'] ?? '', '/auth/login') !== false;
        if (!$isLoginPage && !headers_sent()) {
            header('Location: ' . (defined('BASE_URL') ? BASE_URL : '') . '/auth/login?session_expired=1');
        }
    }
}
