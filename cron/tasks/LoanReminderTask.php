<?php
/**
 * LoanReminderTask — sends notifications 3 days before a loan
 * payment is due, and again on the due date. Reduces defaults
 * by giving farmers advance warning.
 *
 * Schedule: daily (early morning is ideal so notifications appear
 * when the farmer opens the app in the morning).
 * Idempotent — tracks sent reminders via a session key in the
 * notification table (related_id + title check).
 */
class LoanReminderTask extends CronTask {

    public $name = 'loan_reminder';
    public $schedule = 'daily';

    public function run() {
        $pdo = $this->pdo();
        $totalSent = 0;

        // 3-day-advance reminder
        $stmt = $pdo->query(
            "SELECT l.loan_id, l.farmer_id, l.monthly_installment, l.next_payment_date,
                    l.remaining_balance
             FROM loans l
             WHERE l.status IN ('active', 'disbursed')
               AND l.next_payment_date = DATE_ADD(CURDATE(), INTERVAL 3 DAY)
             LIMIT 500"
        );
        $upcoming = $stmt->fetchAll();
        foreach ($upcoming as $loan) {
            // Idempotency check: skip if we already sent a 3-day reminder for this loan today
            $exists = $pdo->prepare(
                "SELECT 1 FROM notifications
                 WHERE user_id = ? AND notification_type = 'loan' AND related_id = ?
                   AND title LIKE '⏰ ৩ দিনে%' AND DATE(created_at) = CURDATE() LIMIT 1"
            );
            $exists->execute([$loan['farmer_id'], $loan['loan_id']]);
            if ($exists->fetchColumn()) continue;

            $this->notify(
                $loan['farmer_id'],
                'loan',
                'high',
                '⏰ ৩ দিনে লোন কিস্তি দিতে হবে',
                sprintf('লোন %s এর পরবর্তী কিস্তি ৳%s দিতে হবে %s তারিখে। সময়মতো পরিশোধে ক্রেডিট স্কোর ভালো থাকে।',
                    'L-' . str_pad($loan['loan_id'], 5, '0', STR_PAD_LEFT),
                    number_format($loan['monthly_installment'], 0),
                    $loan['next_payment_date']
                ),
                '/farmer/loans/detail/' . $loan['loan_id'],
                $loan['loan_id']
            );
            $totalSent++;
        }

        // Due-today reminder
        $stmt = $pdo->query(
            "SELECT l.loan_id, l.farmer_id, l.monthly_installment, l.remaining_balance
             FROM loans l
             WHERE l.status IN ('active', 'disbursed')
               AND l.next_payment_date = CURDATE()
             LIMIT 500"
        );
        $dueToday = $stmt->fetchAll();
        foreach ($dueToday as $loan) {
            $exists = $pdo->prepare(
                "SELECT 1 FROM notifications
                 WHERE user_id = ? AND notification_type = 'loan' AND related_id = ?
                   AND title LIKE '🚨 আজ লোন কিস্তি%' AND DATE(created_at) = CURDATE() LIMIT 1"
            );
            $exists->execute([$loan['farmer_id'], $loan['loan_id']]);
            if ($exists->fetchColumn()) continue;

            $this->notify(
                $loan['farmer_id'],
                'loan',
                'urgent',
                '🚨 আজ লোন কিস্তি দিতে হবে',
                sprintf('লোন %s এর কিস্তি ৳%s আজই পরিশোধ করুন। দেরি হলে জরিমানা এবং ক্রেডিট স্কোরে নেতিবাচক প্রভাব পড়বে।',
                    'L-' . str_pad($loan['loan_id'], 5, '0', STR_PAD_LEFT),
                    number_format($loan['monthly_installment'], 0)
                ),
                '/farmer/loans/detail/' . $loan['loan_id'],
                $loan['loan_id']
            );
            $totalSent++;
        }

        // Overdue (1+ days past due) — mark loan as in danger
        $stmt = $pdo->query(
            "SELECT l.loan_id, l.farmer_id, l.monthly_installment,
                    DATEDIFF(CURDATE(), l.next_payment_date) AS days_overdue
             FROM loans l
             WHERE l.status IN ('active', 'disbursed')
               AND l.next_payment_date < CURDATE()
               AND l.next_payment_date IS NOT NULL
             LIMIT 500"
        );
        $overdue = $stmt->fetchAll();
        foreach ($overdue as $loan) {
            // Send escalating reminders: 1 day, 7 days, 14 days, 30 days, then mark defaulted
            $days = (int)$loan['days_overdue'];
            if (!in_array($days, [1, 7, 14, 30], true)) continue;

            $exists = $pdo->prepare(
                "SELECT 1 FROM notifications
                 WHERE user_id = ? AND notification_type = 'loan' AND related_id = ?
                   AND title LIKE '⚠ লোন পরিশোধ%' AND DATE(created_at) = CURDATE() LIMIT 1"
            );
            $exists->execute([$loan['farmer_id'], $loan['loan_id']]);
            if ($exists->fetchColumn()) continue;

            $this->notify(
                $loan['farmer_id'],
                'loan',
                'urgent',
                '⚠ লোন পরিশোধে দেরি — ' . $days . ' দিন',
                sprintf('লোন %s এর কিস্তি ৳%s এখনো পরিশোধ হয়নি। যত দ্রুত সম্ভব পরিশোধ করুন।',
                    'L-' . str_pad($loan['loan_id'], 5, '0', STR_PAD_LEFT),
                    number_format($loan['monthly_installment'], 0)
                ),
                '/farmer/loans/detail/' . $loan['loan_id'],
                $loan['loan_id']
            );
            $totalSent++;

            // After 30 days overdue, automatically mark as defaulted
            if ($days >= 30) {
                $pdo->prepare("UPDATE loans SET status = 'defaulted' WHERE loan_id = ?")
                    ->execute([$loan['loan_id']]);
                $this->log('Loan ' . 'L-' . str_pad($loan['loan_id'], 5, '0', STR_PAD_LEFT) . ' auto-marked as DEFAULTED (30+ days overdue)');
            }
        }

        return [
            'ok'       => true,
            'message'  => sprintf('Sent %d reminders (%d upcoming, %d due today, %d overdue)',
                                  $totalSent, count($upcoming), count($dueToday), count($overdue)),
            'affected' => $totalSent,
        ];
    }
}
