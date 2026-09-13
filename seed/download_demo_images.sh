#!/usr/bin/env bash
# Downloads real crop photos into frontend/public/crops and points the DB at them.
# Run from ~/Documents/AgroMart.
set -euo pipefail
DIR=frontend/public/crops
mkdir -p "$DIR"
echo "Downloading crop photos..."
for pair in "kachamorich:chili-pepper" "begun:eggplant" "lau:bottle-gourd" \
            "alu:potato" "tomato:tomato" "peyaj:onion" \
            "shorisha:mustard-field" "mugdal:mung-beans" "mosurdal:lentils"; do
  name="${pair%%:*}"; kw="${pair##*:}"
  curl -sL "https://source.unsplash.com/640x480/?$kw" -o "$DIR/$name.jpg" && echo "  got $name.jpg"
done
echo "Pointing DB at local images..."
psql -U agromart -d agromart -h localhost << 'SQL'
UPDATE crops SET images = to_jsonb(ARRAY['/crops/kachamorich.jpg']) WHERE crop_name='কাঁচামরিচ';
UPDATE crops SET images = to_jsonb(ARRAY['/crops/begun.jpg'])       WHERE crop_name='বেগুন';
UPDATE crops SET images = to_jsonb(ARRAY['/crops/lau.jpg'])         WHERE crop_name='লাউ';
UPDATE crops SET images = to_jsonb(ARRAY['/crops/alu.jpg'])         WHERE crop_name='আলু';
UPDATE crops SET images = to_jsonb(ARRAY['/crops/tomato.jpg'])      WHERE crop_name='টমেটো';
UPDATE crops SET images = to_jsonb(ARRAY['/crops/peyaj.jpg'])       WHERE crop_name='পেঁয়াজ';
UPDATE crops SET images = to_jsonb(ARRAY['/crops/shorisha.jpg'])    WHERE crop_name='সরিষা';
UPDATE crops SET images = to_jsonb(ARRAY['/crops/mugdal.jpg'])      WHERE crop_name='মুগ ডাল';
UPDATE crops SET images = to_jsonb(ARRAY['/crops/mosurdal.jpg'])    WHERE crop_name='মসুর ডাল';
SQL
echo "Done. Hard-refresh the marketplace."
