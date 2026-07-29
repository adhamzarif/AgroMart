<?php
/**
 * WeatherAlertModel — admin CRUD for weather alerts; farmer dashboard reads from this.
 */
class WeatherAlertModel extends Model {

    public function listAll($activeOnly = false) {
        $sql = "SELECT wa.*, u.full_name AS created_by_name
                FROM weather_alerts wa
                LEFT JOIN users u ON wa.created_by = u.user_id";
        if ($activeOnly) $sql .= " WHERE wa.is_active = 1";
        $sql .= " ORDER BY wa.created_at DESC";
        return $this->fetchAll($sql);
    }

    public function find($alertId) {
        return $this->fetchOne("SELECT * FROM weather_alerts WHERE alert_id = ?", [$alertId]);
    }

    public function create(array $data) {
        $this->execute(
            "INSERT INTO weather_alerts
             (alert_type, severity, affected_districts, alert_title, alert_message, recommendations,
              affected_crops, start_time, end_time, issued_by, created_by, is_active)
             VALUES (?,?,?,?,?,?,?,?,?,?,?,1)",
            [
                $data['alert_type'], $data['severity'],
                json_encode($data['affected_districts'] ?? [], JSON_UNESCAPED_UNICODE),
                $data['alert_title'], $data['alert_message'],
                $data['recommendations'] ?? null,
                json_encode($data['affected_crops'] ?? [], JSON_UNESCAPED_UNICODE),
                $data['start_time'], $data['end_time'] ?? null,
                $data['issued_by'] ?? 'BMD', $data['created_by'] ?? null,
            ]
        );
        $alertId = $this->lastInsertId();

        // Notify farmers in affected districts
        $districts = $data['affected_districts'] ?? [];
        if (!empty($districts)) {
            $placeholders = implode(',', array_fill(0, count($districts), '?'));
            $farmers = $this->fetchAll(
                "SELECT u.user_id FROM users u
                 JOIN user_roles r ON u.user_id = r.user_id
                 WHERE r.role = 'farmer' AND u.district_id IN ($placeholders) AND u.account_status='active'",
                $districts
            );
            foreach ($farmers as $f) {
                $this->execute(
                    "INSERT INTO notifications (user_id, notification_type, priority, title, message, action_url, related_id)
                     VALUES (?, 'weather', 'high', ?, ?, '/farmer/weather', ?)",
                    [$f['user_id'], '⚠ আবহাওয়া সতর্কতা: ' . $data['alert_title'], $data['alert_message'], $alertId]
                );
            }
        }
        return $alertId;
    }

    public function setActive($alertId, $isActive) {
        return $this->execute("UPDATE weather_alerts SET is_active = ? WHERE alert_id = ?",
            [$isActive ? 1 : 0, $alertId]);
    }

    public function delete($alertId) {
        return $this->execute("DELETE FROM weather_alerts WHERE alert_id = ?", [$alertId]);
    }
}
