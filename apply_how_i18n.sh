#!/usr/bin/env bash
set -e
export PYTHONUTF8=1
export PYTHONIOENCODING=utf-8

STRINGS_FILE="frontend/src/i18n/strings.js"
if [ ! -f "$STRINGS_FILE" ]; then
  echo "ERROR: $STRINGS_FILE not found. Run from project root."
  exit 1
fi

echo "==> Patching $STRINGS_FILE"

python <<'PYEOF'
import io, re, sys

path = "frontend/src/i18n/strings.js"
with io.open(path, "r", encoding="utf-8") as f:
    src = f.read()

BN_BLOCK = """    // HowItWorks
    how_badge: 'কীভাবে এটি কাজ করে',
    how_title: 'AgroMart কীভাবে কাজ করে',
    how_sub: 'কৃষক, ক্রেতা এবং এজেন্টদের জন্য সহজ ধাপ — একই প্ল্যাটফর্মে সরাসরি বিক্রি, স্বচ্ছ মূল্য ও নিরাপদ লেনদেন।',
    role_farmer: 'কৃষক',
    role_farmer_sub: 'আপনার ফসল সরাসরি বিক্রি করুন',
    role_buyer: 'ক্রেতা',
    role_buyer_sub: 'সরাসরি কৃষকের কাছ থেকে কিনুন',
    role_agent: 'এজেন্ট',
    role_agent_sub: 'কৃষক ও ক্রেতার মধ্যে সেতুবন্ধন',
    step_f1: 'রেজিস্টার করুন এবং প্রোফাইল সম্পূর্ণ করুন।',
    step_f2: 'আপনার ফসল তালিকাভুক্ত করুন — পরিমাণ, দাম, ছবি।',
    step_f3: 'অর্ডার গ্রহণ করুন এবং সরাসরি ক্রেতার সাথে যোগাযোগ।',
    step_f4: 'নিরাপদ পেমেন্ট গ্রহণ করুন এবং ডেলিভারি নিশ্চিত করুন।',
    step_b1: 'অ্যাকাউন্ট তৈরি করুন এবং ঠিকানা যোগ করুন।',
    step_b2: 'মার্কেটপ্লেসে ফসল ব্রাউজ করুন এবং লাইভ দাম দেখুন।',
    step_b3: 'অর্ডার দিন এবং নিরাপদ পেমেন্ট সম্পন্ন করুন।',
    step_b4: 'ডেলিভারি বুঝে নিন এবং কৃষককে রেটিং দিন।',
    step_a1: 'এজেন্ট হিসেবে রেজিস্টার করুন এবং যাচাই সম্পন্ন করুন।',
    step_a2: 'আপনার এলাকার কৃষকদের সাথে সংযোগ স্থাপন করুন।',
    step_a3: 'অর্ডার ও লেনদেন সমন্বয় করুন।',
    step_a4: 'কমিশন উপার্জন করুন এবং কৃষককে সহায়তা করুন।',
    how_stats_title: 'বাস্তব সংখ্যা — আজকের প্ল্যাটফর্ম',
    stat_crops: 'উপলব্ধ ফসল',
    stat_districts: 'সেবা প্রদত্ত জেলা',
    how_cta_title: 'আজই শুরু করুন',
    how_cta_sub: 'বিনামূল্যে রেজিস্টার করুন, দাম দেখুন, এবং সরাসরি কৃষি বাজারে যোগ দিন।',
"""

EN_BLOCK = """    // HowItWorks
    how_badge: 'How it works',
    how_title: 'How AgroMart works',
    how_sub: 'Simple steps for farmers, buyers, and agents — direct sales, transparent prices, and secure transactions on one platform.',
    role_farmer: 'Farmer',
    role_farmer_sub: 'Sell your crops directly',
    role_buyer: 'Buyer',
    role_buyer_sub: 'Buy straight from farmers',
    role_agent: 'Agent',
    role_agent_sub: 'Bridge farmers and buyers',
    step_f1: 'Register and complete your profile.',
    step_f2: 'List your crops — quantity, price, photos.',
    step_f3: 'Accept orders and connect with buyers directly.',
    step_f4: 'Receive secure payments and confirm delivery.',
    step_b1: 'Create an account and add your address.',
    step_b2: 'Browse crops in the marketplace and view live prices.',
    step_b3: 'Place an order and complete secure payment.',
    step_b4: 'Receive delivery and rate the farmer.',
    step_a1: 'Register as an agent and complete verification.',
    step_a2: 'Connect with farmers in your area.',
    step_a3: 'Coordinate orders and transactions.',
    step_a4: 'Earn commission and support farmers.',
    how_stats_title: 'Real numbers — the platform today',
    stat_crops: 'Available crops',
    stat_districts: 'Districts served',
    how_cta_title: 'Get started today',
    how_cta_sub: 'Register for free, browse live prices, and join the direct agri-marketplace.',
"""

if "how_title" in src and "stat_crops" in src:
    print("  Already patched — skipping.")
    sys.exit(0)

pattern = re.compile(r"(    market_empty: '[^']*',\n)")
matches = list(pattern.finditer(src))

if len(matches) < 2:
    print(f"  ERROR: expected 2 'market_empty' anchors, found {len(matches)}.")
    sys.exit(1)

bn_end = matches[0].end()
en_end = matches[1].end()

new_src = src[:en_end] + EN_BLOCK + src[en_end:]
new_src = new_src[:bn_end] + BN_BLOCK + new_src[bn_end:]

with io.open(path, "w", encoding="utf-8") as f:
    f.write(new_src)

print("  Inserted BN block after bn: market_empty")
print("  Inserted EN block after en: market_empty")
print("  27 keys per language added.")
PYEOF

echo "==> Done. Refresh browser with Ctrl+Shift+R at http://localhost:5173/how-it-works"
