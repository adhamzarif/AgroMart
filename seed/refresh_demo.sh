#!/usr/bin/env bash
# refresh_demo.sh — run before a demo to ensure DB has today's market prices
# and everything renders correctly. Idempotent, safe to re-run.
# Usage:  bash seed/refresh_demo.sh
set -euo pipefail

cd "$(dirname "$0")/.." 2>/dev/null || true
[ -d backend/src ] || { echo "ERROR: run this from ~/Documents/AgroMart"; exit 1; }

echo "==> Re-seeding today's market prices + price_history..."
psql -U agromart -d agromart -h localhost -f seed/seed_price_history.sql >/dev/null 2>&1 \
  && echo "  ✓ market_prices + price_history refreshed for today ($(date +%Y-%m-%d))"

echo ""
echo "==> Verifying data..."
TODAY_COUNT=$(psql -U agromart -d agromart -h localhost -tAc \
  "SELECT COUNT(*) FROM market_prices WHERE price_date = CURRENT_DATE;" | xargs)
CROP_COUNT=$(psql -U agromart -d agromart -h localhost -tAc \
  "SELECT COUNT(*) FROM crops WHERE status='available';" | xargs)
NULL_IMAGES=$(psql -U agromart -d agromart -h localhost -tAc \
  "SELECT COUNT(*) FROM crops WHERE status='available' AND images IS NULL;" | xargs)

echo "  Today's market_prices: $TODAY_COUNT   (expect 9)"
echo "  Available crops:       $CROP_COUNT   (expect 11)"
echo "  Crops missing images:  $NULL_IMAGES   (expect 0)"

if [ "$NULL_IMAGES" != "0" ]; then
  echo ""
  echo "==> Fixing crops with NULL images..."
  psql -U agromart -d agromart -h localhost -v ON_ERROR_STOP=1 << 'SQL' >/dev/null
UPDATE crops SET images = to_jsonb(ARRAY['/crops/tomato.jpg'])   WHERE crop_name='টমেটো'   AND images IS NULL;
UPDATE crops SET images = to_jsonb(ARRAY['/crops/lau.jpg'])      WHERE crop_name='লাউ'      AND images IS NULL;
UPDATE crops SET images = to_jsonb(ARRAY['/crops/kachamorich.jpg']) WHERE crop_name='কাঁচামরিচ' AND images IS NULL;
UPDATE crops SET images = to_jsonb(ARRAY['/crops/begun.jpg'])    WHERE crop_name='বেগুন'    AND images IS NULL;
UPDATE crops SET images = to_jsonb(ARRAY['/crops/alu.jpg'])      WHERE crop_name='আলু'      AND images IS NULL;
UPDATE crops SET images = to_jsonb(ARRAY['/crops/peyaj.jpg'])    WHERE crop_name='পেঁয়াজ'   AND images IS NULL;
UPDATE crops SET images = to_jsonb(ARRAY['/crops/shorisha.jpg']) WHERE crop_name='সরিষা'    AND images IS NULL;
UPDATE crops SET images = to_jsonb(ARRAY['/crops/mugdal.jpg'])   WHERE crop_name='মুগ ডাল'  AND images IS NULL;
UPDATE crops SET images = to_jsonb(ARRAY['/crops/mosurdal.jpg']) WHERE crop_name='মসুর ডাল' AND images IS NULL;
SQL
  echo "  ✓ null images patched"
fi

echo ""
echo "══════════════════════════════════════════════════"
echo "Demo data refreshed. Restart backend if needed:"
echo "  cd backend && npm run dev"
echo "══════════════════════════════════════════════════"
