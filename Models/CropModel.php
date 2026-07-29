<?php
/**
 * CropModel — manage crop listings (CRUD), search, filters.
 */
class CropModel extends Model {

    /** Find a crop with farmer + category info. */
    public function find($cropId) {
        return $this->fetchOne(
            "SELECT c.*, u.full_name AS farmer_name, u.phone AS farmer_phone, u.profile_picture AS farmer_picture,
                    d.district_name, d.division, cat.category_name_bn, cat.category_name,
                    IFNULL((SELECT AVG(overall_rating) FROM farmer_ratings WHERE farmer_id = c.farmer_id), 0) AS farmer_rating,
                    (SELECT COUNT(*) FROM farmer_ratings WHERE farmer_id = c.farmer_id) AS farmer_rating_count
             FROM crops c
             JOIN users u ON c.farmer_id = u.user_id
             LEFT JOIN districts d ON u.district_id = d.district_id
             JOIN crop_categories cat ON c.category_id = cat.category_id
             WHERE c.crop_id = ?",
            [$cropId]
        );
    }

    /** List crops belonging to a farmer. */
    public function listByFarmer($farmerId, $status = null) {
        $sql = "SELECT c.*, cat.category_name_bn
                FROM crops c JOIN crop_categories cat ON c.category_id = cat.category_id
                WHERE c.farmer_id = ?";
        $params = [$farmerId];
        if ($status) { $sql .= " AND c.status = ?"; $params[] = $status; }
        $sql .= " ORDER BY c.created_at DESC";
        return $this->fetchAll($sql, $params);
    }

    /** Marketplace search with filters. */
    public function search($filters = [], $limit = 24, $offset = 0) {
        // Marketplace shows ONLY crops from real, currently-active farmers.
        // The two extra conditions guarantee that seed/orphan crops never
        // appear, and that suspended/role-revoked farmers' crops disappear
        // instantly without manual cleanup.
        $where = [
            "c.status = 'available'",
            "c.quantity > 0",
            "u.account_status = 'active'",
            "EXISTS (SELECT 1 FROM user_roles ur WHERE ur.user_id = u.user_id AND ur.role = 'farmer')",
        ];
        $params = [];

        if (!empty($filters['q'])) {
            $where[] = "(c.crop_name LIKE ? OR c.crop_variety LIKE ? OR c.description LIKE ?)";
            $like = '%' . $filters['q'] . '%';
            array_push($params, $like, $like, $like);
        }
        if (!empty($filters['category_id'])) {
            $where[] = "c.category_id = ?";
            $params[] = (int)$filters['category_id'];
        }
        if (!empty($filters['district_id'])) {
            $where[] = "u.district_id = ?";
            $params[] = (int)$filters['district_id'];
        }
        if (!empty($filters['min_price'])) {
            $where[] = "c.price_per_unit >= ?";
            $params[] = (float)$filters['min_price'];
        }
        if (!empty($filters['max_price'])) {
            $where[] = "c.price_per_unit <= ?";
            $params[] = (float)$filters['max_price'];
        }
        if (!empty($filters['quality'])) {
            $where[] = "c.quality_grade = ?";
            $params[] = $filters['quality'];
        }
        if (!empty($filters['organic'])) {
            $where[] = "c.is_organic = 1";
        }

        $sort = $filters['sort'] ?? 'newest';
        $orderBy = match($sort) {
            'price_low'  => "c.price_per_unit ASC",
            'price_high' => "c.price_per_unit DESC",
            'popular'    => "c.views_count DESC, c.created_at DESC",
            default      => "c.created_at DESC",
        };

        $sql = "SELECT c.*, u.full_name AS farmer_name, u.profile_picture AS farmer_picture,
                       u.phone AS farmer_phone,
                       d.district_name, cat.category_name_bn,
                       IFNULL((SELECT AVG(overall_rating) FROM farmer_ratings WHERE farmer_id = c.farmer_id), 0) AS farmer_rating,
                       IFNULL((SELECT COUNT(*) FROM farmer_ratings WHERE farmer_id = c.farmer_id), 0) AS farmer_rating_count
                FROM crops c
                JOIN users u ON c.farmer_id = u.user_id
                LEFT JOIN districts d ON u.district_id = d.district_id
                JOIN crop_categories cat ON c.category_id = cat.category_id
                WHERE " . implode(' AND ', $where) . "
                ORDER BY $orderBy
                LIMIT $limit OFFSET $offset";
        return $this->fetchAll($sql, $params);
    }

