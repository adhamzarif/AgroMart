<?php
/**
 * OrderModel — order CRUD and lifecycle.
 */
class OrderModel extends Model {

    public function find($orderId) {
        return $this->fetchOne(
            "SELECT o.*, c.crop_name, c.unit, c.images,
                    fb.full_name AS buyer_name, fb.phone AS buyer_phone,
                    ff.full_name AS farmer_name, ff.phone AS farmer_phone, ff.profile_picture AS farmer_picture,
                    d.district_name AS delivery_district_name
             FROM orders o
             JOIN crops c ON o.crop_id = c.crop_id
             JOIN users fb ON o.buyer_id = fb.user_id
             JOIN users ff ON o.farmer_id = ff.user_id
             LEFT JOIN districts d ON o.delivery_district_id = d.district_id
             WHERE o.order_id = ?",
            [$orderId]
        );
    }

    public function findByNumber($orderNumber) {
        return $this->fetchOne("SELECT * FROM orders WHERE order_number = ?", [$orderNumber]);
    }

    public function listByBuyer($buyerId, $status = null) {
        $sql = "SELECT o.*, c.crop_name, c.unit, c.images,
                       u.full_name AS farmer_name, d.district_name
                FROM orders o
                JOIN crops c ON o.crop_id = c.crop_id
                JOIN users u ON o.farmer_id = u.user_id
                LEFT JOIN districts d ON u.district_id = d.district_id
                WHERE o.buyer_id = ?";
        $params = [$buyerId];
        if ($status) { $sql .= " AND o.order_status = ?"; $params[] = $status; }
        $sql .= " ORDER BY o.order_date DESC";
        return $this->fetchAll($sql, $params);
    }

    public function listByFarmer($farmerId, $status = null) {
        $sql = "SELECT o.*, c.crop_name, c.unit,
                       u.full_name AS buyer_name, u.phone AS buyer_phone
                FROM orders o
                JOIN crops c ON o.crop_id = c.crop_id
                JOIN users u ON o.buyer_id = u.user_id
                WHERE o.farmer_id = ?";
        $params = [$farmerId];
        if ($status) { $sql .= " AND o.order_status = ?"; $params[] = $status; }
        $sql .= " ORDER BY o.order_date DESC";
        return $this->fetchAll($sql, $params);
    }

    /**
     * Create order. Validates crop stock and price.
     * Returns ['ok' => bool, 'order_id' => int|null, 'order_number' => string|null, 'error' => string|null]
     */
    public function create(array $data) {
        $this->db->beginTransaction();
        try {
            // Lock crop row and verify availability
            $crop = $this->fetchOne(
                "SELECT crop_id, farmer_id, quantity, price_per_unit, unit, status
                 FROM crops WHERE crop_id = ? FOR UPDATE",
                [$data['crop_id']]
            );
            if (!$crop) throw new RuntimeException('ফসলটি পাওয়া যায়নি।');
            if ($crop['status'] !== 'available') throw new RuntimeException('এই ফসলটি বর্তমানে বিক্রির জন্য উপলব্ধ নয়।');
            if ((float)$data['quantity_ordered'] <= 0) throw new RuntimeException('পরিমাণ ০ এর চেয়ে বেশি হতে হবে।');
            if ((float)$data['quantity_ordered'] > (float)$crop['quantity']) {
                throw new RuntimeException('উপলব্ধ পরিমাণ মাত্র ' . bn_num($crop['quantity']) . ' ' . $crop['unit'] . '।');
            }
            if ((int)$crop['farmer_id'] === (int)$data['buyer_id']) {
                throw new RuntimeException('আপনার নিজের ফসল আপনি কিনতে পারবেন না।');
            }

            $subtotal = (float)$data['quantity_ordered'] * (float)$crop['price_per_unit'];
            $delivery = (float)($data['delivery_charge'] ?? 0);
            $total    = $subtotal + $delivery;
            $orderNumber = gen_ref('ORD');

            $stmt = $this->db->prepare(
                "INSERT INTO orders
                 (order_number, buyer_id, farmer_id, crop_id, quantity_ordered, unit_price, subtotal,
                  delivery_charge, total_amount, order_status, payment_status,
                  delivery_type, delivery_address, delivery_district_id, preferred_delivery_date, special_instructions)
                 VALUES (?,?,?,?,?,?,?,?,?,'pending','pending',?,?,?,?,?)"
            );
            $stmt->execute([
                $orderNumber, $data['buyer_id'], $crop['farmer_id'], $crop['crop_id'],
                $data['quantity_ordered'], $crop['price_per_unit'], $subtotal,
                $delivery, $total,
                $data['delivery_type'] ?? 'home_delivery',
                $data['delivery_address'] ?? null,
                $data['delivery_district_id'] ?? null,
                $data['preferred_delivery_date'] ?? null,
                $data['special_instructions'] ?? null,
            ]);
            $orderId = (int)$this->db->lastInsertId();

            // Reserve quantity (deduct now to prevent overselling)
            $newQty = (float)$crop['quantity'] - (float)$data['quantity_ordered'];
            $this->db->prepare("UPDATE crops SET quantity = ? WHERE crop_id = ?")->execute([$newQty, $crop['crop_id']]);
            if ($newQty <= 0) {
                $this->db->prepare("UPDATE crops SET status='sold' WHERE crop_id = ?")->execute([$crop['crop_id']]);
            }
            $this->db->prepare(
                "INSERT INTO inventory_logs(crop_id, change_type, quantity_before, quantity_after, change_reason, changed_by)
                 VALUES (?, 'sold', ?, ?, ?, ?)"
            )->execute([$crop['crop_id'], $crop['quantity'], $newQty, "অর্ডার $orderNumber", $data['buyer_id']]);

            // Notify the farmer
            $this->db->prepare(
                "INSERT INTO notifications (user_id, notification_type, priority, title, message, action_url, related_id)
                 VALUES (?, 'order', 'high', ?, ?, ?, ?)"
            )->execute([
                $crop['farmer_id'],
                'নতুন অর্ডার পেয়েছেন',
                'আপনি একটি নতুন অর্ডার পেয়েছেন: ' . $orderNumber,
                '/farmer/orders',
                $orderId,
            ]);

            $this->db->commit();
            return ['ok' => true, 'order_id' => $orderId, 'order_number' => $orderNumber, 'error' => null];
        } catch (Throwable $e) {
            $this->db->rollBack();
            return ['ok' => false, 'order_id' => null, 'order_number' => null, 'error' => $e->getMessage()];
        }
    }

