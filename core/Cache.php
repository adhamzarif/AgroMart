<?php
/**
 * Cache — simple key/value cache with TTL.
 * ─────────────────────────────────────────────────────────────
 * Driver selected via .env CACHE_DRIVER:
 *   file   — default; stores serialized data in storage/cache/
 *   redis  — if Redis extension installed and REDIS_HOST set
 *   apcu   — if APCu installed
 *   none   — disabled (Cache::get always returns null; useful in tests)
 *
 * Used to cache:
 *   - Districts list (rarely changes)
 *   - Crop categories
 *   - Latest market prices (1h TTL)
 *   - Live price chart data
 *   - Stat aggregations on dashboards
 *
 * Usage:
 *   $districts = Cache::remember('districts:all', 3600, function() {
 *       return (new DistrictModel())->all();
 *   });
 * ─────────────────────────────────────────────────────────────
 */
class Cache {

    const DEFAULT_TTL = 3600; // 1 hour

    private static $driver = null;
    private static $instance = null;

    /** Configure once at boot. */
    public static function init() {
        if (self::$driver !== null) return;
        self::$driver = Env::get('CACHE_DRIVER', 'file');

        switch (self::$driver) {
            case 'redis':
                if (extension_loaded('redis')) {
                    self::$instance = new Redis();
                    @self::$instance->connect(
                        Env::get('REDIS_HOST', '127.0.0.1'),
                        Env::getInt('REDIS_PORT', 6379),
                        2.0
                    );
                    $pass = Env::get('REDIS_PASSWORD', '');
                    if ($pass) @self::$instance->auth($pass);
                } else {
                    // Redis driver requested but extension missing — fall back
                    self::$driver = 'file';
                }
                break;
            case 'apcu':
                if (!function_exists('apcu_fetch')) self::$driver = 'file';
                break;
            case 'none':
            case 'file':
            default:
                // No init needed
                break;
        }

        // Ensure file cache dir exists
        if (self::$driver === 'file') {
            $dir = self::fileCacheDir();
            if (!is_dir($dir)) @mkdir($dir, 0775, true);
        }
    }

    /**
     * Get a cached value or null if missing/expired.
     */
    public static function get($key) {
        self::init();
        if (self::$driver === 'none') return null;

        switch (self::$driver) {
            case 'redis':
                if (!self::$instance) return null;
                $val = @self::$instance->get(self::prefix($key));
                return $val === false ? null : unserialize($val);

            case 'apcu':
                $success = false;
                $val = apcu_fetch(self::prefix($key), $success);
                return $success ? $val : null;

            case 'file':
            default:
                $file = self::filePath($key);
                if (!file_exists($file)) return null;
                $raw = @file_get_contents($file);
                if ($raw === false) return null;
                $entry = @unserialize($raw);
                if (!is_array($entry) || !isset($entry['expires'], $entry['value'])) {
                    @unlink($file);
                    return null;
                }
                if ($entry['expires'] < time()) {
                    @unlink($file);
                    return null;
                }
                return $entry['value'];
        }
    }

    /** Set a value with TTL (seconds). Returns success bool. */
    public static function set($key, $value, $ttl = self::DEFAULT_TTL) {
        self::init();
        if (self::$driver === 'none') return false;

        switch (self::$driver) {
            case 'redis':
                if (!self::$instance) return false;
                return (bool)@self::$instance->setex(self::prefix($key), $ttl, serialize($value));

            case 'apcu':
                return apcu_store(self::prefix($key), $value, $ttl);

            case 'file':
            default:
                $file = self::filePath($key);
                $entry = ['expires' => time() + $ttl, 'value' => $value];
                return @file_put_contents($file, serialize($entry), LOCK_EX) !== false;
        }
    }

