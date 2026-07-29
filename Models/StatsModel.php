<?php
/**
 * StatsModel — aggregate counts for each role's dashboard.
 * Returns associative arrays with already-formatted Bangla labels in views.
 */
class StatsModel extends Model {

    public function forFarmer($farmerId) {
        return [
            'total_crops' => (int)$this->fetchScalar(
                "SELECT COUNT(*) FROM crops WHERE farmer_id = ? AND status IN ('available','sold')", [$farmerId]),
            'active_crops' => (int)$this->fetchScalar(
                "SELECT COUNT(*) FROM crops WHERE farmer_id = ? AND status = 'available'", [$farmerId]),
            'pending_orders' => (int)$this->fetchScalar(
                "SELECT COUNT(*) FROM orders WHERE farmer_id = ? AND order_status IN ('pending','confirmed','packed','shipped')", [$farmerId]),
            'completed_orders' => (int)$this->fetchScalar(
                "SELECT COUNT(*) FROM orders WHERE farmer_id = ? AND order_status = 'delivered'", [$farmerId]),
            'total_revenue' => (float)$this->fetchScalar(
                "SELECT IFNULL(SUM(total_amount),0) FROM orders WHERE farmer_id = ? AND order_status = 'delivered'", [$farmerId]),
            'this_month_revenue' => (float)$this->fetchScalar(
                "SELECT IFNULL(SUM(total_amount),0) FROM orders WHERE farmer_id = ? AND order_status = 'delivered' AND MONTH(order_date) = MONTH(CURDATE()) AND YEAR(order_date) = YEAR(CURDATE())", [$farmerId]),
            'avg_rating' => (float)$this->fetchScalar(
                "SELECT IFNULL(AVG(overall_rating),0) FROM farmer_ratings WHERE farmer_id = ?", [$farmerId]),
            'total_ratings' => (int)$this->fetchScalar(
                "SELECT COUNT(*) FROM farmer_ratings WHERE farmer_id = ?", [$farmerId]),
            'wallet_balance' => (float)$this->fetchScalar(
                "SELECT wallet_balance FROM users WHERE user_id = ?", [$farmerId]),
            'active_loans' => (int)$this->fetchScalar(
                "SELECT COUNT(*) FROM loans WHERE farmer_id = ? AND status IN ('approved','disbursed','active')", [$farmerId]),
            'total_loan_balance' => (float)$this->fetchScalar(
                "SELECT IFNULL(SUM(remaining_balance),0) FROM loans WHERE farmer_id = ? AND status IN ('approved','disbursed','active')", [$farmerId]),
            'unread_messages' => (int)$this->fetchScalar(
                "SELECT COUNT(*) FROM messages WHERE receiver_id = ? AND is_read = 0", [$farmerId]),
            'unread_notifications' => (int)$this->fetchScalar(
                "SELECT COUNT(*) FROM notifications WHERE user_id = ? AND is_read = 0", [$farmerId]),
        ];
    }

    public function forBuyer($buyerId) {
        return [
            'total_orders' => (int)$this->fetchScalar(
                "SELECT COUNT(*) FROM orders WHERE buyer_id = ?", [$buyerId]),
            'pending_orders' => (int)$this->fetchScalar(
                "SELECT COUNT(*) FROM orders WHERE buyer_id = ? AND order_status IN ('pending','confirmed','packed','shipped')", [$buyerId]),
            'delivered_orders' => (int)$this->fetchScalar(
                "SELECT COUNT(*) FROM orders WHERE buyer_id = ? AND order_status = 'delivered'", [$buyerId]),
            'total_spent' => (float)$this->fetchScalar(
                "SELECT IFNULL(SUM(total_amount),0) FROM orders WHERE buyer_id = ? AND payment_status = 'paid'", [$buyerId]),
            'this_month_spent' => (float)$this->fetchScalar(
                "SELECT IFNULL(SUM(total_amount),0) FROM orders WHERE buyer_id = ? AND payment_status = 'paid' AND MONTH(order_date) = MONTH(CURDATE()) AND YEAR(order_date) = YEAR(CURDATE())", [$buyerId]),
            'favorite_crops' => (int)$this->fetchScalar(
                "SELECT COUNT(*) FROM favorites WHERE user_id = ? AND favorite_type = 'crop'", [$buyerId]),
            'favorite_farmers' => (int)$this->fetchScalar(
                "SELECT COUNT(*) FROM favorites WHERE user_id = ? AND favorite_type = 'farmer'", [$buyerId]),
            'active_subscriptions' => (int)$this->fetchScalar(
                "SELECT COUNT(*) FROM subscriptions WHERE buyer_id = ? AND status = 'active'", [$buyerId]),
            'unread_messages' => (int)$this->fetchScalar(
                "SELECT COUNT(*) FROM messages WHERE receiver_id = ? AND is_read = 0", [$buyerId]),
            'unread_notifications' => (int)$this->fetchScalar(
                "SELECT COUNT(*) FROM notifications WHERE user_id = ? AND is_read = 0", [$buyerId]),
        ];
    }

