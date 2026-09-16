-- Seed 5 buyers + 15 orders + 15 ratings for the Trust & Ratings feature.
-- All reviews are for user_id=1 (আব্দুল হালিম).
-- Safe to re-run: cleans up prior seed data first.

-- 1. Clean prior seed (delete in FK order)
DELETE FROM farmer_ratings WHERE farmer_id = 1;
DELETE FROM orders WHERE farmer_id = 1;
DELETE FROM user_roles WHERE user_id BETWEEN 2 AND 6;
DELETE FROM users WHERE user_id BETWEEN 2 AND 6;

-- Reset sequence so buyer_id starts at 2
SELECT setval(pg_get_serial_sequence('users', 'user_id'), 1, true);

-- 2. Seed 5 buyer users
INSERT INTO users (full_name, phone, password_hash, district_id, address, phone_verified, preferred_language) VALUES
('রফিকুল ইসলাম',    '01711000001', '$2b$10$dummy.hash.for.seed.data.only.aaaaaaaaaaaaaaaaaaaaa', 1, 'বনানী, ঢাকা',       true, 'bn'),
('সাবিনা ইয়াসমিন',  '01711000002', '$2b$10$dummy.hash.for.seed.data.only.aaaaaaaaaaaaaaaaaaaaa', 2, 'আগ্রাবাদ, চট্টগ্রাম', true, 'bn'),
('কামাল হোসেন',    '01711000003', '$2b$10$dummy.hash.for.seed.data.only.aaaaaaaaaaaaaaaaaaaaa', 3, 'বোয়ালিয়া, রাজশাহী',  true, 'bn'),
('নাসরিন সুলতানা', '01711000004', '$2b$10$dummy.hash.for.seed.data.only.aaaaaaaaaaaaaaaaaaaaa', 5, 'জিন্দাবাজার, সিলেট',  true, 'bn'),
('ইমরান হাসান',    '01711000005', '$2b$10$dummy.hash.for.seed.data.only.aaaaaaaaaaaaaaaaaaaaa', 1, 'মিরপুর, ঢাকা',        true, 'bn');

-- 3. Assign 'buyer' role to each new user
INSERT INTO user_roles (user_id, role)
SELECT user_id, 'buyer' FROM users WHERE user_id BETWEEN 2 AND 6;

-- 4. Seed 15 orders (3 per buyer, spread across the 9 crops)
DO $$
DECLARE
  buyer_id_val INT;
  crop_ids INT[] := ARRAY(SELECT crop_id FROM crops WHERE farmer_id = 1 ORDER BY crop_id LIMIT 9);
  crop_price NUMERIC;
  crop_unit  TEXT;
  order_no   TEXT;
  qty        NUMERIC;
  ord_id     INT;
  days_ago   INT;
BEGIN
  IF array_length(crop_ids, 1) IS NULL THEN
    RAISE EXCEPTION 'No crops found for farmer_id=1 — seed crops first';
  END IF;

  FOR buyer_id_val IN 2..6 LOOP
    FOR i IN 1..3 LOOP
      -- pick a crop, cycling through
      SELECT price_per_unit, unit
        INTO crop_price, crop_unit
        FROM crops
        WHERE crop_id = crop_ids[1 + ((buyer_id_val * 3 + i) % array_length(crop_ids, 1))];

      qty := 5 + (random() * 20)::int;
      days_ago := 3 + (random() * 60)::int;
      order_no := 'ORD-2026-' || LPAD((buyer_id_val * 10 + i)::text, 5, '0');

      INSERT INTO orders (
        order_number, buyer_id, farmer_id,
        crop_id, quantity_ordered, unit_price, subtotal, total_amount,
        order_status, payment_status, delivery_type,
        order_date, confirmed_at, delivered_at
      )
      VALUES (
        order_no, buyer_id_val, 1,
        crop_ids[1 + ((buyer_id_val * 3 + i) % array_length(crop_ids, 1))],
        qty, crop_price, qty * crop_price, qty * crop_price + 50,
        'delivered', 'paid', 'home_delivery',
        NOW() - (days_ago || ' days')::interval,
        NOW() - ((days_ago - 1) || ' days')::interval,
        NOW() - ((days_ago - 2) || ' days')::interval
      )
      RETURNING order_id INTO ord_id;
    END LOOP;
  END LOOP;
END $$;

