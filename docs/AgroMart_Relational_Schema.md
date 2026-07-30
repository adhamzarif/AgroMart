# AgroFin — Relational Database Schema

> *Complete relational schema for the AgroFin Agricultural Marketplace & Microfinance platform.*  

> *Database engine: MariaDB 10+ (XAMPP) · Tables: 39 · Foreign Keys: 71 · Triggers: 3 · Views: 2*


---

## 📑 Table of Contents

- [Identity & Access](#identity-and-access)
- [Geography](#geography)
- [Marketplace — Crops](#marketplace-crops)
- [Marketplace — Orders](#marketplace-orders)
- [Financial — Payments](#financial-payments)
- [Financial — Loans](#financial-loans)
- [Financial — Other](#financial-other)
- [Intelligence](#intelligence)
- [Communication](#communication)
- [Community](#community)
- [System & Operations](#system-and-operations)
- [All Foreign Key Relationships](#all-foreign-key-relationships)
- [Triggers](#triggers)
- [Views](#views)
- [Notation Legend](#notation-legend)

---

## Notation Legend

| Symbol | Meaning |
|---|---|
| 🔑 **PK** | Primary key |
| 🔗 → `table.col` | Foreign key referencing another table |
| **UNIQUE** | Has a UNIQUE constraint |
| **AUTO_INCR** | Auto-incrementing column |
| **NOT NULL** | Column cannot be NULL |
| **ON UPDATE** | Auto-updates timestamp on row change |
| ENUM(…) | Restricted set of allowed string values |

---


## Identity & Access
*User accounts, roles, OTP verification, and agent infrastructure*

### `users`

| Column | Type | Notes |
|---|---|---|
| `user_id` | `INT` | 🔑 PK; NOT NULL |
| `full_name` | `VARCHAR(100)` | NOT NULL |
| `phone` | `VARCHAR(15)` | NOT NULL; UNIQUE |
| `email` | `VARCHAR(100)` | default NULL; UNIQUE |
| `password_hash` | `VARCHAR(255)` | NOT NULL |
| `nid_number` | `VARCHAR(17)` | default NULL; UNIQUE |
| `district_id` | `INT` | 🔗 → `districts.district_id`; NOT NULL |
| `address` | `TEXT` | default NULL |
| `profile_picture` | `VARCHAR(255)` | default NULL |
| `account_status` | `ENUM('active','inactive','suspended','banned')` | default 'active' |
| `phone_verified` | `TINYINT` | default 0 |
| `otp_verified_at` | `TIMESTAMP` | default NULL |
| `email_verified` | `TINYINT` | default 0 |
| `nid_verified` | `TINYINT` | default 0 |
| `wallet_balance` | `DECIMAL(12,2)` | default 0.00 |
| `preferred_language` | `ENUM('bn','en')` | default 'bn' |
| `last_login` | `TIMESTAMP` | default NULL |
| `last_seen_at` | `TIMESTAMP` | default NULL |
| `created_at` | `TIMESTAMP` | NOT NULL; default current_timestamp() |
| `updated_at` | `TIMESTAMP` | NOT NULL; default current_timestamp(); ON UPDATE |

**References:** `districts.district_id` (via `district_id`)

### `user_roles`

| Column | Type | Notes |
|---|---|---|
| `user_id` | `INT` | 🔗 → `users.user_id`; NOT NULL |
| `role` | `ENUM('farmer','buyer','agent','admin')` | NOT NULL |
| `assigned_at` | `TIMESTAMP` | NOT NULL; default current_timestamp() |

**References:** `users.user_id` (via `user_id`)

### `otp_codes`

| Column | Type | Notes |
|---|---|---|
| `otp_id` | `INT` | 🔑 PK; NOT NULL |
| `phone` | `VARCHAR(15)` | NOT NULL |
| `code_hash` | `VARCHAR(255)` | NOT NULL |
| `purpose` | `ENUM('register','login','reset_password','verify_phone','two_factor')` | NOT NULL |
| `expires_at` | `TIMESTAMP` | NOT NULL; default current_timestamp(); ON UPDATE |
| `attempts` | `TINYINT` | NOT NULL; default 0 |
| `max_attempts` | `TINYINT` | NOT NULL; default 5 |
| `verified_at` | `TIMESTAMP` | default NULL |
| `request_ip` | `VARCHAR(45)` | default NULL |
| `sent_via` | `ENUM('sms','log','email')` | NOT NULL; default 'log' |
| `provider_response` | `TEXT` | default NULL |
| `created_at` | `TIMESTAMP` | NOT NULL; default current_timestamp() |

### `agents`

| Column | Type | Notes |
|---|---|---|
| `agent_id` | `INT` | 🔑 PK; NOT NULL |
| `user_id` | `INT` | 🔗 → `users.user_id`; NOT NULL; UNIQUE |
| `agent_code` | `VARCHAR(20)` | NOT NULL; UNIQUE |
| `service_districts` | `LONGTEXT` | NOT NULL |
| `vehicle_type` | `ENUM('motorcycle','bicycle','none')` | default 'none' |
| `commission_rate` | `DECIMAL(5,2)` | default 2.00 |
| `training_completed` | `TINYINT` | default 0 |
| `training_completion_date` | `DATE` | default NULL |
| `agent_rating` | `DECIMAL(3,2)` | default 0.00 |
| `total_farmers_assigned` | `INT` | default 0 |
| `total_commission_earned` | `DECIMAL(12,2)` | default 0.00 |
| `bank_account_number` | `VARCHAR(50)` | default NULL |
| `bank_name` | `VARCHAR(100)` | default NULL |
| `status` | `ENUM('active','inactive','suspended')` | default 'active' |
| `created_at` | `TIMESTAMP` | NOT NULL; default current_timestamp() |
| `updated_at` | `TIMESTAMP` | NOT NULL; default current_timestamp(); ON UPDATE |

**References:** `users.user_id` (via `user_id`)

### `agent_activities`

| Column | Type | Notes |
|---|---|---|
| `activity_id` | `INT` | 🔑 PK; NOT NULL |
| `agent_id` | `INT` | 🔗 → `agents.agent_id`; NOT NULL |
| `farmer_id` | `INT` | 🔗 → `users.user_id`; default NULL |
| `activity_type` | `ENUM('farmer_registration','crop_listing','order_help','loan_assistance','message_help','training_session','field_visit','other')` | NOT NULL |
| `description` | `TEXT` | default NULL |
| `commission_earned` | `DECIMAL(10,2)` | default 0.00 |
| `activity_date` | `TIMESTAMP` | NOT NULL; default current_timestamp() |

**References:** `agents.agent_id` (via `agent_id`), `users.user_id` (via `farmer_id`)

### `agent_farmer_mapping`

| Column | Type | Notes |
|---|---|---|
| `mapping_id` | `INT` | 🔑 PK; NOT NULL |
| `agent_id` | `INT` | 🔗 → `agents.agent_id`; NOT NULL |
| `farmer_id` | `INT` | 🔗 → `users.user_id`; NOT NULL |
| `assigned_date` | `TIMESTAMP` | NOT NULL; default current_timestamp() |
| `help_count` | `INT` | default 0 |
| `last_interaction` | `TIMESTAMP` | default NULL |
| `status` | `ENUM('active','inactive')` | default 'active' |

**References:** `agents.agent_id` (via `agent_id`), `users.user_id` (via `farmer_id`)


## Geography
*Bangladesh districts (administrative reference data)*

### `districts`

| Column | Type | Notes |
|---|---|---|
| `district_id` | `INT` | 🔑 PK; NOT NULL |
| `district_name` | `VARCHAR(50)` | NOT NULL; UNIQUE |
| `division` | `ENUM('dhaka','chittagong','rajshahi','khulna','barishal','sylhet','rangpur','mymensingh')` | NOT NULL |
| `latitude` | `DECIMAL(9,6)` | default NULL |
| `longitude` | `DECIMAL(9,6)` | default NULL |
| `created_at` | `TIMESTAMP` | NOT NULL; default current_timestamp() |


## Marketplace — Crops
*Crop listings, categories, inventory tracking, ratings, favorites*

### `crop_categories`

| Column | Type | Notes |
|---|---|---|
| `category_id` | `INT` | 🔑 PK; NOT NULL |
| `category_name` | `VARCHAR(50)` | NOT NULL; UNIQUE |
| `category_name_bn` | `VARCHAR(50)` | NOT NULL; UNIQUE |
| `parent_category_id` | `INT` | 🔗 → `crop_categories.category_id`; default NULL |
| `description` | `TEXT` | default NULL |
| `icon` | `VARCHAR(100)` | default NULL |
| `created_at` | `TIMESTAMP` | NOT NULL; default current_timestamp() |

**References:** `crop_categories.category_id` (via `parent_category_id`)

### `crops`

| Column | Type | Notes |
|---|---|---|
| `crop_id` | `INT` | 🔑 PK; NOT NULL |
| `farmer_id` | `INT` | 🔗 → `users.user_id`; NOT NULL |
| `category_id` | `INT` | 🔗 → `crop_categories.category_id`; NOT NULL |
| `crop_name` | `VARCHAR(100)` | NOT NULL |
| `crop_variety` | `VARCHAR(100)` | default NULL |
| `quantity` | `DECIMAL(10,2)` | NOT NULL |
| `unit` | `ENUM('kg','ton','mon','piece')` | NOT NULL |
| `price_per_unit` | `DECIMAL(10,2)` | NOT NULL |
| `quality_grade` | `ENUM('a','b','c')` | default 'B' |
| `is_organic` | `TINYINT` | default 0 |
| `harvest_date` | `DATE` | default NULL |
| `available_from` | `DATE` | NOT NULL |
| `available_until` | `DATE` | default NULL |
| `description` | `TEXT` | default NULL |
| `images` | `LONGTEXT` | default NULL |
| `status` | `ENUM('available','sold','expired','removed')` | default 'available' |
| `views_count` | `INT` | default 0 |
| `listed_by_agent` | `TINYINT` | default 0 |
| `agent_id` | `INT` | 🔗 → `agents.agent_id`; default NULL |
| `created_at` | `TIMESTAMP` | NOT NULL; default current_timestamp() |
| `updated_at` | `TIMESTAMP` | NOT NULL; default current_timestamp(); ON UPDATE |

**References:** `users.user_id` (via `farmer_id`), `crop_categories.category_id` (via `category_id`), `agents.agent_id` (via `agent_id`)

### `inventory_logs`

| Column | Type | Notes |
|---|---|---|
| `log_id` | `INT` | 🔑 PK; NOT NULL |
| `crop_id` | `INT` | 🔗 → `crops.crop_id`; NOT NULL |
| `change_type` | `ENUM('listed','sold','adjusted','expired','restocked')` | NOT NULL |
| `quantity_before` | `DECIMAL(10,2)` | NOT NULL |
| `quantity_after` | `DECIMAL(10,2)` | NOT NULL |
| `change_reason` | `VARCHAR(255)` | default NULL |
| `changed_by` | `INT` | 🔗 → `users.user_id`; default NULL |
| `logged_at` | `TIMESTAMP` | NOT NULL; default current_timestamp() |

**References:** `crops.crop_id` (via `crop_id`), `users.user_id` (via `changed_by`)

### `favorites`

| Column | Type | Notes |
|---|---|---|
| `favorite_id` | `INT` | 🔑 PK; NOT NULL |
| `user_id` | `INT` | 🔗 → `users.user_id`; NOT NULL |
| `favorite_type` | `ENUM('crop','farmer')` | NOT NULL |
| `crop_id` | `INT` | 🔗 → `crops.crop_id`; default NULL |
| `farmer_id` | `INT` | 🔗 → `users.user_id`; default NULL |
| `price_alert_enabled` | `TINYINT` | default 0 |
| `alert_price_threshold` | `DECIMAL(10,2)` | default NULL |
| `created_at` | `TIMESTAMP` | NOT NULL; default current_timestamp() |

**References:** `users.user_id` (via `user_id`), `crops.crop_id` (via `crop_id`), `users.user_id` (via `farmer_id`)

### `farmer_ratings`

| Column | Type | Notes |
|---|---|---|
| `rating_id` | `INT` | 🔑 PK; NOT NULL |
| `farmer_id` | `INT` | 🔗 → `users.user_id`; NOT NULL |
| `buyer_id` | `INT` | 🔗 → `users.user_id`; NOT NULL |
| `order_id` | `INT` | 🔗 → `orders.order_id`; NOT NULL |
| `overall_rating` | `DECIMAL(2,1)` | NOT NULL |
| `quality_rating` | `DECIMAL(2,1)` | NOT NULL |
| `delivery_rating` | `DECIMAL(2,1)` | NOT NULL |
| `communication_rating` | `DECIMAL(2,1)` | NOT NULL |
| `review_title` | `VARCHAR(100)` | default NULL |
| `review_text` | `TEXT` | default NULL |
| `review_images` | `LONGTEXT` | default NULL |
| `would_recommend` | `TINYINT` | default 1 |
| `is_verified_purchase` | `TINYINT` | default 1 |
| `helpful_count` | `INT` | default 0 |
| `farmer_response` | `TEXT` | default NULL |
| `responded_at` | `TIMESTAMP` | default NULL |
| `is_flagged` | `TINYINT` | default 0 |
| `created_at` | `TIMESTAMP` | NOT NULL; default current_timestamp() |

**References:** `users.user_id` (via `farmer_id`), `users.user_id` (via `buyer_id`), `orders.order_id` (via `order_id`)


## Marketplace — Orders
*Order lifecycle, delivery, and logistics*

### `orders`

| Column | Type | Notes |
|---|---|---|
| `order_id` | `INT` | 🔑 PK; NOT NULL |
| `order_number` | `VARCHAR(30)` | NOT NULL; UNIQUE |
| `buyer_id` | `INT` | 🔗 → `users.user_id`; NOT NULL |
| `farmer_id` | `INT` | 🔗 → `users.user_id`; NOT NULL |
| `crop_id` | `INT` | 🔗 → `crops.crop_id`; NOT NULL |
| `quantity_ordered` | `DECIMAL(10,2)` | NOT NULL |
| `unit_price` | `DECIMAL(10,2)` | NOT NULL |
| `subtotal` | `DECIMAL(12,2)` | NOT NULL |
| `delivery_charge` | `DECIMAL(8,2)` | default 0.00 |
| `total_amount` | `DECIMAL(12,2)` | NOT NULL |
| `order_status` | `ENUM('pending_payment','pending','confirmed','processing','packed','shipped','delivered','cancelled','refunded')` | default 'pending' |
| `payment_status` | `ENUM('pending','paid','failed','refunded')` | default 'pending' |
| `payment_gateway` | `VARCHAR(30)` | default NULL |
| `payment_id` | `INT` | default NULL |
| `delivery_type` | `ENUM('home_delivery','self_pickup')` | default 'home_delivery' |
| `delivery_address` | `TEXT` | default NULL |
| `delivery_district_id` | `INT` | 🔗 → `districts.district_id`; default NULL |
| `preferred_delivery_date` | `DATE` | default NULL |
| `special_instructions` | `TEXT` | default NULL |
| `cancellation_reason` | `VARCHAR(255)` | default NULL |
| `cancelled_by` | `INT` | 🔗 → `users.user_id`; default NULL |
| `order_date` | `TIMESTAMP` | NOT NULL; default current_timestamp() |
| `confirmed_at` | `TIMESTAMP` | default NULL |
| `delivered_at` | `TIMESTAMP` | default NULL |
| `updated_at` | `TIMESTAMP` | NOT NULL; default current_timestamp(); ON UPDATE |

**References:** `users.user_id` (via `buyer_id`), `users.user_id` (via `farmer_id`), `crops.crop_id` (via `crop_id`), `districts.district_id` (via `delivery_district_id`), `users.user_id` (via `cancelled_by`)

### `deliveries`

| Column | Type | Notes |
|---|---|---|
| `delivery_id` | `INT` | 🔑 PK; NOT NULL |
| `order_id` | `INT` | 🔗 → `orders.order_id`; NOT NULL; UNIQUE |
| `transport_partner_id` | `INT` | 🔗 → `transport_partners.partner_id`; default NULL |
| `vehicle_type` | `ENUM('pickup','truck','van','motorcycle')` | NOT NULL |
| `vehicle_number` | `VARCHAR(20)` | default NULL |
| `driver_name` | `VARCHAR(100)` | default NULL |
| `driver_phone` | `VARCHAR(15)` | default NULL |
| `pickup_address` | `TEXT` | NOT NULL |
| `delivery_address` | `TEXT` | NOT NULL |
| `distance_km` | `DECIMAL(6,2)` | default NULL |
| `delivery_charge` | `DECIMAL(8,2)` | NOT NULL |
| `pickup_time` | `TIMESTAMP` | default NULL |
| `estimated_delivery_time` | `TIMESTAMP` | default NULL |
| `actual_delivery_time` | `TIMESTAMP` | default NULL |
| `current_location` | `LONGTEXT` | default NULL |
| `delivery_status` | `ENUM('pending','picked_up','in_transit','out_for_delivery','delivered','failed')` | default 'pending' |
| `delivery_proof_url` | `VARCHAR(255)` | default NULL |
| `receiver_signature_url` | `VARCHAR(255)` | default NULL |
| `delivery_notes` | `TEXT` | default NULL |
| `delivery_rating` | `DECIMAL(2,1)` | default NULL |
| `created_at` | `TIMESTAMP` | NOT NULL; default current_timestamp() |
| `updated_at` | `TIMESTAMP` | NOT NULL; default current_timestamp(); ON UPDATE |

**References:** `orders.order_id` (via `order_id`), `transport_partners.partner_id` (via `transport_partner_id`)

### `transport_partners`

| Column | Type | Notes |
|---|---|---|
| `partner_id` | `INT` | 🔑 PK; NOT NULL |
| `partner_name` | `VARCHAR(100)` | NOT NULL; UNIQUE |
| `contact_person` | `VARCHAR(100)` | default NULL |
| `contact_phone` | `VARCHAR(15)` | NOT NULL; UNIQUE |
| `contact_email` | `VARCHAR(100)` | default NULL |
| `service_districts` | `LONGTEXT` | NOT NULL |
| `vehicle_types` | `LONGTEXT` | NOT NULL |
| `base_rate_per_km` | `DECIMAL(6,2)` | NOT NULL |
| `min_charge` | `DECIMAL(8,2)` | NOT NULL |
| `rating` | `DECIMAL(3,2)` | default 0.00 |
| `total_deliveries` | `INT` | default 0 |
| `is_active` | `TINYINT` | default 1 |
| `created_at` | `TIMESTAMP` | NOT NULL; default current_timestamp() |
| `updated_at` | `TIMESTAMP` | NOT NULL; default current_timestamp(); ON UPDATE |


## Financial — Payments
*Payment gateway integration and universal transaction ledger*

### `payments`

| Column | Type | Notes |
|---|---|---|
| `payment_id` | `INT` | 🔑 PK; NOT NULL |
| `payment_reference` | `VARCHAR(50)` | NOT NULL; UNIQUE |
| `order_id` | `INT` | 🔗 → `orders.order_id`; default NULL |
| `subscription_id` | `INT` | 🔗 → `subscriptions.subscription_id`; default NULL |
| `user_id` | `INT` | 🔗 → `users.user_id`; NOT NULL |
| `gateway` | `ENUM('sslcommerz','bkash','nagad','rocket','mock','cod')` | NOT NULL |
| `gateway_transaction_id` | `VARCHAR(100)` | default NULL |
| `gateway_session_key` | `VARCHAR(255)` | default NULL |
| `amount` | `DECIMAL(12,2)` | NOT NULL |
| `currency` | `CHAR(3)` | default 'BDT' |
| `status` | `ENUM('initiated','pending','success','failed','cancelled','refunded')` | NOT NULL; default 'initiated' |
| `failure_reason` | `VARCHAR(255)` | default NULL |
| `raw_request` | `LONGTEXT` | default NULL |
| `raw_response` | `LONGTEXT` | default NULL |
| `ipn_payload` | `LONGTEXT` | default NULL |
| `initiated_at` | `TIMESTAMP` | NOT NULL; default current_timestamp() |
| `completed_at` | `TIMESTAMP` | default NULL |
| `refunded_at` | `TIMESTAMP` | default NULL |
| `refund_amount` | `DECIMAL(12,2)` | default 0.00 |
| `refund_reason` | `VARCHAR(255)` | default NULL |

**References:** `orders.order_id` (via `order_id`), `subscriptions.subscription_id` (via `subscription_id`), `users.user_id` (via `user_id`)

### `payment_methods`

| Column | Type | Notes |
|---|---|---|
| `method_id` | `INT` | 🔑 PK; NOT NULL |
| `user_id` | `INT` | 🔗 → `users.user_id`; NOT NULL |
| `method_type` | `ENUM('bkash','nagad','rocket','bank_transfer','wallet')` | NOT NULL |
| `account_number` | `VARCHAR(50)` | NOT NULL |
| `account_name` | `VARCHAR(100)` | default NULL |
| `bank_name` | `VARCHAR(100)` | default NULL |
| `is_default` | `TINYINT` | default 0 |
| `is_verified` | `TINYINT` | default 0 |
| `created_at` | `TIMESTAMP` | NOT NULL; default current_timestamp() |
| `updated_at` | `TIMESTAMP` | NOT NULL; default current_timestamp(); ON UPDATE |

**References:** `users.user_id` (via `user_id`)

### `transactions`

| Column | Type | Notes |
|---|---|---|
| `transaction_id` | `INT` | 🔑 PK; NOT NULL |
| `user_id` | `INT` | 🔗 → `users.user_id`; NOT NULL |
| `transaction_type` | `ENUM('sale','purchase','loan_disbursement','loan_repayment','commission','refund','withdrawal','deposit')` | NOT NULL |
| `amount` | `DECIMAL(12,2)` | NOT NULL |
| `currency` | `CHAR(3)` | default 'BDT' |
| `transaction_status` | `ENUM('pending','completed','failed','cancelled')` | default 'pending' |
| `payment_method_id` | `INT` | 🔗 → `payment_methods.method_id`; default NULL |
| `related_order_id` | `INT` | 🔗 → `orders.order_id`; default NULL |
| `related_loan_id` | `INT` | 🔗 → `loans.loan_id`; default NULL |
| `reference_number` | `VARCHAR(100)` | default NULL; UNIQUE |
| `description` | `VARCHAR(255)` | default NULL |
| `balance_before` | `DECIMAL(12,2)` | default NULL |
| `balance_after` | `DECIMAL(12,2)` | default NULL |
| `is_flagged` | `TINYINT` | default 0 |
| `created_at` | `TIMESTAMP` | NOT NULL; default current_timestamp() |
| `completed_at` | `TIMESTAMP` | default NULL |

**References:** `users.user_id` (via `user_id`), `payment_methods.method_id` (via `payment_method_id`), `orders.order_id` (via `related_order_id`), `loans.loan_id` (via `related_loan_id`)


## Financial — Loans
*Microloan applications, approvals, and repayments*

### `loans`

| Column | Type | Notes |
|---|---|---|
| `loan_id` | `INT` | 🔑 PK; NOT NULL |
| `farmer_id` | `INT` | 🔗 → `users.user_id`; NOT NULL |
| `loan_amount` | `DECIMAL(12,2)` | NOT NULL |
| `interest_rate` | `DECIMAL(5,2)` | default 5.00 |
| `loan_purpose` | `VARCHAR(255)` | NOT NULL |
| `tenure_months` | `INT` | NOT NULL |
| `monthly_installment` | `DECIMAL(10,2)` | NOT NULL |
| `total_payable` | `DECIMAL(12,2)` | NOT NULL |
| `amount_paid` | `DECIMAL(12,2)` | default 0.00 |
| `remaining_balance` | `DECIMAL(12,2)` | NOT NULL |
| `credit_score_at_application` | `INT` | default NULL |
| `application_date` | `TIMESTAMP` | NOT NULL; default current_timestamp() |
| `approval_date` | `TIMESTAMP` | default NULL |
| `disbursement_date` | `TIMESTAMP` | default NULL |
| `next_payment_date` | `DATE` | default NULL |
| `status` | `ENUM('pending','approved','rejected','disbursed','active','completed','defaulted')` | default 'pending' |
| `approved_by` | `INT` | 🔗 → `users.user_id`; default NULL |
| `rejection_reason` | `VARCHAR(255)` | default NULL |
| `assisted_by_agent` | `TINYINT` | default 0 |
| `agent_id` | `INT` | 🔗 → `agents.agent_id`; default NULL |
| `created_at` | `TIMESTAMP` | NOT NULL; default current_timestamp() |
| `updated_at` | `TIMESTAMP` | NOT NULL; default current_timestamp(); ON UPDATE |

**References:** `users.user_id` (via `farmer_id`), `users.user_id` (via `approved_by`), `agents.agent_id` (via `agent_id`)

### `loan_repayments`

| Column | Type | Notes |
|---|---|---|
| `repayment_id` | `INT` | 🔑 PK; NOT NULL |
| `loan_id` | `INT` | 🔗 → `loans.loan_id`; NOT NULL |
| `payment_amount` | `DECIMAL(10,2)` | NOT NULL |
| `payment_date` | `TIMESTAMP` | NOT NULL; default current_timestamp() |
| `payment_method` | `ENUM('auto_deduction','manual','cash','mobile_banking')` | default 'auto_deduction' |
| `transaction_reference` | `VARCHAR(100)` | default NULL |
| `late_fee` | `DECIMAL(8,2)` | default 0.00 |
| `is_early_payment` | `TINYINT` | default 0 |
| `remaining_after_payment` | `DECIMAL(12,2)` | NOT NULL |
| `recorded_by` | `INT` | 🔗 → `users.user_id`; default NULL |
| `created_at` | `TIMESTAMP` | NOT NULL; default current_timestamp() |

**References:** `loans.loan_id` (via `loan_id`), `users.user_id` (via `recorded_by`)


## Financial — Other
*Expense tracking and recurring subscriptions*

### `expenses`

| Column | Type | Notes |
|---|---|---|
| `expense_id` | `INT` | 🔑 PK; NOT NULL |
| `farmer_id` | `INT` | 🔗 → `users.user_id`; NOT NULL |
| `crop_id` | `INT` | 🔗 → `crops.crop_id`; default NULL |
| `expense_category` | `ENUM('seeds','fertilizer','pesticide','labor','irrigation','equipment','transport','other')` | NOT NULL |
| `expense_amount` | `DECIMAL(10,2)` | NOT NULL |
| `expense_description` | `VARCHAR(255)` | default NULL |
| `expense_date` | `DATE` | NOT NULL |
| `receipt_url` | `VARCHAR(255)` | default NULL |
| `created_at` | `TIMESTAMP` | NOT NULL; default current_timestamp() |

**References:** `users.user_id` (via `farmer_id`), `crops.crop_id` (via `crop_id`)

### `subscriptions`

| Column | Type | Notes |
|---|---|---|
| `subscription_id` | `INT` | 🔑 PK; NOT NULL |
| `buyer_id` | `INT` | 🔗 → `users.user_id`; NOT NULL |
| `farmer_id` | `INT` | 🔗 → `users.user_id`; NOT NULL |
| `crop_name` | `VARCHAR(100)` | NOT NULL |
| `quantity_per_delivery` | `DECIMAL(10,2)` | NOT NULL |
| `unit` | `ENUM('kg','ton','mon','piece')` | NOT NULL |
| `price_locked` | `DECIMAL(10,2)` | NOT NULL |
| `frequency` | `ENUM('daily','weekly','biweekly','monthly')` | NOT NULL |
| `next_delivery_date` | `DATE` | NOT NULL |
| `start_date` | `DATE` | NOT NULL |
| `end_date` | `DATE` | default NULL |
| `auto_payment` | `TINYINT` | default 1 |
| `payment_method_id` | `INT` | 🔗 → `payment_methods.method_id`; default NULL |
| `status` | `ENUM('active','paused','cancelled','expired')` | default 'active' |
| `total_orders_generated` | `INT` | default 0 |
| `created_at` | `TIMESTAMP` | NOT NULL; default current_timestamp() |
| `updated_at` | `TIMESTAMP` | NOT NULL; default current_timestamp(); ON UPDATE |

**References:** `users.user_id` (via `buyer_id`), `users.user_id` (via `farmer_id`), `payment_methods.method_id` (via `payment_method_id`)


## Intelligence
*Weather data, market prices, predictions, recommendations, AI*

### `weather_forecasts`

| Column | Type | Notes |
|---|---|---|
| `forecast_id` | `INT` | 🔑 PK; NOT NULL |
| `district_id` | `INT` | 🔗 → `districts.district_id`; NOT NULL |
| `forecast_date` | `DATE` | NOT NULL |
| `forecast_for` | `ENUM('current','today','tomorrow','day_3','day_4','day_5')` | NOT NULL |
| `temp_min` | `DECIMAL(5,2)` | default NULL |
| `temp_max` | `DECIMAL(5,2)` | default NULL |
| `humidity` | `TINYINT` | default NULL |
| `rainfall_mm` | `DECIMAL(6,2)` | default 0.00 |
| `wind_speed_kmh` | `DECIMAL(5,2)` | default NULL |
| `conditions` | `VARCHAR(100)` | default NULL |
| `icon` | `VARCHAR(20)` | default NULL |
| `raw_payload` | `LONGTEXT` | default NULL |
| `fetched_at` | `TIMESTAMP` | NOT NULL; default current_timestamp() |

**References:** `districts.district_id` (via `district_id`)

### `weather_alerts`

| Column | Type | Notes |
|---|---|---|
| `alert_id` | `INT` | NOT NULL |
| `alert_type` | `ENUM('flood','cyclone','drought','heavy_rain','heatwave','cold_wave','storm')` | NOT NULL |
| `severity` | `ENUM('low','medium','high','severe')` | NOT NULL |
| `affected_districts` | `LONGTEXT` | NOT NULL |
| `alert_title` | `VARCHAR(200)` | NOT NULL |
| `alert_message` | `TEXT` | NOT NULL |
| `recommendations` | `TEXT` | default NULL |
| `affected_crops` | `LONGTEXT` | default NULL |
| `start_time` | `TIMESTAMP` | NOT NULL; default current_timestamp(); ON UPDATE |
| `end_time` | `TIMESTAMP` | default NULL |
| `issued_by` | `VARCHAR(100)` | default 'BMD' |
| `created_by` | `INT` | 🔗 → `users.user_id`; default NULL |
| `is_active` | `TINYINT` | default 1 |
| `created_at` | `TIMESTAMP` | NOT NULL; default current_timestamp() |

**References:** `users.user_id` (via `created_by`)

### `market_prices`

| Column | Type | Notes |
|---|---|---|
| `price_id` | `INT` | 🔑 PK; NOT NULL |
| `crop_name` | `VARCHAR(100)` | NOT NULL |
| `district_id` | `INT` | 🔗 → `districts.district_id`; NOT NULL |
| `wholesale_price` | `DECIMAL(10,2)` | NOT NULL |
| `retail_price` | `DECIMAL(10,2)` | NOT NULL |
| `unit` | `ENUM('kg','ton','mon','piece')` | default 'kg' |
| `price_date` | `DATE` | NOT NULL |
| `source` | `VARCHAR(100)` | default 'DAM' |
| `updated_by` | `INT` | 🔗 → `users.user_id`; default NULL |
| `created_at` | `TIMESTAMP` | NOT NULL; default current_timestamp() |

**References:** `districts.district_id` (via `district_id`), `users.user_id` (via `updated_by`)

### `price_history`

| Column | Type | Notes |
|---|---|---|
| `history_id` | `INT` | 🔑 PK; NOT NULL |
| `crop_name` | `VARCHAR(100)` | NOT NULL |
| `district_id` | `INT` | 🔗 → `districts.district_id`; NOT NULL |
| `wholesale_price` | `DECIMAL(10,2)` | NOT NULL |
| `retail_price` | `DECIMAL(10,2)` | NOT NULL |
| `unit` | `ENUM('kg','ton','mon','piece')` | default 'kg' |
| `price_date` | `DATE` | NOT NULL |
| `archived_at` | `TIMESTAMP` | NOT NULL; default current_timestamp() |

**References:** `districts.district_id` (via `district_id`)

### `price_predictions`

| Column | Type | Notes |
|---|---|---|
| `prediction_id` | `INT` | 🔑 PK; NOT NULL |
| `crop_name` | `VARCHAR(100)` | NOT NULL |
| `district_id` | `INT` | 🔗 → `districts.district_id`; NOT NULL |
| `current_price` | `DECIMAL(10,2)` | NOT NULL |
| `predicted_price_7d` | `DECIMAL(10,2)` | NOT NULL |
| `predicted_price_15d` | `DECIMAL(10,2)` | NOT NULL |
| `predicted_price_30d` | `DECIMAL(10,2)` | NOT NULL |
| `prediction_confidence` | `DECIMAL(5,2)` | NOT NULL |
| `trend_direction` | `ENUM('rising','falling','stable')` | NOT NULL |
| `recommendation` | `ENUM('sell_now','wait','moderate')` | NOT NULL |
| `recommendation_reason` | `TEXT` | default NULL |
| `prediction_date` | `DATE` | NOT NULL |
| `model_version` | `VARCHAR(20)` | default NULL |
| `created_at` | `TIMESTAMP` | NOT NULL; default current_timestamp() |

**References:** `districts.district_id` (via `district_id`)

### `crop_recommendations`

| Column | Type | Notes |
|---|---|---|
| `recommendation_id` | `INT` | 🔑 PK; NOT NULL |
| `farmer_id` | `INT` | 🔗 → `users.user_id`; default NULL |
| `district_id` | `INT` | 🔗 → `districts.district_id`; NOT NULL |
| `season` | `ENUM('winter','summer','monsoon','autumn')` | NOT NULL |
| `recommended_crop` | `VARCHAR(100)` | NOT NULL |
| `recommendation_score` | `DECIMAL(5,2)` | NOT NULL |
| `demand_score` | `DECIMAL(5,2)` | NOT NULL |
| `price_score` | `DECIMAL(5,2)` | NOT NULL |
| `success_rate` | `DECIMAL(5,2)` | NOT NULL |
| `expected_profit_margin` | `DECIMAL(5,2)` | default NULL |
| `investment_required` | `DECIMAL(10,2)` | default NULL |
| `growing_duration_days` | `INT` | default NULL |
| `water_requirement` | `ENUM('low','medium','high')` | default 'medium' |
| `difficulty_level` | `ENUM('easy','medium','hard')` | default 'medium' |
| `recommendation_reason` | `TEXT` | default NULL |
| `recommendation_date` | `DATE` | NOT NULL |
| `created_at` | `TIMESTAMP` | NOT NULL; default current_timestamp() |

**References:** `users.user_id` (via `farmer_id`), `districts.district_id` (via `district_id`)

### `demand_analytics`

| Column | Type | Notes |
|---|---|---|
| `demand_id` | `INT` | 🔑 PK; NOT NULL |
| `crop_name` | `VARCHAR(100)` | NOT NULL |
| `district_id` | `INT` | 🔗 → `districts.district_id`; NOT NULL |
| `analysis_date` | `DATE` | NOT NULL |
| `total_supply_kg` | `DECIMAL(12,2)` | default 0.00 |
| `total_demand_orders` | `INT` | default 0 |
| `demand_supply_ratio` | `DECIMAL(8,4)` | default 0.0000 |
| `market_status` | `ENUM('surplus','balanced','shortage')` | default 'balanced' |
| `created_at` | `TIMESTAMP` | NOT NULL; default current_timestamp() |

**References:** `districts.district_id` (via `district_id`)

### `assistant_queries`

| Column | Type | Notes |
|---|---|---|
| `query_id` | `INT` | 🔑 PK; NOT NULL |
| `user_id` | `INT` | 🔗 → `users.user_id`; NOT NULL |
| `query_type` | `ENUM('voice','text')` | NOT NULL |
| `query_language` | `ENUM('bangla','english')` | NOT NULL |
| `user_query` | `TEXT` | NOT NULL |
| `detected_intent` | `VARCHAR(100)` | default NULL |
| `assistant_response` | `TEXT` | default NULL |
| `response_time_ms` | `INT` | default NULL |
| `was_helpful` | `TINYINT` | default NULL |
| `feedback_text` | `VARCHAR(255)` | default NULL |
| `created_at` | `TIMESTAMP` | NOT NULL; default current_timestamp() |

**References:** `users.user_id` (via `user_id`)

### `search_logs`

| Column | Type | Notes |
|---|---|---|
| `search_id` | `INT` | 🔑 PK; NOT NULL |
| `user_id` | `INT` | 🔗 → `users.user_id`; default NULL |
| `search_query` | `VARCHAR(255)` | NOT NULL |
| `search_type` | `ENUM('text','voice','filter')` | default 'text' |
| `filters_applied` | `LONGTEXT` | default NULL |
| `results_count` | `INT` | default 0 |
| `clicked_crop_id` | `INT` | 🔗 → `crops.crop_id`; default NULL |
| `search_timestamp` | `TIMESTAMP` | NOT NULL; default current_timestamp() |

**References:** `users.user_id` (via `user_id`), `crops.crop_id` (via `clicked_crop_id`)


## Communication
*Messages, notifications, and support ticket system*

### `messages`

| Column | Type | Notes |
|---|---|---|
| `message_id` | `INT` | 🔑 PK; NOT NULL |
| `sender_id` | `INT` | 🔗 → `users.user_id`; NOT NULL |
| `receiver_id` | `INT` | 🔗 → `users.user_id`; NOT NULL |
| `message_text` | `TEXT` | NOT NULL |
| `message_type` | `ENUM('text','image','file','voice')` | default 'text' |
| `attachment_url` | `VARCHAR(255)` | default NULL |
| `is_read` | `TINYINT` | default 0 |
| `read_at` | `TIMESTAMP` | default NULL |
| `related_crop_id` | `INT` | 🔗 → `crops.crop_id`; default NULL |
| `sent_by_agent` | `TINYINT` | default 0 |
| `agent_id` | `INT` | 🔗 → `agents.agent_id`; default NULL |
| `created_at` | `TIMESTAMP` | NOT NULL; default current_timestamp() |

**References:** `users.user_id` (via `sender_id`), `users.user_id` (via `receiver_id`), `crops.crop_id` (via `related_crop_id`), `agents.agent_id` (via `agent_id`)

### `notifications`

| Column | Type | Notes |
|---|---|---|
| `notification_id` | `INT` | 🔑 PK; NOT NULL |
| `user_id` | `INT` | 🔗 → `users.user_id`; NOT NULL |
| `notification_type` | `ENUM('order','message','price_alert','loan','weather','payment','rating','agent','system','promotion')` | NOT NULL |
| `priority` | `ENUM('low','medium','high','urgent')` | default 'medium' |
| `title` | `VARCHAR(200)` | NOT NULL |
| `message` | `TEXT` | NOT NULL |
| `action_url` | `VARCHAR(255)` | default NULL |
| `related_id` | `INT` | default NULL |
| `is_read` | `TINYINT` | default 0 |
| `read_at` | `TIMESTAMP` | default NULL |
| `created_at` | `TIMESTAMP` | NOT NULL; default current_timestamp() |

**References:** `users.user_id` (via `user_id`)

### `farmer_support_tickets`

| Column | Type | Notes |
|---|---|---|
| `ticket_id` | `INT` | 🔑 PK; NOT NULL |
| `ticket_number` | `VARCHAR(20)` | NOT NULL; UNIQUE |
| `farmer_id` | `INT` | 🔗 → `users.user_id`; NOT NULL |
| `assigned_agent_id` | `INT` | 🔗 → `agents.agent_id`; default NULL |
| `issue_type` | `ENUM('registration_help','crop_listing','order_issue','payment_problem','loan_query','technical_issue','account_access','other')` | NOT NULL |
| `priority` | `ENUM('low','medium','high','urgent')` | default 'medium' |
| `subject` | `VARCHAR(200)` | NOT NULL |
| `description` | `TEXT` | NOT NULL |
| `status` | `ENUM('open','in_progress','resolved','closed','cancelled')` | default 'open' |
| `resolution_notes` | `TEXT` | default NULL |
| `created_at` | `TIMESTAMP` | NOT NULL; default current_timestamp() |
| `assigned_at` | `TIMESTAMP` | default NULL |
| `resolved_at` | `TIMESTAMP` | default NULL |
| `updated_at` | `TIMESTAMP` | NOT NULL; default current_timestamp(); ON UPDATE |

**References:** `users.user_id` (via `farmer_id`), `agents.agent_id` (via `assigned_agent_id`)


## Community
*Farmer groups and collective organization*

### `farmer_groups`

| Column | Type | Notes |
|---|---|---|
| `group_id` | `INT` | 🔑 PK; NOT NULL |
| `group_name` | `VARCHAR(100)` | NOT NULL; UNIQUE |
| `group_code` | `VARCHAR(20)` | NOT NULL; UNIQUE |
| `group_leader_id` | `INT` | 🔗 → `users.user_id`; NOT NULL |
| `district_id` | `INT` | 🔗 → `districts.district_id`; NOT NULL |
| `total_members` | `INT` | default 1 |
| `total_land_acres` | `DECIMAL(10,2)` | default 0.00 |
| `group_description` | `TEXT` | default NULL |
| `formation_date` | `DATE` | NOT NULL |
| `approved_by` | `INT` | 🔗 → `users.user_id`; default NULL |
| `is_active` | `TINYINT` | default 1 |
| `created_at` | `TIMESTAMP` | NOT NULL; default current_timestamp() |
| `updated_at` | `TIMESTAMP` | NOT NULL; default current_timestamp(); ON UPDATE |

**References:** `users.user_id` (via `group_leader_id`), `districts.district_id` (via `district_id`), `users.user_id` (via `approved_by`)

### `group_members`

| Column | Type | Notes |
|---|---|---|
| `membership_id` | `INT` | 🔑 PK; NOT NULL |
| `group_id` | `INT` | 🔗 → `farmer_groups.group_id`; NOT NULL |
| `farmer_id` | `INT` | 🔗 → `users.user_id`; NOT NULL |
| `land_contribution_acres` | `DECIMAL(8,2)` | default 0.00 |
| `join_date` | `DATE` | NOT NULL |
| `member_role` | `ENUM('leader','member','treasurer')` | default 'member' |
| `is_active` | `TINYINT` | default 1 |
| `created_at` | `TIMESTAMP` | NOT NULL; default current_timestamp() |

**References:** `farmer_groups.group_id` (via `group_id`), `users.user_id` (via `farmer_id`)


## System & Operations
*Audit trail, configuration, and user customization*

### `audit_logs`

| Column | Type | Notes |
|---|---|---|
| `log_id` | `INT` | 🔑 PK; NOT NULL |
| `user_id` | `INT` | 🔗 → `users.user_id`; default NULL |
| `action_type` | `VARCHAR(50)` | NOT NULL |
| `table_name` | `VARCHAR(50)` | NOT NULL |
| `record_id` | `INT` | default NULL |
| `old_values` | `LONGTEXT` | default NULL |
| `new_values` | `LONGTEXT` | default NULL |
| `ip_address` | `VARCHAR(45)` | default NULL |
| `user_agent` | `VARCHAR(255)` | default NULL |
| `created_at` | `TIMESTAMP` | NOT NULL; default current_timestamp() |

**References:** `users.user_id` (via `user_id`)

### `system_settings`

| Column | Type | Notes |
|---|---|---|
| `setting_id` | `INT` | 🔑 PK; NOT NULL |
| `setting_key` | `VARCHAR(100)` | NOT NULL; UNIQUE |
| `setting_value` | `TEXT` | NOT NULL |
| `setting_type` | `ENUM('string','number','boolean','json')` | default 'string' |
| `setting_category` | `VARCHAR(50)` | NOT NULL |
| `setting_description` | `VARCHAR(255)` | default NULL |
| `is_editable` | `TINYINT` | default 1 |
| `updated_by` | `INT` | 🔗 → `users.user_id`; default NULL |
| `created_at` | `TIMESTAMP` | NOT NULL; default current_timestamp() |
| `updated_at` | `TIMESTAMP` | NOT NULL; default current_timestamp(); ON UPDATE |

**References:** `users.user_id` (via `updated_by`)

### `dashboard_widgets`

| Column | Type | Notes |
|---|---|---|
| `widget_id` | `INT` | 🔑 PK; NOT NULL |
| `user_id` | `INT` | 🔗 → `users.user_id`; NOT NULL |
| `widget_type` | `VARCHAR(50)` | NOT NULL |
| `widget_position` | `INT` | NOT NULL |
| `widget_config` | `LONGTEXT` | default NULL |
| `is_visible` | `TINYINT` | default 1 |
| `created_at` | `TIMESTAMP` | NOT NULL; default current_timestamp() |
| `updated_at` | `TIMESTAMP` | NOT NULL; default current_timestamp(); ON UPDATE |

**References:** `users.user_id` (via `user_id`)


---

## All Foreign Key Relationships

There are **71 foreign-key constraints** enforcing referential integrity:

| From | Column | → | To | Column | ON DELETE |
|---|---|---|---|---|---|
| `agents` | `user_id` | → | `users` | `user_id` | CASCADE |
| `agent_activities` | `agent_id` | → | `agents` | `agent_id` | CASCADE |
| `agent_activities` | `farmer_id` | → | `users` | `user_id` | SET NULL |
| `agent_farmer_mapping` | `agent_id` | → | `agents` | `agent_id` | CASCADE |
| `agent_farmer_mapping` | `farmer_id` | → | `users` | `user_id` | CASCADE |
| `assistant_queries` | `user_id` | → | `users` | `user_id` | CASCADE |
| `audit_logs` | `user_id` | → | `users` | `user_id` | SET NULL |
| `crops` | `farmer_id` | → | `users` | `user_id` | CASCADE |
| `crops` | `category_id` | → | `crop_categories` | `category_id` | — |
| `crops` | `agent_id` | → | `agents` | `agent_id` | SET NULL |
| `crop_categories` | `parent_category_id` | → | `crop_categories` | `category_id` | SET NULL |
| `crop_recommendations` | `farmer_id` | → | `users` | `user_id` | CASCADE |
| `crop_recommendations` | `district_id` | → | `districts` | `district_id` | CASCADE |
| `dashboard_widgets` | `user_id` | → | `users` | `user_id` | CASCADE |
| `deliveries` | `order_id` | → | `orders` | `order_id` | CASCADE |
| `deliveries` | `transport_partner_id` | → | `transport_partners` | `partner_id` | SET NULL |
| `demand_analytics` | `district_id` | → | `districts` | `district_id` | CASCADE |
| `expenses` | `farmer_id` | → | `users` | `user_id` | CASCADE |
| `expenses` | `crop_id` | → | `crops` | `crop_id` | SET NULL |
| `farmer_groups` | `group_leader_id` | → | `users` | `user_id` | — |
| `farmer_groups` | `district_id` | → | `districts` | `district_id` | — |
| `farmer_groups` | `approved_by` | → | `users` | `user_id` | SET NULL |
| `farmer_ratings` | `farmer_id` | → | `users` | `user_id` | CASCADE |
| `farmer_ratings` | `buyer_id` | → | `users` | `user_id` | CASCADE |
| `farmer_ratings` | `order_id` | → | `orders` | `order_id` | CASCADE |
| `farmer_support_tickets` | `farmer_id` | → | `users` | `user_id` | CASCADE |
| `farmer_support_tickets` | `assigned_agent_id` | → | `agents` | `agent_id` | SET NULL |
| `favorites` | `user_id` | → | `users` | `user_id` | CASCADE |
| `favorites` | `crop_id` | → | `crops` | `crop_id` | CASCADE |
| `favorites` | `farmer_id` | → | `users` | `user_id` | CASCADE |
| `group_members` | `group_id` | → | `farmer_groups` | `group_id` | CASCADE |
| `group_members` | `farmer_id` | → | `users` | `user_id` | CASCADE |
| `inventory_logs` | `crop_id` | → | `crops` | `crop_id` | CASCADE |
| `inventory_logs` | `changed_by` | → | `users` | `user_id` | SET NULL |
| `loans` | `farmer_id` | → | `users` | `user_id` | CASCADE |
| `loans` | `approved_by` | → | `users` | `user_id` | SET NULL |
| `loans` | `agent_id` | → | `agents` | `agent_id` | SET NULL |
| `loan_repayments` | `loan_id` | → | `loans` | `loan_id` | CASCADE |
| `loan_repayments` | `recorded_by` | → | `users` | `user_id` | SET NULL |
| `market_prices` | `district_id` | → | `districts` | `district_id` | CASCADE |
| `market_prices` | `updated_by` | → | `users` | `user_id` | SET NULL |
| `messages` | `sender_id` | → | `users` | `user_id` | CASCADE |
| `messages` | `receiver_id` | → | `users` | `user_id` | CASCADE |
| `messages` | `related_crop_id` | → | `crops` | `crop_id` | SET NULL |
| `messages` | `agent_id` | → | `agents` | `agent_id` | SET NULL |
| `notifications` | `user_id` | → | `users` | `user_id` | CASCADE |
| `orders` | `buyer_id` | → | `users` | `user_id` | — |
| `orders` | `farmer_id` | → | `users` | `user_id` | — |
| `orders` | `crop_id` | → | `crops` | `crop_id` | — |
| `orders` | `delivery_district_id` | → | `districts` | `district_id` | SET NULL |
| `orders` | `cancelled_by` | → | `users` | `user_id` | SET NULL |
| `payments` | `order_id` | → | `orders` | `order_id` | SET NULL |
| `payments` | `subscription_id` | → | `subscriptions` | `subscription_id` | SET NULL |
| `payments` | `user_id` | → | `users` | `user_id` | CASCADE |
| `payment_methods` | `user_id` | → | `users` | `user_id` | CASCADE |
| `price_history` | `district_id` | → | `districts` | `district_id` | CASCADE |
| `price_predictions` | `district_id` | → | `districts` | `district_id` | CASCADE |
| `search_logs` | `user_id` | → | `users` | `user_id` | SET NULL |
| `search_logs` | `clicked_crop_id` | → | `crops` | `crop_id` | SET NULL |
| `subscriptions` | `buyer_id` | → | `users` | `user_id` | CASCADE |
| `subscriptions` | `farmer_id` | → | `users` | `user_id` | CASCADE |
| `subscriptions` | `payment_method_id` | → | `payment_methods` | `method_id` | SET NULL |
| `system_settings` | `updated_by` | → | `users` | `user_id` | SET NULL |
| `transactions` | `user_id` | → | `users` | `user_id` | CASCADE |
| `transactions` | `payment_method_id` | → | `payment_methods` | `method_id` | SET NULL |
| `transactions` | `related_order_id` | → | `orders` | `order_id` | SET NULL |
| `transactions` | `related_loan_id` | → | `loans` | `loan_id` | SET NULL |
| `users` | `district_id` | → | `districts` | `district_id` | — |
| `user_roles` | `user_id` | → | `users` | `user_id` | CASCADE |
| `weather_alerts` | `created_by` | → | `users` | `user_id` | SET NULL |
| `weather_forecasts` | `district_id` | → | `districts` | `district_id` | CASCADE |

---

## Triggers

AgroFin uses **3 triggers** to enforce data integrity and automate cross-table updates:

### `tr_orders_before_insert`
- **Fires on:** `BEFORE INSERT ON orders`
- **Purpose:** Auto-generates `order_number` in format `ORD-YYYYMMDD-XXXXX` when not supplied by the application.
- **Safety net for:** Direct SQL inserts (e.g., from phpMyAdmin or future API endpoints).

### `tr_crops_after_update`
- **Fires on:** `AFTER UPDATE ON crops`
- **Purpose:** Auto-writes an `inventory_logs` row whenever `crops.quantity` changes.
- **Smart deduplication:** Skips logging if the application code already inserted a log row for the same crop with the same final quantity within the last 2 seconds — prevents duplicate logs.

### `tr_transactions_after_insert`
- **Fires on:** `AFTER INSERT ON transactions`
- **Purpose:** Implements double-entry accounting at the DB level. When a `completed` transaction is inserted:
  - Updates `users.wallet_balance` (`sale`/`deposit`/`loan_disbursement`/`refund` → increase; `purchase`/`withdrawal`/`loan_repayment`/`commission` → decrease)
  - Populates `transactions.balance_before` and `balance_after` (audit snapshot)
  - Refuses any transaction that would cause negative wallet balance (`SIGNAL SQLSTATE`)


---

## Views

Two views simplify common complex queries:

### `vw_active_crops_with_details`
Denormalized view of all crops with status `'available'`. Joins crops with farmer, district, and category for fast read access in dashboards and recommendations.

### `vw_farmer_performance`
Aggregated performance metrics per farmer (total revenue, order count, average rating, etc.). Used by admin dashboards and ranking queries.


---

## Project Statistics

- **Total tables:** 39
- **Total foreign keys:** 71
- **Total triggers:** 3
- **Total views:** 2
- **Composite indexes:** 20+
- **Engine:** InnoDB (transactional with FK support)
- **Charset:** utf8mb4 (full Bangla + emoji support)

---

