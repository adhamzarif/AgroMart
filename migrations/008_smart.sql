-- ═══════════════════════════════════════════════════════════════════
-- AgroMart Migration 008 — Smart features & AI (PostgreSQL)
-- Tables: transport_partners, deliveries, weather_forecasts, weather_alerts,
--         farmer_groups, group_members, subscriptions, demand_analytics,
--         crop_recommendations, price_predictions, assistant_queries, otp_codes
-- Consolidates base + migration 004(otp) + 005(weather). Depends on 001-005.
-- ═══════════════════════════════════════════════════════════════════
BEGIN;

CREATE TABLE transport_partners (
    partner_id      INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    partner_name    VARCHAR(100) NOT NULL,
    contact_person  VARCHAR(100),
    contact_phone   VARCHAR(15) NOT NULL,
    contact_email   VARCHAR(100),
    base_rate_per_km NUMERIC(6,2) NOT NULL,
    min_charge      NUMERIC(8,2) NOT NULL,
    rating          NUMERIC(3,2) DEFAULT 0,
    total_deliveries INTEGER DEFAULT 0,
    is_active       BOOLEAN DEFAULT TRUE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE TRIGGER transport_partners_set_updated_at BEFORE UPDATE ON transport_partners
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE deliveries (
    delivery_id     INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_id        INTEGER NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    transport_partner_id INTEGER REFERENCES transport_partners(partner_id) ON DELETE SET NULL,
    vehicle_type    VARCHAR(12) NOT NULL
                    CHECK (vehicle_type IN ('pickup','truck','van','motorcycle')),
    vehicle_number  VARCHAR(20),
    driver_name     VARCHAR(100),
    driver_phone    VARCHAR(15),
    pickup_address  TEXT NOT NULL,
    delivery_address TEXT NOT NULL,
    distance_km     NUMERIC(6,2),
    delivery_charge NUMERIC(8,2) NOT NULL,
    pickup_time     TIMESTAMPTZ,
    estimated_delivery_time TIMESTAMPTZ,
    actual_delivery_time TIMESTAMPTZ,
    delivery_status VARCHAR(18) DEFAULT 'pending'
                    CHECK (delivery_status IN ('pending','picked_up','in_transit',
                                               'out_for_delivery','delivered','failed')),
    delivery_proof_url VARCHAR(255),
    receiver_signature_url VARCHAR(255),
    delivery_notes  TEXT,
    delivery_rating NUMERIC(2,1),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_deliveries_order ON deliveries(order_id);
CREATE TRIGGER deliveries_set_updated_at BEFORE UPDATE ON deliveries
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE weather_forecasts (
    forecast_id     INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    district_id     INTEGER NOT NULL REFERENCES districts(district_id) ON DELETE CASCADE,
    forecast_date   DATE NOT NULL,
    forecast_for    VARCHAR(8) NOT NULL
                    CHECK (forecast_for IN ('current','today','tomorrow','day_3','day_4','day_5')),
    temp_min        NUMERIC(5,2),
    temp_max        NUMERIC(5,2),
    humidity        SMALLINT,
    rainfall_mm     NUMERIC(6,2) DEFAULT 0,
    wind_speed_kmh  NUMERIC(5,2),
    conditions      VARCHAR(100),
    icon            VARCHAR(20),
    fetched_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_weather_forecasts_district ON weather_forecasts(district_id, forecast_date);

CREATE TABLE weather_alerts (
    alert_id        INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    alert_type      VARCHAR(12) NOT NULL
                    CHECK (alert_type IN ('flood','cyclone','drought','heavy_rain',
                                          'heatwave','cold_wave','storm')),
    severity        VARCHAR(8) NOT NULL CHECK (severity IN ('low','medium','high','severe')),
    alert_title     VARCHAR(200) NOT NULL,
    alert_message   TEXT NOT NULL,
    recommendations TEXT,
    start_time      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    end_time        TIMESTAMPTZ,
    issued_by       VARCHAR(100) DEFAULT 'BMD',
    created_by      INTEGER REFERENCES users(user_id) ON DELETE SET NULL,
    is_active       BOOLEAN DEFAULT TRUE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE farmer_groups (
    group_id        INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    group_name      VARCHAR(100) NOT NULL,
    group_code      VARCHAR(20) NOT NULL UNIQUE,
    group_leader_id INTEGER NOT NULL REFERENCES users(user_id),
    district_id     INTEGER NOT NULL REFERENCES districts(district_id),
    total_members   INTEGER DEFAULT 1,
    total_land_acres NUMERIC(10,2) DEFAULT 0,
    group_description TEXT,
    formation_date  DATE NOT NULL,
    approved_by     INTEGER REFERENCES users(user_id) ON DELETE SET NULL,
    is_active       BOOLEAN DEFAULT TRUE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE TRIGGER farmer_groups_set_updated_at BEFORE UPDATE ON farmer_groups
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE group_members (
    membership_id   INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    group_id        INTEGER NOT NULL REFERENCES farmer_groups(group_id) ON DELETE CASCADE,
    farmer_id       INTEGER NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    land_contribution_acres NUMERIC(8,2) DEFAULT 0,
    join_date       DATE NOT NULL,
    member_role     VARCHAR(10) DEFAULT 'member'
                    CHECK (member_role IN ('leader','member','treasurer')),
    is_active       BOOLEAN DEFAULT TRUE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_group_member UNIQUE (group_id, farmer_id)
);

CREATE TABLE subscriptions (
    subscription_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    buyer_id        INTEGER NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    farmer_id       INTEGER NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    crop_name       VARCHAR(100) NOT NULL,
    quantity_per_delivery NUMERIC(10,2) NOT NULL,
    unit            VARCHAR(10) NOT NULL CHECK (unit IN ('kg','ton','mon','piece')),
    price_locked    NUMERIC(10,2) NOT NULL,
    frequency       VARCHAR(10) NOT NULL
                    CHECK (frequency IN ('daily','weekly','biweekly','monthly')),
    next_delivery_date DATE NOT NULL,
    start_date      DATE NOT NULL,
    end_date        DATE,
    auto_payment    BOOLEAN DEFAULT TRUE,
    payment_method_id INTEGER REFERENCES payment_methods(method_id) ON DELETE SET NULL,
    status          VARCHAR(10) DEFAULT 'active'
                    CHECK (status IN ('active','paused','cancelled','expired')),
    total_orders_generated INTEGER DEFAULT 0,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_subscriptions_next ON subscriptions(status, next_delivery_date);
CREATE TRIGGER subscriptions_set_updated_at BEFORE UPDATE ON subscriptions
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- payments.subscription_id FK now that subscriptions exists
ALTER TABLE payments ADD CONSTRAINT payments_subscription_fk
    FOREIGN KEY (subscription_id) REFERENCES subscriptions(subscription_id) ON DELETE SET NULL;

CREATE TABLE demand_analytics (
    demand_id       INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    crop_name       VARCHAR(100) NOT NULL,
    district_id     INTEGER NOT NULL REFERENCES districts(district_id) ON DELETE CASCADE,
    analysis_date   DATE NOT NULL,
    total_supply_kg NUMERIC(12,2) DEFAULT 0,
    total_demand_orders INTEGER DEFAULT 0,
    demand_supply_ratio NUMERIC(8,4) DEFAULT 0,
    market_status   VARCHAR(10) DEFAULT 'balanced'
                    CHECK (market_status IN ('surplus','balanced','shortage')),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_demand UNIQUE (crop_name, district_id, analysis_date)
);

CREATE TABLE crop_recommendations (
    recommendation_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    farmer_id       INTEGER REFERENCES users(user_id) ON DELETE SET NULL,
    district_id     INTEGER NOT NULL REFERENCES districts(district_id) ON DELETE CASCADE,
    season          VARCHAR(8) NOT NULL CHECK (season IN ('winter','summer','monsoon','autumn')),
    recommended_crop VARCHAR(100) NOT NULL,
    recommendation_score NUMERIC(5,2) NOT NULL,
    demand_score    NUMERIC(5,2) NOT NULL,
    price_score     NUMERIC(5,2) NOT NULL,
    success_rate    NUMERIC(5,2) NOT NULL,
    expected_profit_margin NUMERIC(5,2),
    investment_required NUMERIC(10,2),
    growing_duration_days INTEGER,
    water_requirement VARCHAR(8) DEFAULT 'medium'
                    CHECK (water_requirement IN ('low','medium','high')),
    difficulty_level VARCHAR(8) DEFAULT 'medium'
                    CHECK (difficulty_level IN ('easy','medium','hard')),
    recommendation_reason TEXT,
    recommendation_date DATE NOT NULL,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_crop_rec_district ON crop_recommendations(district_id, season);

CREATE TABLE price_predictions (
    prediction_id   INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    crop_name       VARCHAR(100) NOT NULL,
    district_id     INTEGER NOT NULL REFERENCES districts(district_id) ON DELETE CASCADE,
    current_price   NUMERIC(10,2) NOT NULL,
    predicted_price_7d NUMERIC(10,2) NOT NULL,
    predicted_price_15d NUMERIC(10,2) NOT NULL,
    predicted_price_30d NUMERIC(10,2) NOT NULL,
    prediction_confidence NUMERIC(5,2) NOT NULL,
    trend_direction VARCHAR(8) NOT NULL CHECK (trend_direction IN ('rising','falling','stable')),
    recommendation  VARCHAR(10) NOT NULL CHECK (recommendation IN ('sell_now','wait','moderate')),
    recommendation_reason TEXT,
    prediction_date DATE NOT NULL,
    model_version   VARCHAR(20),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_pred UNIQUE (crop_name, district_id, prediction_date)
);

CREATE TABLE assistant_queries (
    query_id        INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id         INTEGER NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    query_type      VARCHAR(6) NOT NULL CHECK (query_type IN ('voice','text')),
    query_language  VARCHAR(8) NOT NULL CHECK (query_language IN ('bangla','english')),
    user_query      TEXT NOT NULL,
    detected_intent VARCHAR(100),
    assistant_response TEXT,
    response_time_ms INTEGER,
    was_helpful     BOOLEAN,
    feedback_text   VARCHAR(255),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_assistant_queries_user ON assistant_queries(user_id, created_at DESC);

CREATE TABLE otp_codes (
    otp_id          INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    phone           VARCHAR(15) NOT NULL,
    code_hash       VARCHAR(255) NOT NULL,
    purpose         VARCHAR(15) NOT NULL
                    CHECK (purpose IN ('register','login','reset_password','verify_phone','two_factor')),
    expires_at      TIMESTAMPTZ NOT NULL,
    attempts        SMALLINT NOT NULL DEFAULT 0,
    max_attempts    SMALLINT NOT NULL DEFAULT 5,
    verified_at     TIMESTAMPTZ,
    request_ip      VARCHAR(45),
    sent_via        VARCHAR(6) NOT NULL DEFAULT 'log' CHECK (sent_via IN ('sms','log','email')),
    provider_response TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_otp_phone ON otp_codes(phone, purpose, created_at DESC);

COMMIT;