    /** Delete a single key. */
    public static function forget($key) {
        self::init();
        if (self::$driver === 'none') return true;

        switch (self::$driver) {
            case 'redis':
                if (!self::$instance) return false;
                return (bool)@self::$instance->del(self::prefix($key));
            case 'apcu':
                return apcu_delete(self::prefix($key));
            case 'file':
            default:
                $file = self::filePath($key);
                return file_exists($file) ? @unlink($file) : true;
        }
    }

    /**
     * Forget every key starting with a prefix.
     * Useful when you change a parent record and need to invalidate
     * all derived caches (e.g., 'farmer:42:*' when farmer 42 updates).
     */
    public static function forgetPrefix($prefix) {
        self::init();
        if (self::$driver === 'none') return 0;

        $globalPrefix = self::prefix($prefix);

        switch (self::$driver) {
            case 'redis':
                if (!self::$instance) return 0;
                $keys = @self::$instance->keys($globalPrefix . '*');
                if (!$keys) return 0;
                return (int)@self::$instance->del($keys);

            case 'apcu':
                $iter = new APCUIterator('/^' . preg_quote($globalPrefix, '/') . '/');
                $count = 0;
                foreach ($iter as $entry) {
                    apcu_delete($entry['key']);
                    $count++;
                }
                return $count;

            case 'file':
            default:
                $hash = md5($prefix);
                $dir = self::fileCacheDir();
                $count = 0;
                foreach (glob($dir . '/*.cache') as $f) {
                    // Re-deserialize meta? Simpler: rely on hash-prefix.
                    // We can't filter by prefix without a sidecar metadata file,
                    // so we conservatively clear ALL on broad-prefix invalidation.
                    @unlink($f);
                    $count++;
                }
                return $count;
        }
    }

    /**
     * The most-used pattern: get cached value or compute + cache it.
     */
    public static function remember($key, $ttl, callable $loader) {
        $cached = self::get($key);
        if ($cached !== null) return $cached;

        $value = $loader();
        if ($value !== null) self::set($key, $value, $ttl);
        return $value;
    }

    /** Empty the whole cache. Returns bool. */
    public static function flush() {
        self::init();
        if (self::$driver === 'none') return true;

        switch (self::$driver) {
            case 'redis':
                if (!self::$instance) return false;
                return (bool)@self::$instance->flushDB();
            case 'apcu':
                return apcu_clear_cache();
            case 'file':
            default:
                $dir = self::fileCacheDir();
                foreach (glob($dir . '/*.cache') as $f) @unlink($f);
                return true;
        }
    }

    /** Stats — for an admin debug page. */
    public static function stats() {
        self::init();
        $stats = ['driver' => self::$driver];

        switch (self::$driver) {
            case 'redis':
                if (self::$instance) {
                    $info = @self::$instance->info();
                    $stats['connected'] = true;
                    $stats['keys'] = (int)(@self::$instance->dbSize());
                    $stats['memory_used'] = $info['used_memory_human'] ?? 'n/a';
                } else {
                    $stats['connected'] = false;
                }
                break;
            case 'apcu':
                $info = apcu_cache_info(true);
                $stats['keys'] = $info['num_entries'] ?? 0;
                $stats['memory_used'] = number_format(($info['mem_size'] ?? 0) / 1024 / 1024, 2) . ' MB';
                break;
            case 'file':
            default:
                $dir = self::fileCacheDir();
                $files = glob($dir . '/*.cache') ?: [];
                $totalBytes = 0;
                foreach ($files as $f) $totalBytes += filesize($f);
                $stats['keys'] = count($files);
                $stats['memory_used'] = number_format($totalBytes / 1024, 1) . ' KB';
                $stats['path'] = $dir;
                break;
        }
        return $stats;
    }

    // ── Internals ──

    private static function prefix($key) {
        return 'agrofin:' . $key;
    }

    private static function fileCacheDir() {
        return dirname(__DIR__) . '/storage/cache';
    }

    private static function filePath($key) {
        return self::fileCacheDir() . '/' . md5(self::prefix($key)) . '.cache';
    }
}
