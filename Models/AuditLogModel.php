<?php
/**
 * AuditLogModel — record and read admin actions.
 */
class AuditLogModel extends Model {

    public function log($userId, $actionType, $tableName, $recordId, $oldValues = null, $newValues = null) {
        return $this->execute(
            "INSERT INTO audit_logs (user_id, action_type, table_name, record_id, old_values, new_values, ip_address, user_agent)
             VALUES (?,?,?,?,?,?,?,?)",
            [
                $userId, $actionType, $tableName, $recordId,
                $oldValues ? json_encode($oldValues, JSON_UNESCAPED_UNICODE) : null,
                $newValues ? json_encode($newValues, JSON_UNESCAPED_UNICODE) : null,
                $_SERVER['REMOTE_ADDR'] ?? null,
                mb_substr($_SERVER['HTTP_USER_AGENT'] ?? '', 0, 255),
            ]
        );
    }

    public function recent($filters = [], $limit = 100, $offset = 0) {
        $where = ["1=1"];
        $params = [];
        if (!empty($filters['user_id'])) { $where[] = "al.user_id = ?"; $params[] = (int)$filters['user_id']; }
        if (!empty($filters['action_type'])) { $where[] = "al.action_type = ?"; $params[] = $filters['action_type']; }
        if (!empty($filters['table_name'])) { $where[] = "al.table_name = ?"; $params[] = $filters['table_name']; }
        if (!empty($filters['date_from'])) { $where[] = "al.created_at >= ?"; $params[] = $filters['date_from']; }
        if (!empty($filters['date_to'])) { $where[] = "al.created_at <= ?"; $params[] = $filters['date_to'] . ' 23:59:59'; }

        $sql = "SELECT al.*, u.full_name AS actor_name
                FROM audit_logs al
                LEFT JOIN users u ON al.user_id = u.user_id
                WHERE " . implode(' AND ', $where) . "
                ORDER BY al.created_at DESC LIMIT $limit OFFSET $offset";
        return $this->fetchAll($sql, $params);
    }

    public function countRecent($filters = []) {
        $where = ["1=1"];
        $params = [];
        if (!empty($filters['user_id'])) { $where[] = "user_id = ?"; $params[] = (int)$filters['user_id']; }
        if (!empty($filters['action_type'])) { $where[] = "action_type = ?"; $params[] = $filters['action_type']; }
        if (!empty($filters['table_name'])) { $where[] = "table_name = ?"; $params[] = $filters['table_name']; }
        if (!empty($filters['date_from'])) { $where[] = "created_at >= ?"; $params[] = $filters['date_from']; }
        if (!empty($filters['date_to'])) { $where[] = "created_at <= ?"; $params[] = $filters['date_to'] . ' 23:59:59'; }
        return (int)$this->fetchScalar("SELECT COUNT(*) FROM audit_logs WHERE " . implode(' AND ', $where), $params);
    }
}
