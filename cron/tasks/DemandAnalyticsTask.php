<?php
/**
 * DemandAnalyticsTask — nightly aggregation of supply/demand signals into
 * the demand_analytics table. Drives the admin "market intelligence" view
 * and informs crop_recommendations.
 *
 * For each (crop_name, district) pair seen in either recent supply or recent
 * search/order activity (last 7 days), computes:
 *   - total_supply_kg     — sum of available crops × quantity
 *   - total_demand_orders — count of orders placed (last 7d)
 *   - search_count        — count of search_logs entries (last 7d)
 *   - demand_supply_ratio — relative demand pressure
 *   - market_status       — surplus / balanced / shortage
 *
 * Schedule: daily (one row per crop×district×day, idempotent UPSERT)
 */
class DemandAnalyticsTask extends CronTask {

    public $name = 'demand_analytics';
    public $schedule = 'daily';

    public function run() {
        $pdo = $this->pdo();
        $today = date('Y-m-d');
        $weekAgo = date('Y-m-d', strtotime('-7 days'));

        // ── 1. Active supply per (crop_name, district) ──────────────
        $supply = $pdo->prepare(
            "SELECT c.crop_name, u.district_id, SUM(c.quantity) AS total_supply,
                    COUNT(DISTINCT c.farmer_id) AS supplier_count
             FROM crops c
             JOIN users u ON c.farmer_id = u.user_id
             WHERE c.status = 'available'
               AND u.district_id IS NOT NULL
             GROUP BY c.crop_name, u.district_id"
        );
        $supply->execute();
        $supplyRows = $supply->fetchAll();

        // ── 2. Recent demand: orders in the last 7 days ──────────────
        $demand = $pdo->prepare(
            "SELECT c.crop_name, u.district_id, COUNT(o.order_id) AS order_count,
                    SUM(o.quantity_ordered) AS demand_qty
             FROM orders o
             JOIN crops c ON o.crop_id = c.crop_id
             JOIN users u ON c.farmer_id = u.user_id
             WHERE o.order_date >= ?
               AND o.order_status NOT IN ('cancelled')
               AND u.district_id IS NOT NULL
             GROUP BY c.crop_name, u.district_id"
        );
        $demand->execute([$weekAgo]);
        $demandRows = $demand->fetchAll();

        // ── 3. Recent search interest ────────────────────────────────
        // Search logs aren't tied to a specific district directly; we infer it
        // from the buyer's district if available
        $search = $pdo->prepare(
            "SELECT sl.search_query AS crop_name, u.district_id, COUNT(*) AS search_count
             FROM search_logs sl
             LEFT JOIN users u ON sl.user_id = u.user_id
             WHERE sl.search_timestamp >= ?
               AND u.district_id IS NOT NULL
               AND sl.search_query NOT LIKE '%(filter only)%'
               AND CHAR_LENGTH(sl.search_query) BETWEEN 2 AND 60
             GROUP BY sl.search_query, u.district_id"
        );
        $search->execute([$weekAgo]);
        $searchRows = $search->fetchAll();

        // ── 4. Merge by (crop, district) key ──────────────────────────
        $byKey = [];
        foreach ($supplyRows as $r) {
            $key = $r['crop_name'] . '|' . $r['district_id'];
            $byKey[$key] = [
                'crop_name' => $r['crop_name'],
                'district_id' => (int)$r['district_id'],
                'supply' => (float)$r['total_supply'],
                'suppliers' => (int)$r['supplier_count'],
                'orders' => 0,
                'demand_qty' => 0,
                'searches' => 0,
            ];
        }
        foreach ($demandRows as $r) {
            $key = $r['crop_name'] . '|' . $r['district_id'];
            if (!isset($byKey[$key])) {
                $byKey[$key] = ['crop_name' => $r['crop_name'], 'district_id' => (int)$r['district_id'],
                                'supply' => 0, 'suppliers' => 0, 'orders' => 0, 'demand_qty' => 0, 'searches' => 0];
            }
            $byKey[$key]['orders'] = (int)$r['order_count'];
            $byKey[$key]['demand_qty'] = (float)$r['demand_qty'];
        }
        foreach ($searchRows as $r) {
            // Search query may not be an exact crop name, so we match loosely:
            // any (crop_name, district) where search_query is substring of crop_name (case-insensitive)
            foreach ($byKey as &$entry) {
                if ((int)$entry['district_id'] !== (int)$r['district_id']) continue;
                if (mb_stripos($entry['crop_name'], $r['crop_name'], 0, 'UTF-8') !== false ||
                    mb_stripos($r['crop_name'], $entry['crop_name'], 0, 'UTF-8') !== false) {
                    $entry['searches'] += (int)$r['search_count'];
                    break;
                }
            }
            unset($entry);
        }

        // ── 5. Compute ratio + market_status, then UPSERT ────────────
        $upserted = 0;
        $stmt = $pdo->prepare(
            "INSERT INTO demand_analytics
                (crop_name, district_id, analysis_date, total_supply_kg, total_demand_orders, demand_supply_ratio, market_status)
             VALUES (?,?,?,?,?,?,?)
             ON DUPLICATE KEY UPDATE
                total_supply_kg = VALUES(total_supply_kg),
                total_demand_orders = VALUES(total_demand_orders),
                demand_supply_ratio = VALUES(demand_supply_ratio),
                market_status = VALUES(market_status)"
        );

        foreach ($byKey as $entry) {
            $supply = max(0.001, $entry['supply']); // avoid div-by-zero
            // Demand pressure score: orders heavily weighted, searches lightly
            $demandScore = $entry['orders'] * 10 + $entry['searches'] * 1;
            $ratio = round($demandScore / $supply, 4);

            // Classify
            $status = 'balanced';
            if ($ratio > 0.5) $status = 'shortage';
            elseif ($ratio < 0.05) $status = 'surplus';

            $stmt->execute([
                $entry['crop_name'],
                $entry['district_id'],
                $today,
                $entry['supply'],
                $entry['orders'],
                $ratio,
                $status,
            ]);
            $upserted++;
        }

        // ── 6. Cleanup old analytics (> 90 days) ─────────────────────
        $cleanup = $pdo->prepare("DELETE FROM demand_analytics WHERE analysis_date < DATE_SUB(CURDATE(), INTERVAL 90 DAY)");
        $cleanup->execute();
        $purged = $cleanup->rowCount();

        return [
            'ok' => true,
            'message' => sprintf('Aggregated %d crop×district pairs (purged %d old rows)', $upserted, $purged),
            'affected' => $upserted,
        ];
    }
}
