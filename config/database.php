<?php
/**
 * Singleton PDO connection for AgroFin.
 * Reads credentials from .env file. Falls back to sensible defaults so
 * existing XAMPP installs continue to work without an .env file.
 */
class Database {
    private static $instance = null;
    private $pdo;

    private function __construct() {
        $host    = Env::get('DB_HOST', 'localhost');
        $port    = Env::getInt('DB_PORT', 3306);
        $name    = Env::get('DB_NAME', 'agrofin');
        $user    = Env::get('DB_USER', 'root');
        $pass    = Env::get('DB_PASS', '');
        $charset = Env::get('DB_CHARSET', 'utf8mb4');
        $coll    = Env::get('DB_COLLATION', 'utf8mb4_unicode_ci');

        $dsn = "mysql:host={$host};port={$port};dbname={$name};charset={$charset}";
        $options = [
            PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES   => false,
            PDO::MYSQL_ATTR_INIT_COMMAND => "SET NAMES {$charset} COLLATE {$coll}",
        ];
        try {
            $this->pdo = new PDO($dsn, $user, $pass, $options);
        } catch (PDOException $e) {
            // CLI context (cron jobs) — re-throw so caller's try/catch can handle it cleanly
            if (PHP_SAPI === 'cli') {
                throw new RuntimeException(
                    'Database connection failed: ' . $e->getMessage()
                    . ' (host=' . $host . ', db=' . $name . ')'
                );
            }
            // Web context — show user-friendly Bangla error page
            $showDetails = Env::getBool('APP_DEBUG', false);
            $errorMsg = $showDetails ? htmlspecialchars($e->getMessage()) : 'Database unavailable. Contact administrator.';
            die('<div style="font-family:sans-serif;max-width:680px;margin:80px auto;padding:24px;background:#fee;border:1px solid #f99;border-radius:8px">'
              . '<h2 style="margin-top:0;color:#c33">ডাটাবেস সংযোগ ব্যর্থ</h2>'
              . '<p>অনুগ্রহ করে নিশ্চিত করুন:</p>'
              . '<ul><li>XAMPP-এ MySQL চালু আছে</li>'
              . '<li>"' . htmlspecialchars($name) . '" নামে ডাটাবেস তৈরি করা হয়েছে এবং <code>database.sql</code> ইমপোর্ট করা হয়েছে</li>'
              . '<li><code>.env</code> ফাইলে ইউজার/পাসওয়ার্ড সঠিক</li></ul>'
              . '<p style="color:#a33"><small>Error: ' . $errorMsg . '</small></p></div>');
        }
    }

    public static function getInstance() {
        if (self::$instance === null) self::$instance = new self();
        return self::$instance;
    }

    public function getConnection() {
        return $this->pdo;
    }
}
