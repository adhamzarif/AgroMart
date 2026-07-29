<?php
/**
 * AgroFin Cron Runner
 * ─────────────────────────────────────────────────────────────────
 * Invoked from system cron every 5 minutes:
 *   *​/5 * * * * /usr/bin/php /var/www/html/AgroFin/cron/run.php
 *
 * Each task decides for itself whether to run based on its $schedule.
 * Task state (last_run_at) is persisted in storage/cron_state.json so
 * we don't need to add a DB table just for scheduling metadata.
 *
 * Manual invocation:
 *   php cron/run.php                  # run all tasks that are due
 *   php cron/run.php --task=crop_expiry   # force-run a specific task
 *   php cron/run.php --list           # list registered tasks + last run
 *
 * Safety:
 *   - Single-instance lock via flock() — won't overlap with a previous run
 *   - Each task wrapped in try/catch so one failure doesn't kill the rest
 *   - All output also goes to storage/logs/cron-YYYY-MM-DD.log
 * ─────────────────────────────────────────────────────────────────
 */

// Bootstrap (same as front controller)
if (PHP_SAPI !== 'cli' && !($_GET['cron_token'] ?? null)) {
    http_response_code(403);
    die('Cron must be invoked from CLI or with a valid cron_token.');
}

define('CRON_ROOT', __DIR__);
define('APP_ROOT', dirname(__DIR__));

require APP_ROOT . '/core/Env.php';
Env::load(APP_ROOT . '/.env');

// Optional HTTP token check (so a webhook URL works too)
if (PHP_SAPI !== 'cli') {
    $expected = Env::get('CRON_TOKEN', '');
    if (!$expected || ($_GET['cron_token'] ?? '') !== $expected) {
        http_response_code(403);
        die('Invalid cron token.');
    }
}

require APP_ROOT . '/config/database.php';
require APP_ROOT . '/core/Model.php';
require APP_ROOT . '/core/Helpers.php';
require CRON_ROOT . '/CronLogger.php';
require CRON_ROOT . '/CronTask.php';

// Autoloader — same pattern as front controller, so tasks can use any Model/Controller
spl_autoload_register(function ($class) {
    foreach (['Models', 'Controllers'] as $dir) {
        $f = APP_ROOT . '/' . $dir . '/' . $class . '.php';
        if (file_exists($f)) { require_once $f; return; }
    }
});

// Single-instance lock
$lockFile = APP_ROOT . '/storage/cron.lock';
$lock = fopen($lockFile, 'c');
if (!flock($lock, LOCK_EX | LOCK_NB)) {
    CronLogger::log('runner', '⚠ Previous cron run still in progress — skipping.');
    exit(0);
}

// Argument parsing
$argv = $argv ?? [];
$forceTask = null;
$listOnly = false;
foreach ($argv as $arg) {
    if ($arg === '--list') $listOnly = true;
    elseif (strpos($arg, '--task=') === 0) $forceTask = substr($arg, 7);
}

// Auto-load all CronTask files
$taskFiles = glob(CRON_ROOT . '/tasks/*.php');
$tasks = [];
foreach ($taskFiles as $file) {
    require_once $file;
    $className = basename($file, '.php');
    if (class_exists($className) && is_subclass_of($className, 'CronTask')) {
        $tasks[] = new $className();
    }
}

// Load state
$stateFile = APP_ROOT . '/storage/cron_state.json';
$state = file_exists($stateFile) ? (json_decode(file_get_contents($stateFile), true) ?: []) : [];

if ($listOnly) {
    CronLogger::log('runner', '─── Registered Tasks ───');
    foreach ($tasks as $t) {
        $last = $state[$t->name]['last_run_at'] ?? 'never';
        CronLogger::log('runner', sprintf('  • %s (%s) — last: %s — %s',
            $t->name, $t->schedule, $last, $t->enabled ? 'enabled' : 'DISABLED'));
    }
    flock($lock, LOCK_UN);
    exit(0);
}

// Dispatch
$startedAt = microtime(true);
CronLogger::log('runner', '── Cron tick started ──');
$ran = 0;
$failed = 0;

foreach ($tasks as $task) {
    $lastRun = $state[$task->name]['last_run_at'] ?? null;
    $forced = ($forceTask === $task->name);

    if (!$forced && !$task->shouldRun($lastRun)) continue;

    $taskStart = microtime(true);
    try {
        $result = $task->run();
        $ms = (int)((microtime(true) - $taskStart) * 1000);
        if (!is_array($result)) $result = ['ok' => true, 'message' => 'OK', 'affected' => 0];

        if ($result['ok']) {
            CronLogger::success($task->name, sprintf('%s (%d affected, %d ms)',
                $result['message'] ?? 'completed', $result['affected'] ?? 0, $ms));
        } else {
            CronLogger::error($task->name, $result['message'] ?? 'unknown failure');
            $failed++;
        }
        $state[$task->name] = ['last_run_at' => time(), 'last_ok' => $result['ok'], 'duration_ms' => $ms];
        $ran++;
    } catch (Throwable $e) {
        CronLogger::error($task->name, $e->getMessage() . ' @ ' . $e->getFile() . ':' . $e->getLine());
        $state[$task->name] = ['last_run_at' => time(), 'last_ok' => false, 'error' => $e->getMessage()];
        $failed++;
        $ran++;
    }
}

// Persist state
file_put_contents($stateFile, json_encode($state, JSON_PRETTY_PRINT));

$totalMs = (int)((microtime(true) - $startedAt) * 1000);
CronLogger::log('runner', sprintf('── Tick complete: %d tasks executed, %d failed, %d ms ──',
    $ran, $failed, $totalMs));

flock($lock, LOCK_UN);
fclose($lock);
exit($failed > 0 ? 1 : 0);
