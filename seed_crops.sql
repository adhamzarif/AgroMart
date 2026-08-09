-- seed_crops.sql — realistic sample crops so the marketplace + home grid look full.
-- Safe to re-run: uses ON CONFLICT / guards. Uses farmer "আব্দুল হালিম".
-- Run:  psql -U agromart -d agromart -h localhost -f seed_crops.sql

BEGIN;

-- district
INSERT INTO districts (district_name, division)
VALUES ('Rangamati','Chittagong')
ON CONFLICT (district_name) DO NOTHING;

-- categories (Bengali names match the screenshot chips)
INSERT INTO crop_categories (category_name, category_name_bn) VALUES
  ('Vegetables','সবজি'),
  ('Grains','দানাশস্য'),
  ('Pulses','ডাল'),
  ('Fruits','ফল')
ON CONFLICT (category_name) DO NOTHING;

-- a farmer to own the crops (skip if a user with this phone already exists)
INSERT INTO users (full_name, phone, password_hash, district_id)
SELECT 'আব্দুল হালিম', '01712340000', '$2a$12$seedplaceholderhashseedplaceholderhashse',
       (SELECT district_id FROM districts WHERE district_name='Rangamati')
WHERE NOT EXISTS (SELECT 1 FROM users WHERE phone='01712340000');

-- assign farmer role
INSERT INTO user_roles (user_id, role)
SELECT user_id, 'farmer' FROM users WHERE phone='01712340000'
ON CONFLICT (user_id, role) DO NOTHING;

-- crops (variety across categories, like the screenshot)
INSERT INTO crops
  (farmer_id, category_id, crop_name, quantity, unit, price_per_unit, available_from, status, is_organic)
SELECT
  (SELECT user_id FROM users WHERE phone='01712340000'),
  (SELECT category_id FROM crop_categories WHERE category_name = c.cat),
  c.name, c.qty, c.unit, c.price, CURRENT_DATE, 'available', c.organic
FROM (VALUES
  ('লাউ',        'Grains',     100, 'piece', 20.00, false),
  ('কাঁচামরিচ',  'Vegetables',  50, 'kg',    60.00, false),
  ('বেগুন',      'Vegetables',  80, 'kg',    40.00, false),
  ('সরিষা',      'Grains',     200, 'kg',    75.00, false),
  ('মুগ ডাল',    'Pulses',     120, 'kg',   130.00, true),
  ('মসুর ডাল',   'Pulses',     150, 'kg',   110.00, false),
  ('আলু',        'Vegetables', 300, 'kg',    25.00, false),
  ('টমেটো',      'Vegetables',  90, 'kg',    45.00, true),
  ('পেঁয়াজ',    'Vegetables', 250, 'kg',    55.00, false)
) AS c(name, cat, qty, unit, price, organic)
-- avoid duplicating if this crop name already exists for this farmer
WHERE NOT EXISTS (
  SELECT 1 FROM crops x
  WHERE x.crop_name = c.name
    AND x.farmer_id = (SELECT user_id FROM users WHERE phone='01712340000')
);

COMMIT;

-- show what we have
SELECT crop_name, unit, price_per_unit,
       (SELECT category_name_bn FROM crop_categories cc WHERE cc.category_id = crops.category_id) AS category
FROM crops WHERE status='available' ORDER BY created_at DESC;
