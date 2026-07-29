<?php
/**
 * One-shot Flash messages stored in session.
 * Types: success, danger, warning, info.
 * Usage:
 *   Flash::set('success', 'সংরক্ষণ সফল হয়েছে');
 *   foreach (Flash::all() as $f) { ... }
 */
class Flash {
    public static function set($type, $message) {
        if (!isset($_SESSION['_flash'])) $_SESSION['_flash'] = [];
        $_SESSION['_flash'][] = ['type' => $type, 'message' => $message];
    }

    /** Returns all messages and clears the store. */
    public static function all() {
        $all = $_SESSION['_flash'] ?? [];
        unset($_SESSION['_flash']);
        return $all;
    }

    public static function has() {
        return !empty($_SESSION['_flash']);
    }

    /** Render all flash messages as HTML and clear them. */
    public static function render() {
        $all = self::all();
        if (empty($all)) return '';
        $out = '<div class="flash-stack">';
        foreach ($all as $f) {
            $type = htmlspecialchars($f['type'], ENT_QUOTES);
            $msg  = htmlspecialchars($f['message'], ENT_QUOTES);
            $icon = [
                'success' => 'bi-check-circle-fill',
                'danger'  => 'bi-x-circle-fill',
                'warning' => 'bi-exclamation-triangle-fill',
                'info'    => 'bi-info-circle-fill',
            ][$f['type']] ?? 'bi-info-circle-fill';
            $out .= '<div class="flash flash-' . $type . '"><i class="bi ' . $icon . '"></i><span>' . $msg . '</span><button type="button" class="flash-close" onclick="this.parentElement.remove()">&times;</button></div>';
        }
        $out .= '</div>';
        return $out;
    }
}
