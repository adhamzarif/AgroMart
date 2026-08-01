-- ═══════════════════════════════════════════════════════════════════
-- AgroMart Migration 007 — Agent module (PostgreSQL)
-- Tables: agents, agent_activities, agent_farmer_mapping, farmer_support_tickets
-- Then wires up the DEFERRED agent FKs from 003/004/006.
-- Depends on: 001(users). Must run AFTER 003,004,006 (for deferred FKs).
-- ═══════════════════════════════════════════════════════════════════
BEGIN;

CREATE TABLE agents (
    agent_id        INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id         INTEGER NOT NULL UNIQUE REFERENCES users(user_id) ON DELETE CASCADE,
    agent_code      VARCHAR(20) NOT NULL UNIQUE,
    service_districts JSONB NOT NULL,
    vehicle_type    VARCHAR(12) DEFAULT 'none'
                    CHECK (vehicle_type IN ('motorcycle','bicycle','none')),
    commission_rate NUMERIC(5,2) DEFAULT 2.00,
    training_completed BOOLEAN DEFAULT FALSE,
    training_completion_date DATE,
    agent_rating    NUMERIC(3,2) DEFAULT 0,
    total_farmers_assigned INTEGER DEFAULT 0,
    total_commission_earned NUMERIC(12,2) DEFAULT 0,
    bank_account_number VARCHAR(50),
    bank_name       VARCHAR(100),
    status          VARCHAR(10) DEFAULT 'active'
                    CHECK (status IN ('active','inactive','suspended')),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE TRIGGER agents_set_updated_at BEFORE UPDATE ON agents
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE agent_activities (
    activity_id     INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    agent_id        INTEGER NOT NULL REFERENCES agents(agent_id) ON DELETE CASCADE,
    farmer_id       INTEGER REFERENCES users(user_id) ON DELETE SET NULL,
    activity_type   VARCHAR(20) NOT NULL
                    CHECK (activity_type IN ('farmer_registration','crop_listing','order_help',
                                             'loan_assistance','message_help','training_session',
                                             'field_visit','other')),
    description     TEXT,
    commission_earned NUMERIC(10,2) DEFAULT 0,
    activity_date   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_agent_activities_agent ON agent_activities(agent_id, activity_date DESC);

CREATE TABLE agent_farmer_mapping (
    mapping_id      INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    agent_id        INTEGER NOT NULL REFERENCES agents(agent_id) ON DELETE CASCADE,
    farmer_id       INTEGER NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    assigned_date   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    help_count      INTEGER DEFAULT 0,
    last_interaction TIMESTAMPTZ,
    status          VARCHAR(10) DEFAULT 'active' CHECK (status IN ('active','inactive')),
    CONSTRAINT uq_agent_farmer UNIQUE (agent_id, farmer_id)
);

CREATE TABLE farmer_support_tickets (
    ticket_id       INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    ticket_number   VARCHAR(20) NOT NULL UNIQUE,
    farmer_id       INTEGER NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    assigned_agent_id INTEGER REFERENCES agents(agent_id) ON DELETE SET NULL,
    issue_type      VARCHAR(20) NOT NULL
                    CHECK (issue_type IN ('registration_help','crop_listing','order_issue',
                                          'payment_problem','loan_query','technical_issue',
                                          'account_access','other')),
    priority        VARCHAR(10) DEFAULT 'medium'
                    CHECK (priority IN ('low','medium','high','urgent')),
    subject         VARCHAR(200) NOT NULL,
    description     TEXT NOT NULL,
    status          VARCHAR(12) DEFAULT 'open'
                    CHECK (status IN ('open','in_progress','resolved','closed','cancelled')),
    resolution_notes TEXT,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    assigned_at     TIMESTAMPTZ,
    resolved_at     TIMESTAMPTZ,
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
CREATE INDEX idx_tickets_farmer ON farmer_support_tickets(farmer_id, status);
CREATE TRIGGER tickets_set_updated_at BEFORE UPDATE ON farmer_support_tickets
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

-- ─── Wire up DEFERRED agent FKs from earlier migrations ─────────────
ALTER TABLE crops ADD CONSTRAINT crops_agent_fk
    FOREIGN KEY (agent_id) REFERENCES agents(agent_id) ON DELETE SET NULL;
ALTER TABLE messages ADD CONSTRAINT messages_agent_fk
    FOREIGN KEY (agent_id) REFERENCES agents(agent_id) ON DELETE SET NULL;
ALTER TABLE loans ADD CONSTRAINT loans_agent_fk
    FOREIGN KEY (agent_id) REFERENCES agents(agent_id) ON DELETE SET NULL;

COMMIT;
