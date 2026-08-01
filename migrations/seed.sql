-- ═══════════════════════════════════════════════════════════════════
-- AgroMart seed data (PostgreSQL)
-- Run LAST, after 000-009. Idempotent-ish: uses ON CONFLICT DO NOTHING.
-- IMPORTANT: replace demo password hashes — do NOT ship 'password123'.
-- ═══════════════════════════════════════════════════════════════════
BEGIN;

-- ─── Districts (sample; add all 64. VERIFY coordinates against a source) ──
INSERT INTO districts (district_name, division, latitude, longitude) VALUES
  ('Dhaka','Dhaka',23.810300,90.412500),
  ('Chittagong','Chittagong',22.356900,91.783200),
  ('Rajshahi','Rajshahi',24.363600,88.624400),
  ('Khulna','Khulna',22.845600,89.540300),
  ('Sylhet','Sylhet',24.894900,91.868700),
  ('Barishal','Barishal',22.701000,90.353500),
  ('Rangpur','Rangpur',25.746500,89.251700),
  ('Mymensingh','Mymensingh',24.747100,90.420300)
  -- ... add the remaining 56 districts ...
ON CONFLICT (district_name) DO NOTHING;

-- ─── Crop categories ────────────────────────────────────────────────
INSERT INTO crop_categories (category_name, category_name_bn) VALUES
  ('Cereals','খাদ্যশস্য'),
  ('Vegetables','সবজি'),
  ('Fruits','ফল'),
  ('Pulses','ডাল'),
  ('Spices','মসলা'),
  ('Cash Crops','অর্থকরী ফসল'),
  ('Others','অন্যান্য')
ON CONFLICT (category_name) DO NOTHING;

-- ─── Demo admin (REPLACE the hash with a real bcrypt hash) ──────────
-- Generate one:  node -e "console.log(require('bcryptjs').hashSync('YOURPASS',12))"
-- INSERT INTO users (full_name, phone, password_hash, district_id, account_status)
--   VALUES ('Admin','01700000000','$2a$12$REPLACE_ME', 1, 'active');
-- INSERT INTO user_roles (user_id, role) VALUES (1, 'admin');

COMMIT;
