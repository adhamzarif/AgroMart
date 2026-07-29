<?php
/**
 * AgentModel — agent-specific operations: assigned farmers, on-behalf registration,
 * activity logging, commission tracking.
 */
class AgentModel extends Model {

    /** Get agent record by user_id. */
    public function findByUserId($userId) {
        return $this->fetchOne("SELECT * FROM agents WHERE user_id = ?", [$userId]);
    }

    /** Get agent record by agent_id with user details. */
    public function find($agentId) {
        return $this->fetchOne(
            "SELECT a.*, u.full_name, u.phone, u.email, u.profile_picture
             FROM agents a JOIN users u ON a.user_id = u.user_id
             WHERE a.agent_id = ?",
            [$agentId]
        );
    }

    /** List farmers assigned to this agent. */
    public function assignedFarmers($agentId, $status = 'active') {
        $sql = "SELECT u.user_id, u.full_name, u.phone, u.email, u.profile_picture,
                       u.created_at AS user_since, d.district_name,
                       afm.assigned_date, afm.help_count, afm.last_interaction, afm.status,
                       (SELECT COUNT(*) FROM crops WHERE farmer_id = u.user_id) AS crops_count,
                       (SELECT COUNT(*) FROM orders WHERE farmer_id = u.user_id AND order_status='delivered') AS completed_orders
                FROM agent_farmer_mapping afm
                JOIN users u ON afm.farmer_id = u.user_id
                LEFT JOIN districts d ON u.district_id = d.district_id
                WHERE afm.agent_id = ?";
        $params = [$agentId];
        if ($status) { $sql .= " AND afm.status = ?"; $params[] = $status; }
        $sql .= " ORDER BY afm.assigned_date DESC";
        return $this->fetchAll($sql, $params);
    }

    /** Register a farmer on behalf of agent. Returns ['ok','user_id','error']. */
    public function registerFarmer($agentId, array $data) {
        $this->db->beginTransaction();
        try {
            // Check uniqueness
            $exists = $this->fetchScalar("SELECT 1 FROM users WHERE phone = ? OR (email IS NOT NULL AND email = ?)",
                [$data['phone'], $data['email'] ?? null]);
            if ($exists) throw new RuntimeException('এই ফোন/ইমেলে ইতোমধ্যে একজন ব্যবহারকারী আছেন।');

            // Insert user with a default password hash (farmer will be told the password)
            $defaultPass = $data['password'] ?? 'farmer' . substr(preg_replace('/\D/', '', $data['phone']), -4);
            $hash = password_hash($defaultPass, PASSWORD_BCRYPT);

            $stmt = $this->db->prepare(
                "INSERT INTO users (phone, email, password_hash, full_name, district_id, address, language, status, phone_verified)
                 VALUES (?,?,?,?,?,?,'bn','active',1)"
            );
            $stmt->execute([
                $data['phone'], $data['email'] ?? null, $hash, $data['full_name'],
                !empty($data['district_id']) ? (int)$data['district_id'] : null,
                $data['address'] ?? null,
            ]);
            $userId = (int)$this->db->lastInsertId();

            // Assign farmer role
            $this->db->prepare("INSERT INTO user_roles (user_id, role) VALUES (?, 'farmer')")->execute([$userId]);

            // Map to this agent
            $this->db->prepare(
                "INSERT INTO agent_farmer_mapping (agent_id, farmer_id, status, help_count)
                 VALUES (?, ?, 'active', 1)"
            )->execute([$agentId, $userId]);

            // Log activity (commission = 50 Tk for new registration)
            $commission = 50.00;
            $this->db->prepare(
                "INSERT INTO agent_activities (agent_id, farmer_id, activity_type, description, commission_earned)
                 VALUES (?, ?, 'farmer_registration', ?, ?)"
            )->execute([$agentId, $userId, 'কৃষক রেজিস্ট্রেশন: ' . $data['full_name'], $commission]);

            // Update agent stats
            $this->db->prepare(
                "UPDATE agents SET total_farmers_assigned = total_farmers_assigned + 1,
                                   total_commission_earned = total_commission_earned + ?
                 WHERE agent_id = ?"
            )->execute([$commission, $agentId]);

            $this->db->commit();
            return ['ok' => true, 'user_id' => $userId, 'password' => $defaultPass, 'error' => null];
        } catch (Throwable $e) {
            $this->db->rollBack();
            return ['ok' => false, 'user_id' => null, 'password' => null, 'error' => $e->getMessage()];
        }
    }

    /** Record an agent activity (and commission). */
    public function logActivity($agentId, $farmerId, $activityType, $description, $commission = 0) {
        $this->execute(
            "INSERT INTO agent_activities (agent_id, farmer_id, activity_type, description, commission_earned)
             VALUES (?,?,?,?,?)",
            [$agentId, $farmerId, $activityType, $description, $commission]
        );
        if ($commission > 0) {
            $this->execute(
                "UPDATE agents SET total_commission_earned = total_commission_earned + ? WHERE agent_id = ?",
                [$commission, $agentId]
            );
        }
        if ($farmerId) {
            $this->execute(
                "UPDATE agent_farmer_mapping SET help_count = help_count + 1, last_interaction = NOW()
                 WHERE agent_id = ? AND farmer_id = ?",
                [$agentId, $farmerId]
            );
        }
        return $this->lastInsertId();
    }

    /** Get activity history for an agent. */
    public function activities($agentId, $limit = 100, $filter = null) {
        $sql = "SELECT aa.*, u.full_name AS farmer_name
                FROM agent_activities aa
                LEFT JOIN users u ON aa.farmer_id = u.user_id
                WHERE aa.agent_id = ?";
        $params = [$agentId];
        if ($filter) { $sql .= " AND aa.activity_type = ?"; $params[] = $filter; }
        $sql .= " ORDER BY aa.activity_date DESC LIMIT $limit";
        return $this->fetchAll($sql, $params);
    }

    /** Get commission totals (paid + pending). */
    public function commissionSummary($agentId) {
        return $this->fetchOne(
            "SELECT
                a.total_commission_earned AS total,
                a.commission_rate,
                (SELECT IFNULL(SUM(commission_earned),0) FROM agent_activities
                 WHERE agent_id = ? AND DATE(activity_date) = CURDATE()) AS today,
                (SELECT IFNULL(SUM(commission_earned),0) FROM agent_activities
                 WHERE agent_id = ? AND YEAR(activity_date)=YEAR(NOW()) AND MONTH(activity_date)=MONTH(NOW())) AS this_month,
                (SELECT COUNT(*) FROM agent_activities WHERE agent_id = ?) AS activity_count
             FROM agents a WHERE a.agent_id = ?",
            [$agentId, $agentId, $agentId, $agentId]
        );
    }

    /** Is this farmer assigned to this agent? Used for ownership checks. */
    public function isFarmerAssigned($agentId, $farmerId) {
        return (bool)$this->fetchScalar(
            "SELECT 1 FROM agent_farmer_mapping WHERE agent_id = ? AND farmer_id = ? AND status='active'",
            [$agentId, $farmerId]
        );
    }
}
