<?php
/**
 * LoanModel — microfinance loan applications, EMI calculation, repayments.
 */
class LoanModel extends Model {

    public function find($loanId) {
        return $this->fetchOne(
            "SELECT l.*, u.full_name AS farmer_name
             FROM loans l JOIN users u ON l.farmer_id = u.user_id
             WHERE l.loan_id = ?",
            [$loanId]
        );
    }

    public function listByFarmer($farmerId, $status = null) {
        $sql = "SELECT * FROM loans WHERE farmer_id = ?";
        $params = [$farmerId];
        if ($status) { $sql .= " AND status = ?"; $params[] = $status; }
        $sql .= " ORDER BY application_date DESC";
        return $this->fetchAll($sql, $params);
    }

    /** Calculate monthly installment using simple-interest based EMI. */
    public function calculateEmi($principal, $annualRate, $months) {
        $principal = (float)$principal;
        $annualRate = (float)$annualRate;
        $months = (int)$months;
        if ($months <= 0) return ['monthly' => 0, 'total' => $principal];
        $totalInterest = $principal * ($annualRate / 100) * ($months / 12);
        $totalPayable  = $principal + $totalInterest;
        $monthly       = $totalPayable / $months;
        return [
            'monthly' => round($monthly, 2),
            'total'   => round($totalPayable, 2),
            'interest'=> round($totalInterest, 2),
        ];
    }

