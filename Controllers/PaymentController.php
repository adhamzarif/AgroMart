<?php
/**
 * PaymentController — handles payment initiation, callbacks, IPN webhooks,
 * and the mock-checkout page for dev mode.
 *
 * Routes:
 *   GET  /payment/initiate/{order_id}      → start gateway session, redirect to provider
 *   GET  /payment/mock-checkout?ref=PAY-…  → dev-only fake gateway with pass/fail/cancel
 *   POST /payment/callback?status=…        → gateway sends user here after attempt
 *   GET  /payment/callback?status=…        → same (SSLCommerz sometimes uses GET)
 *   POST /payment/ipn                      → server-to-server webhook from gateway
 *   GET  /payment/success/{order_id}       → success landing page
 *   GET  /payment/failed/{order_id}        → failure landing page
 */
class PaymentController extends Controller {

    public function index() { $this->redirect('/'); }

    /** Start a payment for an order. */
    public function initiate($orderId = null) {
        $this->requireLogin();
        $orderId = (int)$orderId;
        if ($orderId <= 0) {
            Flash::set('danger', 'অবৈধ অর্ডার।');
            $this->redirect('/buyer/orders');
        }

        $orderModel = new OrderModel();
        $order = $orderModel->find($orderId);
        if (!$order) {
            Flash::set('danger', 'অর্ডার পাওয়া যায়নি।');
            $this->redirect('/buyer/orders');
        }
        if ((int)$order['buyer_id'] !== $this->userId()) {
            Flash::set('danger', 'এই অর্ডারের পেমেন্ট আপনি করতে পারবেন না।');
            $this->redirect('/buyer/orders');
        }
        if ($order['payment_status'] === 'paid') {
            Flash::set('info', 'এই অর্ডার ইতোমধ্যে পেমেন্ট সম্পন্ন।');
            $this->redirect('/buyer/orders/detail/' . $orderId);
        }
        if ($order['order_status'] === 'cancelled') {
            Flash::set('danger', 'বাতিলকৃত অর্ডারের পেমেন্ট করা যাবে না।');
            $this->redirect('/buyer/orders/detail/' . $orderId);
        }

        // Get buyer info for the gateway request
        $userModel = new UserModel();
        $buyer = $userModel->find($this->userId());

        require_once __DIR__ . '/../core/PaymentProvider.php';
        $result = PaymentProvider::initiate([
            'order_id'        => $orderId,
            'user_id'         => $this->userId(),
            'amount'          => $order['total_amount'],
            'customer_name'   => $buyer['full_name'],
            'customer_email'  => $buyer['email'] ?: 'noemail@agrofin.local',
            'customer_phone'  => $buyer['phone'],
            'customer_address' => $buyer['address'] ?: 'Bangladesh',
            'product_name'    => 'AgroFin Order #' . ($order['order_number'] ?? $orderId),
        ]);

        if (!$result['ok']) {
            Flash::set('danger', 'পেমেন্ট গেটওয়ে শুরু করতে ব্যর্থ: ' . ($result['error'] ?? 'unknown'));
            $this->redirect('/buyer/orders/detail/' . $orderId);
        }

        // Link the payment row to this order
        Database::getInstance()->getConnection()
            ->prepare("UPDATE orders SET payment_id = ?, payment_gateway = ?, order_status = 'pending_payment'
                       WHERE order_id = ?")
            ->execute([$result['payment_id'], Env::get('PAYMENT_PROVIDER', 'mock'), $orderId]);

        // Redirect to gateway
        header('Location: ' . $result['redirect_url']);
        exit;
    }

    /**
     * Mock checkout page — dev-only fake gateway.
     * Renders 3 buttons: pay successfully, simulate failure, cancel.
     */
    public function mockCheckout() {
        $ref = $_GET['ref'] ?? '';
        require_once __DIR__ . '/../core/PaymentProvider.php';
        $payment = PaymentProvider::findByReference($ref);
        if (!$payment) {
            Flash::set('danger', 'অবৈধ পেমেন্ট রেফারেন্স।');
            $this->redirect('/buyer/orders');
        }

        $title = '🧪 Mock Gateway | AgroFin';
        $this->view('payment/mock_checkout', compact('title','payment'));
    }

    /** Gateway callback — accepts both GET and POST. */
    public function callback() {
        $data = array_merge($_GET ?? [], $_POST ?? []);
        $ref = $data['tran_id'] ?? $data['ref'] ?? $data['payment_ref'] ?? '';

        if (!$ref) {
            Flash::set('danger', 'অবৈধ কলব্যাক — কোনো রেফারেন্স পাওয়া যায়নি।');
            $this->redirect('/buyer/orders');
        }

        require_once __DIR__ . '/../core/PaymentProvider.php';
        $result = PaymentProvider::verify($ref, $data);
        $payment = $result['payment'];

        if (!$payment) {
            Flash::set('danger', 'অজানা পেমেন্ট রেফারেন্স।');
            $this->redirect('/');
        }

        $orderId = (int)$payment['order_id'];

        // Update the order based on payment result
        $pdo = Database::getInstance()->getConnection();
        if ($result['ok']) {
            $pdo->beginTransaction();
            try {
                // Mark order paid + confirmed
                $pdo->prepare("UPDATE orders
                               SET payment_status = 'paid', order_status = 'confirmed',
                                   confirmed_at = NOW()
                               WHERE order_id = ?")->execute([$orderId]);

                // Insert transaction record (universal ledger)
                $orderRow = $pdo->prepare("SELECT * FROM orders WHERE order_id = ?");
                $orderRow->execute([$orderId]);
                $order = $orderRow->fetch();

                // Insert transaction records (universal ledger).
                // We record TWO entries per order — the proper double-entry pattern:
                //   1. A 'purchase' from the buyer's perspective
                //   2. A 'sale' from the farmer's perspective
                // The reference_number is shared so they're linkable.
                $txnRef = 'TXN-' . date('Ymd') . '-' . strtoupper(bin2hex(random_bytes(3)));

                // Buyer side: 'purchase'
                $pdo->prepare(
                    "INSERT INTO transactions
                        (user_id, transaction_type, amount, transaction_status,
                         related_order_id, reference_number, description, completed_at)
                     VALUES (?, 'purchase', ?, 'completed', ?, ?, ?, NOW())"
                )->execute([
                    $order['buyer_id'],
                    $payment['amount'],
                    $orderId,
                    $txnRef . '-B',
                    'অর্ডার পেমেন্ট via ' . ($payment['gateway'] ?? 'gateway'),
                ]);

                // Farmer side: 'sale'
                $pdo->prepare(
                    "INSERT INTO transactions
                        (user_id, transaction_type, amount, transaction_status,
                         related_order_id, reference_number, description, completed_at)
                     VALUES (?, 'sale', ?, 'completed', ?, ?, ?, NOW())"
                )->execute([
                    $order['farmer_id'],
                    $payment['amount'],
                    $orderId,
                    $txnRef . '-S',
                    'বিক্রয় আয় (অর্ডার ' . $order['order_number'] . ')',
                ]);

                // Notify farmer
                $pdo->prepare(
                    "INSERT INTO notifications (user_id, notification_type, priority, title, message, action_url, related_id)
                     VALUES (?, 'order', 'high', '💰 নতুন অর্ডার পেমেন্ট', ?, '/farmer/orders/detail/', ?)"
                )->execute([
                    $order['farmer_id'],
                    'অর্ডার ' . $order['order_number'] . ' এর পেমেন্ট সম্পন্ন (৳' . number_format($payment['amount']) . ')।',
                    $orderId,
                ]);

                $pdo->commit();
                Flash::set('success', '✓ পেমেন্ট সফল! ট্রানজেকশন ID: ' . ($payment['gateway_transaction_id'] ?? '—'));
                $this->redirect('/payment/success/' . $orderId);
            } catch (Throwable $e) {
                $pdo->rollBack();
                if ($e instanceof PDOException && $e->getCode() === '45000') {
                    Flash::set('danger', 'পেমেন্ট সফল হয়েছে কিন্তু ওয়ালেট ব্যালেন্সে সমস্যা থাকায় অর্ডার সম্পন্ন করা যায়নি। দয়া করে আপনার ওয়ালেটে টাকা যোগ করুন বা অন্য পেমেন্ট পদ্ধতি ব্যবহার করুন।');
                } else {
                    Flash::set('danger', 'পেমেন্ট সফল কিন্তু অর্ডার আপডেটে সমস্যা: ' . $e->getMessage());
                }
                $this->redirect('/payment/failed/' . $orderId);
            }
        } else {
            // Failed/cancelled — restore stock + mark order accordingly
            $pdo->beginTransaction();
            try {
                $orderRow = $pdo->prepare("SELECT * FROM orders WHERE order_id = ?");
                $orderRow->execute([$orderId]);
                $order = $orderRow->fetch();

                if ($order && $order['order_status'] === 'pending_payment') {
                    // Restore stock
                    $pdo->prepare("UPDATE crops SET quantity = quantity + ? WHERE crop_id = ?")
                        ->execute([$order['quantity_ordered'], $order['crop_id']]);
                    // Mark order cancelled
                    $pdo->prepare("UPDATE orders SET order_status = 'cancelled', payment_status = 'failed',
                                                    cancellation_reason = ? WHERE order_id = ?")
                        ->execute(['Payment ' . ($result['status'] ?? 'failed'), $orderId]);
                    // Inventory log — use the actual schema columns
                    // (quantity_before/after, change_reason, changed_by)
                    $newQty = (float)$pdo->query(
                        "SELECT quantity FROM crops WHERE crop_id = " . (int)$order['crop_id']
                    )->fetchColumn();
                    $oldQty = $newQty - (float)$order['quantity_ordered'];
                    $pdo->prepare(
                        "INSERT INTO inventory_logs
                            (crop_id, change_type, quantity_before, quantity_after, change_reason, changed_by)
                         VALUES (?, 'restocked', ?, ?, ?, ?)"
                    )->execute([
                        $order['crop_id'],
                        $oldQty,
                        $newQty,
                        'Payment failed — stock restored (Order #' . $order['order_number'] . ')',
                        $order['buyer_id'],
                    ]);
                }
                $pdo->commit();
            } catch (Throwable $e) {
                $pdo->rollBack();
                // log but don't block redirect
                Logger::exception($e, 'error', ['stage' => 'payment_failure_cleanup']);
            }

            Flash::set('danger', 'পেমেন্ট ' . ($result['status'] === 'cancelled' ? 'বাতিল' : 'ব্যর্থ') . ': ' . ($result['error'] ?? '—'));
            $this->redirect('/payment/failed/' . $orderId);
        }
    }

    /** IPN webhook — server-to-server confirmation. Same logic but no flash/redirect. */
    public function ipn() {
        $data = array_merge($_GET ?? [], $_POST ?? []);
        $ref = $data['tran_id'] ?? $data['ref'] ?? '';
        if (!$ref) {
            http_response_code(400);
            echo 'No reference';
            return;
        }
        require_once __DIR__ . '/../core/PaymentProvider.php';
        $result = PaymentProvider::verify($ref, $data);
        http_response_code(200);
        echo $result['ok'] ? 'OK' : 'IGNORED';
    }

    public function success($orderId = null) {
        $this->requireLogin();
        $orderId = (int)$orderId;
        $order = (new OrderModel())->find($orderId);
        if (!$order || (int)$order['buyer_id'] !== $this->userId()) {
            $this->redirect('/buyer/orders');
        }
        $title = '✓ পেমেন্ট সফল | AgroFin';
        $this->view('payment/result', compact('title','order') + ['outcome' => 'success']);
    }

    public function failed($orderId = null) {
        $this->requireLogin();
        $orderId = (int)$orderId;
        $order = (new OrderModel())->find($orderId);
        if (!$order || (int)$order['buyer_id'] !== $this->userId()) {
            $this->redirect('/buyer/orders');
        }
        $title = 'পেমেন্ট ব্যর্থ | AgroFin';
        $this->view('payment/result', compact('title','order') + ['outcome' => 'failed']);
    }
}
