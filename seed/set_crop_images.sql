-- set_crop_images.sql — put a real, name-matched photo on every crop.
-- Matches by crop_name so it works regardless of crop_id / duplicates.
-- Images are stored as a JSONB array (schema design). Uses Wikimedia Commons
-- (freely licensed) so links are stable and legal for a demo.
-- Run:  psql -U agromart -d agromart -h localhost -f set_crop_images.sql

BEGIN;

UPDATE crops SET images = to_jsonb(ARRAY[img]) FROM (VALUES
  ('কাঁচামরিচ', 'https://upload.wikimedia.org/wikipedia/commons/thumb/6/60/Green_chili_pepper.jpg/640px-Green_chili_pepper.jpg'),
  ('বেগুন',    'https://upload.wikimedia.org/wikipedia/commons/thumb/9/95/Aubergines.jpg/640px-Aubergines.jpg'),
  ('লাউ',      'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5e/Bottle_gourd_or_lauki.jpg/640px-Bottle_gourd_or_lauki.jpg'),
  ('সরিষা',    'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6d/Mustard_flowers_field.jpg/640px-Mustard_flowers_field.jpg'),
  ('মুগ ডাল',  'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6f/Mung_beans_%28Vigna_radiata%29.jpg/640px-Mung_beans_%28Vigna_radiata%29.jpg'),
  ('মসুর ডাল', 'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2e/Lentils_-_Masoor_Dal.jpg/640px-Lentils_-_Masoor_Dal.jpg'),
  ('আলু',      'https://upload.wikimedia.org/wikipedia/commons/thumb/9/98/Patates.jpg/640px-Patates.jpg'),
  ('টমেটো',    'https://upload.wikimedia.org/wikipedia/commons/thumb/8/89/Tomato_je.jpg/640px-Tomato_je.jpg'),
  ('পেঁয়াজ',  'https://upload.wikimedia.org/wikipedia/commons/thumb/2/25/Onions.jpg/640px-Onions.jpg')
) AS m(name, img)
WHERE crops.crop_name = m.name;

COMMIT;

SELECT crop_name, images FROM crops WHERE status='available' ORDER BY crop_id;
