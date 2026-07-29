<?php
/**
 * AgroFin Test Runner
 * ─────────────────────────────────────────────────────────────
 * A minimal, composer-less test framework. Why not PHPUnit?
 *   - This project deliberately has zero dependencies (no Composer)
 *   - PHPUnit assumes a typical Composer/autoload setup that would
 *     conflict with the project's manual require pattern
 *   - For ~30 critical-flow assertions, a 100-line runner is enough
 *
 * Test files live in tests/unit/ and tests/integration/, named *Test.php.
 * Each file defines a class extending TestCase with public test_* methods.
 *
 * Usage:
 *   php tests/run.php                    # run all tests
 *   php tests/run.php unit               # only unit tests
 *   php tests/run.php integration        # only integration tests
 *   php tests/run.php --filter=auth      # only tests matching "auth"
 *
 * Integration tests require a working AgroFin database. They run inside
 * a transaction that's rolled back after each test, so they're safe
 * to run against a real install.
 * ─────────────────────────────────────────────────────────────
 */

define('APP_ROOT', dirname(__DIR__));
define('BASE_PATH', APP_ROOT);
define('TEST_MODE', true);

// Allow opt-in environment override (e.g. point at a test DB)
$_ENV['AGROFIN_TEST'] = '1';

require APP_ROOT . '/core/Env.php';
Env::load(APP_ROOT . '/.env');

// Tests must NEVER hit a production DB. Hard guard.
if (Env::get('DB_NAME', '') !== 'agrofin' && Env::get('DB_NAME', '') !== 'agrofin_test') {
    fwrite(STDERR, "❌ Refusing to run tests against DB '" . Env::get('DB_NAME', '') . "'.\n");
    fwrite(STDERR, "   Set DB_NAME=agrofin or DB_NAME=agrofin_test in .env first.\n");
    exit(2);
}

// ─── TestCase + assertion helpers ────────────────────────────────────
abstract class TestCase {
    public static $passed = 0;
    public static $failed = 0;
    public static $errors = [];

    /** Called before every test_ method. Override for setup. */
    public function setUp() {}
    /** Called after every test_ method. Override for cleanup. */
    public function tearDown() {}

    public function assertEquals($expected, $actual, $msg = '') {
        if ($expected === $actual) return self::pass();
        return self::fail($msg ?: sprintf("Expected %s, got %s", var_export($expected, true), var_export($actual, true)));
    }

    public function assertTrue($cond, $msg = '') {
        return $cond === true ? self::pass() : self::fail($msg ?: 'Expected true, got ' . var_export($cond, true));
    }

    public function assertFalse($cond, $msg = '') {
        return $cond === false ? self::pass() : self::fail($msg ?: 'Expected false, got ' . var_export($cond, true));
    }

    public function assertNotEmpty($value, $msg = '') {
        return !empty($value) ? self::pass() : self::fail($msg ?: 'Expected non-empty, got empty');
    }

    public function assertEmpty($value, $msg = '') {
        return empty($value) ? self::pass() : self::fail($msg ?: 'Expected empty, got ' . var_export($value, true));
    }

    public function assertContains($needle, $haystack, $msg = '') {
        $found = is_array($haystack) ? in_array($needle, $haystack, true) : (strpos($haystack, $needle) !== false);
        return $found ? self::pass() : self::fail($msg ?: "'$needle' not found in given value");
    }

    public function assertGreaterThan($expected, $actual, $msg = '') {
        return $actual > $expected ? self::pass() : self::fail($msg ?: "Expected > $expected, got $actual");
    }

    public function assertCount($expected, $arr, $msg = '') {
        $actual = is_countable($arr) ? count($arr) : -1;
        return $actual === $expected ? self::pass() : self::fail($msg ?: "Expected count $expected, got $actual");
    }

    public function assertThrows(callable $fn, $msg = '') {
        try {
            $fn();
        } catch (Throwable $e) {
            return self::pass();
        }
        return self::fail($msg ?: 'Expected exception, none thrown');
    }

    private static function pass() { self::$passed++; return true; }
    private static function fail($msg) {
        self::$failed++;
        $stack = debug_backtrace();
        $frame = $stack[2] ?? $stack[0];
        self::$errors[] = sprintf("  %s in %s line %d", $msg, basename($frame['file'] ?? '?'), $frame['line'] ?? 0);
        return false;
    }
}