    public function searchCount($filters = []) {
        // Match the same conditions as search() to keep pagination counts honest.
        $where = [
            "c.status = 'available'",
            "c.quantity > 0",
            "u.account_status = 'active'",
            "EXISTS (SELECT 1 FROM user_roles ur WHERE ur.user_id = u.user_id AND ur.role = 'farmer')",
        ];
        $params = [];

        if (!empty($filters['q'])) {
            $where[] = "(c.crop_name LIKE ? OR c.crop_variety LIKE ? OR c.description LIKE ?)";
            $like = '%' . $filters['q'] . '%';
            array_push($params, $like, $like, $like);
        }
        if (!empty($filters['category_id'])) { $where[] = "c.category_id = ?"; $params[] = (int)$filters['category_id']; }
        if (!empty($filters['district_id'])) { $where[] = "u.district_id = ?"; $params[] = (int)$filters['district_id']; }
        if (!empty($filters['min_price']))   { $where[] = "c.price_per_unit >= ?"; $params[] = (float)$filters['min_price']; }
        if (!empty($filters['max_price']))   { $where[] = "c.price_per_unit <= ?"; $params[] = (float)$filters['max_price']; }
        if (!empty($filters['quality']))     { $where[] = "c.quality_grade = ?"; $params[] = $filters['quality']; }
        if (!empty($filters['organic']))     { $where[] = "c.is_organic = 1"; }

        return (int)$this->fetchScalar(
            "SELECT COUNT(*) FROM crops c JOIN users u ON c.farmer_id = u.user_id
             WHERE " . implode(' AND ', $where),
            $params
        );
    }

