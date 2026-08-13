-- seed_price_history.sql
-- Seeds market_prices (today's bazar rates) and 7 days of price_history so the
-- Live Prices page has real trend data to compute arrows from. Safe to re-run.
-- Run: psql -U agromart -d agromart -h localhost -f seed_price_history.sql

BEGIN;

-- Make sure the reference district exists (used as the "market")
INSERT INTO districts (district_name, division)
VALUES ('Dhaka','Dhaka')
ON CONFLICT (district_name) DO NOTHING;

-- Today's bazar rates for the 9 seed crops. Each is (crop_name, wholesale, retail).
-- Retail is the "bazar rate" shown as bazar_rate; wholesale is the market-buyer level.
DELETE FROM market_prices WHERE price_date = CURRENT_DATE
  AND crop_name IN ('কাঁচামরিচ','বেগুন','লাউ','সরিষা','মুগ ডাল','মসুর ডাল','আলু','টমেটো','পেঁয়াজ');

INSERT INTO market_prices (crop_name, district_id, wholesale_price, retail_price, unit, price_date, source)
SELECT c.name, (SELECT district_id FROM districts WHERE district_name='Dhaka'),
       c.wp, c.rp, c.unit, CURRENT_DATE, 'DAM'
FROM (VALUES
  ('কাঁচামরিচ',  50.00, 75.00, 'kg'),
  ('বেগুন',      35.00, 55.00, 'kg'),
  ('লাউ',        18.00, 30.00, 'piece'),
  ('সরিষা',      65.00, 90.00, 'kg'),
  ('মুগ ডাল',   120.00,160.00, 'kg'),
  ('মসুর ডাল',  100.00,140.00, 'kg'),
  ('আলু',        22.00, 35.00, 'kg'),
  ('টমেটো',      38.00, 60.00, 'kg'),
  ('পেঁয়াজ',    48.00, 70.00, 'kg')
) AS c(name, wp, rp, unit);

-- 7 days of history for each — realistic ±10% wobble per day, with a slight trend
-- so arrows have direction. Seed uses a repeatable formula.
DELETE FROM price_history WHERE price_date >= CURRENT_DATE - INTERVAL '7 days'
  AND crop_name IN ('কাঁচামরিচ','বেগুন','লাউ','সরিষা','মুগ ডাল','মসুর ডাল','আলু','টমেটো','পেঁয়াজ');

INSERT INTO price_history (crop_name, district_id, wholesale_price, retail_price, unit, price_date)
SELECT c.name,
       (SELECT district_id FROM districts WHERE district_name='Dhaka'),
       ROUND((c.wp * (1 + c.trend * d / 7.0) * (0.95 + 0.10 * ((d * 3) % 7) / 7.0))::numeric, 2),
       ROUND((c.rp * (1 + c.trend * d / 7.0) * (0.95 + 0.10 * ((d * 3) % 7) / 7.0))::numeric, 2),
       c.unit,
       CURRENT_DATE - (d || ' days')::interval
FROM (VALUES
  ('কাঁচামরিচ',  50.00, 75.00, 'kg',   0.12),   -- rising
  ('বেগুন',      35.00, 55.00, 'kg',  -0.08),   -- falling
  ('লাউ',        18.00, 30.00, 'piece', 0.02),  -- stable
  ('সরিষা',      65.00, 90.00, 'kg',   0.05),   -- rising a bit
  ('মুগ ডাল',   120.00,160.00, 'kg',  -0.03),   -- slightly falling
  ('মসুর ডাল',  100.00,140.00, 'kg',   0.01),   -- stable
  ('আলু',        22.00, 35.00, 'kg',  -0.15),   -- falling
  ('টমেটো',      38.00, 60.00, 'kg',   0.20),   -- rising sharply
  ('পেঁয়াজ',    48.00, 70.00, 'kg',   0.08)    -- rising
) AS c(name, wp, rp, unit, trend),
generate_series(1, 7) AS d;

COMMIT;

-- Show what we have
SELECT crop_name, wholesale_price, retail_price, price_date
FROM price_history
WHERE price_date >= CURRENT_DATE - INTERVAL '7 days'
ORDER BY crop_name, price_date DESC
LIMIT 15;
