<?php
/**
 * WeatherFetchTask — pulls forecasts from OpenWeatherMap for every district,
 * upserts into weather_forecasts, and auto-creates alerts when severity thresholds
 * are exceeded.
 *
 * Schedule: every 6 hours (4×/day for all 64 districts = 256 calls/day,
 * well within OpenWeatherMap's free-tier 1M/month limit).
 *
 * Designed to be safe to fail: if WEATHER_API_KEY is missing, the task is a
 * no-op. If individual district fetches fail, they're logged but don't kill
 * the rest of the run.
 */
class WeatherFetchTask extends CronTask {

    public $name = 'weather_fetch';
    public $schedule = 'every_6_hours';

    public function run() {
        require_once dirname(__DIR__, 2) . '/core/WeatherProvider.php';
        require_once dirname(__DIR__, 2) . '/Models/WeatherAlertModel.php';

        if (!WeatherProvider::isAvailable()) {
            return ['ok' => true, 'message' => 'WEATHER_API_KEY not configured — task disabled', 'affected' => 0];
        }

        $pdo = $this->pdo();
        $districts = $pdo->query(
            "SELECT district_id, district_name, latitude, longitude
             FROM districts
             WHERE latitude IS NOT NULL AND longitude IS NOT NULL"
        )->fetchAll();

        if (empty($districts)) {
            return ['ok' => false, 'message' => 'No districts have coordinates — run migration 005', 'affected' => 0];
        }

        $fetched = 0;
        $upserted = 0;
        $alertsCreated = 0;
        $failures = 0;
        $alertModel = new WeatherAlertModel();

        foreach ($districts as $d) {
            try {
                $result = WeatherProvider::fetchForDistrict($d['district_id'], $d['latitude'], $d['longitude']);
                if (!$result['ok']) {
                    $this->log("District {$d['district_name']}: " . ($result['error'] ?? 'unknown error'));
                    $failures++;
                    continue;
                }
                $fetched++;

                // Upsert current + 5 daily entries
                $allEntries = [];
                if (!empty($result['current'])) $allEntries[] = $result['current'];
                $allEntries = array_merge($allEntries, $result['daily']);

                foreach ($allEntries as $entry) {
                    $pdo->prepare(
                        "INSERT INTO weather_forecasts
                            (district_id, forecast_date, forecast_for, temp_min, temp_max, humidity,
                             rainfall_mm, wind_speed_kmh, conditions, icon, raw_payload, fetched_at)
                         VALUES (?,?,?,?,?,?,?,?,?,?,?,NOW())
                         ON DUPLICATE KEY UPDATE
                            temp_min = VALUES(temp_min),
                            temp_max = VALUES(temp_max),
                            humidity = VALUES(humidity),
                            rainfall_mm = VALUES(rainfall_mm),
                            wind_speed_kmh = VALUES(wind_speed_kmh),
                            conditions = VALUES(conditions),
                            icon = VALUES(icon),
                            raw_payload = VALUES(raw_payload),
                            fetched_at = NOW()"
                    )->execute([
                        $d['district_id'], $entry['forecast_date'], $entry['forecast_for'],
                        $entry['temp_min'], $entry['temp_max'], $entry['humidity'],
                        $entry['rainfall_mm'], $entry['wind_speed_kmh'],
                        $entry['conditions'], $entry['icon'],
                        json_encode($entry, JSON_UNESCAPED_UNICODE),
                    ]);
                    $upserted++;
                }

                // Auto-create alerts for the daily forecasts (skip 'current' — too transient)
                foreach ($result['daily'] as $day) {
                    $candidates = WeatherProvider::classifyAlert($day, $d['district_name']);
                    foreach ($candidates as $a) {
                        // Idempotency: skip if active alert for same (district, type, date) already exists
                        $exists = $pdo->prepare(
                            "SELECT 1 FROM weather_alerts
                             WHERE is_active = 1
                               AND alert_type = ?
                               AND DATE(start_time) = ?
                               AND JSON_CONTAINS(affected_districts, ?)
                             LIMIT 1"
                        );
                        $exists->execute([$a['alert_type'], $day['forecast_date'], (string)$d['district_id']]);
                        if ($exists->fetchColumn()) continue;

                        $alertModel->create([
                            'alert_type'         => $a['alert_type'],
                            'severity'           => $a['severity'],
                            'alert_title'        => $a['title'],
                            'alert_message'      => $a['message'],
                            'recommendations'    => $a['recommendations'],
                            'affected_districts' => [$d['district_id']],
                            'affected_crops'     => [],
                            'issued_by'          => 'AgroFin Weather Bot',
                            'start_time'         => $day['forecast_date'] . ' 06:00:00',
                            'end_time'           => $day['forecast_date'] . ' 23:59:59',
                            'is_active'          => 1,
                        ]);
                        $alertsCreated++;
                    }
                }
            } catch (Throwable $e) {
                $this->log("District {$d['district_name']} EXCEPTION: " . $e->getMessage());
                $failures++;
            }
        }

        return [
            'ok' => $failures < count($districts),
            'message' => sprintf('Fetched %d districts, upserted %d forecasts, created %d alerts (%d failures)',
                $fetched, $upserted, $alertsCreated, $failures),
            'affected' => $alertsCreated,
        ];
    }
}
