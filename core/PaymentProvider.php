<?php
/**
 * Payment Provider Layer
 * ─────────────────────────────────────────────────────────────
 * Same strategy pattern as SmsProvider — single interface, pluggable backends.
 *
 * Active provider chosen via .env PAYMENT_PROVIDER:
 *   mock         — instant success (dev mode); no real money
 *   sslcommerz   — SSLCommerz (BD's most popular gateway; sandbox available)
 *   bkash        — bKash direct
 *   disabled     — payments disabled; orders go straight to confirmed
 *
 * Flow for any provider:
 *   1. PaymentProvider::initiate(order, user) → returns redirect URL
 *   2. User completes payment on gateway page
 *   3. Gateway POSTs to our /payment/callback?status=...&payment_ref=...
 *   4. PaymentProvider::verify(payload) confirms with the gateway and
 *      returns the final status
 * ─────────────────────────────────────────────────────────────
 */
class PaymentProvider {

    const STATUS_INITIATED = 'initiated';
    const STATUS_PENDING   = 'pending';
    const STATUS_SUCCESS   = 'success';
    const STATUS_FAILED    = 'failed';
    const STATUS_CANCELLED = 'cancelled';

    /**
     * Begin a payment session. Returns:
     *   ['ok'=>bool, 'payment_id'=>int, 'payment_ref'=>str,
     *    'redirect_url'=>str, 'gateway_session_key'=>str, 'error'=>str|null]
     */
    public static function initiate(array $context) {
        $provider = Env::get('PAYMENT_PROVIDER', 'mock');
        if ($provider === 'disabled') $provider = 'mock';

        $ref = self::generateReference();
        $context['payment_reference'] = $ref;

        // First, write an 'initiated' payment row so we have an ID even if the call fails
        $paymentId = self::insertPaymentRow($context, $provider, $ref);
        $context['payment_id'] = $paymentId;

        switch ($provider) {
            case 'sslcommerz': $result = self::initiateSslCommerz($context); break;
            case 'bkash':      $result = self::initiateBkash($context); break;
            case 'mock':
            default:           $result = self::initiateMock($context); break;
        }

        $result['payment_id'] = $paymentId;
        $result['payment_ref'] = $ref;

        // Persist gateway session key + raw request
        self::updatePaymentRow($paymentId, [
            'gateway_session_key' => $result['gateway_session_key'] ?? null,
            'raw_request' => json_encode($context, JSON_UNESCAPED_UNICODE),
            'raw_response' => json_encode($result['raw'] ?? [], JSON_UNESCAPED_UNICODE),
            'status' => $result['ok'] ? self::STATUS_PENDING : self::STATUS_FAILED,
            'failure_reason' => $result['ok'] ? null : ($result['error'] ?? null),
        ]);

        return $result;
    }

    /**
     * Verify a callback from the gateway. Returns:
     *   ['ok'=>bool, 'status'=>str, 'payment'=>row, 'error'=>str|null]
     */
    public static function verify($paymentRef, array $callbackData) {
        $payment = self::findByReference($paymentRef);
        if (!$payment) {
            return ['ok' => false, 'status' => self::STATUS_FAILED, 'payment' => null, 'error' => 'Unknown payment reference'];
        }

        $provider = $payment['gateway'];
        switch ($provider) {
            case 'sslcommerz': $verifyResult = self::verifySslCommerz($payment, $callbackData); break;
            case 'bkash':      $verifyResult = self::verifyBkash($payment, $callbackData); break;
            case 'mock':
            default:           $verifyResult = self::verifyMock($payment, $callbackData); break;
        }

        // Update payment row
        self::updatePaymentRow($payment['payment_id'], [
            'status' => $verifyResult['status'],
            'gateway_transaction_id' => $verifyResult['transaction_id'] ?? null,
            'completed_at' => date('Y-m-d H:i:s'),
            'ipn_payload' => json_encode($callbackData, JSON_UNESCAPED_UNICODE),
            'failure_reason' => $verifyResult['ok'] ? null : ($verifyResult['error'] ?? null),
        ]);

        $verifyResult['payment'] = array_merge($payment, ['status' => $verifyResult['status']]);
        return $verifyResult;
    }

    // ═══════════════════════════════════════════════════════════
    // MOCK PROVIDER (dev mode — always succeeds in sandbox)
    // ═══════════════════════════════════════════════════════════
    private static function initiateMock(array $context) {
        // In mock mode, redirect to our own callback URL with simulated success params
        $base = Env::get('APP_URL', 'http://localhost');
        $url = rtrim($base, '/') . '/AgroFin/payment/mock-checkout?ref=' . urlencode($context['payment_reference']);
        return [
            'ok' => true,
            'redirect_url' => $url,
            'gateway_session_key' => 'mock_' . uniqid(),
            'raw' => ['provider' => 'mock', 'message' => 'Mock checkout page will offer pass/fail/cancel choice'],
            'error' => null,
        ];
    }