    /** Farmer/Admin updates the order status. Notifies buyer. */
    public function updateStatus($orderId, $newStatus, $actingUserId, $reason = null) {
        $allowed = ['pending','confirmed','packed','shipped','delivered','cancelled','refunded'];
        if (!in_array($newStatus, $allowed, true)) return false;

        $order = $this->find($orderId);
        if (!$order) return false;

        $fields = ['order_status' => $newStatus];
        if ($newStatus === 'confirmed' && !$order['confirmed_at']) $fields['confirmed_at'] = date('Y-m-d H:i:s');
        if ($newStatus === 'delivered') {
            $fields['delivered_at']   = date('Y-m-d H:i:s');
            $fields['payment_status'] = 'paid';
        }
        if ($newStatus === 'cancelled') {
            $fields['cancellation_reason'] = $reason;
            $fields['cancelled_by'] = $actingUserId;
            // Restore stock
            $this->execute(
                "UPDATE crops SET quantity = quantity + ?, status='available' WHERE crop_id = ?",
                [$order['quantity_ordered'], $order['crop_id']]
            );
            $this->execute(
                "INSERT INTO inventory_logs(crop_id, change_type, quantity_before, quantity_after, change_reason, changed_by)
                 SELECT ?, 'restocked', quantity - ?, quantity, ?, ? FROM crops WHERE crop_id = ?",
                [$order['crop_id'], $order['quantity_ordered'], "অর্ডার বাতিল: $reason", $actingUserId, $order['crop_id']]
            );
        }

        $sets = []; $params = [];
        foreach ($fields as $k => $v) { $sets[] = "$k = ?"; $params[] = $v; }
        $params[] = $orderId;
        $this->execute("UPDATE orders SET " . implode(', ', $sets) . " WHERE order_id = ?", $params);

        // Notify the other party
        $notifyUserId = $actingUserId === (int)$order['farmer_id'] ? $order['buyer_id'] : $order['farmer_id'];
        $statusMap = [
            'confirmed'=>'নিশ্চিত করা হয়েছে',
            'packed'=>'প্যাক করা হয়েছে',
            'shipped'=>'পাঠানো হয়েছে',
            'delivered'=>'ডেলিভারি সম্পন্ন',
            'cancelled'=>'বাতিল',
        ];
        if (isset($statusMap[$newStatus])) {
            $this->execute(
                "INSERT INTO notifications (user_id, notification_type, priority, title, message, action_url, related_id)
                 VALUES (?, 'order', 'medium', ?, ?, ?, ?)",
                [
                    $notifyUserId, 'অর্ডার ' . $statusMap[$newStatus],
                    'অর্ডার ' . $order['order_number'] . ' এর অবস্থা: ' . $statusMap[$newStatus],
                    $actingUserId === (int)$order['farmer_id'] ? '/buyer/orders' : '/farmer/orders',
                    $orderId,
                ]
            );
        }
        return true;
    }
}
