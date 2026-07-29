<?php
/**
 * SubscriptionSchedulerTask — fires recurring orders for active subscriptions
 * whose next_delivery_date is today.
 *
 * For each due subscription:
 *   1. Check crop is still available with enough stock
 *   2. Create the order (atomically, with stock decrement + inventory log)
 *   3. Advance the subscription's next_delivery_date based on frequency
 *   4. Notify the buyer + farmer
 *   5. If auto_payment is on and a payment method is set, attempt payment
 *      (otherwise the order stays pending_payment for the buyer to pay manually)
 *
 * Schedule: every 6 hours (so subscriptions don't all fire at once + retries
 * if a previous run failed)
 */
class SubscriptionSchedulerTask extends CronTask {

    public $name = 'subscription_scheduler';
    public $schedule = 'every_6_hours';

    public function run() {
        $pdo = $this->pdo();

        // Find due subscriptions
        $stmt = $pdo->query(
            "SELECT s.*, c.crop_id, c.crop_name AS current_crop_name, c.price_per_unit, c.quantity AS stock,
                    c.unit AS crop_unit, c.farmer_id AS crop_farmer
             FROM subscriptions s
             LEFT JOIN crops c
                 ON c.farmer_id = s.farmer_id
                AND c.crop_name = s.crop_name
                AND c.status = 'available'
                AND c.quantity > 0
             WHERE s.status = 'active'
               AND s.next_delivery_date <= CURDATE()
               AND (s.end_date IS NULL OR s.end_date >= CURDATE())
             LIMIT 100"
        );
        $due = $stmt->fetchAll();

        if (empty($due)) {
            return ['ok' => true, 'message' => 'No subscriptions due', 'affected' => 0];
        }

        $created = 0;
        $skipped = 0;
        $expired = 0;

        foreach ($due as $sub) {
            try {
                // No matching crop currently listed?
                if (empty($sub['crop_id'])) {
                    $this->notify(
                        $sub['buyer_id'],
                        'system',
                        'medium',
                        '⚠ Subscription স্কিপ হয়েছে',
                        sprintf('"%s" এর জন্য কৃষকের কোনো লিস্টিং পাওয়া যায়নি। আপনার subscription সক্রিয় আছে — পরবর্তীতে আবার চেষ্টা হবে।',
                            $sub['crop_name']),
                        '/buyer/subscriptions',
                        $sub['subscription_id']
                    );
                    $this->advanceNextDate($sub);
                    $skipped++;
                    continue;
                }

                // Stock too low?
                if ((float)$sub['stock'] < (float)$sub['quantity_per_delivery']) {
                    $this->notify(
                        $sub['buyer_id'],
                        'system',
                        'medium',
                        '⚠ পর্যাপ্ত স্টক নেই',
                        sprintf('"%s" এর জন্য মাত্র %s %s স্টক আছে (প্রয়োজন %s %s)। পরবর্তী সাইকেলে আবার চেষ্টা হবে।',
                            $sub['crop_name'],
                            number_format((float)$sub['stock'], 2),
                            $sub['crop_unit'],
                            number_format((float)$sub['quantity_per_delivery'], 2),
                            $sub['unit']),
                        '/buyer/subscriptions',
                        $sub['subscription_id']
                    );
                    $this->advanceNextDate($sub);
                    $skipped++;
                    continue;
                }

                // Create the order via OrderModel (transactional)
                $orderData = [
                    'buyer_id'                => $sub['buyer_id'],
                    'crop_id'                 => $sub['crop_id'],
                    'quantity_ordered'        => $sub['quantity_per_delivery'],
                    'delivery_type'           => 'home_delivery',
                    'delivery_address'        => 'From subscription',
                    'delivery_district_id'    => null,
                    'preferred_delivery_date' => $sub['next_delivery_date'],
                    'special_instructions'    => 'Auto-generated from subscription #' . $sub['subscription_id'],
                    'delivery_charge'         => 50,
                ];

                $orderModel = new OrderModel();
                $res = $orderModel->create($orderData);
                if (!$res['ok']) {
                    $this->log('Subscription ' . $sub['subscription_id'] . ' order creation failed: ' . $res['error']);
                    $skipped++;
                    continue;
                }

                // If subscription has auto_payment + a payment_method, attempt charge
                // (currently we just mark as pending_payment — real auto-charge requires
                // a saved card token, not in scope yet)
                if (!empty($sub['payment_method_id']) && $sub['auto_payment']) {
                    // Stub: full auto-charge requires saved-card tokenization with SSLCommerz
                    $pdo->prepare("UPDATE orders SET order_status = 'pending_payment',
                                                    payment_gateway = 'subscription_pending'
                                   WHERE order_id = ?")->execute([$res['order_id']]);
                }

                // Increment subscription counter + advance date
                $pdo->prepare(
                    "UPDATE subscriptions
                     SET total_orders_generated = total_orders_generated + 1
                     WHERE subscription_id = ?"
                )->execute([$sub['subscription_id']]);
                $this->advanceNextDate($sub);

                // Notify both parties
                $this->notify(
                    $sub['buyer_id'],
                    'order',
                    'medium',
                    '🔁 Subscription অর্ডার তৈরি',
                    sprintf('আপনার subscription থেকে অর্ডার %s তৈরি হয়েছে (%s %s %s)।',
                        $res['order_number'],
                        number_format((float)$sub['quantity_per_delivery'], 2),
                        $sub['unit'],
                        $sub['crop_name']),
                    '/buyer/orders/detail/' . $res['order_id'],
                    $res['order_id']
                );
                $this->notify(
                    $sub['farmer_id'],
                    'order',
                    'medium',
                    '🔁 Subscription থেকে নতুন অর্ডার',
                    'অর্ডার ' . $res['order_number'] . ' — ক্রেতার subscription থেকে স্বয়ংক্রিয়ভাবে তৈরি।',
                    '/farmer/orders/detail/' . $res['order_id'],
                    $res['order_id']
                );

                $created++;

                // Check if subscription has expired (past end_date)
                if (!empty($sub['end_date']) && strtotime($sub['end_date']) < time()) {
                    $pdo->prepare("UPDATE subscriptions SET status = 'expired'
                                   WHERE subscription_id = ?")->execute([$sub['subscription_id']]);
                    $expired++;
                }
            } catch (Throwable $e) {
                $this->log('Subscription ' . $sub['subscription_id'] . ' EXCEPTION: ' . $e->getMessage());
                $skipped++;
            }
        }

        return [
            'ok'       => true,
            'message'  => sprintf('Created %d orders, skipped %d, expired %d', $created, $skipped, $expired),
            'affected' => $created,
        ];
    }

    /** Advance next_delivery_date based on frequency. */
    private function advanceNextDate(array $sub) {
        $interval = match($sub['frequency']) {
            'daily'    => '+1 day',
            'weekly'   => '+7 days',
            'biweekly' => '+14 days',
            'monthly'  => '+1 month',
            default    => '+7 days',
        };
        $next = date('Y-m-d', strtotime($sub['next_delivery_date'] . ' ' . $interval));
        $this->pdo()->prepare("UPDATE subscriptions SET next_delivery_date = ? WHERE subscription_id = ?")
            ->execute([$next, $sub['subscription_id']]);
    }
}
