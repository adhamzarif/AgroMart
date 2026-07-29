-- ═══════════════════════════════════════════════════════════════════
-- AgroFin Migration 002: CHECK Constraints
-- ═══════════════════════════════════════════════════════════════════
-- Adds database-level value validation that the schema previously
-- relied on the application layer to enforce.
--
-- Requires MariaDB 10.2.1+ or MySQL 8.0+ (enforced; parsed but not
-- enforced on MySQL 5.7).
-- ═══════════════════════════════════════════════════════════════════

USE agrofin;

-- ─── CROPS — positive quantities and prices ──────────────────────────
ALTER TABLE crops
    ADD CONSTRAINT chk_crops_qty_nonneg     CHECK (quantity >= 0),
    ADD CONSTRAINT chk_crops_price_positive CHECK (price_per_unit > 0);

-- ─── ORDERS — using actual schema column names ───────────────────────
ALTER TABLE orders
    ADD CONSTRAINT chk_orders_qty_positive   CHECK (quantity_ordered > 0),
    ADD CONSTRAINT chk_orders_price_positive CHECK (unit_price > 0),
    ADD CONSTRAINT chk_orders_total_positive CHECK (total_amount > 0),
    ADD CONSTRAINT chk_orders_delivery_nonneg CHECK (delivery_charge >= 0);

-- ─── LOANS — sensible bounds ─────────────────────────────────────────
ALTER TABLE loans
    ADD CONSTRAINT chk_loans_amount       CHECK (loan_amount BETWEEN 1000 AND 1000000),
    ADD CONSTRAINT chk_loans_interest     CHECK (interest_rate BETWEEN 0 AND 30),
    ADD CONSTRAINT chk_loans_tenure       CHECK (tenure_months BETWEEN 1 AND 60),
    ADD CONSTRAINT chk_loans_paid_nonneg  CHECK (amount_paid >= 0),
    ADD CONSTRAINT chk_loans_balance_okay CHECK (remaining_balance >= 0);

-- ─── LOAN REPAYMENTS — positive payments only ────────────────────────
ALTER TABLE loan_repayments
    ADD CONSTRAINT chk_repayment_positive CHECK (payment_amount > 0);

-- ─── EXPENSES — must be positive ─────────────────────────────────────
ALTER TABLE expenses
    ADD CONSTRAINT chk_expense_positive CHECK (expense_amount > 0);

-- ─── FARMER RATINGS — 1-5 scale on each of 4 dimensions ──────────────
ALTER TABLE farmer_ratings
    ADD CONSTRAINT chk_rating_overall  CHECK (overall_rating BETWEEN 1 AND 5),
    ADD CONSTRAINT chk_rating_quality  CHECK (quality_rating BETWEEN 1 AND 5),
    ADD CONSTRAINT chk_rating_delivery CHECK (delivery_rating BETWEEN 1 AND 5),
    ADD CONSTRAINT chk_rating_comm     CHECK (communication_rating BETWEEN 1 AND 5);

-- ─── MARKET PRICES — positive and retail >= wholesale ────────────────
ALTER TABLE market_prices
    ADD CONSTRAINT chk_price_wholesale_pos CHECK (wholesale_price > 0),
    ADD CONSTRAINT chk_price_retail_pos    CHECK (retail_price > 0),
    ADD CONSTRAINT chk_price_retail_gt_ws  CHECK (retail_price >= wholesale_price);

-- ─── TRANSPORT PARTNERS — rates and ratings ──────────────────────────
ALTER TABLE transport_partners
    ADD CONSTRAINT chk_transport_rate      CHECK (base_rate_per_km > 0),
    ADD CONSTRAINT chk_transport_mincharge CHECK (min_charge >= 0),
    ADD CONSTRAINT chk_transport_rating    CHECK (rating BETWEEN 0 AND 5);

-- ─── FARMER GROUPS — counters cannot go negative ─────────────────────
ALTER TABLE farmer_groups
    ADD CONSTRAINT chk_group_members_nonneg CHECK (total_members >= 0),
    ADD CONSTRAINT chk_group_land_nonneg    CHECK (total_land_acres >= 0);

-- ─── GROUP MEMBERS — land contribution ───────────────────────────────
ALTER TABLE group_members
    ADD CONSTRAINT chk_member_land CHECK (land_contribution_acres >= 0);

-- ─── AGENTS — counters and rate ──────────────────────────────────────
ALTER TABLE agents
    ADD CONSTRAINT chk_agent_commission_rate CHECK (commission_rate BETWEEN 0 AND 50),
    ADD CONSTRAINT chk_agent_farmers_nonneg  CHECK (total_farmers_assigned >= 0),
    ADD CONSTRAINT chk_agent_earnings_nonneg CHECK (total_commission_earned >= 0);

-- ─── SUBSCRIPTIONS — quantity > 0 ────────────────────────────────────
ALTER TABLE subscriptions
    ADD CONSTRAINT chk_sub_quantity CHECK (quantity_per_delivery > 0),
    ADD CONSTRAINT chk_sub_price    CHECK (price_locked > 0);

-- ─── INVENTORY LOGS — quantity_after >= 0 ────────────────────────────
ALTER TABLE inventory_logs
    ADD CONSTRAINT chk_inv_qty_after CHECK (quantity_after >= 0);

-- ─── DELIVERIES — distance and charge non-negative ───────────────────
ALTER TABLE deliveries
    ADD CONSTRAINT chk_delivery_distance CHECK (distance_km >= 0),
    ADD CONSTRAINT chk_delivery_charge   CHECK (delivery_charge >= 0);

-- ─── TRANSACTIONS — amounts must be positive ─────────────────────────
ALTER TABLE transactions
    ADD CONSTRAINT chk_tx_amount CHECK (amount > 0);

SELECT 'Migration 002 complete. CHECK constraints active where supported.' AS msg;
