-- Migration 006: Fix transactions trigger so only wallet-backed debits affect wallet balance
-- This prevents external payments from failing when a purchase transaction is recorded.

DELIMITER $$
DROP TRIGGER IF EXISTS `tr_transactions_after_insert`;
CREATE TRIGGER `tr_transactions_after_insert` AFTER INSERT ON `transactions` FOR EACH ROW BEGIN
    DECLARE current_balance DECIMAL(12,2) DEFAULT 0;
    DECLARE new_balance     DECIMAL(12,2) DEFAULT 0;
    DECLARE wallet_payment_count INT DEFAULT 0;

    IF NEW.transaction_status = 'completed' THEN
        SELECT COALESCE(wallet_balance, 0) INTO current_balance
        FROM users WHERE user_id = NEW.user_id;

        IF NEW.payment_method_id IS NOT NULL THEN
            SELECT COUNT(*) INTO wallet_payment_count
            FROM payment_methods
            WHERE method_id = NEW.payment_method_id AND method_type = 'wallet';
        END IF;

        IF NEW.transaction_type IN ('sale','deposit','loan_disbursement','refund') THEN
            SET new_balance = current_balance + NEW.amount;
        ELSEIF NEW.transaction_type IN ('purchase','withdrawal','loan_repayment','commission') THEN
            IF wallet_payment_count > 0 THEN
                SET new_balance = current_balance - NEW.amount;
            ELSE
                SET new_balance = current_balance;
            END IF;
        ELSE
            SET new_balance = current_balance;
        END IF;

        IF new_balance < 0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Transaction would result in negative wallet balance';
        END IF;

        UPDATE users SET wallet_balance = new_balance
        WHERE user_id = NEW.user_id;

        UPDATE transactions
        SET balance_before = current_balance,
            balance_after  = new_balance
        WHERE transaction_id = NEW.transaction_id;
    END IF;
END
$$
DELIMITER ;
