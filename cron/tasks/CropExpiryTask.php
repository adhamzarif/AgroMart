<?php
/**
 * CropExpiryTask — marks crops whose available_until date has passed
 * as 'expired', so they disappear from the marketplace.
 *
 * Schedule: daily (1×/day is plenty — granularity is days)
 * Notifies the farmer for each expired crop so they can re-list.
 */
class CropExpiryTask extends CronTask {

    public $name = 'crop_expiry';
    public $schedule = 'daily';

    public function run() {
        $pdo = $this->pdo();

        // Find crops to expire
        $stmt = $pdo->query(
            "SELECT crop_id, farmer_id, crop_name, available_until
             FROM crops
             WHERE status = 'available'
               AND available_until IS NOT NULL
               AND available_until < CURDATE()
             LIMIT 500"
        );
        $expired = $stmt->fetchAll();
        if (empty($expired)) {
            return ['ok' => true, 'message' => 'No crops to expire', 'affected' => 0];
        }

        // Bulk update
        $ids = array_map(fn($r) => (int)$r['crop_id'], $expired);
        $placeholders = implode(',', array_fill(0, count($ids), '?'));
        $pdo->prepare("UPDATE crops SET status = 'expired' WHERE crop_id IN ($placeholders)")->execute($ids);

        // Notify farmers (1 notification per expired crop)
        foreach ($expired as $c) {
            $this->notify(
                $c['farmer_id'],
                'system',
                'medium',
                'ফসল লিস্ট মেয়াদ শেষ',
                $c['crop_name'] . ' এর উপলব্ধতা শেষ হয়ে গেছে। আবার বিক্রির জন্য নতুন লিস্ট তৈরি করুন।',
                '/farmer/crops',
                $c['crop_id']
            );
        }

        return [
            'ok'       => true,
            'message'  => sprintf('Expired %d crop listings', count($expired)),
            'affected' => count($expired),
        ];
    }
}
