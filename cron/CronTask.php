<?php
/**
 * Base class for all scheduled tasks.
 * Each task lives in cron/tasks/, extends CronTask, and implements run().
 *
 *  - $name           — human-readable identifier (used in logs)
 *  - $schedule       — cron-style string OR a frequency keyword
 *                       (hourly, daily, every_15_minutes, weekly)
 *  - $enabled        — set false to skip without deletion
 *  - run()           — the actual work; returns ['ok'=>bool, 'message'=>..., 'affected'=>N]
 *
 * Tasks should be idempotent — running twice should not cause double-charging,
 * duplicate notifications, etc.
 */
abstract class CronTask {

    public $name = 'unnamed_task';
    public $schedule = 'daily';
    public $enabled = true;

    /** Implement in each subclass. Return ['ok','message','affected']. */
    abstract public function run();

    /** Get a PDO connection. Available to subclasses. */
    protected function pdo() {
        return Database::getInstance()->getConnection();
    }

    /** Helper: insert a notification row. */
    protected function notify($userId, $type, $priority, $title, $message, $actionUrl = null, $relatedId = null) {
        $this->pdo()->prepare(
            "INSERT INTO notifications (user_id, notification_type, priority, title, message, action_url, related_id)
             VALUES (?,?,?,?,?,?,?)"
        )->execute([$userId, $type, $priority, $title, $message, $actionUrl, $relatedId]);
    }

    /** Helper: log a line to storage/logs/cron.log. */
    protected function log($message) {
        CronLogger::log($this->name, $message);
    }

    /** Decide whether this task should run on this invocation. */
    public function shouldRun($lastRunAt = null) {
        if (!$this->enabled) return false;

        $now = time();
        if (!$lastRunAt) return true;
        $lastTs = is_int($lastRunAt) ? $lastRunAt : strtotime($lastRunAt);

        switch ($this->schedule) {
            case 'every_5_minutes':  return ($now - $lastTs) >= 300;
            case 'every_15_minutes': return ($now - $lastTs) >= 900;
            case 'hourly':           return ($now - $lastTs) >= 3600;
            case 'every_6_hours':    return ($now - $lastTs) >= 21600;
            case 'daily':            return ($now - $lastTs) >= 86400;
            case 'weekly':           return ($now - $lastTs) >= 604800;
            default:                 return ($now - $lastTs) >= 3600; // fallback hourly
        }
    }
}
