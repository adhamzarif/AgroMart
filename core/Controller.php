<?php
/**
 * Base Controller — extends by every concrete controller.
 * Provides: view rendering, login/role guards, CSRF check, redirect, json helpers.
 */
class Controller {

    /** Render a view (includes header/navbar/footer if requested). */
    public function view($view, $data = []) {
        extract($data, EXTR_SKIP);
        $viewFile = BASE_PATH . '/views/' . $view . '.php';
        if (!file_exists($viewFile)) {
            http_response_code(404);
            die("View not found: " . htmlspecialchars($view));
        }
        require $viewFile;
    }

    /** Require any logged-in user. */
    public function requireLogin() {
        if (empty($_SESSION['user_id'])) {
            Flash::set('warning', 'অনুগ্রহ করে প্রথমে লগইন করুন।');
            $this->redirect('/auth/login');
        }
        $this->_touchLastSeen();
    }

    /**
     * Update users.last_seen_at — throttled to once every 5 minutes per session
     * to avoid hitting the DB on every page navigation.
     */
    private function _touchLastSeen() {
        $now = time();
        $last = $_SESSION['_last_seen_pushed'] ?? 0;
        if (($now - $last) < 300) return; // 5-minute throttle
        try {
            $pdo = Database::getInstance()->getConnection();
            $pdo->prepare("UPDATE users SET last_seen_at = NOW() WHERE user_id = ?")
                ->execute([(int)$_SESSION['user_id']]);
            $_SESSION['_last_seen_pushed'] = $now;
        } catch (Throwable $e) {
            // non-fatal — column may not yet exist if migration 003 not run
        }
    }

    /**
     * Require a specific role for the active session.
     * Accepts a single role string or an array. The user's active_role must match.
     */
    public function requireRole($role) {
        $this->requireLogin();
        $allowed = is_array($role) ? $role : [$role];
        $active  = $_SESSION['active_role'] ?? null;
        if (!in_array($active, $allowed, true)) {
            Flash::set('danger', 'এই পেজে প্রবেশের অনুমতি আপনার নেই।');
            $this->redirect('/');
        }
    }

    /** Verify a CSRF token from POST. Call at the top of every POST handler. */
    public function requireCsrf() {
        $token = $_POST['_csrf'] ?? '';
        if (!Csrf::verify($token)) {
            Flash::set('danger', 'অবৈধ অনুরোধ (CSRF সুরক্ষা)। অনুগ্রহ করে পেজটি রিফ্রেশ করে আবার চেষ্টা করুন।');
            $this->redirect($_SERVER['HTTP_REFERER'] ?? BASE_URL . '/');
        }
    }

    /** Internal redirect (path relative to BASE_URL or absolute URL). */
    public function redirect($path) {
        if (preg_match('#^https?://#', $path)) {
            header('Location: ' . $path);
        } else {
            header('Location: ' . BASE_URL . $path);
        }
        exit;
    }

    /** Return JSON and exit. */
    public function json($data, $code = 200) {
        http_response_code($code);
        header('Content-Type: application/json; charset=utf-8');
        echo json_encode($data, JSON_UNESCAPED_UNICODE);
        exit;
    }

    /** Resolve current user id (returns 0 if not logged in). */
    public function userId() {
        return (int)($_SESSION['user_id'] ?? 0);
    }

    /** Resolve active role for the user. */
    public function activeRole() {
        return $_SESSION['active_role'] ?? null;
    }
}
