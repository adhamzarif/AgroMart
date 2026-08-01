-- ═══════════════════════════════════════════════════════════════════
-- AgroMart Migration 004 — Orders & communication (PostgreSQL)
-- Tables: orders, inventory_logs, messages, notifications, dashboard_widgets
-- Depends on: 001(users), 002(districts), 003(crops), 007(agents for msg.agent_id)
-- The messages.agent_id FK is added in 007 (deferred) to avoid ordering issues.
-- ═══════════════════════════════════════════════════════════════════
BEGIN;

CREATE TABLE orders (
    order_id        INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    order_number    VARCHAR(30) NOT NULL UNIQUE,
    buyer_id        INTEGER NOT NULL REFERENCES users(user_id),
    farmer_id       INTEGER NOT NULL REFERENCES users(user_id),
    crop_id         INTEGER NOT NULL REFERENCES crops(crop_id),
    quantity_ordered NUMERIC(10,2) NOT NULL CHECK (quantity_ordered > 0),
    unit_price      NUMERIC(10,2) NOT NULL CHECK (unit_price >= 0),
    subtotal        NUMERIC(12,2) NOT NULL,
    delivery_charge NUMERIC(8,2) DEFAULT 0,
    total_amount    NUMERIC(12,2) NOT NULL,
    order_status    VARCHAR(20) DEFAULT 'pending'
                    CHECK (order_status IN ('pending_payment','pending','confirmed','processing',
                                            'packed','shipped','delivered','cancelled','refunded')),
    payment_status  VARCHAR(10) DEFAULT 'pending'
                    CHECK (payment_status IN ('pending','paid','failed','refunded')),
    payment_gateway VARCHAR(30),
    payment_id      INTEGER,  -- FK to payments added in 005 (deferred)
    delivery_type   VARCHAR(15) DEFAULT 'home_delivery'
                    CHECK (delivery_type IN ('home_delivery','self_pickup')),
    delivery_address TEXT,
    delivery_district_id INTEGER REFERENCES districts(district_id) ON DELETE SET NULL,
    preferred_delivery_date DATE,
    special_instructions TEXT,
    cancellation_reason VARCHAR(255),
    cancelled_by    INTEGER REFERENCES users(user_id) ON DELETE SET NULL,
    order_date      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    confirmed_at    TIMESTAMPTZ,
    delivered_at    TIMESTAMPTZ,
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_orders_buyer  ON orders(buyer_id, order_date DESC);
CREATE INDEX idx_orders_farmer ON orders(farmer_id, order_date DESC);
CREATE INDEX idx_orders_status ON orders(order_status);
CREATE TRIGGER orders_set_updated_at BEFORE UPDATE ON orders
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE inventory_logs (
    log_id          INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    crop_id         INTEGER NOT NULL REFERENCES crops(crop_id) ON DELETE CASCADE,
    change_type     VARCHAR(12) NOT NULL
                    CHECK (change_type IN ('listed','sold','adjusted','expired','restocked')),
    quantity_before NUMERIC(10,2) NOT NULL,
    quantity_after  NUMERIC(10,2) NOT NULL,
    change_reason   VARCHAR(255),
    changed_by      INTEGER REFERENCES users(user_id) ON DELETE SET NULL,
    logged_at       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_inventory_logs_crop ON inventory_logs(crop_id, logged_at DESC);

CREATE TABLE messages (
    message_id      INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    sender_id       INTEGER NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    receiver_id     INTEGER NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    message_text    TEXT NOT NULL,
    message_type    VARCHAR(10) DEFAULT 'text'
                    CHECK (message_type IN ('text','image','file','voice')),
    attachment_url  VARCHAR(255),
    is_read         BOOLEAN DEFAULT FALSE,
    read_at         TIMESTAMPTZ,
    related_crop_id INTEGER REFERENCES crops(crop_id) ON DELETE SET NULL,
    sent_by_agent   BOOLEAN DEFAULT FALSE,
    agent_id        INTEGER,  -- FK to agents added in 007 (deferred)
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_msg_sender_ne_receiver CHECK (sender_id <> receiver_id)
);
CREATE INDEX idx_messages_conv ON messages(sender_id, receiver_id, created_at DESC);
CREATE INDEX idx_messages_unread ON messages(receiver_id, is_read);

CREATE TABLE notifications (
    notification_id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id         INTEGER NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    notification_type VARCHAR(15) NOT NULL
                    CHECK (notification_type IN ('order','message','price_alert','loan','weather',
                                                 'payment','rating','agent','system','promotion')),
    priority        VARCHAR(10) DEFAULT 'medium'
                    CHECK (priority IN ('low','medium','high','urgent')),
    title           VARCHAR(200) NOT NULL,
    message         TEXT NOT NULL,
    action_url      VARCHAR(255),
    related_id      INTEGER,
    is_read         BOOLEAN DEFAULT FALSE,
    read_at         TIMESTAMPTZ,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_notifications_user ON notifications(user_id, is_read, created_at DESC);

CREATE TABLE dashboard_widgets (
    widget_id       INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id         INTEGER NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    widget_type     VARCHAR(50) NOT NULL,
    widget_position INTEGER NOT NULL,
    widget_config   JSONB,
    is_visible      BOOLEAN DEFAULT TRUE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE TRIGGER dashboard_widgets_set_updated_at BEFORE UPDATE ON dashboard_widgets
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

COMMIT;
