-- Demo alerts for user_id=1 (আব্দুল হালিম).
-- Chosen so at least one triggers on today's seeded market prices,
-- and one stays untriggered — page looks alive.
-- Safe to re-run.

DELETE FROM price_alerts WHERE user_id = 1;

INSERT INTO price_alerts (user_id, crop_name, district_id, direction, target_price, is_active) VALUES
-- Fires when কাঁচামরিচ retail hits ৳100+ anywhere (target ৳100, market ~৳90-130)
(1, 'কাঁচামরিচ', NULL, 'above', 100.00, true),

-- Fires when আলু retail drops to ৳30 or below in Rangamati (id=9)
(1, 'আলু',       9,    'below', 30.00,  true),

-- Doesn't fire yet — টমেটো would need to spike to ৳150 (unrealistic given ~৳60-90)
(1, 'টমেটো',    NULL, 'above', 150.00, true),

-- Inactive one — user paused it
(1, 'বেগুন',      1,    'above', 70.00,  false);
