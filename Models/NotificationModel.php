<?php
class NotificationModel extends Model {

    public function listForUser($userId, $limit = 50) {
        return $this->fetchAll(
            "SELECT * FROM notifications WHERE user_id = ? ORDER BY created_at DESC LIMIT $limit",
            [$userId]
        );
    }

    public function markAllRead($userId) {
        return $this->execute(
            "UPDATE notifications SET is_read = 1, read_at = NOW() WHERE user_id = ? AND is_read = 0",
            [$userId]
        );
    }

    public function markRead($notificationId, $userId) {
        return $this->execute(
            "UPDATE notifications SET is_read = 1, read_at = NOW() WHERE notification_id = ? AND user_id = ?",
            [$notificationId, $userId]
        );
    }

    public function unreadCount($userId) {
        return (int)$this->fetchScalar(
            "SELECT COUNT(*) FROM notifications WHERE user_id = ? AND is_read = 0",
            [$userId]
        );
    }
}