    public function forAgent($userId) {
        $agent = $this->fetchOne("SELECT * FROM agents WHERE user_id = ?", [$userId]);
        if (!$agent) return [
            'agent_id' => 0, 'agent_code' => 'N/A',
            'assigned_farmers' => 0, 'total_commission' => 0,
            'this_month_commission' => 0, 'open_tickets' => 0,
            'activities_total' => 0, 'rating' => 0,
        ];
        $agentId = (int)$agent['agent_id'];
        return [
            'agent_id'   => $agentId,
            'agent_code' => $agent['agent_code'],
            'rating'     => (float)$agent['agent_rating'],
            'assigned_farmers' => (int)$this->fetchScalar(
                "SELECT COUNT(DISTINCT farmer_id) FROM agent_farmer_mapping WHERE agent_id = ? AND status='active'", [$agentId]),
            'total_commission' => (float)$agent['total_commission_earned'],
            'this_month_commission' => (float)$this->fetchScalar(
                "SELECT IFNULL(SUM(commission_earned),0) FROM agent_activities WHERE agent_id = ? AND MONTH(activity_date)=MONTH(CURDATE()) AND YEAR(activity_date)=YEAR(CURDATE())", [$agentId]),
            'open_tickets' => (int)$this->fetchScalar(
                "SELECT COUNT(*) FROM farmer_support_tickets WHERE assigned_agent_id = ? AND status IN ('open','in_progress')", [$agentId]),
            'activities_total' => (int)$this->fetchScalar(
                "SELECT COUNT(*) FROM agent_activities WHERE agent_id = ?", [$agentId]),
            'crops_listed_by_agent' => (int)$this->fetchScalar(
                "SELECT COUNT(*) FROM crops WHERE agent_id = ?", [$agentId]),
            'unread_notifications' => (int)$this->fetchScalar(
                "SELECT COUNT(*) FROM notifications WHERE user_id = ? AND is_read = 0", [$userId]),
        ];
    }

    public function forAdmin() {
        return [
            'total_users' => (int)$this->fetchScalar("SELECT COUNT(*) FROM users"),
            'total_farmers' => (int)$this->fetchScalar("SELECT COUNT(*) FROM user_roles WHERE role='farmer'"),
            'total_buyers'  => (int)$this->fetchScalar("SELECT COUNT(*) FROM user_roles WHERE role='buyer'"),
            'total_agents'  => (int)$this->fetchScalar("SELECT COUNT(*) FROM user_roles WHERE role='agent'"),
            'pending_loans' => (int)$this->fetchScalar("SELECT COUNT(*) FROM loans WHERE status='pending'"),
            'active_loans'  => (int)$this->fetchScalar("SELECT COUNT(*) FROM loans WHERE status IN ('approved','disbursed','active')"),
            'total_orders'  => (int)$this->fetchScalar("SELECT COUNT(*) FROM orders"),
            'today_orders'  => (int)$this->fetchScalar("SELECT COUNT(*) FROM orders WHERE DATE(order_date) = CURDATE()"),
            'today_revenue' => (float)$this->fetchScalar("SELECT IFNULL(SUM(total_amount),0) FROM orders WHERE DATE(order_date) = CURDATE() AND payment_status='paid'"),
            'total_revenue' => (float)$this->fetchScalar("SELECT IFNULL(SUM(total_amount),0) FROM orders WHERE payment_status='paid'"),
            'active_crops'  => (int)$this->fetchScalar("SELECT COUNT(*) FROM crops WHERE status='available'"),
            'suspended_users' => (int)$this->fetchScalar("SELECT COUNT(*) FROM users WHERE account_status IN ('suspended','banned')"),
            'open_tickets'  => (int)$this->fetchScalar("SELECT COUNT(*) FROM farmer_support_tickets WHERE status IN ('open','in_progress')"),
            'active_alerts' => (int)$this->fetchScalar("SELECT COUNT(*) FROM weather_alerts WHERE is_active=1"),
        ];
    }
}