    /** Compute a simple credit score 0-100 based on farmer history. */
    public function creditScore($farmerId) {
        $factors = [];
        $score = 50; // baseline

        // On-time repayments
        $onTime = (int)$this->fetchScalar(
            "SELECT COUNT(*) FROM loan_repayments lr
             JOIN loans l ON lr.loan_id = l.loan_id
             WHERE l.farmer_id = ?", [$farmerId]);
        $factors[] = ['name' => 'লোন কিস্তি জমা', 'value' => $onTime, 'impact' => '+' . min(20, $onTime * 3)];
        $score += min(20, $onTime * 3);

        // Defaulted loans
        $defaulted = (int)$this->fetchScalar(
            "SELECT COUNT(*) FROM loans WHERE farmer_id = ? AND status = 'defaulted'", [$farmerId]);
        $factors[] = ['name' => 'খেলাপি লোন', 'value' => $defaulted, 'impact' => $defaulted ? '-' . ($defaulted * 25) : '0'];
        $score -= $defaulted * 25;

        // Completed orders (positive signal)
        $completedOrders = (int)$this->fetchScalar(
            "SELECT COUNT(*) FROM orders WHERE farmer_id = ? AND order_status = 'delivered'", [$farmerId]);
        $factors[] = ['name' => 'সম্পন্ন অর্ডার', 'value' => $completedOrders, 'impact' => '+' . min(15, intdiv($completedOrders, 2))];
        $score += min(15, intdiv($completedOrders, 2));

        // Average rating
        $avgRating = (float)$this->fetchScalar(
            "SELECT IFNULL(AVG(overall_rating), 0) FROM farmer_ratings WHERE farmer_id = ?", [$farmerId]);
        $rImpact = (int)round(($avgRating - 3) * 5); // 5 stars = +10, 3 stars = 0
        $factors[] = ['name' => 'গড় রেটিং', 'value' => number_format($avgRating, 1), 'impact' => ($rImpact >= 0 ? '+' : '') . $rImpact];
        $score += $rImpact;

        // Account age
        $age = (int)$this->fetchScalar(
            "SELECT DATEDIFF(NOW(), created_at) FROM users WHERE user_id = ?", [$farmerId]);
        $ageImpact = min(10, intdiv($age, 30));
        $factors[] = ['name' => 'অ্যাকাউন্টের বয়স (দিন)', 'value' => $age, 'impact' => '+' . $ageImpact];
        $score += $ageImpact;

        // Verifications
        $u = $this->fetchOne("SELECT phone_verified, email_verified, nid_verified FROM users WHERE user_id = ?", [$farmerId]);
        $verImpact = ((int)$u['phone_verified'] + (int)$u['email_verified'] + (int)$u['nid_verified']) * 3;
        $factors[] = ['name' => 'যাচাইকৃত তথ্য', 'value' => $verImpact / 3 . '/3', 'impact' => '+' . $verImpact];
        $score += $verImpact;

        $score = max(0, min(100, $score));
        return [
            'score' => $score,
            'grade' => $score >= 85 ? 'A+' : ($score >= 75 ? 'A' : ($score >= 65 ? 'B' : ($score >= 55 ? 'C' : 'D'))),
            'factors' => $factors,
            'max_loan' => $score >= 75 ? 50000 : ($score >= 65 ? 30000 : ($score >= 55 ? 15000 : 5000)),
            'is_eligible' => $score >= 55,
        ];
    }

    /**
     * Apply for a loan. Returns ['ok'=>bool, 'loan_id'=>?, 'error'=>?]
     */
    public function apply(array $data) {
        $cs = $this->creditScore($data['farmer_id']);
        if (!$cs['is_eligible']) {
            return ['ok' => false, 'loan_id' => null, 'error' => 'আপনার ক্রেডিট স্কোর (' . $cs['score'] . ') লোনের জন্য পর্যাপ্ত নয়। ন্যূনতম ৫৫ প্রয়োজন।'];
        }
        if ((float)$data['loan_amount'] > $cs['max_loan']) {
            return ['ok' => false, 'loan_id' => null, 'error' => 'আপনার ক্রেডিট স্কোর অনুযায়ী সর্বোচ্চ ৳' . bn_num(number_format($cs['max_loan'])) . ' পর্যন্ত লোন নিতে পারবেন।'];
        }

        $rate = (float)($data['interest_rate'] ?? 8.0);
        $emi = $this->calculateEmi($data['loan_amount'], $rate, $data['tenure_months']);

        $this->execute(
            "INSERT INTO loans
             (farmer_id, loan_amount, interest_rate, loan_purpose, tenure_months,
              monthly_installment, total_payable, remaining_balance, credit_score_at_application, status)
             VALUES (?,?,?,?,?,?,?,?,?,'pending')",
            [
                $data['farmer_id'], $data['loan_amount'], $rate, $data['loan_purpose'], $data['tenure_months'],
                $emi['monthly'], $emi['total'], $emi['total'], $cs['score'],
            ]
        );
        $loanId = $this->lastInsertId();

        // Notify admins
        $admins = $this->fetchAll(
            "SELECT u.user_id FROM users u JOIN user_roles ur ON u.user_id=ur.user_id WHERE ur.role='admin'"
        );
        foreach ($admins as $a) {
            $this->execute(
                "INSERT INTO notifications (user_id, notification_type, priority, title, message, action_url, related_id)
                 VALUES (?, 'loan', 'medium', ?, ?, '/admin/loans', ?)",
                [$a['user_id'], 'নতুন লোন আবেদন', '৳' . bn_num(number_format($data['loan_amount'])) . ' এর নতুন লোন আবেদন পর্যালোচনার জন্য অপেক্ষমাণ', $loanId]
            );
        }
        return ['ok' => true, 'loan_id' => $loanId, 'error' => null];
    }

    /** Record a manual repayment. */
    public function recordRepayment($loanId, $farmerId, $amount, $method = 'manual', $ref = null) {
        $loan = $this->fetchOne("SELECT * FROM loans WHERE loan_id = ? AND farmer_id = ?", [$loanId, $farmerId]);
        if (!$loan || !in_array($loan['status'], ['active','disbursed'], true)) {
            return ['ok' => false, 'error' => 'এই লোনে এখন পরিশোধ করা যাবে না।'];
        }
        if ((float)$amount <= 0) return ['ok' => false, 'error' => 'পরিমাণ ০ এর বেশি হতে হবে।'];

        $this->db->beginTransaction();
        try {
            $newRemaining = max(0, (float)$loan['remaining_balance'] - (float)$amount);
            $newPaid      = (float)$loan['amount_paid'] + (float)$amount;
            $this->db->prepare(
                "INSERT INTO loan_repayments (loan_id, payment_amount, payment_method, transaction_reference, remaining_after_payment)
                 VALUES (?,?,?,?,?)"
            )->execute([$loanId, $amount, $method, $ref, $newRemaining]);
            $this->db->prepare(
                "UPDATE loans SET amount_paid = ?, remaining_balance = ?, status = IF(? <= 0, 'completed', status) WHERE loan_id = ?"
            )->execute([$newPaid, $newRemaining, $newRemaining, $loanId]);
            $this->db->commit();
            return ['ok' => true, 'remaining' => $newRemaining];
        } catch (Throwable $e) {
            $this->db->rollBack();
            return ['ok' => false, 'error' => $e->getMessage()];
        }
    }

    public function repaymentsForLoan($loanId) {
        return $this->fetchAll(
            "SELECT * FROM loan_repayments WHERE loan_id = ? ORDER BY payment_date DESC",
            [$loanId]
        );
    }
}
