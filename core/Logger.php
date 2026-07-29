<?php
/**
 * Logger
 * ─────────────────────────────────────────────────────────────
 * PSR-3-style structured logger with multiple channels:
 *
 *   - file (default)  — writes to storage/logs/{channel}-YYYY-MM-DD.log
 *   - stderr          — for containerized / systemd setups
 *   - syslog          — for production servers using rsyslog
 *
 * Sentry integration is hook-only: if SENTRY_DSN is set in .env, the
 * static $sentryHook closure is invoked on error/critical levels. The
 * hook itself stays empty unless you install sentry/sdk via Composer
 * and register it explicitly — this avoids any external dependency.
 *
 * Usage:
 *   Logger::info('Order placed', ['order_id' => 42, 'amount' => 1500]);
 *   Logger::error('Payment gateway timeout', ['ref' => $ref, 'gateway' => 'sslcommerz']);
 *
 * Each log line is JSON, so it's grep-able + ingestable into ELK/Loki/etc.
 *
 * Configure via .env:
 *   LOG_CHANNEL=file        # file | stderr | syslog
 *   LOG_LEVEL=info          # debug | info | notice | warning | error | critical
 *   LOG_PATH=storage/logs
 * ─────────────────────────────────────────────────────────────
 */
class Logger {

    const LEVELS = [
        'debug'     => 100,
        'info'      => 200,
        'notice'    => 250,
        'warning'   => 300,
        'error'     => 400,
        'critical'  => 500,
        'alert'     => 550,
        'emergency' => 600,
    ];

    private static $channel = null;
    private static $minLevel = 200; // info
    private static $logDir = null;
    private static $sentryHook = null;
    private static $requestContext = null;

    public static function init() {
        if (self::$channel !== null) return;
        self::$channel = Env::get('LOG_CHANNEL', 'file');
        $minLevelName = Env::get('LOG_LEVEL', 'info');
        self::$minLevel = self::LEVELS[$minLevelName] ?? 200;

        // Support both absolute paths (e.g. /var/log/agrofin) and relative paths
        // (which are resolved against the project root).
        $logPath = Env::get('LOG_PATH', 'storage/logs');
        self::$logDir = self::isAbsolutePath($logPath)
            ? rtrim($logPath, '/')
            : dirname(__DIR__) . '/' . trim($logPath, '/');

        if (self::$channel === 'file' && !is_dir(self::$logDir)) {
            @mkdir(self::$logDir, 0775, true);
        }
        if (self::$channel === 'syslog') {
            openlog('AgroFin', LOG_PID | LOG_ODELAY, LOG_USER);
        }
    }

    private static function isAbsolutePath($path) {
        if ($path === '' || $path[0] === '/') return true;        // Unix
        if (preg_match('/^[a-zA-Z]:[\\\\\/]/', $path)) return true; // Windows
        return false;
    }

    /**
     * Register a closure to be invoked on error/critical-level events.
     * Used by Sentry/Bugsnag/Rollbar integrations. Not invoked unless registered.
     *
     *   Logger::registerSentryHook(function($level, $message, $context) {
     *       \Sentry\captureException(new \Exception($message), ['context' => $context]);
     *   });
     */
    public static function registerSentryHook(callable $hook) {
        self::$sentryHook = $hook;
    }

    /** Cache request-level context to attach to every log line. */
    private static function requestContext() {
        if (self::$requestContext !== null) return self::$requestContext;

        $ctx = [];
        if (PHP_SAPI !== 'cli') {
            $ctx['ip']     = $_SERVER['REMOTE_ADDR']   ?? null;
            $ctx['method'] = $_SERVER['REQUEST_METHOD'] ?? null;
            $ctx['url']    = $_SERVER['REQUEST_URI']    ?? null;
            $ctx['ua']     = isset($_SERVER['HTTP_USER_AGENT'])
                ? substr($_SERVER['HTTP_USER_AGENT'], 0, 200) : null;
        }
        $ctx['user_id'] = $_SESSION['user_id'] ?? null;
        return self::$requestContext = $ctx;
    }

    /** Core log method. Other public methods are sugar around this. */
    public static function log($level, $message, array $context = []) {
        self::init();
        $levelNum = self::LEVELS[$level] ?? 200;
        if ($levelNum < self::$minLevel) return;

        $entry = [
            'ts'      => date('c'),
            'level'   => $level,
            'msg'     => $message,
            'context' => self::sanitizeContext($context),
            'req'     => self::requestContext(),
        ];

        $line = json_encode($entry, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);

        switch (self::$channel) {
            case 'stderr':
                @fwrite(STDERR, $line . PHP_EOL);
                break;
            case 'syslog':
                $syslogLevel = match($level) {
                    'debug'     => LOG_DEBUG,
                    'info'      => LOG_INFO,
                    'notice'    => LOG_NOTICE,
                    'warning'   => LOG_WARNING,
                    'error'     => LOG_ERR,
                    'critical'  => LOG_CRIT,
                    'alert'     => LOG_ALERT,
                    'emergency' => LOG_EMERG,
                    default     => LOG_INFO,
                };
                @syslog($syslogLevel, $line);
                break;
            case 'file':
            default:
                $file = self::$logDir . '/app-' . date('Y-m-d') . '.log';
                @file_put_contents($file, $line . PHP_EOL, FILE_APPEND | LOCK_EX);
                break;
        }

        // Forward errors+ to Sentry hook if registered
        if ($levelNum >= self::LEVELS['error'] && self::$sentryHook !== null) {
            try {
                (self::$sentryHook)($level, $message, $entry);
            } catch (Throwable $e) {
                // Hook itself failed — don't recurse
            }
        }
    }

    /** Strip sensitive keys before logging. */
    private static function sanitizeContext(array $ctx) {
        $sensitive = ['password', 'password_hash', 'csrf_token', 'session_id',
                      'api_key', 'token', 'nid_number', 'card_number'];
        foreach ($sensitive as $k) {
            if (array_key_exists($k, $ctx)) $ctx[$k] = '[REDACTED]';
        }
        return $ctx;
    }

    // ── Sugar methods ──
    public static function debug($msg, $ctx = [])     { self::log('debug',     $msg, $ctx); }
    public static function info($msg, $ctx = [])      { self::log('info',      $msg, $ctx); }
    public static function notice($msg, $ctx = [])    { self::log('notice',    $msg, $ctx); }
    public static function warning($msg, $ctx = [])   { self::log('warning',   $msg, $ctx); }
    public static function error($msg, $ctx = [])     { self::log('error',     $msg, $ctx); }
    public static function critical($msg, $ctx = [])  { self::log('critical',  $msg, $ctx); }

    /** Convenience for catching exceptions. */
    public static function exception(Throwable $e, $level = 'error', array $extra = []) {
        $ctx = array_merge($extra, [
            'exception_class' => get_class($e),
            'file'            => $e->getFile(),
            'line'            => $e->getLine(),
            'trace_snippet'   => array_slice(explode("\n", $e->getTraceAsString()), 0, 6),
        ]);
        self::log($level, $e->getMessage(), $ctx);
    }

    /**
     * Log rotation helper — call from cron to delete logs older than N days.
     */
    public static function rotate($keepDays = 30) {
        self::init();
        if (self::$channel !== 'file' || !is_dir(self::$logDir)) return 0;
        $threshold = time() - ($keepDays * 86400);
        $removed = 0;
        foreach (glob(self::$logDir . '/*.log') as $f) {
            if (filemtime($f) < $threshold) {
                @unlink($f);
                $removed++;
            }
        }
        return $removed;
    }
}
