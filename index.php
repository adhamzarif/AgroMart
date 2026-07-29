<?php
/**
 * AgroFin – Application Entry Point
 * Bootstraps configuration, session, autoloader, and routes the request.
 */

define('BASE_PATH', __DIR__);
define('UPLOAD_PATH', BASE_PATH . '/uploads');

// ─── Load .env (must happen before any config that depends on it) ───
require_once BASE_PATH . '/core/Env.php';
Env::load(BASE_PATH . '/.env');

// Honor APP_DEBUG for error visibility
$appDebug = Env::getBool('APP_DEBUG', true);
error_reporting($appDebug ? E_ALL : (E_ALL & ~E_NOTICE & ~E_DEPRECATED));
ini_set('display_errors', $appDebug ? '1' : '0');
date_default_timezone_set(Env::get('APP_TIMEZONE', 'Asia/Dhaka'));

// BASE_URL: derive from APP_URL or fall back to '/AgroFin' for XAMPP installs
$appUrl = Env::get('APP_URL', '');
$basePath = $appUrl ? parse_url($appUrl, PHP_URL_PATH) : '';
define('BASE_URL', $basePath ?: '/AgroFin');
define('UPLOAD_URL', BASE_URL . '/uploads');

// Secure session cookie params (must be before session_start)
$cookieParams = session_get_cookie_params();
session_set_cookie_params([
    'lifetime' => Env::getInt('SESSION_LIFETIME', 0),
    'path'     => '/',
    'domain'   => $cookieParams['domain'],
    'secure'   => Env::getBool('SESSION_SECURE', false) || isset($_SERVER['HTTPS']),
    'httponly' => true,
    'samesite' => Env::get('SESSION_SAMESITE', 'Lax'),
]);
session_start();

require_once BASE_PATH . '/core/Logger.php';
require_once BASE_PATH . '/core/SessionGuard.php';

// Enforce idle/absolute timeout + fingerprint binding on every request
SessionGuard::enforce();

require_once BASE_PATH . '/config/database.php';
require_once BASE_PATH . '/core/Helpers.php';
require_once BASE_PATH . '/core/Csrf.php';
require_once BASE_PATH . '/core/Flash.php';
require_once BASE_PATH . '/core/Model.php';
require_once BASE_PATH . '/core/Controller.php';
require_once BASE_PATH . '/core/Router.php';
require_once BASE_PATH . '/core/Cache.php';
require_once BASE_PATH . '/core/RateLimit.php';
require_once BASE_PATH . '/core/SearchProvider.php';

// Autoloader for Models / Controllers
spl_autoload_register(function ($class) {
    foreach (['Models', 'Controllers'] as $dir) {
        $f = BASE_PATH . '/' . $dir . '/' . $class . '.php';
        if (file_exists($f)) { require_once $f; return; }
    }
});

try {
    (new Router())->dispatch();
} catch (Throwable $e) {
    Logger::exception($e, 'critical', ['source' => 'router_dispatch']);
    if (ini_get('display_errors')) {
        echo '<h2>Application Error</h2><pre style="background:#fee;padding:12px;border:1px solid #f99">'
           . htmlspecialchars($e->getMessage()) . "\n\n"
           . htmlspecialchars($e->getTraceAsString()) . '</pre>';
    } else {
        http_response_code(500);
        echo 'Internal server error';
    }
}