    private static function verifyMock($payment, $data) {
        // The mock checkout page passes a "result" param: success, failed, or cancelled
        $result = $data['result'] ?? 'success';
        $statusMap = [
            'success'   => self::STATUS_SUCCESS,
            'failed'    => self::STATUS_FAILED,
            'cancelled' => self::STATUS_CANCELLED,
        ];
        $status = $statusMap[$result] ?? self::STATUS_FAILED;
        return [
            'ok' => $status === self::STATUS_SUCCESS,
            'status' => $status,
            'transaction_id' => 'MOCK-' . strtoupper(substr(uniqid(), -8)),
            'error' => $status === self::STATUS_SUCCESS ? null : 'User selected: ' . $result,
        ];
    }

    // ═══════════════════════════════════════════════════════════
    // SSLCOMMERZ PROVIDER
    // ═══════════════════════════════════════════════════════════
    private static function initiateSslCommerz(array $context) {
        $storeId = Env::get('SSLCOMMERZ_STORE_ID', '');
        $storePass = Env::get('SSLCOMMERZ_STORE_PASSWORD', '');
        $sandbox = Env::getBool('PAYMENT_SANDBOX', true);

        if (!$storeId || !$storePass) {
            return ['ok' => false, 'redirect_url' => null, 'gateway_session_key' => null,
                'raw' => [], 'error' => 'SSLCOMMERZ_STORE_ID / SSLCOMMERZ_STORE_PASSWORD not configured in .env'];
        }

        $url = $sandbox
            ? 'https://sandbox.sslcommerz.com/gwprocess/v4/api.php'
            : 'https://securepay.sslcommerz.com/gwprocess/v4/api.php';

        $base = rtrim(Env::get('APP_URL', 'http://localhost'), '/') . '/AgroFin';
        $payload = [
            'store_id'       => $storeId,
            'store_passwd'   => $storePass,
            'total_amount'   => number_format((float)$context['amount'], 2, '.', ''),
            'currency'       => 'BDT',
            'tran_id'        => $context['payment_reference'],
            'success_url'    => $base . '/payment/callback?status=success',
            'fail_url'       => $base . '/payment/callback?status=failed',
            'cancel_url'     => $base . '/payment/callback?status=cancelled',
            'ipn_url'        => $base . '/payment/ipn',
            // Customer
            'cus_name'       => $context['customer_name'] ?? 'Customer',
            'cus_email'      => $context['customer_email'] ?? 'customer@example.com',
            'cus_add1'       => $context['customer_address'] ?? 'Bangladesh',
            'cus_phone'      => $context['customer_phone'] ?? '01700000000',
            'cus_country'    => 'Bangladesh',
            // Shipping
            'shipping_method' => 'YES',
            'ship_name'      => $context['customer_name'] ?? 'Customer',
            'ship_add1'      => $context['customer_address'] ?? 'Bangladesh',
            'ship_country'   => 'Bangladesh',
            // Product
            'product_name'   => $context['product_name'] ?? 'AgroFin Order',
            'product_category' => 'Agriculture',
            'product_profile' => 'general',
        ];

        $ch = curl_init($url);
        curl_setopt_array($ch, [
            CURLOPT_POST => true,
            CURLOPT_POSTFIELDS => http_build_query($payload),
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_TIMEOUT => 30,
            CURLOPT_SSL_VERIFYPEER => true,
        ]);
        $response = curl_exec($ch);
        $err = curl_error($ch);
        curl_close($ch);

        if ($err) {
            return ['ok' => false, 'redirect_url' => null, 'gateway_session_key' => null,
                'raw' => ['curl_error' => $err], 'error' => 'Gateway unreachable: ' . $err];
        }

        $parsed = json_decode($response, true) ?: [];
        $statusOk = ($parsed['status'] ?? '') === 'SUCCESS';
        if (!$statusOk || empty($parsed['GatewayPageURL'])) {
            return ['ok' => false, 'redirect_url' => null, 'gateway_session_key' => null,
                'raw' => $parsed, 'error' => $parsed['failedreason'] ?? 'Gateway init failed'];
        }

        return [
            'ok' => true,
            'redirect_url' => $parsed['GatewayPageURL'],
            'gateway_session_key' => $parsed['sessionkey'] ?? null,
            'raw' => $parsed,
            'error' => null,
        ];
    }

