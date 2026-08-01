#!/usr/bin/env bash
# AgroMart — database verification. Run after applying migrations 000-009.
# Usage:  DB_USER=agromart DB_NAME=agromart bash verify_db.sh
# Every check prints PASS or FAIL with what was expected.
set -uo pipefail

DB_NAME="${DB_NAME:-agromart}"
DB_USER="${DB_USER:-agromart}"
DB_HOST="${DB_HOST:-localhost}"
Q="psql -U $DB_USER -d $DB_NAME -h $DB_HOST -tA -c"   # -tA = tuples only, unaligned

pass=0; fail=0
check() {  # check "label" "actual" "expected"
  if [ "$2" = "$3" ]; then echo "  PASS  $1 ($2)"; pass=$((pass+1))
  else echo "  FAIL  $1 — got '$2', expected '$3'"; fail=$((fail+1)); fi
}
expect_error() {  # expect_error "label" "sql that SHOULD be rejected"
  if psql -U "$DB_USER" -d "$DB_NAME" -h "$DB_HOST" -c "$2" >/dev/null 2>&1; then
    echo "  FAIL  $1 — was allowed but should have been rejected"; fail=$((fail+1))
  else echo "  PASS  $1 (correctly rejected)"; pass=$((pass+1)); fi
}

echo "== 1. STRUCTURE =="
check "39 base tables" "$($Q "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='public' AND table_type='BASE TABLE';")" "39"
check "2 views" "$($Q "SELECT COUNT(*) FROM information_schema.views WHERE table_schema='public';")" "2"
check "foreign keys present" "$($Q "SELECT COUNT(*) FROM information_schema.table_constraints WHERE constraint_type='FOREIGN KEY';")" "72"
check "triggers present" "$($Q "SELECT COUNT(*) FROM information_schema.triggers;")" "15"

echo "== 2. TYPES CONVERTED (no MySQL leftovers) =="
check "is_organic is boolean" "$($Q "SELECT data_type FROM information_schema.columns WHERE table_name='crops' AND column_name='is_organic';")" "boolean"
check "crop_id is identity" "$($Q "SELECT is_identity FROM information_schema.columns WHERE table_name='crops' AND column_name='crop_id';")" "YES"
check "images is jsonb" "$($Q "SELECT data_type FROM information_schema.columns WHERE table_name='crops' AND column_name='images';")" "jsonb"
check "created_at is timestamptz" "$($Q "SELECT data_type FROM information_schema.columns WHERE table_name='users' AND column_name='created_at';")" "timestamp with time zone"

echo "== 3. CONSTRAINTS ENFORCE (these inserts SHOULD be rejected) =="
# seed one district + user so FK-valid rows exist
psql -U "$DB_USER" -d "$DB_NAME" -h "$DB_HOST" -c \
  "INSERT INTO districts (district_name,division) VALUES ('VCheck','Dhaka') ON CONFLICT DO NOTHING;" >/dev/null 2>&1
DID=$($Q "SELECT district_id FROM districts WHERE district_name='VCheck';")
psql -U "$DB_USER" -d "$DB_NAME" -h "$DB_HOST" -c \
  "INSERT INTO users (full_name,phone,password_hash,district_id) VALUES ('VUser','01900000001','x',$DID) ON CONFLICT DO NOTHING;" >/dev/null 2>&1
TUID=$($Q "SELECT user_id FROM users WHERE phone='01900000001';")

expect_error "reject bad enum (account_status)" \
  "UPDATE users SET account_status='banana' WHERE user_id=$TUID;"
expect_error "reject duplicate phone (UNIQUE)" \
  "INSERT INTO users (full_name,phone,password_hash,district_id) VALUES ('Dup','01900000001','x',$DID);"
expect_error "reject FK to missing district" \
  "INSERT INTO users (full_name,phone,password_hash,district_id) VALUES ('BadFK','01900000002','x',999999);"
expect_error "reject message sender=receiver" \
  "INSERT INTO messages (sender_id,receiver_id,message_text) VALUES ($TUID,$TUID,'hi');"
expect_error "reject negative crop quantity (CHECK)" \
  "INSERT INTO crops (farmer_id,category_id,crop_name,quantity,unit,price_per_unit,available_from) VALUES ($TUID,1,'x',-5,'kg',10,CURRENT_DATE);"

echo "== 4. WALLET TRIGGER (behavioural) =="
psql -U "$DB_USER" -d "$DB_NAME" -h "$DB_HOST" -c \
  "INSERT INTO transactions (user_id,transaction_type,amount,transaction_status) VALUES ($TUID,'deposit',500,'completed');" >/dev/null 2>&1
check "deposit credits wallet" "$($Q "SELECT wallet_balance FROM users WHERE user_id=$TUID;")" "500.00"
psql -U "$DB_USER" -d "$DB_NAME" -h "$DB_HOST" -c \
  "INSERT INTO transactions (user_id,transaction_type,amount,transaction_status) VALUES ($TUID,'withdrawal',200,'completed');" >/dev/null 2>&1
check "withdrawal debits wallet" "$($Q "SELECT wallet_balance FROM users WHERE user_id=$TUID;")" "300.00"
check "balance_before/after stamped" "$($Q "SELECT balance_after FROM transactions WHERE user_id=$TUID ORDER BY transaction_id DESC LIMIT 1;")" "300.00"

echo "== 5. VIEWS QUERYABLE =="
check "vw_farmer_performance runs" "$($Q "SELECT COUNT(*) >= 0 FROM vw_farmer_performance;" 2>/dev/null)" "t"
check "vw_active_crops_with_details runs" "$($Q "SELECT COUNT(*) >= 0 FROM vw_active_crops_with_details;" 2>/dev/null)" "t"

echo "== 6. updated_at TRIGGER =="
OLD=$($Q "SELECT updated_at FROM users WHERE user_id=$TUID;")
sleep 1
psql -U "$DB_USER" -d "$DB_NAME" -h "$DB_HOST" -c "UPDATE users SET full_name='VUser2' WHERE user_id=$TUID;" >/dev/null 2>&1
NEW=$($Q "SELECT updated_at FROM users WHERE user_id=$TUID;")
if [ "$OLD" != "$NEW" ]; then echo "  PASS  updated_at auto-updates"; pass=$((pass+1));
else echo "  FAIL  updated_at did not change"; fail=$((fail+1)); fi

# cleanup test rows
psql -U "$DB_USER" -d "$DB_NAME" -h "$DB_HOST" -c \
  "DELETE FROM transactions WHERE user_id=$TUID; DELETE FROM users WHERE user_id=$TUID; DELETE FROM districts WHERE district_name='VCheck';" >/dev/null 2>&1

echo ""
echo "════════════════════════════════════"
echo "  PASSED: $pass    FAILED: $fail"
[ $fail -eq 0 ] && echo "  ALL CHECKS PASSED ✓" || echo "  SOME CHECKS FAILED — see above"
echo "════════════════════════════════════"
