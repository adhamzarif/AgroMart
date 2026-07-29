<?php
class RatingModel extends Model {

    public function createForOrder($orderId, $buyerId, array $data) {
        $order = $this->fetchOne(
            "SELECT * FROM orders WHERE order_id = ? AND buyer_id = ? AND order_status = 'delivered'",
            [$orderId, $buyerId]
        );
        if (!$order) return ['ok' => false, 'error' => 'এই অর্ডারের জন্য আপনি রিভিউ দিতে পারবেন না।'];

        if ($this->fetchScalar("SELECT 1 FROM farmer_ratings WHERE order_id = ?", [$orderId])) {
            return ['ok' => false, 'error' => 'এই অর্ডারের জন্য ইতোমধ্যে রিভিউ দেওয়া হয়েছে।'];
        }

        $this->execute(
            "INSERT INTO farmer_ratings (farmer_id, buyer_id, order_id, overall_rating, quality_rating,
                                          delivery_rating, communication_rating, review_title, review_text, would_recommend)
             VALUES (?,?,?,?,?,?,?,?,?,?)",
            [
                $order['farmer_id'], $buyerId, $orderId,
                $data['overall_rating'], $data['quality_rating'],
                $data['delivery_rating'], $data['communication_rating'],
                $data['review_title'] ?? null, $data['review_text'] ?? null,
                !empty($data['would_recommend']) ? 1 : 0,
            ]
        );
        return ['ok' => true, 'rating_id' => $this->lastInsertId()];
    }

    public function ratingForOrder($orderId) {
        return $this->fetchOne("SELECT * FROM farmer_ratings WHERE order_id = ?", [$orderId]);
    }

    public function listForFarmer($farmerId, $limit = 20) {
        return $this->fetchAll(
            "SELECT fr.*, u.full_name AS buyer_name, u.profile_picture AS buyer_picture
             FROM farmer_ratings fr
             JOIN users u ON fr.buyer_id = u.user_id
             WHERE fr.farmer_id = ? AND fr.is_flagged = 0
             ORDER BY fr.created_at DESC LIMIT $limit",
            [$farmerId]
        );
    }
}