    private static function verifySslCommerz($payment, $data) {
        $storeId = Env::get('SSLCOMMERZ_STORE_ID', '');
        $storePass = Env::get('SSLCOMMERZ_STORE_PASSWORD', '');
        $sandbox = Env::getBool('PAYMENT_SANDBOX', true);

        // SSLCommerz callback gives us val_id; we must call validation API
        $valId = $data['val_id'] ?? null;
        $providedStatus = strtolower($data['status'] ?? '');

        if ($providedStatus === 'cancelled') {
            return ['ok' => false, 'status' => self::STATUS_CANCELLED, 'transaction_id' => null, 'error' => 'Cancelled by user'];
        }
        if ($providedStatus === 'failed' || !$valId) {
            return ['ok' => false, 'status' => self::STATUS_FAILED, 'transaction_id' => null, 'error' => $data['error'] ?? 'Validation failed'];
        }

        // Call validation API
        $url = $sandbox
            ? "https://sandbox.sslcommerz.com/validator/api/validationserverAPI.php?val_id=" . urlencode($valId) . "&store_id=" . urlencode($storeId) . "&store_passwd=" . urlencode($storePass) . "&format=json"
            : "https://securepay.sslcommerz.com/validator/api/validationserverAPI.php?val_id=" . urlencode($valId) . "&store_id=" . urlencode($storeId) . "&store_passwd=" . urlencode($storePass) . "&format=json";

        $ch = curl_init($url);
        curl_setopt_array($ch, [
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_TIMEOUT => 15,
        ]);
        $response = curl_exec($ch);
        curl_close($ch);

        $parsed = json_decode($response, true) ?: [];
        $isValid = ($parsed['status'] ?? '') === 'VALID' || ($parsed['status'] ?? '') === 'VALIDATED';
        $amountMatch = abs((float)($parsed['amount'] ?? 0) - (float)$payment['amount']) < 0.01;

        if ($isValid && $amountMatch) {
            return [
                'ok' => true,
                'status' => self::STATUS_SUCCESS,
                'transaction_id' => $parsed['bank_tran_id'] ?? $parsed['tran_id'] ?? null,
                'error' => null,
            ];
        }
        return [
            'ok' => false,
            'status' => self::STATUS_FAILED,
            'transaction_id' => null,
            'error' => !$isValid ? 'Validation failed: ' . ($parsed['status'] ?? 'unknown') : 'Amount mismatch',
        ];
    }

    // ═══════════════════════════════════════════════════════════
    // BKASH PROVIDER (skeleton)
    // ═══════════════════════════════════════════════════════════
    private static function initiateBkash(array $context) {
        // Skeleton — bKash Tokenized Checkout requires OAuth handshake + create + execute
        // See https://developer.bka.sh
        return ['ok' => false, 'redirect_url' => null, 'gateway_session_key' => null,
            'raw' => [], 'error' => 'bKash provider not yet implemented — use sslcommerz or mock'];
    }

    private static function verifyBkash($payment, $data) {
        return ['ok' => false, 'status' => self::STATUS_FAILED, 'transaction_id' => null, 'error' => 'bKash not implemented'];
    }

    // ═══════════════════════════════════════════════════════════
    // DB HELPERS
    // ═══════════════════════════════════════════════════════════
    private static function pdo() {
        return Database::getInstance()->getConnection();
    }

    private static function insertPaymentRow($context, $provider, $ref) {
        self::pdo()->prepare(
            "INSERT INTO payments
                (payment_reference, order_id, subscription_id, user_id, gateway, amount, status)
             VALUES (?,?,?,?,?,?,?)"
        )->execute([
            $ref,
            $context['order_id'] ?? null,
            $context['subscription_id'] ?? null,
            $context['user_id'],
            $provider,
            $context['amount'],
            self::STATUS_INITIATED,
        ]);
        return (int)self::pdo()->lastInsertId();
    }

    private static function updatePaymentRow($paymentId, array $fields) {
        if (empty($fields)) return;
        $set = [];
        $params = [];
        foreach ($fields as $col => $val) {
            $set[] = "$col = ?";
            $params[] = $val;
        }
        $params[] = $paymentId;
        $sql = "UPDATE payments SET " . implode(', ', $set) . " WHERE payment_id = ?";
        self::pdo()->prepare($sql)->execute($params);
    }

    public static function findByReference($ref) {
        $stmt = self::pdo()->prepare("SELECT * FROM payments WHERE payment_reference = ?");
        $stmt->execute([$ref]);
        return $stmt->fetch() ?: null;
    }

    public static function findById($paymentId) {
        $stmt = self::pdo()->prepare("SELECT * FROM payments WHERE payment_id = ?");
        $stmt->execute([$paymentId]);
        return $stmt->fetch() ?: null;
    }

    private static function generateReference() {
        return 'PAY-' . date('Ymd') . '-' . strtoupper(bin2hex(random_bytes(4)));
    }
}
