<?php
/**
 * TransportModel — transport partners + deliveries.
 */
class TransportModel extends Model {

    // ─── PARTNERS ─────────────────────────────────────────────────────

    public function listPartners($activeOnly = false) {
        $sql = "SELECT * FROM transport_partners";
        if ($activeOnly) $sql .= " WHERE is_active = 1";
        $sql .= " ORDER BY rating DESC, total_deliveries DESC";
        return $this->fetchAll($sql);
    }

    public function findPartner($partnerId) {
        return $this->fetchOne("SELECT * FROM transport_partners WHERE partner_id = ?", [$partnerId]);
    }

    public function createPartner(array $data) {
        $this->execute(
            "INSERT INTO transport_partners
             (partner_name, contact_person, contact_phone, contact_email, service_districts, vehicle_types,
              base_rate_per_km, min_charge, is_active)
             VALUES (?,?,?,?,?,?,?,?,1)",
            [
                $data['partner_name'], $data['contact_person'] ?? null, $data['contact_phone'],
                $data['contact_email'] ?? null,
                json_encode($data['service_districts'] ?? [], JSON_UNESCAPED_UNICODE),
                json_encode($data['vehicle_types'] ?? [], JSON_UNESCAPED_UNICODE),
                (float)$data['base_rate_per_km'], (float)$data['min_charge'],
            ]
        );
        return $this->lastInsertId();
    }

    public function updatePartner($partnerId, array $data) {
        return $this->execute(
            "UPDATE transport_partners SET
                partner_name = ?, contact_person = ?, contact_phone = ?, contact_email = ?,
                service_districts = ?, vehicle_types = ?, base_rate_per_km = ?, min_charge = ?
             WHERE partner_id = ?",
            [
                $data['partner_name'], $data['contact_person'] ?? null, $data['contact_phone'],
                $data['contact_email'] ?? null,
                json_encode($data['service_districts'] ?? [], JSON_UNESCAPED_UNICODE),
                json_encode($data['vehicle_types'] ?? [], JSON_UNESCAPED_UNICODE),
                (float)$data['base_rate_per_km'], (float)$data['min_charge'],
                $partnerId,
            ]
        );
    }

    public function setPartnerActive($partnerId, $active) {
        return $this->execute("UPDATE transport_partners SET is_active = ? WHERE partner_id = ?",
            [$active ? 1 : 0, $partnerId]);
    }

    public function deletePartner($partnerId) {
        return $this->execute("DELETE FROM transport_partners WHERE partner_id = ?", [$partnerId]);
    }

    // ─── DELIVERIES ───────────────────────────────────────────────────

    public function deliveryForOrder($orderId) {
        return $this->fetchOne(
            "SELECT d.*, tp.partner_name FROM deliveries d
             LEFT JOIN transport_partners tp ON d.transport_partner_id = tp.partner_id
             WHERE d.order_id = ?",
            [$orderId]
        );
    }

    public function listDeliveries($statusFilter = null, $limit = 50) {
        $sql = "SELECT d.*, o.order_number, tp.partner_name,
                       fu.full_name AS farmer_name, bu.full_name AS buyer_name
                FROM deliveries d
                JOIN orders o ON d.order_id = o.order_id
                JOIN users fu ON o.farmer_id = fu.user_id
                JOIN users bu ON o.buyer_id = bu.user_id
                LEFT JOIN transport_partners tp ON d.transport_partner_id = tp.partner_id";
        $params = [];
        if ($statusFilter) {
            $sql .= " WHERE d.delivery_status = ?";
            $params[] = $statusFilter;
        }
        $sql .= " ORDER BY d.created_at DESC LIMIT $limit";
        return $this->fetchAll($sql, $params);
    }
}