-- 5. Seed a rating for each delivered order
DO $$
DECLARE
  o RECORD;
  overall NUMERIC;
  quality NUMERIC;
  delivery NUMERIC;
  communication NUMERIC;
  titles TEXT[] := ARRAY[
    'দারুণ মানের ফসল!',
    'সময়মতো ডেলিভারি',
    'তাজা এবং ভালো প্যাকেজিং',
    'সৎ ও বিশ্বস্ত বিক্রেতা',
    'দাম অনুযায়ী চমৎকার',
    'বার বার কিনবো',
    'ভালো যোগাযোগ, দ্রুত সেবা',
    'সেরা গুণমান পেয়েছি',
    'পরিমাণ সঠিক',
    'সন্তুষ্ট',
    'উত্তম সেবা',
    'বিশ্বাসযোগ্য কৃষক',
    'দ্রুত ডেলিভারি ঢাকায়',
    'পরিবারের সবাই খুশি',
    'নিয়মিত অর্ডার দিব'
  ];
  reviews TEXT[] := ARRAY[
    'ফসল খুবই তাজা ছিল। প্যাকেজিং ভালো। রফিকুল সাহেব খুবই ভদ্র মানুষ।',
    'অর্ডারের ২ দিনের মধ্যে বাসায় পৌঁছেছে। মান দেখে অবাক হয়েছি।',
    'কৃষক নিজে ফোনে কথা বলেছেন, ফসলের ব্যাপারে সব বিস্তারিত বলেছেন।',
    'পরিমাণ এবং দাম দুইটাই ঠিক ছিল। কোনো ঝামেলা হয়নি।',
    'বাজারের চেয়ে সস্তা পেয়েছি, কিন্তু গুণমান বাজারের চেয়ে ভালো।',
    'AgroMart-এ কেনাকাটা করে খুবই ভালো লাগলো। মধ্যস্বত্বভোগী নেই।',
    'পরিবারের জন্য নিয়মিত কিনবো। বিশ্বাস তৈরি হয়েছে।',
    'তরকারি রান্না করে খুবই সুস্বাদু হয়েছে। প্রাকৃতিক স্বাদ পেয়েছি।',
    'কৃষকের সাথে সরাসরি কথা বলে খুব ভালো লেগেছে। কৃষি সম্পর্কেও জানলাম।',
    'দ্রুত ডেলিভারি এবং সঠিক পরিমাণ। পাঁচ তারা!',
    'এত ভালো ফসল অনেক দিন পাইনি। বিশেষ করে পাকা ও তাজা।',
    'পেমেন্ট সিস্টেমও সহজ। বিকাশ দিয়ে করেছি, সাথে সাথে কনফার্মেশন।',
    'অন্য কৃষকদের কাছ থেকেও অর্ডার করব। প্ল্যাটফর্মটা দারুণ।',
    'বন্ধুদের রেকমেন্ড করেছি। সবাই খুবই পছন্দ করেছে।',
    'সংক্ষেপে বলতে গেলে — চমৎকার অভিজ্ঞতা!'
  ];
  idx INT := 1;
BEGIN
  FOR o IN SELECT order_id, buyer_id, farmer_id, delivered_at FROM orders WHERE farmer_id = 1 ORDER BY order_id LOOP
    -- rating distribution biased toward good: mostly 4-5, a few 3s
    overall       := CASE WHEN random() < 0.7 THEN 4.5 + (random() * 0.5) ELSE 3.5 + (random() * 1.0) END;
    quality       := LEAST(5.0, overall + (random() * 0.4 - 0.2));
    delivery      := LEAST(5.0, overall + (random() * 0.4 - 0.2));
    communication := LEAST(5.0, overall + (random() * 0.4 - 0.2));

    INSERT INTO farmer_ratings (
      farmer_id, buyer_id, order_id,
      overall_rating, quality_rating, delivery_rating, communication_rating,
      review_title, review_text, would_recommend,
      is_verified_purchase, helpful_count,
      created_at
    )
    VALUES (
      o.farmer_id, o.buyer_id, o.order_id,
      ROUND(overall, 1),
      ROUND(quality, 1),
      ROUND(delivery, 1),
      ROUND(communication, 1),
      titles[1 + ((idx - 1) % array_length(titles, 1))],
      reviews[1 + ((idx - 1) % array_length(reviews, 1))],
      overall >= 4.0,
      true,
      (random() * 20)::int,
      o.delivered_at + INTERVAL '1 day'
    );

    idx := idx + 1;
  END LOOP;
END $$;
