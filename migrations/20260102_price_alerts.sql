-- Price alerts: users get notified when a crop's market price crosses their target.
CREATE TABLE IF NOT EXISTS price_alerts (
  alert_id       integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  user_id        integer NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
  crop_name      varchar(100) NOT NULL,
  district_id    integer REFERENCES districts(district_id) ON DELETE SET NULL,
  direction      varchar(10) NOT NULL CHECK (direction IN ('above', 'below')),
  target_price   numeric(10,2) NOT NULL CHECK (target_price > 0),
  is_active      boolean NOT NULL DEFAULT true,
  last_triggered timestamp with time zone,
  trigger_count  integer NOT NULL DEFAULT 0,
  created_at     timestamp with time zone NOT NULL DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_price_alerts_user   ON price_alerts (user_id, is_active);
CREATE INDEX IF NOT EXISTS idx_price_alerts_lookup ON price_alerts (crop_name, district_id) WHERE is_active = true;
