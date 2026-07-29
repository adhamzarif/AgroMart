<?php
/**
 * SecurityTest — unit tests for CSRF, RateLimit, Logger, SessionGuard.
 * Uses fresh in-memory session state per test.
 */
class SecurityTest extends TestCase {

    public function setUp() {
        if (session_status() === PHP_SESSION_ACTIVE) {
            $_SESSION = [];
        } else {
            // Headers may already be sent in CLI test; that's OK
            @session_start();
            $_SESSION = [];
        }
        require_once APP_ROOT . '/core/Csrf.php';
        require_once APP_ROOT . '/core/Cache.php';
        require_once APP_ROOT . '/core/RateLimit.php';
        require_once APP_ROOT . '/core/Helpers.php';
        require_once APP_ROOT . '/core/Logger.php';
    }

    public function test_csrf_token_is_generated_and_verifiable() {
        $token = Csrf::token();
        $this->assertNotEmpty($token);
        $this->assertTrue(Csrf::verify($token));
    }

    public function test_csrf_rejects_wrong_token() {
        Csrf::token(); // generate one
        $this->assertFalse(Csrf::verify('wrong-token'));
        $this->assertFalse(Csrf::verify(''));
        $this->assertFalse(Csrf::verify(null));
    }

    public function test_csrf_uses_timing_safe_comparison() {
        $token = Csrf::token();
        // Same-length wrong token should still safely return false
        $wrong = str_repeat('a', strlen($token));
        $this->assertFalse(Csrf::verify($wrong));
    }

    public function test_csrf_rotation_keeps_old_tokens_valid_for_window() {
        $tokenA = Csrf::token();
        $tokenB = Csrf::issueNew();
        // After issueNew, both should still be valid (rolling window)
        $this->assertTrue(Csrf::verify($tokenA));
        $this->assertTrue(Csrf::verify($tokenB));
    }

    public function test_csrf_field_includes_token() {
        $field = Csrf::field();
        $this->assertContains('_csrf', $field);
        $this->assertContains('hidden', $field);
    }

    public function test_ratelimit_allows_then_blocks() {
        $key = 'test:' . uniqid();
        // 3 attempts allowed
        for ($i = 0; $i < 3; $i++) {
            $r = RateLimit::attempt($key, 3, 60);
            $this->assertTrue($r['ok']);
        }
        // 4th must be blocked
        $r = RateLimit::attempt($key, 3, 60);
        $this->assertFalse($r['ok']);
        $this->assertGreaterThan(0, $r['retry_after']);
    }

    public function test_ratelimit_clear_resets() {
        $key = 'test:clear:' . uniqid();
        RateLimit::hit($key, 60);
        RateLimit::hit($key, 60);
        RateLimit::clear($key);
        $r = RateLimit::check($key, 1, 60);
        $this->assertTrue($r['ok']);
        $this->assertEquals(0, $r['attempts']);
    }

    public function test_ratelimit_format_retry_returns_bangla_string() {
        $this->assertContains('সেকেন্ড', RateLimit::formatRetry(45));
        $this->assertContains('মিনিট', RateLimit::formatRetry(120));
        $this->assertContains('ঘণ্টা', RateLimit::formatRetry(7200));
    }

    public function test_logger_redacts_sensitive_keys() {
        // Use a dedicated temp directory so we can inspect the output
        $tmpDir = sys_get_temp_dir() . '/agrofin_test_logs_' . uniqid();
        @mkdir($tmpDir, 0775, true);

        // Env::get checks Env::$loaded FIRST, so we must override that, not $_ENV
        $envR = new ReflectionClass('Env');
        $loadedProp = $envR->getProperty('loaded');
        $loadedProp->setAccessible(true);
        $original = $loadedProp->getValue();
        $override = array_merge($original, [
            'LOG_PATH' => $tmpDir,
            'LOG_CHANNEL' => 'file',
            'LOG_LEVEL' => 'debug',
        ]);
        $loadedProp->setValue(null, $override);

        // Force Logger to re-init by resetting ALL static props via reflection
        $logR = new ReflectionClass('Logger');
        foreach (['channel', 'minLevel', 'logDir', 'requestContext'] as $propName) {
            if ($logR->hasProperty($propName)) {
                $p = $logR->getProperty($propName);
                $p->setAccessible(true);
                $p->setValue(null, null);
            }
        }

        // Write a log line with sensitive fields
        Logger::info('Test event with secrets', [
            'user_id' => 42,
            'password' => 'secret123',
            'api_key' => 'sk-deadbeef',
            'safe_value' => 'visible',
        ]);

        // Look for the log file
        $files = glob($tmpDir . '/*.log');
        $this->assertGreaterThan(0, count($files), 'No log file was created in tmp dir: ' . $tmpDir);

        $contents = $files ? file_get_contents($files[0]) : '';
        $this->assertContains('REDACTED', $contents);
        $this->assertContains('visible', $contents);
        $this->assertFalse(strpos($contents, 'secret123') !== false, 'Password leaked in log output');
        $this->assertFalse(strpos($contents, 'sk-deadbeef') !== false, 'API key leaked in log output');

        // Restore original Env state + reset Logger so subsequent tests aren't affected
        $loadedProp->setValue(null, $original);
        foreach (['channel', 'minLevel', 'logDir'] as $propName) {
            $p = $logR->getProperty($propName);
            $p->setAccessible(true);
            $p->setValue(null, null);
        }
        // Cleanup tmp files
        foreach (glob($tmpDir . '/*') as $f) @unlink($f);
        @rmdir($tmpDir);
    }
}
