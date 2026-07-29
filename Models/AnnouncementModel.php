<?php
/**
 * AnnouncementModel — broadcast system messages using the notifications table.
 * Since there's no system_announcements table, we use notification_type='system'
 * and a special title prefix to recognize broadcasts in admin views.
 */
class AnnouncementModel extends Model {

    /**
     * Broadcast to users matching the target criteria.
     * $target = ['roles' => ['farmer','buyer'], 'districts' => [1,2,3]]
     * Either or both filters can be set.
     */
    public function broadcast($createdByUserId, $title, $message, array $target = [], $priority = 'medium') {
        $where = ["u.account_status = 'active'"];
        $params = [];

        if (!empty($target['roles'])) {
            $placeholders = implode(',', array_fill(0, count($target['roles']), '?'));
            $where[] = "EXISTS (SELECT 1 FROM user_roles WHERE user_id = u.user_id AND role IN ($placeholders))";
            $params = array_merge($params, $target['roles']);
        }
        if (!empty($target['districts'])) {
            $placeholders = implode(',', array_fill(0, count($target['districts']), '?'));
            $where[] = "u.district_id IN ($placeholders)";
            $params = array_merge($params, array_map('intval', $target['districts']));
        }

        // Find targeted users
        $sql = "SELECT user_id FROM users u WHERE " . implode(' AND ', $where);
        $users = $this->fetchAll($sql, $params);

        $broadcastId = uniqid('bc_');
        $count = 0;
        foreach ($users as $u) {
            $ok = $this->execute(
                "INSERT INTO notifications (user_id, notification_type, priority, title, message, action_url)
                 VALUES (?, 'system', ?, ?, ?, NULL)",
                [$u['user_id'], $priority, '📢 ' . $title, $message]
            );
            if ($ok) $count++;
        }
        return ['ok' => true, 'broadcast_id' => $broadcastId, 'recipient_count' => $count];
    }

    /**
     * List recent broadcasts (notifications with type=system and title starting with 📢).
     * Groups by (title, message, created_at±1min) approximated by created_at minute precision.
     */
    public function listBroadcasts($limit = 20) {
        return $this->fetchAll(
            "SELECT
                DATE_FORMAT(created_at, '%Y-%m-%d %H:%i') AS sent_minute,
                title,
                message,
                priority,
                MIN(created_at) AS sent_at,
                COUNT(*) AS recipient_count,
                SUM(is_read) AS read_count
             FROM notifications
             WHERE notification_type = 'system' AND title LIKE '📢%'
             GROUP BY sent_minute, title, message, priority
             ORDER BY sent_at DESC
             LIMIT $limit"
        );
    }
}
