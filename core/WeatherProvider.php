<?php
/**
 * WeatherProvider
 * ─────────────────────────────────────────────────────────────
 * Pulls weather forecasts from OpenWeatherMap for a district.
 * Provider is chosen via .env WEATHER_PROVIDER (default: openweathermap).
 *
 * OpenWeatherMap free tier:
 *   - 60 calls/minute, 1,000,000 calls/month
 *   - 5-day / 3-hour forecast endpoint
 *   - 64 BD districts × 4 calls/day = 256 calls/day = ~7,700/month (well under limit)
 *
 * Severity thresholds (auto-create alerts):
 *   - heavy_rain: > 50mm/day  rainfall
 *   - storm:      > 60 km/h sustained wind
 *   - heatwave:   > 38°C any day
 *   - cold_wave:  < 8°C any day
 * ─────────────────────────────────────────────────────────────
 */
class WeatherProvider {

    const ALERT_RAIN_MM    = 50.0;
    const ALERT_WIND_KMH   = 60.0;
    const ALERT_HEAT_C     = 38.0;
    const ALERT_COLD_C     = 8.0;

    public static function isAvailable() {
        $provider = Env::get('WEATHER_PROVIDER', 'openweathermap');
        if ($provider === 'none' || $provider === '') return false;
        return !empty(Env::get('WEATHER_API_KEY', ''));
    }

    /**
     * Fetch forecasts for a district. Returns:
     *   ['ok'=>bool, 'current'=>array, 'daily'=>[5 days], 'raw'=>array, 'error'=>string|null]
     */
    public static function fetchForDistrict($districtId, $lat, $lon) {
        $provider = Env::get('WEATHER_PROVIDER', 'openweathermap');
        if (!self::isAvailable()) {
            return ['ok' => false, 'current' => null, 'daily' => [], 'raw' => [], 'error' => 'WEATHER_API_KEY not configured'];
        }
        if (!$lat || !$lon) {
            return ['ok' => false, 'current' => null, 'daily' => [], 'raw' => [], 'error' => 'District has no coordinates'];
        }

        if ($provider === 'openweathermap') {
            return self::fetchFromOpenWeatherMap($lat, $lon);
        }
        return ['ok' => false, 'current' => null, 'daily' => [], 'raw' => [], 'error' => "Unknown provider: $provider"];
    }

    /** Call OpenWeatherMap 5-day/3-hour forecast endpoint + group to daily summaries. */
    private static function fetchFromOpenWeatherMap($lat, $lon) {
        $apiKey = Env::get('WEATHER_API_KEY', '');
        $url = sprintf(
            'https://api.openweathermap.org/data/2.5/forecast?lat=%f&lon=%f&appid=%s&units=metric',
            (float)$lat, (float)$lon, urlencode($apiKey)
        );

        $ch = curl_init($url);
        curl_setopt_array($ch, [
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_TIMEOUT => 15,
            CURLOPT_CONNECTTIMEOUT => 5,
        ]);
        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        $err = curl_error($ch);
        curl_close($ch);

        if ($err) {
            return ['ok' => false, 'current' => null, 'daily' => [], 'raw' => [], 'error' => 'cURL: ' . $err];
        }
        if ($httpCode !== 200) {
            return ['ok' => false, 'current' => null, 'daily' => [], 'raw' => [], 'error' => "OpenWeatherMap HTTP $httpCode"];
        }

        $parsed = json_decode($response, true) ?: [];
        if (empty($parsed['list'])) {
            return ['ok' => false, 'current' => null, 'daily' => [], 'raw' => $parsed, 'error' => 'No forecast data'];
        }

        // Group 3-hour entries by date
        $byDay = [];
        foreach ($parsed['list'] as $entry) {
            $day = substr($entry['dt_txt'], 0, 10);
            if (!isset($byDay[$day])) $byDay[$day] = [];
            $byDay[$day][] = $entry;
        }

        // Aggregate each day
        $daily = [];
        ksort($byDay);
        $today = date('Y-m-d');
        $labels = ['today', 'tomorrow', 'day_3', 'day_4', 'day_5'];
        $i = 0;
        foreach ($byDay as $date => $entries) {
            if ($i >= count($labels)) break;
            $minTemp = INF;
            $maxTemp = -INF;
            $totalRain = 0;
            $maxWind = 0;
            $humSum = 0;
            $humCount = 0;
            $conditions = [];
            foreach ($entries as $e) {
                $t = $e['main']['temp'] ?? null;
                if ($t !== null) {
                    $minTemp = min($minTemp, $t);
                    $maxTemp = max($maxTemp, $t);
                }
                $totalRain += ($e['rain']['3h'] ?? 0);
                $wind = ($e['wind']['speed'] ?? 0) * 3.6; // m/s → km/h
                $maxWind = max($maxWind, $wind);
                $humSum += ($e['main']['humidity'] ?? 0);
                $humCount++;
                if (!empty($e['weather'][0]['main'])) $conditions[] = $e['weather'][0]['main'];
            }
            // Dominant condition (most common)
            $condCounts = array_count_values($conditions);
            arsort($condCounts);
            $dominant = $condCounts ? array_key_first($condCounts) : null;
            $iconEntry = $entries[(int)floor(count($entries) / 2)] ?? $entries[0];
            $iconCode = $iconEntry['weather'][0]['icon'] ?? null;

            $daily[] = [
                'forecast_date'   => $date,
                'forecast_for'    => $labels[$i],
                'temp_min'        => round($minTemp, 2),
                'temp_max'        => round($maxTemp, 2),
                'humidity'        => $humCount ? (int)round($humSum / $humCount) : null,
                'rainfall_mm'     => round($totalRain, 2),
                'wind_speed_kmh'  => round($maxWind, 2),
                'conditions'      => $dominant,
                'icon'            => $iconCode,
            ];
            $i++;
        }

        // Build "current" entry from the next upcoming 3-hour slot
        $first = $parsed['list'][0];
        $current = [
            'forecast_date'   => $today,
            'forecast_for'    => 'current',
            'temp_min'        => $first['main']['temp_min'] ?? $first['main']['temp'],
            'temp_max'        => $first['main']['temp_max'] ?? $first['main']['temp'],
            'humidity'        => $first['main']['humidity'] ?? null,
            'rainfall_mm'     => $first['rain']['3h'] ?? 0,
            'wind_speed_kmh'  => round(($first['wind']['speed'] ?? 0) * 3.6, 2),
            'conditions'      => $first['weather'][0]['main'] ?? null,
            'icon'            => $first['weather'][0]['icon'] ?? null,
        ];

        return ['ok' => true, 'current' => $current, 'daily' => $daily, 'raw' => ['city' => $parsed['city'] ?? null], 'error' => null];
    }