// ─── Bootstrap the app for integration tests ────────────────────────
function bootstrapApp() {
    static $done = false;
    if ($done) return;
    require_once APP_ROOT . '/config/database.php';
    require_once APP_ROOT . '/core/Helpers.php';
    require_once APP_ROOT . '/core/Csrf.php';
    require_once APP_ROOT . '/core/Flash.php';
    require_once APP_ROOT . '/core/Model.php';
    require_once APP_ROOT . '/core/Controller.php';
    require_once APP_ROOT . '/core/Cache.php';
    require_once APP_ROOT . '/core/RateLimit.php';
    require_once APP_ROOT . '/core/Logger.php';
    require_once APP_ROOT . '/core/SessionGuard.php';
    require_once APP_ROOT . '/core/SearchProvider.php';
    spl_autoload_register(function ($class) {
        foreach (['Models', 'Controllers'] as $dir) {
            $f = APP_ROOT . '/' . $dir . '/' . $class . '.php';
            if (file_exists($f)) { require_once $f; return; }
        }
    });
    if (session_status() !== PHP_SESSION_ACTIVE) {
        @session_start();
    }
    $done = true;
}

// ─── Argument parsing ────────────────────────────────────────────────
$argv = $argv ?? [];
$category = null;
$filter = null;
foreach ($argv as $arg) {
    if ($arg === 'unit') $category = 'unit';
    elseif ($arg === 'integration') $category = 'integration';
    elseif (str_starts_with($arg, '--filter=')) $filter = substr($arg, 9);
}

// ─── Discover test files ─────────────────────────────────────────────
$testFiles = [];
if ($category === null || $category === 'unit') {
    $testFiles = array_merge($testFiles, glob(__DIR__ . '/unit/*Test.php') ?: []);
}
if ($category === null || $category === 'integration') {
    $testFiles = array_merge($testFiles, glob(__DIR__ . '/integration/*Test.php') ?: []);
}

// ─── Run tests ───────────────────────────────────────────────────────
echo "──────────────────────────────────────────────────\n";
echo "  AgroFin Test Suite\n";
echo "──────────────────────────────────────────────────\n\n";

$totalMethods = 0;
$totalTime = microtime(true);

foreach ($testFiles as $file) {
    require_once $file;
    $className = basename($file, '.php');
    if (!class_exists($className)) {
        echo "✗ {$className}: class not found in file\n";
        continue;
    }
    $obj = new $className();
    if (!($obj instanceof TestCase)) {
        echo "✗ {$className}: doesn't extend TestCase\n";
        continue;
    }
    $methods = array_filter(
        get_class_methods($obj),
        fn($m) => str_starts_with($m, 'test_')
    );
    if ($filter !== null) {
        $methods = array_filter($methods, fn($m) => stripos($m, $filter) !== false);
    }
    if (empty($methods)) continue;

    echo "▸ {$className}\n";
    foreach ($methods as $method) {
        $totalMethods++;
        $before = ['p' => TestCase::$passed, 'f' => TestCase::$failed];
        $t0 = microtime(true);
        try {
            $obj->setUp();
            $obj->$method();
            $obj->tearDown();
        } catch (Throwable $e) {
            TestCase::$failed++;
            TestCase::$errors[] = sprintf("  %s::%s threw %s: %s @ line %d",
                $className, $method, get_class($e), $e->getMessage(), $e->getLine());
        }
        $passed = TestCase::$passed - $before['p'];
        $failed = TestCase::$failed - $before['f'];
        $ms = (int)((microtime(true) - $t0) * 1000);
        $icon = $failed > 0 ? '✗' : '✓';
        printf("  %s %-40s %d assertions  %dms\n", $icon, $method, $passed + $failed, $ms);
    }
    echo "\n";
}

$elapsed = (int)((microtime(true) - $totalTime) * 1000);

echo "──────────────────────────────────────────────────\n";
printf("  %d test methods, %d assertions: %d passed, %d failed  (%dms)\n",
    $totalMethods, TestCase::$passed + TestCase::$failed, TestCase::$passed, TestCase::$failed, $elapsed);
echo "──────────────────────────────────────────────────\n";

if (!empty(TestCase::$errors)) {
    echo "\nFailures:\n";
    foreach (TestCase::$errors as $e) echo $e . "\n";
}

exit(TestCase::$failed > 0 ? 1 : 0);
