<?php
/**
 * UserModel — handles registration, authentication, roles, profile.
 */
class UserModel extends Model {

    /** Find a user by user_id with district info. */
    public function find($userId) {
        return $this->fetchOne(
            "SELECT u.*, d.district_name, d.division
             FROM users u
             LEFT JOIN districts d ON u.district_id = d.district_id
             WHERE u.user_id = ?",
            [$userId]
        );
    }

    /** Find by phone or email (used for login). */
    public function findByIdentifier($identifier) {
        return $this->fetchOne(
            "SELECT u.*, d.district_name, d.division
             FROM users u
             LEFT JOIN districts d ON u.district_id = d.district_id
             WHERE u.phone = ? OR u.email = ?
             LIMIT 1",
            [$identifier, $identifier]
        );
    }

    public function findByPhone($phone) {
        return $this->fetchOne("SELECT * FROM users WHERE phone = ? LIMIT 1", [$phone]);
    }

    public function findByEmail($email) {
        return $this->fetchOne("SELECT * FROM users WHERE email = ? LIMIT 1", [$email]);
    }

    /** Get all role names (lowercase) for a user. */
    public function getRoles($userId) {
        $rows = $this->fetchAll("SELECT role FROM user_roles WHERE user_id = ?", [$userId]);
        return array_map(fn($r) => $r['role'], $rows);
    }

    /**
     * Create a new user with the given roles.
     * Returns the new user_id.
     * $data: full_name, phone, email, password, district_id, address, nid_number(optional)
     * $roles: array of lowercase role names ('farmer','buyer','agent','admin')
     */
    public function create(array $data, array $roles) {
        $this->db->beginTransaction();
        try {
            $stmt = $this->db->prepare(
                "INSERT INTO users (full_name, phone, email, password_hash, nid_number, district_id, address, account_status, phone_verified)
                 VALUES (:full_name, :phone, :email, :password_hash, :nid, :district_id, :address, 'active', 0)"
            );
            $stmt->execute([
                ':full_name'     => $data['full_name'],
                ':phone'         => $data['phone'],
                ':email'         => $data['email'] ?: null,
                ':password_hash' => password_hash($data['password'], PASSWORD_DEFAULT),
                ':nid'           => $data['nid_number'] ?? null,
                ':district_id'   => $data['district_id'],
                ':address'       => $data['address'] ?? null,
            ]);
            $userId = (int)$this->db->lastInsertId();

            $roleStmt = $this->db->prepare("INSERT IGNORE INTO user_roles (user_id, role) VALUES (?, ?)");
            foreach ($roles as $r) {
                $roleStmt->execute([$userId, strtolower($r)]);
            }

            // If registering as agent, create an agent record
            if (in_array('agent', array_map('strtolower', $roles), true)) {
                $code = $this->generateAgentCode($data['district_id']);
                $this->db->prepare(
                    "INSERT INTO agents (user_id, agent_code, service_districts, vehicle_type, training_completed)
                     VALUES (?, ?, JSON_ARRAY(?), 'none', 0)"
                )->execute([$userId, $code, $data['district_id']]);
            }

            $this->db->commit();
            return $userId;
        } catch (Throwable $e) {
            $this->db->rollBack();
            throw $e;
        }
    }

    /** Verify password and return user row, or null on failure. */
    public function authenticate($identifier, $password) {
        $user = $this->findByIdentifier($identifier);
        if (!$user) return null;
        if ($user['account_status'] === 'banned' || $user['account_status'] === 'suspended') {
            return ['__blocked' => $user['account_status']];
        }
        if (!password_verify($password, $user['password_hash'])) return null;
        // Update last_login
        $this->execute("UPDATE users SET last_login = NOW() WHERE user_id = ?", [$user['user_id']]);
        return $user;
    }

    /** Update profile (name, email, address, district, picture). */
    public function updateProfile($userId, array $fields) {
        $allowed = ['full_name','email','address','district_id','profile_picture'];
        $sets = []; $params = [];
        foreach ($allowed as $k) {
            if (array_key_exists($k, $fields)) {
                $sets[] = "$k = ?";
                $params[] = $fields[$k];
            }
        }
        if (empty($sets)) return 0;
        $params[] = $userId;
        return $this->execute("UPDATE users SET " . implode(', ', $sets) . " WHERE user_id = ?", $params);
    }

    public function changePassword($userId, $newPassword) {
        return $this->execute("UPDATE users SET password_hash = ? WHERE user_id = ?",
            [password_hash($newPassword, PASSWORD_DEFAULT), $userId]);
    }

    public function setStatus($userId, $status) {
        return $this->execute("UPDATE users SET account_status = ? WHERE user_id = ?", [$status, $userId]);
    }

    public function setVerified($userId, $field, $value = true) {
        $allowed = ['phone_verified','email_verified','nid_verified'];
        if (!in_array($field, $allowed, true)) return 0;
        return $this->execute("UPDATE users SET $field = ? WHERE user_id = ?", [$value ? 1 : 0, $userId]);
    }

    /** Get all users with primary role + district (admin listing). */
    public function listAll($filters = []) {
        $where = []; $params = [];
        if (!empty($filters['role'])) {
            $where[] = "EXISTS (SELECT 1 FROM user_roles ur WHERE ur.user_id = u.user_id AND ur.role = ?)";
            $params[] = $filters['role'];
        }
        if (!empty($filters['status'])) {
            $where[] = "u.account_status = ?";
            $params[] = $filters['status'];
        }
        if (!empty($filters['search'])) {
            $where[] = "(u.full_name LIKE ? OR u.phone LIKE ? OR u.email LIKE ?)";
            $like = '%' . $filters['search'] . '%';
            array_push($params, $like, $like, $like);
        }
        $sql = "SELECT u.*, d.district_name,
                       (SELECT GROUP_CONCAT(role) FROM user_roles WHERE user_id = u.user_id) AS roles
                FROM users u
                LEFT JOIN districts d ON u.district_id = d.district_id";
        if ($where) $sql .= " WHERE " . implode(' AND ', $where);
        $sql .= " ORDER BY u.created_at DESC LIMIT 200";
        return $this->fetchAll($sql, $params);
    }

    /** Get counts of users grouped by role. */
    public function countsByRole() {
        return $this->fetchAll(
            "SELECT role, COUNT(*) AS cnt FROM user_roles GROUP BY role"
        );
    }

    public function countAll() {
        return (int)$this->fetchScalar("SELECT COUNT(*) FROM users");
    }

    /** Generate a unique agent code: AGT-<DistrictPrefix>-<3 digits>. */
    private function generateAgentCode($districtId) {
        $district = $this->fetchOne("SELECT district_name FROM districts WHERE district_id = ?", [$districtId]);
        $prefix = strtoupper(substr(preg_replace('/[^A-Za-z]/', '', $district['district_name'] ?? 'GEN'), 0, 3));
        if (strlen($prefix) < 3) $prefix = str_pad($prefix, 3, 'X');
        for ($i = 0; $i < 50; $i++) {
            $code = sprintf('AGT-%s-%03d', $prefix, random_int(1, 999));
            $exists = $this->fetchScalar("SELECT 1 FROM agents WHERE agent_code = ?", [$code]);
            if (!$exists) return $code;
        }
        return sprintf('AGT-%s-%03d', $prefix, random_int(100, 999));
    }
}
