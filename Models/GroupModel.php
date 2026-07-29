<?php
/**
 * GroupModel — farmer groups (collective farming organization).
 */
class GroupModel extends Model {

    /** All groups, optional district filter. */
    public function listAll($districtId = null, $activeOnly = true) {
        $sql = "SELECT g.*, u.full_name AS leader_name, d.district_name
                FROM farmer_groups g
                JOIN users u ON g.group_leader_id = u.user_id
                JOIN districts d ON g.district_id = d.district_id";
        $where = [];
        $params = [];
        if ($activeOnly) { $where[] = "g.is_active = 1"; }
        if ($districtId) { $where[] = "g.district_id = ?"; $params[] = (int)$districtId; }
        if ($where) $sql .= " WHERE " . implode(' AND ', $where);
        $sql .= " ORDER BY g.total_members DESC";
        return $this->fetchAll($sql, $params);
    }

    /** Groups a farmer belongs to. */
    public function listForFarmer($farmerId) {
        return $this->fetchAll(
            "SELECT g.*, gm.member_role, gm.land_contribution_acres, gm.join_date,
                    u.full_name AS leader_name, d.district_name
             FROM group_members gm
             JOIN farmer_groups g ON gm.group_id = g.group_id
             JOIN users u ON g.group_leader_id = u.user_id
             JOIN districts d ON g.district_id = d.district_id
             WHERE gm.farmer_id = ? AND gm.is_active = 1 AND g.is_active = 1
             ORDER BY gm.join_date DESC",
            [$farmerId]
        );
    }

    public function find($groupId) {
        return $this->fetchOne(
            "SELECT g.*, u.full_name AS leader_name, u.phone AS leader_phone, d.district_name
             FROM farmer_groups g
             JOIN users u ON g.group_leader_id = u.user_id
             JOIN districts d ON g.district_id = d.district_id
             WHERE g.group_id = ?",
            [$groupId]
        );
    }

    public function members($groupId) {
        return $this->fetchAll(
            "SELECT gm.*, u.full_name, u.phone, u.profile_picture
             FROM group_members gm
             JOIN users u ON gm.farmer_id = u.user_id
             WHERE gm.group_id = ? AND gm.is_active = 1
             ORDER BY gm.member_role, gm.join_date",
            [$groupId]
        );
    }

    public function isMember($groupId, $farmerId) {
        return (bool)$this->fetchScalar(
            "SELECT 1 FROM group_members WHERE group_id = ? AND farmer_id = ? AND is_active = 1",
            [$groupId, $farmerId]
        );
    }

    public function create(array $data) {
        $this->db->beginTransaction();
        try {
            $groupCode = 'GRP-' . strtoupper(substr(uniqid(), -6));
            $this->db->prepare(
                "INSERT INTO farmer_groups (group_name, group_code, group_leader_id, district_id,
                                            total_members, total_land_acres, group_description, formation_date, is_active)
                 VALUES (?,?,?,?,?,?,?,?,1)"
            )->execute([
                $data['group_name'], $groupCode, $data['leader_id'], $data['district_id'],
                1, $data['land_contribution'] ?? 0,
                $data['description'] ?? null, $data['formation_date'] ?? date('Y-m-d'),
            ]);
            $groupId = (int)$this->db->lastInsertId();

            // Leader joins as 'leader'
            $this->db->prepare(
                "INSERT INTO group_members (group_id, farmer_id, land_contribution_acres, join_date, member_role, is_active)
                 VALUES (?,?,?,?,?,1)"
            )->execute([
                $groupId, $data['leader_id'], $data['land_contribution'] ?? 0,
                $data['formation_date'] ?? date('Y-m-d'), 'leader',
            ]);

            $this->db->commit();
            return ['ok' => true, 'group_id' => $groupId, 'group_code' => $groupCode];
        } catch (Throwable $e) {
            $this->db->rollBack();
            return ['ok' => false, 'error' => $e->getMessage()];
        }
    }

    public function join($groupId, $farmerId, $landContribution = 0) {
        if ($this->isMember($groupId, $farmerId)) {
            return ['ok' => false, 'error' => 'আপনি ইতোমধ্যে এই গ্রুপের সদস্য।'];
        }
        $this->db->beginTransaction();
        try {
            $this->db->prepare(
                "INSERT INTO group_members (group_id, farmer_id, land_contribution_acres, join_date, member_role, is_active)
                 VALUES (?,?,?,?,?,1)"
            )->execute([$groupId, $farmerId, $landContribution, date('Y-m-d'), 'member']);
            $this->db->prepare(
                "UPDATE farmer_groups SET total_members = total_members + 1, total_land_acres = total_land_acres + ?
                 WHERE group_id = ?"
            )->execute([$landContribution, $groupId]);
            $this->db->commit();
            return ['ok' => true];
        } catch (Throwable $e) {
            $this->db->rollBack();
            return ['ok' => false, 'error' => $e->getMessage()];
        }
    }

    public function leave($groupId, $farmerId) {
        $member = $this->fetchOne(
            "SELECT * FROM group_members WHERE group_id = ? AND farmer_id = ? AND is_active = 1",
            [$groupId, $farmerId]
        );
        if (!$member) return ['ok' => false, 'error' => 'আপনি এই গ্রুপের সদস্য নন।'];
        if ($member['member_role'] === 'leader') {
            return ['ok' => false, 'error' => 'গ্রুপ লিডার হিসেবে আপনি গ্রুপ ত্যাগ করতে পারবেন না। আগে লিডারশিপ অন্য কাউকে দিন।'];
        }
        $this->db->beginTransaction();
        try {
            $this->db->prepare("UPDATE group_members SET is_active = 0 WHERE membership_id = ?")
                ->execute([$member['membership_id']]);
            $this->db->prepare(
                "UPDATE farmer_groups SET total_members = GREATEST(total_members - 1, 0),
                                          total_land_acres = GREATEST(total_land_acres - ?, 0)
                 WHERE group_id = ?"
            )->execute([$member['land_contribution_acres'], $groupId]);
            $this->db->commit();
            return ['ok' => true];
        } catch (Throwable $e) {
            $this->db->rollBack();
            return ['ok' => false, 'error' => $e->getMessage()];
        }
    }
}