    public function create(array $data) {
        $sql = "INSERT INTO crops
                  (farmer_id, category_id, crop_name, crop_variety, quantity, unit, price_per_unit,
                   quality_grade, is_organic, harvest_date, available_from, available_until,
                   description, images, status)
                VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,'available')";
        $this->execute($sql, [
            $data['farmer_id'], $data['category_id'], $data['crop_name'], $data['crop_variety'] ?? null,
            $data['quantity'], $data['unit'], $data['price_per_unit'],
            $data['quality_grade'] ?? 'B', !empty($data['is_organic']) ? 1 : 0,
            $data['harvest_date'] ?? null, $data['available_from'], $data['available_until'] ?? null,
            $data['description'] ?? null, json_encode($data['images'] ?? [], JSON_UNESCAPED_UNICODE),
        ]);
        $cropId = $this->lastInsertId();
        // Log creation
        $this->execute(
            "INSERT INTO inventory_logs(crop_id, change_type, quantity_before, quantity_after, change_reason, changed_by)
             VALUES (?, 'listed', 0, ?, 'নতুন ফসল লিস্ট', ?)",
            [$cropId, $data['quantity'], $data['farmer_id']]
        );
        // Push to search index (no-op if Meili not configured)
        $this->indexInSearch($cropId);
        return $cropId;
    }

    public function update($cropId, $farmerId, array $data) {
        // Verify ownership
        $owner = $this->fetchScalar("SELECT farmer_id FROM crops WHERE crop_id = ?", [$cropId]);
        if ((int)$owner !== (int)$farmerId) return false;

        $old = $this->fetchOne("SELECT quantity FROM crops WHERE crop_id = ?", [$cropId]);
        $sql = "UPDATE crops SET
                  category_id = ?, crop_name = ?, crop_variety = ?, quantity = ?, unit = ?, price_per_unit = ?,
                  quality_grade = ?, is_organic = ?, harvest_date = ?, available_from = ?, available_until = ?,
                  description = ?, images = ?
                WHERE crop_id = ? AND farmer_id = ?";
        $this->execute($sql, [
            $data['category_id'], $data['crop_name'], $data['crop_variety'] ?? null,
            $data['quantity'], $data['unit'], $data['price_per_unit'],
            $data['quality_grade'] ?? 'B', !empty($data['is_organic']) ? 1 : 0,
            $data['harvest_date'] ?? null, $data['available_from'], $data['available_until'] ?? null,
            $data['description'] ?? null, json_encode($data['images'] ?? [], JSON_UNESCAPED_UNICODE),
            $cropId, $farmerId,
        ]);
        if ((float)$old['quantity'] !== (float)$data['quantity']) {
            $this->execute(
                "INSERT INTO inventory_logs(crop_id, change_type, quantity_before, quantity_after, change_reason, changed_by)
                 VALUES (?, 'adjusted', ?, ?, 'কৃষক কর্তৃক সংশোধন', ?)",
                [$cropId, $old['quantity'], $data['quantity'], $farmerId]
            );
        }
        // Refresh search index
        $this->indexInSearch($cropId);
        return true;
    }

    public function delete($cropId, $farmerId) {
        $result = $this->execute(
            "UPDATE crops SET status='removed' WHERE crop_id = ? AND farmer_id = ?",
            [$cropId, $farmerId]
        );
        // Remove from search index
        if ($result) SearchProvider::deindexCrop($cropId);
        return $result;
    }

    /** Push (or refresh) a single crop to the search index. Non-fatal on failure. */
    private function indexInSearch($cropId) {
        try {
            $crop = $this->fetchOne(
                "SELECT c.*, u.full_name AS farmer_name, u.district_id, d.district_name, cat.category_name_bn
                 FROM crops c
                 JOIN users u ON c.farmer_id = u.user_id
                 LEFT JOIN districts d ON u.district_id = d.district_id
                 LEFT JOIN crop_categories cat ON c.category_id = cat.category_id
                 WHERE c.crop_id = ?",
                [$cropId]
            );
            if ($crop) SearchProvider::indexCrop($crop);
        } catch (Throwable $e) { /* non-fatal */ }
    }

    /** Hydrate a list of crop_ids (preserving order) — used when MeiliSearch returns ranked IDs. */
    public function findByIds(array $ids) {
        if (empty($ids)) return [];
        $clean = array_filter(array_map('intval', $ids));
        if (empty($clean)) return [];
        $placeholders = implode(',', array_fill(0, count($clean), '?'));
        $rows = $this->fetchAll(
            "SELECT c.*, u.full_name AS farmer_name, u.profile_picture AS farmer_picture,
                    d.district_name, cat.category_name_bn,
                    IFNULL((SELECT AVG(overall_rating) FROM farmer_ratings WHERE farmer_id = c.farmer_id), 0) AS farmer_rating
             FROM crops c
             JOIN users u ON c.farmer_id = u.user_id
             LEFT JOIN districts d ON u.district_id = d.district_id
             JOIN crop_categories cat ON c.category_id = cat.category_id
             WHERE c.crop_id IN ($placeholders)
               AND c.status = 'available' AND c.quantity > 0",
            $clean
        );
        // Preserve the order Meili returned
        $byId = [];
        foreach ($rows as $r) $byId[(int)$r['crop_id']] = $r;
        $ordered = [];
        foreach ($clean as $id) {
            if (isset($byId[$id])) $ordered[] = $byId[$id];
        }
        return $ordered;
    }

    public function incrementViews($cropId) {
        $this->execute("UPDATE crops SET views_count = views_count + 1 WHERE crop_id = ?", [$cropId]);
    }

    /** Reduce quantity after an order (called from OrderModel). */
    public function reduceQuantity($cropId, $by, $reason = 'অর্ডার পূরণ', $byUser = null) {
        $row = $this->fetchOne("SELECT quantity FROM crops WHERE crop_id = ? FOR UPDATE", [$cropId]);
        if (!$row) return false;
        $before = (float)$row['quantity'];
        $after  = max(0, $before - (float)$by);
        $this->execute("UPDATE crops SET quantity = ? WHERE crop_id = ?", [$after, $cropId]);
        $this->execute(
            "INSERT INTO inventory_logs(crop_id, change_type, quantity_before, quantity_after, change_reason, changed_by)
             VALUES (?, 'sold', ?, ?, ?, ?)",
            [$cropId, $before, $after, $reason, $byUser]
        );
        if ($after <= 0) {
            $this->execute("UPDATE crops SET status='sold' WHERE crop_id = ?", [$cropId]);
        }
        return true;
    }

    /** Get inventory logs for a farmer. */
    public function inventoryLogs($farmerId, $limit = 100) {
        return $this->fetchAll(
            "SELECT il.*, c.crop_name, u.full_name AS changed_by_name
             FROM inventory_logs il
             JOIN crops c ON il.crop_id = c.crop_id
             LEFT JOIN users u ON il.changed_by = u.user_id
             WHERE c.farmer_id = ?
             ORDER BY il.logged_at DESC LIMIT $limit",
            [$farmerId]
        );
    }

    /** Get crops from farmers connected to the current buyer (those with orders or favorites). */
    public function getConnectedFarmerCrops($buyerId, $limit = 24, $offset = 0) {
        return $this->fetchAll(
            "SELECT DISTINCT c.*, u.full_name AS farmer_name, u.phone AS farmer_phone, u.profile_picture AS farmer_picture,
                    d.district_name, d.division, cat.category_name_bn,
                    IFNULL((SELECT AVG(overall_rating) FROM farmer_ratings WHERE farmer_id = c.farmer_id), 0) AS farmer_rating,
                    (SELECT COUNT(*) FROM farmer_ratings WHERE farmer_id = c.farmer_id) AS farmer_rating_count
             FROM crops c
             JOIN users u ON c.farmer_id = u.user_id
             LEFT JOIN districts d ON u.district_id = d.district_id
             JOIN crop_categories cat ON c.category_id = cat.category_id
             WHERE c.status = 'available' AND c.quantity > 0
             AND (
                -- Farmers with orders from this buyer
                c.farmer_id IN (SELECT DISTINCT farmer_id FROM orders WHERE buyer_id = ? AND order_status != 'cancelled')
                -- OR farmers marked as favorites
                OR c.farmer_id IN (SELECT item_id FROM favorites WHERE user_id = ? AND favorite_type = 'farmer')
             )
             ORDER BY c.created_at DESC
             LIMIT ? OFFSET ?",
            [$buyerId, $buyerId, $limit, $offset]
        );
    }

    /** Count total crops from connected farmers. */
    public function countConnectedFarmerCrops($buyerId) {
        $result = $this->fetchOne(
            "SELECT COUNT(DISTINCT c.crop_id) AS total
             FROM crops c
             JOIN users u ON c.farmer_id = u.user_id
             WHERE c.status = 'available' AND c.quantity > 0
             AND (
                -- Farmers with orders from this buyer
                c.farmer_id IN (SELECT DISTINCT farmer_id FROM orders WHERE buyer_id = ? AND order_status != 'cancelled')
                -- OR farmers marked as favorites
                OR c.farmer_id IN (SELECT item_id FROM favorites WHERE user_id = ? AND favorite_type = 'farmer')
             )",
            [$buyerId, $buyerId]
        );
        return $result['total'] ?? 0;
    }
}
