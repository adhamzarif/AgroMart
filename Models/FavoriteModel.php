<?php
class FavoriteModel extends Model {

    public function toggleCrop($userId, $cropId) {
        $existing = $this->fetchOne(
            "SELECT favorite_id FROM favorites WHERE user_id = ? AND favorite_type='crop' AND crop_id = ?",
            [$userId, $cropId]
        );
        if ($existing) {
            $this->execute("DELETE FROM favorites WHERE favorite_id = ?", [$existing['favorite_id']]);
            return 'removed';
        }
        $this->execute(
            "INSERT INTO favorites (user_id, favorite_type, crop_id) VALUES (?, 'crop', ?)",
            [$userId, $cropId]
        );
        return 'added';
    }

    public function toggleFarmer($userId, $farmerId) {
        $existing = $this->fetchOne(
            "SELECT favorite_id FROM favorites WHERE user_id = ? AND favorite_type='farmer' AND farmer_id = ?",
            [$userId, $farmerId]
        );
        if ($existing) {
            $this->execute("DELETE FROM favorites WHERE favorite_id = ?", [$existing['favorite_id']]);
            return 'removed';
        }
        $this->execute(
            "INSERT INTO favorites (user_id, favorite_type, farmer_id) VALUES (?, 'farmer', ?)",
            [$userId, $farmerId]
        );
        return 'added';
    }

    public function isCropFavorite($userId, $cropId) {
        return (bool)$this->fetchScalar(
            "SELECT 1 FROM favorites WHERE user_id = ? AND favorite_type='crop' AND crop_id = ?",
            [$userId, $cropId]
        );
    }

    public function listCrops($userId) {
        return $this->fetchAll(
            "SELECT f.*, c.crop_name, c.price_per_unit, c.unit, c.quantity, c.status, c.images,
                    u.full_name AS farmer_name, d.district_name
             FROM favorites f
             JOIN crops c ON f.crop_id = c.crop_id
             JOIN users u ON c.farmer_id = u.user_id
             LEFT JOIN districts d ON u.district_id = d.district_id
             WHERE f.user_id = ? AND f.favorite_type = 'crop'
             ORDER BY f.created_at DESC",
            [$userId]
        );
    }

    public function listFarmers($userId) {
        return $this->fetchAll(
            "SELECT f.*, u.full_name AS farmer_name, u.profile_picture, u.phone, d.district_name,
                    IFNULL((SELECT AVG(overall_rating) FROM farmer_ratings WHERE farmer_id = u.user_id), 0) AS rating,
                    (SELECT COUNT(*) FROM crops WHERE farmer_id = u.user_id AND status='available') AS active_crops
             FROM favorites f
             JOIN users u ON f.farmer_id = u.user_id
             LEFT JOIN districts d ON u.district_id = d.district_id
             WHERE f.user_id = ? AND f.favorite_type = 'farmer'
             ORDER BY f.created_at DESC",
            [$userId]
        );
    }
}
