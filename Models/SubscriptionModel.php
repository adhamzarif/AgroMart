<?php
class SubscriptionModel extends Model {

    public function listByBuyer($buyerId) {
        return $this->fetchAll(
            "SELECT s.*, u.full_name AS farmer_name, u.phone AS farmer_phone, d.district_name
             FROM subscriptions s
             JOIN users u ON s.farmer_id = u.user_id
             LEFT JOIN districts d ON u.district_id = d.district_id
             WHERE s.buyer_id = ?
             ORDER BY s.created_at DESC",
            [$buyerId]
        );
    }

    public function find($subscriptionId, $buyerId) {
        return $this->fetchOne(
            "SELECT s.*, u.full_name AS farmer_name FROM subscriptions s
             JOIN users u ON s.farmer_id = u.user_id
             WHERE s.subscription_id = ? AND s.buyer_id = ?",
            [$subscriptionId, $buyerId]
        );
    }

    public function create(array $data) {
        $this->execute(
            "INSERT INTO subscriptions (buyer_id, farmer_id, crop_name, quantity_per_delivery, unit, price_locked, frequency,
                                        next_delivery_date, start_date, end_date, auto_payment, payment_method_id, status)
             VALUES (?,?,?,?,?,?,?,?,?,?,?,?,'active')",
            [
                $data['buyer_id'], $data['farmer_id'], $data['crop_name'],
                $data['quantity_per_delivery'], $data['unit'], $data['price_locked'],
                $data['frequency'], $data['next_delivery_date'], $data['start_date'],
                $data['end_date'] ?? null,
                !empty($data['auto_payment']) ? 1 : 0,
                !empty($data['payment_method_id']) ? (int)$data['payment_method_id'] : null,
            ]
        );
        return $this->lastInsertId();
    }

    public function setStatus($subscriptionId, $buyerId, $status) {
        $allowed = ['active','paused','cancelled'];
        if (!in_array($status, $allowed, true)) return false;
        return $this->execute(
            "UPDATE subscriptions SET status = ? WHERE subscription_id = ? AND buyer_id = ?",
            [$status, $subscriptionId, $buyerId]
        );
    }
}
