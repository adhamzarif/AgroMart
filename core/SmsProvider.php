<?php
/**
 * SMS Provider Layer
 * ─────────────────────────────────────────────────────────────
 * Strategy pattern: a single SmsProvider::send() interface with
 * pluggable backends. The active provider is chosen at runtime
 * from .env's SMS_PROVIDER setting.
 *
 * Available backends:
 *   log           — writes to storage/logs/sms.log (default for dev)
 *   ssl_wireless  — SSL Wireless API (BD aggregator)
 *   mim           — MIM (BD aggregator)
 *   banglalink    — Banglalink BMS
 *
 * To plug in a real provider:
 *   1. Set SMS_PROVIDER=ssl_wireless (or another) in .env
 *   2. Fill SMS_API_KEY, SMS_API_SECRET, SMS_SENDER_ID
 *   3. Done — every send() call now goes through that provider
 *
 * ─────────────────────────────────────────────────────────────
 */
class SmsProvider {

    /** Send an SMS. Returns ['ok'=>bool, 'message_id'=>str, 'raw'=>array, 'error'=>str|null]. */
    public static function send($phone, $message, $context = 'transactional') {
        $provider = Env::get('SMS_PROVIDER', 'log');
        $phone = self::normalizePhone($phone);

        if (!preg_match('/^01[3-9]\d{8}$/', $phone)) {
            return ['ok' => false, 'message_id' => null, 'raw' => [], 'error' => 'Invalid Bangladesh phone number'];
        }

        switch ($provider) {
            case 'ssl_wireless':  return self::sendViaSslWireless($phone, $message);
            case 'mim':           return self::sendViaMim($phone, $message);
            case 'banglalink':    return self::sendViaBanglalink($phone, $message);
            case 'log':
            case '':
            default:
                return self::sendViaLog($phone, $message, $context);
        }
    }

    /** Mock provider for development. Writes to log + returns success. */
    private static function sendViaLog($phone, $message, $context) {
        $dir = dirname(__DIR__) . '/storage/logs';
        if (!is_dir($dir)) @mkdir($dir, 0755, true);
        $file = $dir . '/sms.log';
        $line = sprintf("[%s] [%s] TO=%s | %s\n",
            date('Y-m-d H:i:s'), $context, $phone, $message);
        @file_put_contents($file, $line, FILE_APPEND | LOCK_EX);

        // In dev, also flash the message to PHP error log so devs see it
        if (Env::getBool('APP_DEBUG', false)) {
            Logger::debug('SMS (dev mode)', ['to' => $phone, 'message' => $message, 'context' => $context]);
        }

        return ['ok' => true, 'message_id' => 'log-' . uniqid(), 'raw' => ['logged' => true], 'error' => null];
    }

    /** SSL Wireless API — popular BD aggregator. https://sslwireless.com */
    private static function sendViaSslWireless($phone, $message) {
        $apiKey = Env::get('SMS_API_KEY', '');
        $apiSecret = Env::get('SMS_API_SECRET', '');
        $senderId = Env::get('SMS_SENDER_ID', 'AgroFin');
        $sandbox = Env::getBool('PAYMENT_SANDBOX', true); // reuse sandbox flag

        if (!$apiKey || !$apiSecret) {
            return ['ok' => false, 'message_id' => null, 'raw' => [], 'error' => 'SMS_API_KEY/SMS_API_SECRET not configured'];
        }

        $url = $sandbox
            ? 'https://smsplus.sslwireless.com/api/v3/send-sms'
            : 'https://smsplus.sslwireless.com/api/v3/send-sms';

        $payload = [
            'api_token' => $apiKey,
            'sid' => $senderId,
            'msisdn' => $phone,
            'sms' => $message,
            'csms_id' => 'agrofin_' . uniqid(),
        ];

        $ch = curl_init($url);
        curl_setopt_array($ch, [
            CURLOPT_POST => true,
            CURLOPT_POSTFIELDS => json_encode($payload),
            CURLOPT_HTTPHEADER => ['Content-Type: application/json'],
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_TIMEOUT => 15,
        ]);
        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        $error = curl_error($ch);
        curl_close($ch);

        if ($error) {
            return ['ok' => false, 'message_id' => null, 'raw' => ['curl_error' => $error], 'error' => $error];
        }
        $parsed = json_decode($response, true) ?: [];
        $ok = isset($parsed['status']) && $parsed['status'] === 'SUCCESS';
        return [
            'ok' => $ok,
            'message_id' => $parsed['smsinfo'][0]['reference_id'] ?? null,
            'raw' => $parsed,
            'error' => $ok ? null : ($parsed['error_message'] ?? "HTTP $httpCode"),
        ];
    }

    /** MIM SMS gateway (skeleton — fill API details from MIM dashboard). */
    private static function sendViaMim($phone, $message) {
        $apiKey = Env::get('SMS_API_KEY', '');
        if (!$apiKey) {
            return ['ok' => false, 'message_id' => null, 'raw' => [], 'error' => 'SMS_API_KEY not configured'];
        }
        // Skeleton — adapt to your MIM contract
        $url = 'https://api.mimsms.com/api/v1/send';
        $payload = ['api_key' => $apiKey, 'phone' => $phone, 'message' => $message];

        $ch = curl_init($url);
        curl_setopt_array($ch, [
            CURLOPT_POST => true,
            CURLOPT_POSTFIELDS => http_build_query($payload),
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_TIMEOUT => 15,
        ]);
        $response = curl_exec($ch);
        $err = curl_error($ch);
        curl_close($ch);

        if ($err) return ['ok' => false, 'message_id' => null, 'raw' => [], 'error' => $err];
        $parsed = json_decode($response, true) ?: [];
        $ok = !empty($parsed['success']);
        return ['ok' => $ok, 'message_id' => $parsed['message_id'] ?? null, 'raw' => $parsed, 'error' => $ok ? null : ($parsed['error'] ?? 'unknown')];
    }

    /** Banglalink BMS skeleton — fill from BMS docs. */
    private static function sendViaBanglalink($phone, $message) {
        $apiKey = Env::get('SMS_API_KEY', '');
        if (!$apiKey) return ['ok' => false, 'message_id' => null, 'raw' => [], 'error' => 'SMS_API_KEY not configured'];
        // Implementation skeleton — Banglalink BMS uses a SOAP API; HTTP wrapper recommended
        return self::sendViaLog($phone, $message, 'banglalink-stub');
    }

    /** Normalize a phone string to plain 11-digit BD format. */
    private static function normalizePhone($phone) {
        $phone = preg_replace('/\D/', '', $phone);
        if (strpos($phone, '88') === 0 && strlen($phone) === 13) $phone = substr($phone, 2);
        if (strpos($phone, '0') !== 0 && strlen($phone) === 10) $phone = '0' . $phone;
        return $phone;
    }
}
