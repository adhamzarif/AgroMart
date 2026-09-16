-- Supply-chain margins per crop and role.
-- Used by the "Higher margins" feature to show what farmers earn under
-- the traditional multi-hop system vs direct-to-buyer on AgroMart.
CREATE TABLE IF NOT EXISTS supply_chain_margins (
  margin_id     integer GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  crop_name     varchar(100) NOT NULL,
  role          varchar(20)  NOT NULL,
  share_pct     numeric(5,2) NOT NULL CHECK (share_pct >= 0 AND share_pct <= 100),
  system        varchar(20)  NOT NULL DEFAULT 'traditional'
                             CHECK (system IN ('traditional', 'agromart')),
  UNIQUE (crop_name, role, system)
);

CREATE INDEX IF NOT EXISTS idx_supply_chain_margins_crop
  ON supply_chain_margins (crop_name, system);
