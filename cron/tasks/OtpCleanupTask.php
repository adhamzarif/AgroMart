<?php
/**
 * OtpCleanupTask — purges old OTP records.
 *
 * Removes:
 *   - Verified OTPs older than 7 days (kept briefly for audit)
 *   - Unverified OTPs whose expiry was over 24 hours ago
 *
 * Schedule: daily — low priority cleanup
 */
class OtpCleanupTask extends CronTask {

    public $name = 'otp_cleanup';
    public $schedule = 'daily';

    public function run() {
        require_once dirname(__DIR__, 2) . '/Models/OtpModel.php';
        $deleted = (new OtpModel())->purgeOld();
        return [
            'ok' => true,
            'message' => "Purged $deleted old OTP records",
            'affected' => $deleted,
        ];
    }
}
