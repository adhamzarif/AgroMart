<?php
/**
 * TransactionModel — wallet ledger queries
 *
 * Reads from the `transactions` table to power the farmer wallet view.
 * Trigger T3 keeps users.wallet_balance in sync automatically on every
 * completed insert — this model only READS the ledger and inserts
 * withdrawal requests on behalf of the user.
 */
class TransactionModel extends Model {

    /** Bangla label for each transaction type. */
    public static function typeLabel($type) {
        $map = [
            'sale'              => 'বিক্রয়',
            'purchase'          => 'ক্রয়',
            'loan_disbursement' => 'লোন বিতরণ',
            'loan_repayment'    => 'লোন কিস্তি',
            'commission'        => 'কমিশন',
            'refund'            => 'রিফান্ড',
            'withdrawal'        => 'উত্তোলন',
            'deposit'           => 'ডিপোজিট',
        ];
        return $map[$type] ?? $type;
    }

    /** Returns 'in' if the type credits the wallet, 'out' otherwise. */
    public static function direction($type) {
        $in = ['sale', 'deposit', 'loan_disbursement', 'refund'];
        return in_array($type, $in, true) ? 'in' : 'out';
    }

    /** Status label in Bangla. */
    public static function statusLabel($status) {
        $map = [
            'pending'   => 'অপেক্ষমাণ',
            'completed' => 'সম্পন্ন',
            'failed'    => 'ব্যর্থ',
            'cancelled' => 'বাতিল',
        ];
        return $map[$status] ?? $status;
    }

    /** All transactions for a user, newest first. */
    public function listForUser($userId, $limit = 50) {
        return $this->fetchAll(
            "SELECT * FROM transactions
             WHERE user_id = ?
             ORDER BY created_at DESC
             LIMIT $limit",
            [$userId]
        );
    }

    /** Wallet summary for the dashboard / wallet page. */
    public function summary($userId) {
        $row = $this->fetchOne(
            "SELECT
                COALESCE(SUM(CASE WHEN transaction_type IN ('sale','deposit','loan_disbursement','refund')
                                  AND transaction_status='completed' THEN amount ELSE 0 END), 0) AS total_in,
                COALESCE(SUM(CASE WHEN transaction_type IN ('purchase','withdrawal','loan_repayment','commission')
                                  AND transaction_status='completed' THEN amount ELSE 0 END), 0) AS total_out,
                COALESCE(SUM(CASE WHEN transaction_type='sale'
                                  AND transaction_status='completed' THEN amount ELSE 0 END), 0) AS total_sales,
                COALESCE(SUM(CASE WHEN transaction_type='withdrawal'
                                  AND transaction_status IN ('completed','pending') THEN amount ELSE 0 END), 0) AS total_withdrawn,
                COALESCE(SUM(CASE WHEN transaction_type='sale'
                                  AND transaction_status='completed'
                                  AND MONTH(created_at)=MONTH(CURDATE())
                                  AND YEAR(created_at)=YEAR(CURDATE())
                                  THEN amount ELSE 0 END), 0) AS this_month_sales,
                COUNT(*) AS total_count
             FROM transactions
             WHERE user_id = ?",
            [$userId]
        );
        return $row ?: [
            'total_in' => 0, 'total_out' => 0,
            'total_sales' => 0, 'total_withdrawn' => 0,
            'this_month_sales' => 0, 'total_count' => 0,
        ];
    }

    /** Record a withdrawal request (pending until admin approves). */
    public function requestWithdrawal($userId, $amount, $method, $account, $accountName) {
        $amount = (float)$amount;
        if ($amount <= 0) return ['ok' => false, 'error' => 'উত্তোলনের পরিমাণ অবশ্যই ০ এর বেশি হতে হবে।'];

        // Re-fetch current balance to validate (do not trust client-side display)
        $bal = $this->fetchScalar(
            "SELECT COALESCE(wallet_balance, 0) FROM users WHERE user_id = ?",
            [$userId]
        );
        if ($amount > (float)$bal) {
            return ['ok' => false, 'error' => 'আপনার ওয়ালেটে যথেষ্ট ব্যালেন্স নেই।'];
        }
        if ($amount < 100) {
            return ['ok' => false, 'error' => 'সর্বনিম্ন উত্তোলনের পরিমাণ ১০০ টাকা।'];
        }

        // Generate a reference number
        $ref = 'WD-' . date('Ymd') . '-' . strtoupper(substr(uniqid(), -6));

        // Insert as PENDING — admin will approve later, which flips it to 'completed'
        // (Trigger T3 fires only on completed status — so wallet does NOT decrement here.)
        $description = sprintf('উত্তোলন অনুরোধ — %s (%s)', $method, $account);

        $this->execute(
            "INSERT INTO transactions
                (user_id, transaction_type, amount, currency, transaction_status,
                 reference_number, description, created_at)
             VALUES (?, 'withdrawal', ?, 'BDT', 'pending', ?, ?, NOW())",
            [$userId, $amount, $ref, $description]
        );

        return ['ok' => true, 'reference' => $ref];
    }
}
