<?php
/**
 * Lightweight logger for cron output.
 * Writes to storage/logs/cron-YYYY-MM-DD.log and also to STDOUT
 * (so `tail -f` works when running cron manually).
 */
class CronLogger {

    public static function log($task, $message) {
        $dir = dirname(__DIR__) . '/storage/logs';
        if (!is_dir($dir)) @mkdir($dir, 0755, true);
        $file = $dir . '/cron-' . date('Y-m-d') . '.log';
        $line = '[' . date('Y-m-d H:i:s') . '] [' . str_pad($task, 20) . '] ' . $message . PHP_EOL;
        @file_put_contents($file, $line, FILE_APPEND | LOCK_EX);
        if (PHP_SAPI === 'cli') fwrite(STDOUT, $line);
    }

    public static function error($task, $message) {
        self::log($task, '❌ ERROR: ' . $message);
    }

    public static function success($task, $message) {
        self::log($task, '✓ ' . $message);
    }
}
