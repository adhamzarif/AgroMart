<?php
/**
 * LogRotateTask — deletes log files older than LOG_RETENTION_DAYS.
 *
 * Schedule: daily. Keeps storage/logs/ from growing unboundedly.
 * Configurable via .env LOG_RETENTION_DAYS (default 30).
 */
class LogRotateTask extends CronTask {

    public $name = 'log_rotate';
    public $schedule = 'daily';

    public function run() {
        require_once dirname(__DIR__, 2) . '/core/Logger.php';
        $days = Env::getInt('LOG_RETENTION_DAYS', 30);
        $removed = Logger::rotate($days);
        return [
            'ok'       => true,
            'message'  => "Pruned $removed log file(s) older than $days days",
            'affected' => $removed,
        ];
    }
}
