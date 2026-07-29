<?php
/**
 * PriceModel — market prices (per crop, per district, per date).
 */
class PriceModel extends Model {

    /** Latest prices, optionally filtered by district/crop. Cached 5 min. */
    public function latest($filters = [], $limit = 50) {
        // Cache key includes the filter signature
        $cacheKey = 'prices:latest:' . md5(serialize($filters) . ':' . (int)$limit);
        return Cache::remember($cacheKey, 300, function() use ($filters, $limit) {
            $where = ["1=1"];
            $params = [];
            if (!empty($filters['district_id'])) {
                $where[] = "mp.district_id = ?";
                $params[] = (int)$filters['district_id'];
            }
            if (!empty($filters['crop_name'])) {
                $where[] = "mp.crop_name LIKE ?";
                $params[] = '%' . $filters['crop_name'] . '%';
            }

            $sql = "SELECT mp.*, d.district_name, u.full_name AS updated_by_name
                    FROM market_prices mp
                    JOIN districts d ON mp.district_id = d.district_id
                    LEFT JOIN users u ON mp.updated_by = u.user_id
                    WHERE " . implode(' AND ', $where) . "
                    ORDER BY mp.price_date DESC, mp.crop_name LIMIT $limit";
            return $this->fetchAll($sql, $params);
        });
    }

    /** Invalidate price caches (called after upsert/delete). */
    private function bustCache() {
        Cache::forgetPrefix('prices:');
    }

    public function find($priceId) {
        return $this->fetchOne(
            "SELECT mp.*, d.district_name FROM market_prices mp
             JOIN districts d ON mp.district_id = d.district_id
             WHERE mp.price_id = ?",
            [$priceId]
        );
    }

    /** Insert or update price for (crop, district, date). */
    public function upsert(array $data) {
        $existing = $this->fetchOne(
            "SELECT price_id, wholesale_price, retail_price FROM market_prices
             WHERE crop_name = ? AND district_id = ? AND price_date = ?",
            [$data['crop_name'], $data['district_id'], $data['price_date']]
        );

        if ($existing) {
            // Archive the OLD value into price_history before overwriting.
            // price_history schema stores a snapshot of how the price was —
            // not a diff — so we just record the existing values, then update.
            $this->execute(
                "INSERT INTO price_history (crop_name, district_id, wholesale_price, retail_price, unit, price_date)
                 VALUES (?,?,?,?,?,?)",
                [
                    $data['crop_name'], $data['district_id'],
                    $existing['wholesale_price'], $existing['retail_price'],
                    $data['unit'] ?? 'kg', $data['price_date'],
                ]
            );
            $this->execute(
                "UPDATE market_prices SET wholesale_price = ?, retail_price = ?, unit = ?, source = ?, updated_by = ?
                 WHERE price_id = ?",
                [
                    $data['wholesale_price'], $data['retail_price'],
                    $data['unit'] ?? 'kg', $data['source'] ?? 'DAM',
                    $data['updated_by'] ?? null, $existing['price_id'],
                ]
            );
            $this->bustCache();
            return $existing['price_id'];
        } else {
            $this->execute(
                "INSERT INTO market_prices (crop_name, district_id, wholesale_price, retail_price, unit, price_date, source, updated_by)
                 VALUES (?,?,?,?,?,?,?,?)",
                [
                    $data['crop_name'], $data['district_id'],
                    $data['wholesale_price'], $data['retail_price'],
                    $data['unit'] ?? 'kg', $data['price_date'],
                    $data['source'] ?? 'DAM', $data['updated_by'] ?? null,
                ]
            );
            $this->bustCache();
            return $this->lastInsertId();
        }
    }

    public function delete($priceId) {
        $result = $this->execute("DELETE FROM market_prices WHERE price_id = ?", [$priceId]);
        $this->bustCache();
        return $result;
    }
}
