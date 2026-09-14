-- Regenerate 90 days of history for market_prices. Safe to re-run.
DELETE FROM market_prices WHERE source = 'SEED';
DO $$
DECLARE
  crops TEXT[] := ARRAY['লাউ', 'কাঁচামরিচ', 'বেগুন', 'আলু', 'টমেটো', 'পেঁয়াজ', 'সরিষা', 'মুগ ডাল', 'মসুর ডাল'];
  units TEXT[] := ARRAY['piece', 'kg', 'kg', 'kg', 'kg', 'kg', 'kg', 'kg', 'kg'];
  base_wholesale NUMERIC[] := ARRAY[20, 75, 45, 27, 50, 55, 80, 130, 110];
  retail_ratio NUMERIC[] := ARRAY[1.45, 1.42, 1.44, 1.48, 1.46, 1.40, 1.35, 1.28, 1.30];
  ci INT; di INT; day_offset INT;
  wholesale NUMERIC; retail NUMERIC;
  noise NUMERIC; drift NUMERIC; shock NUMERIC;
  district_multiplier NUMERIC;
BEGIN
  FOR ci IN 1..array_length(crops, 1) LOOP
    FOR di IN 1..9 LOOP
      district_multiplier := 0.85 + (di * 0.04);
      FOR day_offset IN 0..89 LOOP
        noise := 0.94 + random() * 0.12;
        drift := 1.0 + ((day_offset - 45) * 0.003 * (CASE WHEN ci % 2 = 0 THEN -1 ELSE 1 END));
        shock := CASE WHEN random() < 0.05 THEN 0.85 + random() * 0.30 ELSE 1.0 END;
        wholesale := ROUND(base_wholesale[ci] * district_multiplier * noise * drift * shock, 2);
        retail := ROUND(wholesale * retail_ratio[ci], 2);
        INSERT INTO market_prices (crop_name, district_id, wholesale_price, retail_price, unit, price_date, source)
        VALUES (crops[ci], di, wholesale, retail, units[ci], CURRENT_DATE - day_offset, 'SEED')
        ON CONFLICT (crop_name, district_id, price_date) DO NOTHING;
      END LOOP;
    END LOOP;
  END LOOP;
END $$;
