#!/usr/bin/env bash
# Applies all AgroMart PostgreSQL migrations in the correct order.
# Usage:  ./apply_all.sh
# Env:    DB_NAME (default agromart) DB_USER (default agromart) DB_HOST (default localhost)
set -euo pipefail

DB_NAME="${DB_NAME:-agromart}"
DB_USER="${DB_USER:-agromart}"
DB_HOST="${DB_HOST:-localhost}"
PSQL="psql -U $DB_USER -d $DB_NAME -h $DB_HOST -v ON_ERROR_STOP=1"

echo "Applying migrations to $DB_NAME@$DB_HOST as $DB_USER"
for f in 000_prelude 001_init 002_reference 003_marketplace 004_transactions \
         005_payments 006_financial 007_agent 008_smart 009_views; do
    echo "==> $f.sql"
    $PSQL -f "$f.sql"
done

echo "==> seed.sql (optional reference/demo data)"
[ -f seed.sql ] && $PSQL -f seed.sql || echo "   (no seed.sql — skipping)"

echo ""
echo "DONE. Verify:"
echo "  $PSQL -c '\\dt'   # expect 39 tables"
echo "  $PSQL -c '\\dv'   # expect 2 views"
