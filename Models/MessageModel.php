<?php
/**
 * MessageModel — direct messaging between users.
 */
class MessageModel extends Model {

    /** Get inbox: list of distinct conversations with latest message + unread count. */
    public function inbox($userId) {
        return $this->fetchAll(
            "SELECT
                u.user_id AS partner_id,
                u.full_name AS partner_name,
                u.profile_picture AS partner_picture,
                u.phone AS partner_phone,
                (SELECT GROUP_CONCAT(role) FROM user_roles WHERE user_id = u.user_id) AS partner_roles,
                (SELECT message_text FROM messages m
                  WHERE (m.sender_id = u.user_id AND m.receiver_id = ?)
                     OR (m.sender_id = ? AND m.receiver_id = u.user_id)
                  ORDER BY created_at DESC LIMIT 1) AS last_message,
                (SELECT created_at FROM messages m
                  WHERE (m.sender_id = u.user_id AND m.receiver_id = ?)
                     OR (m.sender_id = ? AND m.receiver_id = u.user_id)
                  ORDER BY created_at DESC LIMIT 1) AS last_at,
                (SELECT COUNT(*) FROM messages WHERE sender_id = u.user_id AND receiver_id = ? AND is_read = 0) AS unread
             FROM users u
             WHERE u.user_id IN (
                SELECT DISTINCT IF(sender_id = ?, receiver_id, sender_id)
                FROM messages WHERE sender_id = ? OR receiver_id = ?
             )
             ORDER BY last_at DESC",
            [$userId,$userId,$userId,$userId,$userId,$userId,$userId,$userId]
        );
    }

    /** Get conversation between two users. */
    public function conversation($userA, $userB, $limit = 50) {
        $sql = "SELECT m.*,
                       s.full_name AS sender_name, s.profile_picture AS sender_picture
                FROM messages m
                JOIN users s ON m.sender_id = s.user_id
                WHERE (m.sender_id = ? AND m.receiver_id = ?)
                   OR (m.sender_id = ? AND m.receiver_id = ?)
                ORDER BY m.created_at ASC
                LIMIT $limit";
        return $this->fetchAll($sql, [$userA, $userB, $userB, $userA]);
    }

    /** Send a message. */
    public function send($senderId, $receiverId, $text, $cropId = null) {
        $this->execute(
            "INSERT INTO messages (sender_id, receiver_id, message_text, message_type, related_crop_id)
             VALUES (?,?,?,'text',?)",
            [$senderId, $receiverId, $text, $cropId]
        );
        $msgId = $this->lastInsertId();
        // Notify
        $sender = $this->fetchOne("SELECT full_name FROM users WHERE user_id = ?", [$senderId]);
        $preview = mb_substr($text, 0, 60, 'UTF-8');
        $this->execute(
            "INSERT INTO notifications (user_id, notification_type, priority, title, message, action_url, related_id)
             VALUES (?, 'message', 'medium', ?, ?, '/messages', ?)",
            [$receiverId, $sender['full_name'] . ' এর কাছ থেকে নতুন বার্তা', $preview, $msgId]
        );
        return $msgId;
    }

    /** Mark all messages from $partnerId to $userId as read. */
    public function markRead($userId, $partnerId) {
        return $this->execute(
            "UPDATE messages SET is_read = 1, read_at = NOW()
             WHERE receiver_id = ? AND sender_id = ? AND is_read = 0",
            [$userId, $partnerId]
        );
    }
}
