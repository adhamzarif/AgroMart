-- 010_demo_users.sql — seed three demo accounts for login demos.
-- Passwords are pre-hashed bcrypt hashes of the plaintext passwords shown below.
-- Safe to re-run: uses ON CONFLICT to skip if the phone already exists.
-- Uses ID -1/-2/-3 sentinel via ON CONFLICT (phone) — we let the sequence assign real IDs.
--
-- Demo credentials:
--   Admin  | phone 01700000001 | password demo1234
--   Farmer | phone 01700000002 | password demo1234
--   Buyer  | phone 01700000003 | password demo1234

BEGIN;

-- Bcrypt hashes for "demo1234" (cost 12). Generated fresh; safe to commit.
-- If you change the plaintext password, regenerate: node -e "console.log(require('bcryptjs').hashSync('demo1234',12))"

-- Admin demo user
INSERT INTO users (full_name, phone, email, password_hash, account_status)
SELECT 'Demo Admin', '01700000001', 'admin@demo.agromart',
       '$2b$12$GYLSZZ1t.LqT.7Htepue1e2YsJs3soKGTyaWClUFFYbr3Mb1w6wea', 'active'
WHERE NOT EXISTS (SELECT 1 FROM users WHERE phone = '01700000001');

INSERT INTO user_roles (user_id, role)
SELECT user_id, 'admin' FROM users WHERE phone = '01700000001'
ON CONFLICT (user_id, role) DO NOTHING;

-- Farmer demo user (also assigned district Rangamati if it exists)
INSERT INTO users (full_name, phone, email, password_hash, district_id, account_status)
SELECT 'Demo Farmer', '01700000002', 'farmer@demo.agromart',
       '$2b$12$GYLSZZ1t.LqT.7Htepue1e2YsJs3soKGTyaWClUFFYbr3Mb1w6wea',
       (SELECT district_id FROM districts WHERE district_name='Rangamati' LIMIT 1),
       'active'
WHERE NOT EXISTS (SELECT 1 FROM users WHERE phone = '01700000002');

INSERT INTO user_roles (user_id, role)
SELECT user_id, 'farmer' FROM users WHERE phone = '01700000002'
ON CONFLICT (user_id, role) DO NOTHING;

-- Buyer demo user
INSERT INTO users (full_name, phone, email, password_hash, account_status)
SELECT 'Demo Buyer', '01700000003', 'buyer@demo.agromart',
       '$2b$12$GYLSZZ1t.LqT.7Htepue1e2YsJs3soKGTyaWClUFFYbr3Mb1w6wea', 'active'
WHERE NOT EXISTS (SELECT 1 FROM users WHERE phone = '01700000003');

INSERT INTO user_roles (user_id, role)
SELECT user_id, 'buyer' FROM users WHERE phone = '01700000003'
ON CONFLICT (user_id, role) DO NOTHING;

COMMIT;

-- Verify
SELECT u.user_id, u.full_name, u.phone, ur.role
FROM users u
JOIN user_roles ur ON ur.user_id = u.user_id
WHERE u.phone IN ('01700000001','01700000002','01700000003')
ORDER BY u.phone;
