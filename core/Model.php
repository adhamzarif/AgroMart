<?php
/**
 * Base Model — concrete models extend this to access the PDO connection.
 * Provides thin query helpers but encourages prepared statements.
 */
class Model {
    /** @var PDO */
    protected $db;

    public function __construct() {
        $this->db = Database::getInstance()->getConnection();
    }

    /** Get raw PDO. */
    public function pdo() {
        return $this->db;
    }

    /** Fetch first row (assoc) or null. */
    protected function fetchOne($sql, $params = []) {
        $stmt = $this->db->prepare($sql);
        $stmt->execute($params);
        $row = $stmt->fetch();
        return $row === false ? null : $row;
    }

    /** Fetch all rows. */
    protected function fetchAll($sql, $params = []) {
        $stmt = $this->db->prepare($sql);
        $stmt->execute($params);
        return $stmt->fetchAll();
    }

    /** Fetch a single scalar column from first row, or null. */
    protected function fetchScalar($sql, $params = []) {
        $stmt = $this->db->prepare($sql);
        $stmt->execute($params);
        $val = $stmt->fetchColumn();
        return $val === false ? null : $val;
    }

    /** Execute and return rowCount(). */
    protected function execute($sql, $params = []) {
        $stmt = $this->db->prepare($sql);
        $stmt->execute($params);
        return $stmt->rowCount();
    }

    /** Last inserted id. */
    protected function lastInsertId() {
        return (int)$this->db->lastInsertId();
    }
}
