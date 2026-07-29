<?php
/**
 * ExpenseModel — farmer expense tracking + profit/loss reports.
 */
class ExpenseModel extends Model {

    public function find($expenseId, $farmerId) {
        return $this->fetchOne(
            "SELECT e.*, c.crop_name FROM expenses e LEFT JOIN crops c ON e.crop_id = c.crop_id
             WHERE e.expense_id = ? AND e.farmer_id = ?",
            [$expenseId, $farmerId]
        );
    }

    public function listByFarmer($farmerId, $filters = []) {
        $sql = "SELECT e.*, c.crop_name FROM expenses e
                LEFT JOIN crops c ON e.crop_id = c.crop_id
                WHERE e.farmer_id = ?";
        $params = [$farmerId];
        if (!empty($filters['category'])) {
            $sql .= " AND e.expense_category = ?";
            $params[] = $filters['category'];
        }
        if (!empty($filters['date_from'])) {
            $sql .= " AND e.expense_date >= ?";
            $params[] = $filters['date_from'];
        }
        if (!empty($filters['date_to'])) {
            $sql .= " AND e.expense_date <= ?";
            $params[] = $filters['date_to'];
        }
        if (!empty($filters['crop_id'])) {
            $sql .= " AND e.crop_id = ?";
            $params[] = (int)$filters['crop_id'];
        }
        $sql .= " ORDER BY e.expense_date DESC LIMIT 200";
        return $this->fetchAll($sql, $params);
    }

    public function create(array $data) {
        $this->execute(
            "INSERT INTO expenses (farmer_id, crop_id, expense_category, expense_amount, expense_description, expense_date, receipt_url)
             VALUES (?,?,?,?,?,?,?)",
            [
                $data['farmer_id'],
                !empty($data['crop_id']) ? (int)$data['crop_id'] : null,
                $data['expense_category'],
                $data['expense_amount'],
                $data['expense_description'] ?? null,
                $data['expense_date'],
                $data['receipt_url'] ?? null,
            ]
        );
        return $this->lastInsertId();
    }

    public function update($expenseId, $farmerId, array $data) {
        return $this->execute(
            "UPDATE expenses SET crop_id = ?, expense_category = ?, expense_amount = ?,
                                 expense_description = ?, expense_date = ?, receipt_url = COALESCE(?, receipt_url)
             WHERE expense_id = ? AND farmer_id = ?",
            [
                !empty($data['crop_id']) ? (int)$data['crop_id'] : null,
                $data['expense_category'],
                $data['expense_amount'],
                $data['expense_description'] ?? null,
                $data['expense_date'],
                $data['receipt_url'] ?? null,
                $expenseId, $farmerId,
            ]
        );
    }

    public function delete($expenseId, $farmerId) {
        return $this->execute(
            "DELETE FROM expenses WHERE expense_id = ? AND farmer_id = ?",
            [$expenseId, $farmerId]
        );
    }

    /** Sum expenses for a farmer, optionally filtered by date range. */
    public function totalForFarmer($farmerId, $from = null, $to = null) {
        $sql = "SELECT IFNULL(SUM(expense_amount),0) FROM expenses WHERE farmer_id = ?";
        $params = [$farmerId];
        if ($from) { $sql .= " AND expense_date >= ?"; $params[] = $from; }
        if ($to)   { $sql .= " AND expense_date <= ?"; $params[] = $to; }
        return (float)$this->fetchScalar($sql, $params);
    }

    /** Category-wise breakdown. */
    public function byCategory($farmerId, $from = null, $to = null) {
        $sql = "SELECT expense_category, SUM(expense_amount) AS total, COUNT(*) AS cnt
                FROM expenses WHERE farmer_id = ?";
        $params = [$farmerId];
        if ($from) { $sql .= " AND expense_date >= ?"; $params[] = $from; }
        if ($to)   { $sql .= " AND expense_date <= ?"; $params[] = $to; }
        $sql .= " GROUP BY expense_category ORDER BY total DESC";
        return $this->fetchAll($sql, $params);
    }

    /** Complete profit/loss for a date range. */
    public function profitLoss($farmerId, $from = null, $to = null) {
        $rev = $this->fetchOne(
            "SELECT IFNULL(SUM(total_amount),0) AS revenue, COUNT(*) AS orders_completed
             FROM orders WHERE farmer_id = ? AND order_status='delivered'"
            . ($from ? " AND delivered_at >= ?" : "")
            . ($to   ? " AND delivered_at <= ?" : ""),
            array_filter([$farmerId, $from, $to])
        );
        $exp = $this->totalForFarmer($farmerId, $from, $to);
        $revenue = (float)$rev['revenue'];
        $profit = $revenue - $exp;
        return [
            'revenue'  => $revenue,
            'expenses' => $exp,
            'profit'   => $profit,
            'margin'   => $revenue > 0 ? round(($profit / $revenue) * 100, 2) : 0,
            'orders_completed' => (int)$rev['orders_completed'],
        ];
    }
}
