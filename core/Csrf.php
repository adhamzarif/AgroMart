<?php
/**
 * CSRF Token Utility
 * ─────────────────────────────────────────────────────────────
 * Per-session synchronizer-token pattern. Each session holds up to
 * MAX_TOKENS recent tokens (rolling window), so multiple tabs / back-button
 * scenarios still work after the token rotates.
 *
 * On verify():
 *   - Failures are logged with request context for audit
 *   - Token comparison is timing-safe via hash_equals()
 *   - Returns true once; doesn't remove the token (re-submit safe within session)
 *
 * Usage in forms:  <input type="hidden" name="_csrf" value="<?= Csrf::token() ?>">
 * In controllers:  $this->requireCsrf();
 * ─────────────────────────────────────────────────────────────
 */
class Csrf {

    const SESSION_KEY = '_csrf_tokens';
    const MAX_TOKENS = 5;
    const TOKEN_TTL = 3600; // 1 hour

    /** Get (or generate) the current token for forms. */
    public static function token() {
        self::pruneExpired();
        // Reuse the most recent unexpired token within the session
        $tokens = $_SESSION[self::SESSION_KEY] ?? [];
        if (!empty($tokens)) {
            // Return the newest token
            $latest = end($tokens);
            return $latest['value'];
        }
        return self::issueNew();
    }

    /** Issue a fresh token (rotate). Called on login/privilege change. */
    public static function issueNew() {
        $token = bin2hex(random_bytes(32));
        if (!isset($_SESSION[self::SESSION_KEY])) $_SESSION[self::SESSION_KEY] = [];
        $_SESSION[self::SESSION_KEY][] = [
            'value' => $token,
            'created' => time(),
        ];
        // Cap the rolling window
        if (count($_SESSION[self::SESSION_KEY]) > self::MAX_TOKENS) {
            $_SESSION[self::SESSION_KEY] = array_slice($_SESSION[self::SESSION_KEY], -self::MAX_TOKENS);
        }
        return $token;
    }

    /** Verify a token against the rolling window. */
    public static function verify($submitted) {
        if (!is_string($submitted) || $submitted === '') {
            self::logFailure('empty_or_invalid_type');
            return false;
        }
        self::pruneExpired();
        $tokens = $_SESSION[self::SESSION_KEY] ?? [];
        foreach ($tokens as $t) {
            if (hash_equals($t['value'], $submitted)) {
                return true;
            }
        }
        self::logFailure('no_match');
        return false;
    }

    /** Print hidden input. */
    public static function field() {
        return '<input type="hidden" name="_csrf" value="' . self::token() . '">';
    }

    /** Convenience alias used by some legacy views. */
    public static function input() {
        return self::field();
    }

    /** Remove tokens older than TOKEN_TTL. */
    private static function pruneExpired() {
        if (empty($_SESSION[self::SESSION_KEY])) return;
        $threshold = time() - self::TOKEN_TTL;
        $_SESSION[self::SESSION_KEY] = array_values(array_filter(
            $_SESSION[self::SESSION_KEY],
            fn($t) => ($t['created'] ?? 0) > $threshold
        ));
    }

    private static function logFailure($reason) {
        if (!class_exists('Logger')) return;
        Logger::warning('CSRF verification failed', [
            'reason' => $reason,
            'user_id' => $_SESSION['user_id'] ?? null,
            'method' => $_SERVER['REQUEST_METHOD'] ?? null,
            'url' => $_SERVER['REQUEST_URI'] ?? null,
            'referrer' => $_SERVER['HTTP_REFERER'] ?? null,
        ]);
    }
}
