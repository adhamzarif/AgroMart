<?php
/**
 * Tiny .env loader — pure PHP, no dependencies.
 * Parses a KEY=value file and populates $_ENV + getenv().
 *
 * Usage in index.php:
 *   require __DIR__ . '/core/Env.php';
 *   Env::load(__DIR__ . '/.env');
 *   $db = Env::get('DB_NAME', 'agrofin');
 *
 * Format:
 *   KEY=value           (no quotes)
 *   KEY="value here"    (double-quoted; supports spaces)
 *   KEY='value'         (single-quoted)
 *   # comment line
 *   KEY=               (empty string)
 */
class Env {
    private static $loaded = [];
    private static $isLoaded = false;

    public static function load($path) {
        if (!file_exists($path)) return false;
        if (self::$isLoaded) return true;

        $lines = file($path, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
        foreach ($lines as $line) {
            $line = trim($line);
            if ($line === '' || $line[0] === '#') continue;
            if (strpos($line, '=') === false) continue;

            list($key, $value) = explode('=', $line, 2);
            $key = trim($key);
            $value = trim($value);

            // Strip surrounding quotes
            if (strlen($value) >= 2) {
                $first = $value[0];
                $last = $value[strlen($value) - 1];
                if (($first === '"' && $last === '"') || ($first === "'" && $last === "'")) {
                    $value = substr($value, 1, -1);
                }
            }

            // Expand escape sequences inside double-quoted strings
            $value = str_replace(['\\n', '\\t', '\\"', '\\\\'], ["\n", "\t", '"', '\\'], $value);

            self::$loaded[$key] = $value;
            if (!array_key_exists($key, $_ENV)) $_ENV[$key] = $value;
            if (getenv($key) === false) putenv("$key=$value");
        }
        self::$isLoaded = true;
        return true;
    }

    /** Get an env value with optional default. */
    public static function get($key, $default = null) {
        if (array_key_exists($key, self::$loaded)) return self::$loaded[$key];
        if (array_key_exists($key, $_ENV)) return $_ENV[$key];
        $val = getenv($key);
        return ($val === false) ? $default : $val;
    }

    /** Get an env value cast to bool (accepts true/false/1/0/yes/no/on/off). */
    public static function getBool($key, $default = false) {
        $v = self::get($key);
        if ($v === null) return $default;
        $v = strtolower(trim($v));
        return in_array($v, ['true', '1', 'yes', 'on'], true);
    }

    /** Get an env value cast to int. */
    public static function getInt($key, $default = 0) {
        $v = self::get($key);
        return ($v === null) ? $default : (int)$v;
    }

    /** True if .env was loaded successfully. */
    public static function isLoaded() { return self::$isLoaded; }
}
