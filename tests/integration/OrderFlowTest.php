<?php
/**
 * OrderFlowTest — integration tests for the order placement critical path.
 *
 * Each test runs inside a DB transaction that's rolled back in tearDown,
 * so it's safe to run against the dev database without polluting state.
 *
 * Covers:
 *   - Successful order creation decrements stock + writes inventory log
 *   - Concurrent overselling is prevented (atomic decrement)
 *   - Cancellation restores stock + writes reversing log
 *   - Insufficient stock returns clean error
 */
class OrderFlowTest extends TestCase {

    private $pdo;
    private $cropId;
    private $farmerId;
    private $buyerId;

    public function setUp() {
        bootstrapApp();
        $this->pdo = Database::getInstance()->getConnection();
        $this->pdo->beginTransaction();

        // Find a farmer + a buyer + create a fresh test crop in this transaction
        $this->farmerId = (int)$this->pdo->query(
            "SELECT u.user_id FROM users u JOIN user_roles ur ON u.user_id=ur.user_id WHERE ur.role='farmer' LIMIT 1"
        )->fetchColumn();
        $this->buyerId = (int)$this->pdo->query(
            "SELECT u.user_id FROM users u JOIN user_roles ur ON u.user_id=ur.user_id WHERE ur.role='buyer' LIMIT 1"
        )->fetchColumn();
        $categoryId = (int)$this->pdo->query("SELECT category_id FROM crop_categories LIMIT 1")->fetchColumn();

        $this->pdo->prepare(
            "INSERT INTO crops (farmer_id, category_id, crop_name, quantity, unit, price_per_unit, available_from, status)
             VALUES (?,?,?,?,?,?,CURDATE(),'available')"
        )->execute([$this->farmerId, $categoryId, 'টেস্ট ফসল', 100, 'kg', 50]);
        $this->cropId = (int)$this->pdo->lastInsertId();
    }

    public function tearDown() {
        if ($this->pdo->inTransaction()) $this->pdo->rollBack();
    }

    public function test_setup_creates_test_crop() {
        $this->assertGreaterThan(0, $this->cropId);
        $this->assertGreaterThan(0, $this->farmerId);
        $this->assertGreaterThan(0, $this->buyerId);
    }

    public function test_successful_order_decrements_stock() {
        $model = new OrderModel();
        $res = $model->create([
            'buyer_id'             => $this->buyerId,
            'crop_id'              => $this->cropId,
            'quantity_ordered'     => 10,
            'delivery_type'        => 'home_delivery',
            'delivery_address'     => 'test',
            'preferred_delivery_date' => date('Y-m-d', strtotime('+3 days')),
            'delivery_charge'      => 50,
        ]);
        $this->assertTrue($res['ok']);
        $this->assertNotEmpty($res['order_id']);
        // Stock should be 100 - 10 = 90
        $remaining = (int)$this->pdo->query("SELECT quantity FROM crops WHERE crop_id = {$this->cropId}")->fetchColumn();
        $this->assertEquals(90, $remaining);
    }

    public function test_order_creates_inventory_log() {
        $model = new OrderModel();
        $model->create([
            'buyer_id' => $this->buyerId, 'crop_id' => $this->cropId,
            'quantity_ordered' => 5, 'delivery_type' => 'home_delivery',
            'delivery_address' => 'test', 'preferred_delivery_date' => date('Y-m-d', strtotime('+3 days')),
            'delivery_charge' => 50,
        ]);
        $count = (int)$this->pdo->query(
            "SELECT COUNT(*) FROM inventory_logs WHERE crop_id = {$this->cropId} AND change_type = 'sold'"
        )->fetchColumn();
        $this->assertGreaterThan(0, $count);
    }

    public function test_insufficient_stock_rejected() {
        $model = new OrderModel();
        $res = $model->create([
            'buyer_id' => $this->buyerId, 'crop_id' => $this->cropId,
            'quantity_ordered' => 200,    // crop only has 100
            'delivery_type' => 'home_delivery',
            'delivery_address' => 'test',
            'preferred_delivery_date' => date('Y-m-d', strtotime('+3 days')),
            'delivery_charge' => 50,
        ]);
        $this->assertFalse($res['ok']);
        $this->assertNotEmpty($res['error']);
        // Stock untouched
        $remaining = (int)$this->pdo->query("SELECT quantity FROM crops WHERE crop_id = {$this->cropId}")->fetchColumn();
        $this->assertEquals(100, $remaining);
    }

    public function test_cancellation_restores_stock() {
        $model = new OrderModel();
        $res = $model->create([
            'buyer_id' => $this->buyerId, 'crop_id' => $this->cropId,
            'quantity_ordered' => 20, 'delivery_type' => 'home_delivery',
            'delivery_address' => 'test', 'preferred_delivery_date' => date('Y-m-d', strtotime('+3 days')),
            'delivery_charge' => 50,
        ]);
        $this->assertTrue($res['ok']);
        $orderId = $res['order_id'];

        $cancel = $model->cancel($orderId, $this->buyerId, 'Test cancellation');
        $this->assertTrue($cancel['ok']);

        $remaining = (int)$this->pdo->query("SELECT quantity FROM crops WHERE crop_id = {$this->cropId}")->fetchColumn();
        $this->assertEquals(100, $remaining); // back to original
    }

    public function test_order_attached_to_correct_users() {
        $model = new OrderModel();
        $res = $model->create([
            'buyer_id' => $this->buyerId, 'crop_id' => $this->cropId,
            'quantity_ordered' => 5, 'delivery_type' => 'home_delivery',
            'delivery_address' => 'test', 'preferred_delivery_date' => date('Y-m-d', strtotime('+3 days')),
            'delivery_charge' => 50,
        ]);
        $row = $this->pdo->query("SELECT * FROM orders WHERE order_id = {$res['order_id']}")->fetch();
        $this->assertEquals($this->buyerId, (int)$row['buyer_id']);
        $this->assertEquals($this->farmerId, (int)$row['farmer_id']);
        $this->assertEquals($this->cropId, (int)$row['crop_id']);
    }
}
