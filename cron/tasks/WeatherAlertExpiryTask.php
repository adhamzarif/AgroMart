<?php
/**
 * WeatherAlertExpiryTask — auto-deactivates weather alerts whose end_time
 * has passed. Runs hourly so dashboards reflect current state without
 * admin intervention.
 */
class WeatherAlertExpiryTask extends CronTask {

    public $name = 'weather_expiry';
    public $schedule = 'hourly';

    public function run() {
        $stmt = $this->pdo()->prepare(
            "UPDATE weather_alerts
             SET is_active = 0
             WHERE is_active = 1 AND end_time IS NOT NULL AND end_time < NOW()"
        );
        $stmt->execute();
        $affected = $stmt->rowCount();
        return [
            'ok' => true,
            'message' => $affected ? "Deactivated $affected expired alerts" : 'No alerts to deactivate',
            'affected' => $affected,
        ];
    }
}
