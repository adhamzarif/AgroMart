<?php
/**
 * MarketPriceProvider
 * ─────────────────────────────────────────────────────────────
 * Pulls market prices from a configured feed. Falls back to bundled
 * seed data so the system stays useful even without an external feed.
 *
 * Configured via .env:
 *   PRICE_FEED_URL=https://example.com/prices.csv   (CSV or JSON)
 *   PRICE_FEED_FORMAT=auto                           (auto | csv | json)
 *
 * Expected CSV columns (header row required):
 *   crop_name,district_name,wholesale_price,retail_price,unit
 *
 * Expected JSON shape:
 *   [{"crop_name":"...","district_name":"...","wholesale_price":N,"retail_price":N,"unit":"kg"}, ...]
 *
 * If PRICE_FEED_URL is empty or unreachable, returns the seed dataset —
 * lets the cron task keep prices fresh even in offline/free-tier setups.
 * ─────────────────────────────────────────────────────────────
 */
class MarketPriceProvider {

    /** Bundled seed data — slightly randomized day-over-day so the table shows movement. */
    private static function seedData() {
        // Base prices (BDT per kg) — typical wholesale / retail spreads
        $base = [
            ['ধান (Boro)',    'Dhaka',      32, 42, 'kg'],
            ['ধান (Boro)',    'Mymensingh', 30, 40, 'kg'],
            ['ধান (Boro)',    'Rangpur',    29, 38, 'kg'],
            ['গম',            'Dinajpur',   38, 50, 'kg'],
            ['গম',            'Dhaka',      42, 55, 'kg'],
            ['ভুট্টা',         'Bogura',     30, 40, 'kg'],
            ['ভুট্টা',         'Rangpur',    28, 38, 'kg'],
            ['আলু',           'Munshiganj', 18, 28, 'kg'],
            ['আলু',           'Dhaka',      22, 32, 'kg'],
            ['পেঁয়াজ',         'Faridpur',   55, 75, 'kg'],
            ['পেঁয়াজ',         'Dhaka',      65, 85, 'kg'],
            ['রসুন',          'Chittagong', 120, 160, 'kg'],
            ['রসুন',          'Dhaka',      130, 175, 'kg'],
            ['টমেটো',         'Jessore',    35, 55, 'kg'],
            ['টমেটো',         'Dhaka',      45, 70, 'kg'],
            ['বেগুন',          'Mymensingh', 28, 45, 'kg'],
            ['বেগুন',          'Dhaka',      35, 55, 'kg'],
            ['লাউ',           'Comilla',    25, 40, 'kg'],
            ['কাঁচামরিচ',      'Bogura',     80, 130, 'kg'],
            ['কাঁচামরিচ',      'Dhaka',     100, 160, 'kg'],
            ['আদা',           'Sylhet',    180, 240, 'kg'],
            ['ইলিশ',          'Barishal',  550, 850, 'kg'],
            ['ইলিশ',          'Chandpur',  500, 800, 'kg'],
            ['পাট',           'Rangpur',    65, 85, 'kg'],
            ['পাট',           'Jessore',    62, 80, 'kg'],
            ['ডাল (মসুর)',    'Pabna',      95, 130, 'kg'],
            ['ডাল (মুগ)',     'Pabna',     110, 150, 'kg'],
            ['সরিষা',         'Dinajpur',   85, 115, 'kg'],
        ];

        // Day-of-year-based deterministic jitter so values move slightly each day
        $jitter = (sin(date('z') / 10) + 1) / 2 * 0.10;  // 0–10% variance
        $today = date('Y-m-d');

        $rows = [];
        foreach ($base as $row) {
            list($crop, $district, $wholesale, $retail, $unit) = $row;
            $rows[] = [
                'crop_name'       => $crop,
                'district_name'   => $district,
                'wholesale_price' => round($wholesale * (1 + $jitter * (mt_rand(-5, 5) / 100)), 2),
                'retail_price'    => round($retail * (1 + $jitter * (mt_rand(-5, 5) / 100)), 2),
                'unit'            => $unit,
                'source'          => 'AgroFin Seed',
                'price_date'      => $today,
            ];
        }
        return $rows;
    }

    /** Returns ['ok'=>bool, 'rows'=>[...], 'source'=>'feed|seed', 'error'=>string|null]. */
    public static function fetch() {
        $url = trim(Env::get('PRICE_FEED_URL', ''));
        if ($url === '') {
            return ['ok' => true, 'rows' => self::seedData(), 'source' => 'seed', 'error' => null];
        }

        $format = Env::get('PRICE_FEED_FORMAT', 'auto');
        if ($format === 'auto') {
            $format = stripos($url, '.json') !== false ? 'json' : 'csv';
        }

        $ch = curl_init($url);
        curl_setopt_array($ch, [
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_TIMEOUT => 30,
            CURLOPT_FOLLOWLOCATION => true,
            CURLOPT_USERAGENT => 'AgroFin-Bot/1.0',
        ]);
        $body = curl_exec($ch);
        $err = curl_error($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);

        if ($err || $httpCode !== 200 || !$body) {
            // Network failure — return seed data and log
            return [
                'ok' => false,
                'rows' => self::seedData(),
                'source' => 'seed (fallback)',
                'error' => $err ?: "HTTP $httpCode",
            ];
        }

        try {
            $rows = $format === 'json'
                ? self::parseJson($body)
                : self::parseCsv($body);
            if (empty($rows)) {
                return ['ok' => false, 'rows' => self::seedData(), 'source' => 'seed (empty feed)', 'error' => 'Feed returned no usable rows'];
            }
            $today = date('Y-m-d');
            foreach ($rows as &$r) {
                if (empty($r['price_date'])) $r['price_date'] = $today;
                if (empty($r['source'])) $r['source'] = 'External Feed';
            }
            return ['ok' => true, 'rows' => $rows, 'source' => 'feed', 'error' => null];
        } catch (Throwable $e) {
            return ['ok' => false, 'rows' => self::seedData(), 'source' => 'seed (parse error)', 'error' => $e->getMessage()];
        }
    }

    private static function parseCsv($body) {
        $rows = [];
        $lines = preg_split('/\r\n|\n|\r/', trim($body));
        if (empty($lines)) return $rows;
        $headers = str_getcsv(array_shift($lines));
        $headers = array_map('trim', $headers);
        foreach ($lines as $line) {
            if (trim($line) === '') continue;
            $values = str_getcsv($line);
            if (count($values) !== count($headers)) continue;
            $row = array_combine($headers, array_map('trim', $values));
            // Normalize numeric fields
            $row['wholesale_price'] = (float)($row['wholesale_price'] ?? 0);
            $row['retail_price'] = (float)($row['retail_price'] ?? 0);
            if (!empty($row['crop_name']) && !empty($row['district_name'])) $rows[] = $row;
        }
        return $rows;
    }

    private static function parseJson($body) {
        $parsed = json_decode($body, true);
        if (!is_array($parsed)) return [];
        return array_filter($parsed, fn($r) => !empty($r['crop_name']) && !empty($r['district_name']));
    }
}
