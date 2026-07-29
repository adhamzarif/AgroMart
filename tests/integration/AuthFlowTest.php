<?php
/**
 * AuthFlowTest — integration tests for authentication-critical paths.
 *
 * Covers:
 *   - Password hashing/verification roundtrip
 *   - findByPhone / findByEmail lookups
 *   - authenticate() rejects bad passwords + recognizes good ones
 *   - authenticate() returns blocked marker for suspended/banned accounts
 *   - getRoles() reflects user_roles table
 */
class AuthFlowTest extends TestCase {

    private $pdo;
    private $testUserId;

    public function setUp() {
        bootstrapApp();
        $this->pdo = Database::getInstance()->getConnection();
        $this->pdo->beginTransaction();

        // Create a fresh test user inside the transaction
        $hash = password_hash('TestP@ss123', PASSWORD_BCRYPT);
        $this->pdo->prepare(
            "INSERT INTO users (full_name, phone, email, password_hash, district_id, status)
             VALUES (?,?,?,?,?,'active')"
        )->execute(['Test User', '01711111111', 'test_user_'.uniqid().'@local', $hash, 1]);
        $this->testUserId = (int)$this->pdo->lastInsertId();
        $this->pdo->prepare("INSERT INTO user_roles (user_id, role, is_active) VALUES (?, 'farmer', 1)")
            ->execute([$this->testUserId]);
    }

    public function tearDown() {
        if ($this->pdo->inTransaction()) $this->pdo->rollBack();
    }

    public function test_password_hash_round_trip() {
        $hash = password_hash('mysecret', PASSWORD_BCRYPT);
        $this->assertTrue(password_verify('mysecret', $hash));
        $this->assertFalse(password_verify('wrongpassword', $hash));
    }

    public function test_find_by_phone() {
        $model = new UserModel();
        $user = $model->findByPhone('01711111111');
        $this->assertNotEmpty($user);
        $this->assertEquals($this->testUserId, (int)$user['user_id']);
    }

    public function test_find_by_phone_nonexistent_returns_null() {
        $model = new UserModel();
        $user = $model->findByPhone('01900000000');
        $this->assertEmpty($user);
    }

    public function test_authenticate_success() {
        $model = new UserModel();
        $user = $model->authenticate('01711111111', 'TestP@ss123');
        $this->assertNotEmpty($user);
        $this->assertEquals($this->testUserId, (int)$user['user_id']);
    }

    public function test_authenticate_wrong_password_fails() {
        $model = new UserModel();
        $user = $model->authenticate('01711111111', 'WrongPassword');
        $this->assertEmpty($user);
    }

    public function test_authenticate_returns_blocked_for_suspended() {
        $this->pdo->prepare("UPDATE users SET status = 'suspended' WHERE user_id = ?")->execute([$this->testUserId]);
        $model = new UserModel();
        $user = $model->authenticate('01711111111', 'TestP@ss123');
        $this->assertNotEmpty($user);
        $this->assertContains('__blocked', array_keys($user));
    }

    public function test_get_roles_reflects_user_roles_table() {
        $model = new UserModel();
        $roles = $model->getRoles($this->testUserId);
        $this->assertContains('farmer', $roles);
    }

    public function test_create_user_with_dual_roles() {
        $model = new UserModel();
        $newId = $model->create([
            'full_name'   => 'Dual Role Test',
            'phone'       => '01722222222',
            'email'       => 'dual_'.uniqid().'@local',
            'password'    => 'TestP@ss123',
            'district_id' => 1,
            'address'     => 'Test address',
        ], ['farmer', 'buyer']);

        $this->assertGreaterThan(0, $newId);
        $roles = $model->getRoles($newId);
        $this->assertContains('farmer', $roles);
        $this->assertContains('buyer', $roles);
    }
}
