<?php
/**
 * HelpersTest — unit tests for core/Helpers.php utility functions.
 * No DB needed; these are pure-function tests.
 */
class HelpersTest extends TestCase {

    public function setUp() {
        require_once APP_ROOT . '/core/Helpers.php';
    }

    public function test_bn_num_converts_english_digits() {
        $this->assertEquals('১২৩', bn_num('123'));
        $this->assertEquals('০', bn_num('0'));
        $this->assertEquals('১৯৭১', bn_num(1971));
    }

    public function test_e_escapes_html() {
        $this->assertEquals('&lt;script&gt;', e('<script>'));
        $this->assertEquals('Tom &amp; Jerry', e('Tom & Jerry'));
        $this->assertEquals('&quot;quoted&quot;', e('"quoted"'));
    }

    public function test_is_valid_phone() {
        $this->assertTrue(is_valid_phone('01712345001'));
        $this->assertTrue(is_valid_phone('01912345678'));
        $this->assertTrue(is_valid_phone('01612345678'));
        $this->assertFalse(is_valid_phone('1712345001'));      // missing leading 0
        $this->assertFalse(is_valid_phone('0171234500'));      // 10 digits
        $this->assertFalse(is_valid_phone('017123450012'));    // 12 digits
        $this->assertFalse(is_valid_phone('abcdefghijk'));     // non-numeric
        $this->assertFalse(is_valid_phone(''));
    }

    public function test_is_valid_email() {
        $this->assertTrue(is_valid_email('user@example.com'));
        $this->assertTrue(is_valid_email('user+tag@sub.example.bd'));
        $this->assertFalse(is_valid_email('not-an-email'));
        $this->assertFalse(is_valid_email('@example.com'));
        $this->assertFalse(is_valid_email(''));
    }

    public function test_is_valid_nid() {
        $this->assertTrue(is_valid_nid('1234567890'));      // 10 digits (legacy)
        $this->assertTrue(is_valid_nid('1234567890123'));   // 13 digits
        $this->assertTrue(is_valid_nid('12345678901234567')); // 17 digits
        $this->assertFalse(is_valid_nid('123'));
        $this->assertFalse(is_valid_nid('abcd1234567'));
        $this->assertFalse(is_valid_nid('12345678901234'));  // 14 digits — invalid length
    }

    public function test_clean_str_trims_and_strips_control_chars() {
        $this->assertEquals('hello', clean_str('  hello  ', 100));
        $this->assertEquals('', clean_str(null, 100));
        $this->assertEquals('clean', clean_str("clean\x00\x01", 100));
        // Truncation only works when mb_substr is loaded (it ships with XAMPP)
        if (function_exists('mb_substr')) {
            $this->assertEquals('hel', clean_str('hello', 3));
        } else {
            // Without mb_substr, clean_str returns the full string — that's the
            // documented fallback behavior, not a bug
            $this->assertEquals('hello', clean_str('hello', 3));
        }
    }

    public function test_bdt_formats_taka() {
        $result = bdt(1500, 0);
        $this->assertContains('৳', $result);
        $this->assertContains('১,৫০০', $result);
    }

    public function test_canonical_role_normalizes() {
        $this->assertEquals('Farmer', canonical_role('farmer'));
        $this->assertEquals('Farmer', canonical_role('FARMER'));
        $this->assertEquals('Buyer', canonical_role('buyer'));
        $this->assertEquals('Agent', canonical_role('agent'));
        $this->assertEquals('Admin', canonical_role('admin'));
    }
}