    /**
     * Given a daily forecast row, return [alert_type, severity, title, message, recommendations]
     * if any threshold is exceeded — or null if the day is safe.
     */
    public static function classifyAlert(array $day, $districtName = '') {
        $alerts = [];

        if ($day['rainfall_mm'] > self::ALERT_RAIN_MM) {
            $severity = $day['rainfall_mm'] > 100 ? 'severe' : ($day['rainfall_mm'] > 75 ? 'high' : 'medium');
            $alerts[] = [
                'alert_type' => 'heavy_rain',
                'severity' => $severity,
                'title' => 'ভারী বর্ষণের পূর্বাভাস',
                'message' => sprintf('%s জেলায় %s তারিখে আনুমানিক %sমিমি বৃষ্টিপাত হতে পারে।',
                    $districtName, $day['forecast_date'], number_format($day['rainfall_mm'], 1)),
                'recommendations' => "ক্ষেতে অতিরিক্ত পানি জমা প্রতিরোধে নর্দমা পরিষ্কার রাখুন।\nপাকা ধান বা সবজি দ্রুত কাটার ব্যবস্থা করুন।\nবাইরে রাখা গবাদিপশুকে নিরাপদ স্থানে নিন।",
            ];
        }

        if ($day['wind_speed_kmh'] > self::ALERT_WIND_KMH) {
            $severity = $day['wind_speed_kmh'] > 90 ? 'severe' : ($day['wind_speed_kmh'] > 75 ? 'high' : 'medium');
            $alerts[] = [
                'alert_type' => 'storm',
                'severity' => $severity,
                'title' => 'ঝড়ের সতর্কতা',
                'message' => sprintf('%s জেলায় %s তারিখে প্রায় %s কিমি/ঘণ্টা গতির বাতাস হতে পারে।',
                    $districtName, $day['forecast_date'], number_format($day['wind_speed_kmh'], 0)),
                'recommendations' => "ফসলের সাপোর্ট দড়ি/বাঁশ মজবুত করুন।\nগ্রিনহাউস ও প্লাস্টিক টানেলের কভার নিরাপদে বেঁধে রাখুন।\nগবাদিপশু আবদ্ধ স্থানে রাখুন।",
            ];
        }

        if ($day['temp_max'] > self::ALERT_HEAT_C) {
            $severity = $day['temp_max'] > 42 ? 'severe' : ($day['temp_max'] > 40 ? 'high' : 'medium');
            $alerts[] = [
                'alert_type' => 'heatwave',
                'severity' => $severity,
                'title' => 'তাপদাহের পূর্বাভাস',
                'message' => sprintf('%s জেলায় %s তারিখে সর্বোচ্চ তাপমাত্রা %s°সে পর্যন্ত উঠতে পারে।',
                    $districtName, $day['forecast_date'], number_format($day['temp_max'], 1)),
                'recommendations' => "ফসলে দিনে একাধিকবার পানি দিন (ভোরে ও বিকেলে)।\nগবাদিপশুকে ছায়া ও পরিষ্কার পানির ব্যবস্থা করুন।\nবেশি রোদে কাজ এড়িয়ে চলুন।",
            ];
        }

        if ($day['temp_min'] < self::ALERT_COLD_C && $day['temp_min'] !== null) {
            $severity = $day['temp_min'] < 5 ? 'severe' : ($day['temp_min'] < 7 ? 'high' : 'medium');
            $alerts[] = [
                'alert_type' => 'cold_wave',
                'severity' => $severity,
                'title' => 'শৈত্যপ্রবাহের পূর্বাভাস',
                'message' => sprintf('%s জেলায় %s তারিখে সর্বনিম্ন তাপমাত্রা %s°সে পর্যন্ত নামতে পারে।',
                    $districtName, $day['forecast_date'], number_format($day['temp_min'], 1)),
                'recommendations' => "চারা গাছকে রাতে কাপড়/পলিথিন দিয়ে ঢেকে রাখুন।\nগবাদিপশুর ঘরে গরম রাখার ব্যবস্থা করুন।\nবয়স্ক ও শিশুদের গরম পোশাক পরান।",
            ];
        }

        return $alerts;
    }
}
