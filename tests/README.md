# AgroFin Test Suite

A minimal composer-less test framework covering the critical flows of the app.

## Running tests

```bash
php tests/run.php                     # run everything (unit + integration)
php tests/run.php unit                # only unit tests (no DB needed)
php tests/run.php integration         # only integration tests (needs DB)
php tests/run.php --filter=csrf       # only tests matching "csrf"
php tests/run.php --filter=order      # only tests matching "order"
```

## Suite layout

### Unit tests (`tests/unit/`) — no DB required

| File | What it covers |
|---|---|
| `HelpersTest.php` | `bn_num`, `e`, `is_valid_phone`, `is_valid_email`, `is_valid_nid`, `clean_str`, `bdt`, `canonical_role` |
| `SecurityTest.php` | CSRF (generation, verification, timing-safe compare, rolling window), RateLimit (allow/block/reset, retry formatting), Logger (sensitive-key redaction) |

### Integration tests (`tests/integration/`) — DB required

| File | What it covers |
|---|---|
| `OrderFlowTest.php` | Order placement decrements stock, creates inventory log, rejects insufficient stock, cancellation restores stock, order attached to correct users |
| `AuthFlowTest.php` | Password hash round-trip, `findByPhone`, authenticate success/failure, blocked-account detection, role retrieval, dual-role registration |
| `LoanFlowTest.php` | Application creates pending row, approval transitions state, rejection works, double-approval doesn't double-disburse |

Each integration test runs inside a DB transaction that's rolled back at the end of the test — your data is never modified.

## Safety guard

The runner refuses to start unless `DB_NAME` in `.env` is `agrofin` or `agrofin_test`. This prevents accidentally running tests against a production database.

## Writing new tests

Create a file at `tests/unit/MyThingTest.php` (or `tests/integration/MyThingTest.php`):

```php
<?php
class MyThingTest extends TestCase {

    public function setUp() {
        bootstrapApp();   // only needed for integration tests
    }

    public function test_my_thing_does_what_i_expect() {
        $result = doTheThing();
        $this->assertEquals('expected', $result);
        $this->assertNotEmpty($result);
        $this->assertContains('substring', $result);
    }
}
```

Every `public function` starting with `test_` is auto-discovered and run.

## Available assertions

```php
$this->assertEquals($expected, $actual);
$this->assertTrue($condition);
$this->assertFalse($condition);
$this->assertNotEmpty($value);
$this->assertEmpty($value);
$this->assertContains($needle, $haystack);   // in_array OR strpos
$this->assertGreaterThan($min, $actual);
$this->assertCount($expected, $array);
$this->assertThrows(function() { ... });
```

## Why not PHPUnit?

This project deliberately has zero Composer dependencies. PHPUnit's autoloader would conflict with the manual `require` pattern used throughout. The custom runner is ~100 lines and covers what's needed.
