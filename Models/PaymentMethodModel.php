<?php
class PaymentMethodModel extends Model {

    public function listForUser($userId) {
        return $this->fetchAll(
            "SELECT * FROM payment_methods WHERE user_id = ? ORDER BY is_default DESC, created_at DESC",
            [$userId]
        );
    }

    public function find($methodId, $userId) {
        return $this->fetchOne(
            "SELECT * FROM payment_methods WHERE method_id = ? AND user_id = ?",
            [$methodId, $userId]
        );
    }

    public function add(array $data) {
        if (!empty($data['is_default'])) {
            $this->execute("UPDATE payment_methods SET is_default = 0 WHERE user_id = ?", [$data['user_id']]);
        }
        $this->execute(
            "INSERT INTO payment_methods (user_id, method_type, account_number, account_name, bank_name, is_default)
             VALUES (?,?,?,?,?,?)",
            [
                $data['user_id'], $data['method_type'], $data['account_number'],
                $data['account_name'] ?? null, $data['bank_name'] ?? null,
                !empty($data['is_default']) ? 1 : 0,
            ]
        );
        return $this->lastInsertId();
    }

    public function setDefault($methodId, $userId) {
        $this->execute("UPDATE payment_methods SET is_default = 0 WHERE user_id = ?", [$userId]);
        return $this->execute(
            "UPDATE payment_methods SET is_default = 1 WHERE method_id = ? AND user_id = ?",
            [$methodId, $userId]
        );
    }

    public function delete($methodId, $userId) {
        return $this->execute(
            "DELETE FROM payment_methods WHERE method_id = ? AND user_id = ?",
            [$methodId, $userId]
        );
    }
}
