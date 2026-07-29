<?php
/**
 * CacheCleanupTask — periodically prune expired file-cache entries.
 *
 * The file driver doesn't auto-evict on access miss; entries are deleted
 * lazily when get() finds them expired. But abandoned keys (set but never
 * fetched again) accumulate indefinitely. This task scans the cache dir
 * and removes anything past its expiry.
 *
 * Schedule: daily — low priority maintenance
 * No-op for redis/apcu drivers (they handle eviction natively).
 */
class CacheCleanupTask extends CronTask {

    public $name = 'cache_cleanup';
    public $schedule = 'daily';

    public function run() {
        require_once dirname(__DIR__, 2) . '/core/Cache.php';
        $stats = Cache::stats();
        if ($stats['driver'] !== 'file') {
            return ['ok' => true, 'message' => "Driver is {$stats['driver']} — no-op", 'affected' => 0];
        }

        $dir = $stats['path'] ?? null;
        if (!$dir || !is_dir($dir)) {
            return ['ok' => true, 'message' => 'No cache dir', 'affected' => 0];
        }

        $now = time();
        $removed = 0;
        $kept = 0;

        foreach (glob($dir . '/*.cache') as $file) {
            $raw = @file_get_contents($file);
            if ($raw === false) {
                @unlink($file); $removed++; continue;
            }
            $entry = @unserialize($raw);
            if (!is_array($entry) || empty($entry['expires']) || $entry['expires'] < $now) {
                @unlink($file);
                $removed++;
            } else {
                $kept++;
            }
        }

        return [
            'ok' => true,
            'message' => "Removed $removed expired entries, kept $kept",
            'affected' => $removed,
        ];
    }
}
