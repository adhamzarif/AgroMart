<?php
/**
 * TicketModel — farmer support tickets (raised by farmer, answered by agent/admin).
 */
class TicketModel extends Model {

    public function find($ticketId) {
        return $this->fetchOne(
            "SELECT t.*, u.full_name AS farmer_name, u.phone AS farmer_phone, u.profile_picture AS farmer_picture,
                    au.full_name AS agent_name
             FROM farmer_support_tickets t
             JOIN users u ON t.farmer_id = u.user_id
             LEFT JOIN agents a ON t.assigned_agent_id = a.agent_id
             LEFT JOIN users au ON a.user_id = au.user_id
             WHERE t.ticket_id = ?",
            [$ticketId]
        );
    }

    public function listForAgent($agentId, $status = null) {
        $sql = "SELECT t.*, u.full_name AS farmer_name, u.phone AS farmer_phone, d.district_name
                FROM farmer_support_tickets t
                JOIN users u ON t.farmer_id = u.user_id
                LEFT JOIN districts d ON u.district_id = d.district_id
                WHERE t.assigned_agent_id = ?";
        $params = [$agentId];
        if ($status) { $sql .= " AND t.status = ?"; $params[] = $status; }
        $sql .= " ORDER BY FIELD(t.priority,'urgent','high','medium','low'), t.created_at DESC";
        return $this->fetchAll($sql, $params);
    }

    public function listForFarmer($farmerId, $status = null) {
        $sql = "SELECT t.*, au.full_name AS agent_name
                FROM farmer_support_tickets t
                LEFT JOIN agents a ON t.assigned_agent_id = a.agent_id
                LEFT JOIN users au ON a.user_id = au.user_id
                WHERE t.farmer_id = ?";
        $params = [$farmerId];
        if ($status) { $sql .= " AND t.status = ?"; $params[] = $status; }
        $sql .= " ORDER BY t.created_at DESC";
        return $this->fetchAll($sql, $params);
    }

    public function listUnassigned() {
        return $this->fetchAll(
            "SELECT t.*, u.full_name AS farmer_name, d.district_name
             FROM farmer_support_tickets t
             JOIN users u ON t.farmer_id = u.user_id
             LEFT JOIN districts d ON u.district_id = d.district_id
             WHERE t.assigned_agent_id IS NULL AND t.status IN ('open','in_progress')
             ORDER BY FIELD(t.priority,'urgent','high','medium','low'), t.created_at ASC"
        );
    }

    public function create(array $data) {
        $ticketNumber = gen_ref('TKT');
        $this->execute(
            "INSERT INTO farmer_support_tickets
             (ticket_number, farmer_id, issue_type, priority, subject, description, status)
             VALUES (?,?,?,?,?,?,'open')",
            [
                $ticketNumber, $data['farmer_id'], $data['issue_type'],
                $data['priority'] ?? 'medium', $data['subject'], $data['description'],
            ]
        );
        $tid = $this->lastInsertId();

        // Notify all active agents in farmer's district (or all agents)
        $agents = $this->fetchAll("SELECT user_id FROM agents WHERE status='active'");
        foreach ($agents as $a) {
            $this->execute(
                "INSERT INTO notifications (user_id, notification_type, priority, title, message, action_url, related_id)
                 VALUES (?, 'support', ?, 'নতুন সাপোর্ট টিকেট', ?, '/agent/tickets', ?)",
                [$a['user_id'], $data['priority'] === 'urgent' ? 'urgent' : 'medium', $data['subject'], $tid]
            );
        }
        return ['ok' => true, 'ticket_id' => $tid, 'ticket_number' => $ticketNumber];
    }

    /** Agent claims a ticket. */
    public function assign($ticketId, $agentId) {
        return $this->execute(
            "UPDATE farmer_support_tickets
             SET assigned_agent_id = ?, status = IF(status='open','in_progress',status), assigned_at = NOW()
             WHERE ticket_id = ?",
            [$agentId, $ticketId]
        );
    }

    /** Update status (and resolution notes if resolved). */
    public function updateStatus($ticketId, $newStatus, $resolutionNotes = null, $actingUserId = null) {
        $sql = "UPDATE farmer_support_tickets SET status = ?";
        $params = [$newStatus];
        if ($newStatus === 'resolved' || $newStatus === 'closed') {
            $sql .= ", resolution_notes = ?, resolved_at = NOW()";
            $params[] = $resolutionNotes;
        }
        $sql .= " WHERE ticket_id = ?";
        $params[] = $ticketId;
        $ok = $this->execute($sql, $params);

        if ($ok) {
            $t = $this->find($ticketId);
            if ($t) {
                $statusLabels = ['open'=>'খোলা','in_progress'=>'প্রক্রিয়াধীন','resolved'=>'সমাধান হয়েছে','closed'=>'বন্ধ','cancelled'=>'বাতিল'];
                $this->execute(
                    "INSERT INTO notifications (user_id, notification_type, priority, title, message, action_url, related_id)
                     VALUES (?, 'support', 'medium', ?, ?, '/farmer/tickets', ?)",
                    [
                        $t['farmer_id'],
                        'টিকেট আপডেট: ' . ($statusLabels[$newStatus] ?? $newStatus),
                        $t['ticket_number'] . ' — ' . ($resolutionNotes ? mb_substr($resolutionNotes, 0, 80, 'UTF-8') : 'অবস্থা পরিবর্তিত'),
                        $ticketId,
                    ]
                );
            }
        }
        return $ok;
    }

    /** Stats for an agent dashboard. */
    public function statsForAgent($agentId) {
        return $this->fetchOne(
            "SELECT
                COUNT(*) AS total,
                SUM(CASE WHEN status='open' THEN 1 ELSE 0 END) AS open_count,
                SUM(CASE WHEN status='in_progress' THEN 1 ELSE 0 END) AS in_progress_count,
                SUM(CASE WHEN status='resolved' THEN 1 ELSE 0 END) AS resolved_count
             FROM farmer_support_tickets WHERE assigned_agent_id = ?",
            [$agentId]
        );
    }
}
