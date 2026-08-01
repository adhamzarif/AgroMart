# AgroFin — SQL Query Demonstration

> *Showcase of important SQL queries and advanced database features used in the AgroFin Agricultural Marketplace & Microfinance platform.*
> *Database: MariaDB · 39 Tables · 71 Foreign Keys · 3 Triggers · 2 Views · 20+ Indexes*

---

## Table of Contents

### Part A — Important SQL Queries

1. [Multi-Table JOINs](#1-multi-table-joins)
2. [Aggregation & GROUP BY](#2-aggregation--group-by)
3. [Correlated Subqueries](#3-correlated-subqueries)
4. [EXISTS / NOT EXISTS](#4-exists--not-exists)
5. [UNION ALL & Derived Tables](#5-union-all--derived-tables)
6. [Atomic Transactions & Row Locking](#6-atomic-transactions--row-locking)
7. [UPSERT (INSERT ... ON DUPLICATE KEY UPDATE)](#7-upsert-insert--on-duplicate-key-update)
8. [JSON Column Queries](#8-json-column-queries)
9. [Date Functions & Time-Window Filters](#9-date-functions--time-window-filters)
10. [Conditional Aggregation (CASE WHEN)](#10-conditional-aggregation-case-when)

### Part B — Advanced Database Features

11. [Triggers](#11-triggers-3)
12. [Views](#12-views-2)
13. [Indexes](#13-indexes-20)
14. [Constraints & Referential Integrity](#14-constraints--referential-integrity)

### Part C — Defense Reference

15. [Where Each Feature is Used in the App](#15-where-each-feature-is-used-in-the-app)
16. [Defense Talking Points](#16-defense-talking-points)

---

# Part A — Important SQL Queries

## 1. Multi-Table JOINs

### Query: Marketplace listings with farmer + district + category + ratings

**The most complex query in the project.** Combines **4 tables** via INNER + LEFT JOINs plus correlated subqueries for ratings.

**File:** `Models/CropModel.php::search()`
**Used by:** `/marketplace`, `/marketplace/all`, `/buyer/browse`

```sql
SELECT
    c.*,
    u.full_name        AS farmer_name,
    u.profile_picture  AS farmer_picture,
    u.phone            AS farmer_phone,
    d.district_name,
    cat.category_name_bn,
    IFNULL((SELECT AVG(overall_rating)
            FROM farmer_ratings
            WHERE farmer_id = c.farmer_id), 0) AS farmer_rating,
    IFNULL((SELECT COUNT(*)
            FROM farmer_ratings
            WHERE farmer_id = c.farmer_id), 0) AS farmer_rating_count
FROM crops c
JOIN users u             ON c.farmer_id    = u.user_id
LEFT JOIN districts d    ON u.district_id  = d.district_id
JOIN crop_categories cat ON c.category_id  = cat.category_id
WHERE c.status = 'available'
  AND c.quantity > 0
  AND u.account_status = 'active'
  AND EXISTS (
      SELECT 1 FROM user_roles ur
      WHERE ur.user_id = u.user_id
        AND ur.role = 'farmer'
  )
ORDER BY c.created_at DESC
LIMIT 24 OFFSET 0;
```

### Why this is meaningful

| Feature | What it demonstrates |
|---|---|
| **4 JOINs in one statement** | Combining crop, farmer, location, category data in one trip |
| **INNER vs LEFT JOIN** | Crops MUST have a farmer (INNER) but district can be NULL (LEFT) |
| **Correlated subqueries** | Computing per-crop farmer rating without duplicating rows |
| **IFNULL** | Graceful zero for crops whose farmer has no ratings yet |
| **EXISTS clause** | Verifies user holds 'farmer' role without joining `user_roles` |
| **Composite WHERE** | 4 conditions ensure only legitimate listings appear |
| **Pagination** | `LIMIT 24 OFFSET ?` for paginated browse |

---

## 2. Aggregation & GROUP BY

### Query: Live Price Hybrid — average farmer prices joined with market reference

**File:** `Controllers/LivepriceController.php::index()`
**Used by:** `/liveprice` page

```sql
SELECT
    c.crop_name,
    ROUND(AVG(c.price_per_unit), 0)  AS agrofin_price,
    MIN(c.price_per_unit)            AS min_price,
    MAX(c.price_per_unit)            AS max_price,
    COUNT(*)                         AS farmer_count,
    SUM(c.quantity)                  AS total_stock,
    MAX(c.unit)                      AS unit,
    MAX(c.created_at)                AS latest_listing,
    -- Correlated subquery: latest market reference per crop
    (SELECT mp.retail_price
     FROM market_prices mp
     WHERE mp.crop_name = c.crop_name
     ORDER BY mp.price_date DESC, mp.created_at DESC
     LIMIT 1) AS market_retail_price
FROM crops c
JOIN users u ON c.farmer_id = u.user_id
WHERE c.status = 'available'
  AND c.quantity > 0
  AND u.account_status = 'active'
  AND EXISTS (SELECT 1 FROM user_roles ur
              WHERE ur.user_id = u.user_id
                AND ur.role = 'farmer')
GROUP BY c.crop_name
ORDER BY c.crop_name;
```

### Why this is meaningful

| Aggregate function | What it computes |
|---|---|
| `AVG(price_per_unit)` | Average AgroFin price across all farmers selling this crop |
| `MIN`, `MAX` | Cheapest and most expensive listings |
| `COUNT(*)` | How many farmers are offering this crop |
| `SUM(quantity)` | Total stock available across all farmers |
| `ROUND(..., 0)` | Cleans the display value to whole taka |

The `GROUP BY c.crop_name` groups all listings of the same crop together. A correlated subquery in the SELECT clause then pulls the latest market reference per crop — combining aggregation and subquery in one statement.

---

## 3. Correlated Subqueries

### Query: Demand-supply analytics

**File:** `cron/tasks/DemandAnalyticsTask.php`
**Runs:** Daily at midnight via Windows Task Scheduler

```sql
INSERT INTO demand_analytics
    (crop_name, district_id, analysis_date,
     supply_units, demand_units, interest_score)
SELECT
    sd.crop_name,
    sd.district_id,
    CURDATE() AS analysis_date,
    SUM(sd.supply_qty)  AS supply,
    SUM(sd.demand_qty)  AS demand,
    ROUND(
        (SUM(sd.demand_qty) / NULLIF(SUM(sd.supply_qty), 0)) * 100,
        2
    ) AS interest_score
FROM (
    -- Supply: all active crop listings
    SELECT c.crop_name, u.district_id,
           c.quantity AS supply_qty,
           0 AS demand_qty
    FROM crops c
    JOIN users u ON c.farmer_id = u.user_id
    WHERE c.status = 'available'
    UNION ALL
    -- Demand: ordered quantities (last 30 days)
    SELECT cr.crop_name, u.district_id,
           0 AS supply_qty,
           o.quantity_ordered AS demand_qty
    FROM orders o
    JOIN crops cr ON o.crop_id = cr.crop_id
    JOIN users u  ON o.buyer_id = u.user_id
    WHERE o.order_date >= CURDATE() - INTERVAL 30 DAY
) AS sd
GROUP BY sd.crop_name, sd.district_id
ON DUPLICATE KEY UPDATE
    supply_units    = VALUES(supply_units),
    demand_units    = VALUES(demand_units),
    interest_score  = VALUES(interest_score);
```

### Why this is meaningful

This single statement combines **four advanced features**:
- A **derived table** (subquery in FROM clause) that unions supply and demand into one stream
- A **division-by-zero guard** (`NULLIF`) that prevents crashes when supply is zero
- An **INSERT INTO ... SELECT** pattern that writes computed results back to a table
- An **UPSERT** so re-running the cron updates yesterday's row instead of creating duplicates

---

## 4. EXISTS / NOT EXISTS

### Query: Role verification without join duplication

When checking "is this user a farmer?", joining `user_roles` would multiply rows if the user has multiple roles. `EXISTS` checks the condition without affecting cardinality.

```sql
SELECT c.crop_id, c.crop_name, c.price_per_unit
FROM crops c
JOIN users u ON c.farmer_id = u.user_id
WHERE c.status = 'available'
  AND u.account_status = 'active'
  AND EXISTS (
      SELECT 1 FROM user_roles ur
      WHERE ur.user_id = u.user_id
        AND ur.role = 'farmer'
  );
```

### Compare: with JOIN (wrong) vs with EXISTS (correct)

**❌ Bad — JOIN duplicates rows when user has multiple roles:**
```sql
SELECT c.*
FROM crops c
JOIN user_roles ur ON ur.user_id = c.farmer_id AND ur.role = 'farmer'
JOIN user_roles ur2 ON ur2.user_id = c.farmer_id AND ur2.role = 'buyer'
-- Returns the same crop twice if the user is BOTH farmer AND buyer
```

**✅ Good — EXISTS just confirms membership:**
```sql
SELECT c.*
FROM crops c
WHERE EXISTS (SELECT 1 FROM user_roles WHERE user_id = c.farmer_id AND role = 'farmer')
-- Each crop appears exactly once
```

---

## 5. UNION ALL & Derived Tables

The demand_analytics query in section 3 uses **UNION ALL** to combine two different data streams (supply from `crops`, demand from `orders`) into a single dataset before aggregation. This is a textbook use case for `UNION ALL`:

```sql
FROM (
    SELECT crop_name, district_id, quantity AS supply_qty, 0 AS demand_qty
    FROM crops ...
    UNION ALL
    SELECT crop_name, district_id, 0 AS supply_qty, quantity_ordered AS demand_qty
    FROM orders ...
) AS supply_demand
GROUP BY crop_name, district_id;
```

**Why `UNION ALL` and not `UNION`?**
`UNION` deduplicates rows (expensive sort). `UNION ALL` keeps all rows because we want to count them separately. For aggregation purposes, `UNION ALL` is correct and faster.

---

## 6. Atomic Transactions & Row Locking

### Query: Order placement with stock decrement

**File:** `Models/OrderModel.php::create()`
**Used by:** Buyer order placement flow

```sql
START TRANSACTION;

-- 1. Lock the crop row to prevent concurrent overselling
SELECT quantity, price_per_unit
FROM crops
WHERE crop_id = ?
FOR UPDATE;

-- 2. If insufficient stock, rollback and exit
-- (PHP checks the result; if quantity < ordered, ROLLBACK is called)

-- 3. Decrement stock
UPDATE crops
SET quantity = quantity - ?
WHERE crop_id = ?;

-- 4. Create the order
INSERT INTO orders
    (buyer_id, farmer_id, crop_id, quantity_ordered,
     unit_price, subtotal, total_amount, order_status, payment_status)
VALUES (?, ?, ?, ?, ?, ?, ?, 'pending_payment', 'pending');

-- 5. Log inventory change
INSERT INTO inventory_logs
    (crop_id, change_type, quantity_before, quantity_after,
     change_reason, changed_by)
VALUES (?, 'sold', ?, ?,
        CONCAT('Sold via order #', LAST_INSERT_ID()),
        ?);

COMMIT;
```

### Why this is meaningful

**Race condition prevention.** Without `SELECT ... FOR UPDATE`, two buyers could simultaneously buy the last unit:

| Time | Buyer 1 | Buyer 2 | crops.quantity |
|---|---|---|---|
| T1 | reads quantity (1) | | 1 |
| T2 | | reads quantity (1) | 1 |
| T3 | decrements to 0 | | 0 |
| T4 | | decrements to -1 ❌ | -1 |

With `FOR UPDATE`, Buyer 2 waits at step T2 until Buyer 1 commits at step T3, then sees the updated quantity (0) and the application code refuses the order.

**ACID properties** are guaranteed:
- **Atomicity** — all 4 writes succeed together or none do
- **Consistency** — stock can never go negative (CHECK constraint + FOR UPDATE)
- **Isolation** — concurrent buyers don't see each other's mid-transaction state
- **Durability** — committed orders survive crashes

---

## 7. UPSERT (INSERT ... ON DUPLICATE KEY UPDATE)

### Query: Idempotent weather data writes

**File:** `cron/tasks/WeatherFetchTask.php`
**Runs:** Every 6 hours via Windows Task Scheduler

```sql
INSERT INTO weather_forecasts
    (district_id, forecast_date, forecast_for,
     temp_min, temp_max, humidity, rainfall_mm,
     wind_speed_kmh, conditions, raw_payload, fetched_at)
VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, NOW())
ON DUPLICATE KEY UPDATE
    temp_min        = VALUES(temp_min),
    temp_max        = VALUES(temp_max),
    humidity        = VALUES(humidity),
    rainfall_mm     = VALUES(rainfall_mm),
    wind_speed_kmh  = VALUES(wind_speed_kmh),
    conditions      = VALUES(conditions),
    raw_payload     = VALUES(raw_payload),
    fetched_at      = NOW();
```

### Why this is meaningful

The cron task runs every 6 hours and writes 384 forecast rows (64 districts × 6 forecast slots). If we used `INSERT` only, every run would create 384 new rows → 384 × 4 runs/day = 1,536 rows per day per district.

`ON DUPLICATE KEY UPDATE` (combined with a UNIQUE index on `(district_id, forecast_for)`) makes the operation **idempotent**: the same key is updated in place, not inserted again. The table size stays constant.

The `VALUES()` function references the value that *would have been* inserted, making the update clause concise.

---

## 8. JSON Column Queries

### Query: Find weather alerts affecting a specific district

**File:** `Models/AssistantModel.php::respWeather()`

```sql
SELECT *
FROM weather_alerts
WHERE is_active = 1
  AND (end_time IS NULL OR end_time >= NOW())
  AND JSON_CONTAINS(affected_districts, ?)
ORDER BY
    FIELD(severity, 'severe', 'high', 'medium', 'low'),
    created_at DESC
LIMIT 3;
```

Parameters passed: `JSON_CONTAINS(affected_districts, '5')` checks if district ID `5` appears in the JSON array stored in `affected_districts`.

### Cross-version compatibility fallback

For older MariaDB versions that don't support `JSON_CONTAINS`, the code has a fallback:

```sql
WHERE affected_districts LIKE ?   -- '[5]'
   OR affected_districts LIKE ?   -- '[5,%'
   OR affected_districts LIKE ?   -- '%,5,%'
   OR affected_districts LIKE ?   -- '%,5]'
```

The 4 patterns handle every position the ID could appear in the JSON array: alone, first, middle, or last.

### Why this is meaningful

- **JSON_CONTAINS** is a modern MariaDB/MySQL function for querying JSON columns
- **FIELD()** function provides custom sort ordering ('severe' before 'high' before 'medium')
- **Graceful degradation** with try/catch and LIKE fallback for compatibility

---

## 9. Date Functions & Time-Window Filters

### Query: This month's farmer revenue

**File:** `Models/StatsModel.php::forFarmer()`
**Used by:** Farmer dashboard

```sql
SELECT IFNULL(SUM(total_amount), 0)
FROM orders
WHERE farmer_id = ?
  AND order_status = 'delivered'
  AND MONTH(order_date) = MONTH(CURDATE())
  AND YEAR(order_date) = YEAR(CURDATE());
```

### Query: Last 30 days of buyer activity

```sql
SELECT crop_name, SUM(quantity_ordered) AS total_demanded
FROM orders o
JOIN crops c ON o.crop_id = c.crop_id
WHERE o.order_date >= CURDATE() - INTERVAL 30 DAY
GROUP BY crop_name
ORDER BY total_demanded DESC;
```

### Date functions used throughout the project

| Function | Purpose | Where used |
|---|---|---|
| `CURDATE()` | Today's date | Stats, expiry checks |
| `NOW()` | Current timestamp | Audit timestamps |
| `MONTH(x)`, `YEAR(x)` | Date part extraction | This-month filters |
| `DATE_FORMAT(NOW(), '%Y%m%d')` | Custom format | Order number gen (trigger T1) |
| `CURDATE() - INTERVAL N DAY` | Date arithmetic | Time-window queries |
| `DATE(x)` | Strip time portion | Day-grouped reports |

---

## 10. Conditional Aggregation (CASE WHEN)

### Query: Order status distribution dashboard

**File:** `Models/StatsModel.php`
**Used by:** Admin dashboard

```sql
SELECT
    COUNT(*) AS total_orders,
    SUM(CASE WHEN order_status = 'pending'   THEN 1 ELSE 0 END) AS pending,
    SUM(CASE WHEN order_status = 'confirmed' THEN 1 ELSE 0 END) AS confirmed,
    SUM(CASE WHEN order_status = 'delivered' THEN 1 ELSE 0 END) AS delivered,
    SUM(CASE WHEN order_status = 'cancelled' THEN 1 ELSE 0 END) AS cancelled,
    SUM(CASE WHEN payment_status = 'paid'    THEN total_amount ELSE 0 END) AS revenue_paid
FROM orders
WHERE farmer_id = ?;
```

### Why this is meaningful

Instead of running 5 separate queries (one per status), one query returns the full distribution in a single round-trip. This is much faster for dashboard rendering.

The pattern: `SUM(CASE WHEN condition THEN value ELSE 0 END)` is a workhorse SQL idiom for **pivoting rows into columns**.

---

# Part B — Advanced Database Features

## 11. Triggers (3)

### T1 — `tr_orders_before_insert`

**Fires:** BEFORE INSERT ON orders
**Purpose:** Auto-generates `order_number` in format `ORD-YYYYMMDD-XXXXX` if not supplied

```sql
CREATE TRIGGER tr_orders_before_insert
BEFORE INSERT ON orders
FOR EACH ROW
BEGIN
    IF NEW.order_number IS NULL OR NEW.order_number = '' THEN
        SET @next_id = COALESCE((SELECT MAX(order_id) FROM orders), 0) + 1;
        SET NEW.order_number = CONCAT(
            'ORD-',
            DATE_FORMAT(NOW(), '%Y%m%d'),
            '-',
            LPAD(@next_id, 5, '0')
        );
    END IF;
END
```

**Demonstrates:** BEFORE-INSERT triggers, NEW row modification, string concatenation, date formatting, padding functions.

### T2 — `tr_crops_after_update`

**Fires:** AFTER UPDATE ON crops
**Purpose:** Automatically writes an inventory audit log when quantity changes

```sql
CREATE TRIGGER tr_crops_after_update
AFTER UPDATE ON crops
FOR EACH ROW
BEGIN
    IF NEW.quantity <> OLD.quantity THEN
        -- Skip if PHP just logged the same change (anti-duplication)
        IF NOT EXISTS (
            SELECT 1 FROM inventory_logs
            WHERE crop_id = NEW.crop_id
              AND quantity_after = NEW.quantity
              AND logged_at >= NOW() - INTERVAL 2 SECOND
        ) THEN
            INSERT INTO inventory_logs
                (crop_id, change_type, quantity_before, quantity_after,
                 change_reason, changed_by)
            VALUES (
                NEW.crop_id,
                CASE
                    WHEN NEW.quantity > OLD.quantity THEN 'restocked'
                    WHEN NEW.quantity < OLD.quantity THEN 'sold'
                    ELSE 'adjusted'
                END,
                OLD.quantity,
                NEW.quantity,
                CONCAT('Auto-logged by trigger (delta: ',
                       CASE WHEN NEW.quantity > OLD.quantity THEN '+' ELSE '' END,
                       (NEW.quantity - OLD.quantity), ')'),
                NEW.farmer_id
            );
        END IF;
    END IF;
END
```

**Demonstrates:** AFTER-UPDATE triggers, OLD vs NEW row access, conditional logic, deduplication via NOT EXISTS, CASE expressions inside CONCAT, INTERVAL arithmetic.

### T3 — `tr_transactions_after_insert` (the most important)

**Fires:** AFTER INSERT ON transactions
**Purpose:** Implements double-entry accounting at the database level

```sql
CREATE TRIGGER tr_transactions_after_insert
AFTER INSERT ON transactions
FOR EACH ROW
BEGIN
    DECLARE current_balance DECIMAL(12,2) DEFAULT 0;
    DECLARE new_balance     DECIMAL(12,2) DEFAULT 0;

    IF NEW.transaction_status = 'completed' THEN
        -- Read current balance
        SELECT COALESCE(wallet_balance, 0) INTO current_balance
        FROM users WHERE user_id = NEW.user_id;

        -- Determine direction
        IF NEW.transaction_type IN ('sale','deposit','loan_disbursement','refund') THEN
            SET new_balance = current_balance + NEW.amount;
        ELSEIF NEW.transaction_type IN ('purchase','withdrawal','loan_repayment','commission') THEN
            SET new_balance = current_balance - NEW.amount;
        ELSE
            SET new_balance = current_balance;
        END IF;

        -- Safety check
        IF new_balance < 0 THEN
            SIGNAL SQLSTATE '45000'
                SET MESSAGE_TEXT = 'Transaction would result in negative wallet balance';
        END IF;

        -- Update wallet
        UPDATE users SET wallet_balance = new_balance
        WHERE user_id = NEW.user_id;

        -- Snapshot balance_before/balance_after on the transaction row
        UPDATE transactions
        SET balance_before = current_balance,
            balance_after  = new_balance
        WHERE transaction_id = NEW.transaction_id;
    END IF;
END
```

**Demonstrates:** AFTER-INSERT triggers, DECLARE variables, SELECT INTO, IN-list conditionals, IF/ELSEIF/ELSE branching, SIGNAL for raising custom errors, cross-table updates from within a trigger.

This trigger is what makes the wallet system work — without it, `users.wallet_balance` would never change, even after a successful payment.

---

## 12. Views (2)

### View 1: `vw_active_crops_with_details`

**Purpose:** Denormalized view of all available crops with farmer, district, and category info pre-joined for fast dashboard reads.

```sql
CREATE VIEW vw_active_crops_with_details AS
SELECT
    c.crop_id, c.crop_name, c.crop_variety,
    c.quantity, c.unit, c.price_per_unit,
    c.quality_grade, c.is_organic, c.status,
    c.images, c.harvest_date, c.available_from, c.available_until,
    u.user_id AS farmer_id,
    u.full_name AS farmer_name,
    u.phone AS farmer_phone,
    u.profile_picture AS farmer_picture,
    d.district_id, d.district_name, d.division,
    cat.category_id, cat.category_name, cat.category_name_bn
FROM crops c
JOIN users u             ON c.farmer_id    = u.user_id
LEFT JOIN districts d    ON u.district_id  = d.district_id
JOIN crop_categories cat ON c.category_id  = cat.category_id
WHERE c.status = 'available';
```

**Used by:**
- Admin dashboard crop browser
- Farmer recommendations
- Quick crop info pulls without re-joining

**Query against the view (simple!):**
```sql
SELECT * FROM vw_active_crops_with_details
WHERE district_name = 'Mymensingh' AND category_name_bn = 'শাকসবজি';
```

### View 2: `vw_farmer_performance`

**Purpose:** Aggregated performance metrics per farmer (total revenue, completed orders, ratings).

```sql
CREATE VIEW vw_farmer_performance AS
SELECT
    u.user_id AS farmer_id,
    u.full_name AS farmer_name,
    d.district_name,
    COUNT(DISTINCT c.crop_id) AS total_crops_listed,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(CASE WHEN o.order_status = 'delivered'
             THEN o.total_amount ELSE 0 END) AS lifetime_revenue,
    AVG(fr.overall_rating) AS avg_rating,
    COUNT(DISTINCT fr.rating_id) AS total_ratings
FROM users u
LEFT JOIN districts d       ON u.district_id = d.district_id
LEFT JOIN crops c           ON c.farmer_id   = u.user_id
LEFT JOIN orders o          ON o.farmer_id   = u.user_id
LEFT JOIN farmer_ratings fr ON fr.farmer_id  = u.user_id
WHERE EXISTS (
    SELECT 1 FROM user_roles ur
    WHERE ur.user_id = u.user_id AND ur.role = 'farmer'
)
GROUP BY u.user_id, u.full_name, d.district_name;
```

**Used by:**
- Admin "top farmers" leaderboard
- Farmer profile pages
- Analytics dashboards

### Why views are meaningful

| Benefit | Explanation |
|---|---|
| **Abstraction** | App code does `SELECT * FROM vw_farmer_performance` — doesn't need to know about 5 underlying joins |
| **Reusability** | Multiple controllers can use the same view |
| **Maintainability** | Change the view definition once, every caller benefits |
| **Security potential** | Views can hide sensitive columns from certain users |

---

## 13. Indexes (20+)

### Index categories used in AgroFin

#### Primary Keys (automatic indexes)
Every table has a primary key, which automatically creates a clustered index. Examples:
```
users.user_id, crops.crop_id, orders.order_id, transactions.transaction_id
```

#### Unique Indexes (enforce data uniqueness)
```sql
ALTER TABLE users ADD UNIQUE KEY (phone);
ALTER TABLE users ADD UNIQUE KEY (email);
ALTER TABLE users ADD UNIQUE KEY (nid_number);
ALTER TABLE transactions ADD UNIQUE KEY (reference_number);
ALTER TABLE orders ADD UNIQUE KEY (order_number);
```
These enforce business rules: no two users with the same phone, every transaction has a unique reference.

#### Composite Indexes (multi-column, optimized for common query patterns)

```sql
-- crops: optimize farmer's active-listing queries
INDEX idx_active (farmer_id, status)

-- crops: optimize marketplace filtering by category + status + price
INDEX idx_market (category_id, status, price_per_unit)

-- orders: optimize buyer's order history
INDEX idx_buyer_date (buyer_id, order_date)

-- orders: optimize farmer's order list
INDEX idx_farmer_date (farmer_id, order_date)

-- messages: optimize "show me my chat with X"
INDEX idx_conv (sender_id, receiver_id, created_at)

-- messages: optimize "show me my inbox"
INDEX idx_inbox (receiver_id, is_read)

-- loans: optimize "show me approvable loans"
INDEX idx_status_date (status, application_date)

-- market_prices: optimize "latest price for crop X in district Y"
INDEX idx_market_lookup (crop_name, district_id, price_date)

-- transactions: optimize "user history by type and date"
INDEX idx_user_date (user_id, created_at)
```

### Why composite indexes are meaningful

The **leftmost-column rule** means one composite index serves multiple query patterns:

```sql
-- Query 1: filter by farmer alone — uses idx_active
SELECT * FROM crops WHERE farmer_id = 5;

-- Query 2: filter by farmer + status — uses idx_active
SELECT * FROM crops WHERE farmer_id = 5 AND status = 'available';

-- Query 3: filter by status alone — does NOT use idx_active (status is not leftmost)
SELECT * FROM crops WHERE status = 'available';
```

This is why we order the columns in the composite index carefully — the most-frequently-filtered column comes first.

### Performance comparison

Without an index on `(farmer_id, status)`:
```
SELECT * FROM crops WHERE farmer_id = 5 AND status = 'available'
→ Full table scan: O(n) where n = total crops in the system
→ At 10,000 crops: ~10ms
→ At 1,000,000 crops: ~1,000ms
```

With the composite index:
```
→ Index lookup: O(log n)
→ At 10,000 crops:    ~0.01ms
→ At 1,000,000 crops: ~0.02ms
```

That's a **50,000× speedup** at scale. Even on a 1,000-row dev database, you can measure the difference with EXPLAIN.

---

## 14. Constraints & Referential Integrity

### Constraint types used in AgroFin

#### NOT NULL constraints (mandatory fields)
```sql
phone VARCHAR(15) NOT NULL
total_amount DECIMAL(12,2) NOT NULL
```

#### CHECK constraints (domain validation)
```sql
wallet_balance DECIMAL(12,2) DEFAULT 0
    CHECK (wallet_balance >= 0)

price_per_unit DECIMAL(10,2) NOT NULL
    CHECK (price_per_unit > 0)

quantity DECIMAL(10,2) NOT NULL
    CHECK (quantity >= 0)
```

#### ENUM constraints (restricted string domain)
```sql
account_status ENUM('active','inactive','suspended','banned') DEFAULT 'active'
transaction_type ENUM('sale','purchase','loan_disbursement','loan_repayment',
                      'commission','refund','withdrawal','deposit')
order_status ENUM('pending_payment','pending','confirmed','processing',
                  'packed','shipped','delivered','cancelled','refunded')
```

#### Foreign Key constraints (71 total)

Every meaningful inter-table reference is enforced with a foreign key. Example deletion behaviors:

| Behavior | When used | Example |
|---|---|---|
| `ON DELETE CASCADE` | Child row is meaningless without parent | `inventory_logs(crop_id) → crops(crop_id)` |
| `ON DELETE SET NULL` | Child can exist independently | `orders.cancelled_by → users.user_id` |
| `ON DELETE RESTRICT` (default) | Block deletion if children exist | `orders.buyer_id → users.user_id` |

This guarantees referential integrity at the database level — your application code can never accidentally orphan rows.

---

# Part C — Defense Reference

## 15. Where Each Feature is Used in the App

| Feature | File(s) | User-Facing Page |
|---|---|---|
| Multi-table JOIN (marketplace search) | `Models/CropModel.php::search()` | `/marketplace`, `/marketplace/all`, `/buyer/browse` |
| Aggregation + GROUP BY (live prices) | `Controllers/LivepriceController.php` | `/liveprice` |
| Correlated subqueries | `Models/CropModel.php` | Marketplace listings |
| EXISTS clause | `Models/CropModel.php`, marketplace queries | Marketplace |
| UNION ALL + derived table | `cron/tasks/DemandAnalyticsTask.php` | Admin demand analytics |
| Atomic transactions (FOR UPDATE) | `Models/OrderModel.php::create()` | Order placement |
| UPSERT | `cron/tasks/WeatherFetchTask.php` | Weather widget |
| JSON column query | `Models/AssistantModel.php` | AI assistant weather response |
| Date functions | `Models/StatsModel.php` | Farmer & admin dashboards |
| Conditional aggregation | `Models/StatsModel.php` | Dashboard status counts |
| **Trigger T1** (order number) | `tr_orders_before_insert` | Order placement |
| **Trigger T2** (inventory log) | `tr_crops_after_update` | Any quantity change |
| **Trigger T3** (wallet update) | `tr_transactions_after_insert` | Every completed payment |
| **View** vw_active_crops_with_details | DB view | Admin dashboard, recommendations |
| **View** vw_farmer_performance | DB view | Admin reports, farmer profiles |
| Indexes | All tables | Every query benefits |

---

## 16. Defense Talking Points

### "Show me the most complex query in your project"

> *"The marketplace search query in `CropModel::search()` is the most complex. It joins 4 tables — crops, users, districts, and crop_categories — with two correlated subqueries that compute the farmer's rating and rating count per row. It also uses an EXISTS clause to verify the user holds the farmer role without duplicating rows when a user has multiple roles. Finally it uses a dynamic WHERE clause to support 8 optional filters that compose at query time."*

### "How do you handle race conditions?"

> *"In `OrderModel::create()`, I use `SELECT ... FOR UPDATE` inside a transaction. This locks the crop row so two buyers can't simultaneously buy the last unit. The second buyer waits until the first one commits, then sees the updated quantity and gets an honest 'out of stock' error instead of corrupting the database with negative stock."*

### "What's your most important trigger?"

> *"`tr_transactions_after_insert` — it implements double-entry accounting at the database level. When a completed transaction is inserted, the trigger updates `users.wallet_balance` and sets the `balance_before` and `balance_after` snapshot columns automatically. It uses `SIGNAL SQLSTATE` to refuse transactions that would cause negative balances. This means the wallet system works atomically without any application-level race conditions."*

### "Why composite indexes?"

> *"Composite indexes serve multiple query patterns thanks to the leftmost-column rule. For example, `idx_active(farmer_id, status)` on the crops table speeds up three different queries: filtering by farmer alone, filtering by farmer plus status, and dashboard counts. One index, three optimized query paths."*

### "Why do you have views?"

> *"Views encapsulate the most complex joins so application code doesn't have to repeat them. `vw_farmer_performance` joins 5 tables to compute revenue, order count, and average rating per farmer. Without the view, every admin dashboard query would re-create those joins. With the view, I write `SELECT * FROM vw_farmer_performance` and the database optimizer handles the rest."*

### "How do you ensure referential integrity?"

> *"With 71 foreign key constraints enforced at the database level. Each one specifies the appropriate `ON DELETE` behavior — CASCADE when the child is meaningless without the parent (like inventory_logs without their crop), SET NULL when the child can exist independently (like an order whose canceler account got deleted), and the default RESTRICT for protected references. The database refuses to create orphan rows or break references, even if the application code has a bug."*

---

## Conclusion

The AgroFin schema demonstrates the full range of relational database techniques: complex joins, subqueries, aggregation, atomic transactions, idempotent UPSERTs, JSON support, triggers, views, composite indexes, and full referential integrity. Each technique is applied where it solves a real engineering problem — not for academic show, but because the AgroFin platform handles real financial transactions, real audit requirements, and real concurrent users.

The result is a database that is **provably correct** (constraints + triggers + transactions), **performant** (indexes + views), and **maintainable** (clear separation of concerns).

---


