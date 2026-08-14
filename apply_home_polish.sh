#!/usr/bin/env bash
# AgroMart — home polish: fix invisible hero CTA + install refresh_demo.sh
# Run from ~/Documents/AgroMart:  bash apply_home_polish.sh
set -euo pipefail
[ -d backend/src ] || { echo "ERROR: run from ~/Documents/AgroMart"; exit 1; }
say(){ echo "  $*"; }
mkdir -p seed

echo "==> [1/2] Installing seed/refresh_demo.sh..."
echo 'IyEvdXNyL2Jpbi9lbnYgYmFzaAojIHJlZnJlc2hfZGVtby5zaCDigJQgcnVuIGJlZm9yZSBhIGRlbW8gdG8gZW5zdXJlIERCIGhhcyB0b2RheSdzIG1hcmtldCBwcmljZXMKIyBhbmQgZXZlcnl0aGluZyByZW5kZXJzIGNvcnJlY3RseS4gSWRlbXBvdGVudCwgc2FmZSB0byByZS1ydW4uCiMgVXNhZ2U6ICBiYXNoIHNlZWQvcmVmcmVzaF9kZW1vLnNoCnNldCAtZXVvIHBpcGVmYWlsCgpjZCAiJChkaXJuYW1lICIkMCIpLy4uIiAyPi9kZXYvbnVsbCB8fCB0cnVlClsgLWQgYmFja2VuZC9zcmMgXSB8fCB7IGVjaG8gIkVSUk9SOiBydW4gdGhpcyBmcm9tIH4vRG9jdW1lbnRzL0Fncm9NYXJ0IjsgZXhpdCAxOyB9CgplY2hvICI9PT4gUmUtc2VlZGluZyB0b2RheSdzIG1hcmtldCBwcmljZXMgKyBwcmljZV9oaXN0b3J5Li4uIgpwc3FsIC1VIGFncm9tYXJ0IC1kIGFncm9tYXJ0IC1oIGxvY2FsaG9zdCAtZiBzZWVkL3NlZWRfcHJpY2VfaGlzdG9yeS5zcWwgPi9kZXYvbnVsbCAyPiYxIFwKICAmJiBlY2hvICIgIOKckyBtYXJrZXRfcHJpY2VzICsgcHJpY2VfaGlzdG9yeSByZWZyZXNoZWQgZm9yIHRvZGF5ICgkKGRhdGUgKyVZLSVtLSVkKSkiCgplY2hvICIiCmVjaG8gIj09PiBWZXJpZnlpbmcgZGF0YS4uLiIKVE9EQVlfQ09VTlQ9JChwc3FsIC1VIGFncm9tYXJ0IC1kIGFncm9tYXJ0IC1oIGxvY2FsaG9zdCAtdEFjIFwKICAiU0VMRUNUIENPVU5UKCopIEZST00gbWFya2V0X3ByaWNlcyBXSEVSRSBwcmljZV9kYXRlID0gQ1VSUkVOVF9EQVRFOyIgfCB4YXJncykKQ1JPUF9DT1VOVD0kKHBzcWwgLVUgYWdyb21hcnQgLWQgYWdyb21hcnQgLWggbG9jYWxob3N0IC10QWMgXAogICJTRUxFQ1QgQ09VTlQoKikgRlJPTSBjcm9wcyBXSEVSRSBzdGF0dXM9J2F2YWlsYWJsZSc7IiB8IHhhcmdzKQpOVUxMX0lNQUdFUz0kKHBzcWwgLVUgYWdyb21hcnQgLWQgYWdyb21hcnQgLWggbG9jYWxob3N0IC10QWMgXAogICJTRUxFQ1QgQ09VTlQoKikgRlJPTSBjcm9wcyBXSEVSRSBzdGF0dXM9J2F2YWlsYWJsZScgQU5EIGltYWdlcyBJUyBOVUxMOyIgfCB4YXJncykKCmVjaG8gIiAgVG9kYXkncyBtYXJrZXRfcHJpY2VzOiAkVE9EQVlfQ09VTlQgICAoZXhwZWN0IDkpIgplY2hvICIgIEF2YWlsYWJsZSBjcm9wczogICAgICAgJENST1BfQ09VTlQgICAoZXhwZWN0IDExKSIKZWNobyAiICBDcm9wcyBtaXNzaW5nIGltYWdlczogICROVUxMX0lNQUdFUyAgIChleHBlY3QgMCkiCgppZiBbICIkTlVMTF9JTUFHRVMiICE9ICIwIiBdOyB0aGVuCiAgZWNobyAiIgogIGVjaG8gIj09PiBGaXhpbmcgY3JvcHMgd2l0aCBOVUxMIGltYWdlcy4uLiIKICBwc3FsIC1VIGFncm9tYXJ0IC1kIGFncm9tYXJ0IC1oIGxvY2FsaG9zdCAtdiBPTl9FUlJPUl9TVE9QPTEgPDwgJ1NRTCcgPi9kZXYvbnVsbApVUERBVEUgY3JvcHMgU0VUIGltYWdlcyA9IHRvX2pzb25iKEFSUkFZWycvY3JvcHMvdG9tYXRvLmpwZyddKSAgIFdIRVJFIGNyb3BfbmFtZT0n4Kaf4Kau4KeH4Kaf4KeLJyAgIEFORCBpbWFnZXMgSVMgTlVMTDsKVVBEQVRFIGNyb3BzIFNFVCBpbWFnZXMgPSB0b19qc29uYihBUlJBWVsnL2Nyb3BzL2xhdS5qcGcnXSkgICAgICBXSEVSRSBjcm9wX25hbWU9J+CmsuCmvuCmiScgICAgICBBTkQgaW1hZ2VzIElTIE5VTEw7ClVQREFURSBjcm9wcyBTRVQgaW1hZ2VzID0gdG9fanNvbmIoQVJSQVlbJy9jcm9wcy9rYWNoYW1vcmljaC5qcGcnXSkgV0hFUkUgY3JvcF9uYW1lPSfgppXgpr7gpoHgpprgpr7gpq7gprDgpr/gpponIEFORCBpbWFnZXMgSVMgTlVMTDsKVVBEQVRFIGNyb3BzIFNFVCBpbWFnZXMgPSB0b19qc29uYihBUlJBWVsnL2Nyb3BzL2JlZ3VuLmpwZyddKSAgICBXSEVSRSBjcm9wX25hbWU9J+CmrOCnh+Cml+CngeCmqCcgICAgQU5EIGltYWdlcyBJUyBOVUxMOwpVUERBVEUgY3JvcHMgU0VUIGltYWdlcyA9IHRvX2pzb25iKEFSUkFZWycvY3JvcHMvYWx1LmpwZyddKSAgICAgIFdIRVJFIGNyb3BfbmFtZT0n4KaG4Kay4KeBJyAgICAgIEFORCBpbWFnZXMgSVMgTlVMTDsKVVBEQVRFIGNyb3BzIFNFVCBpbWFnZXMgPSB0b19qc29uYihBUlJBWVsnL2Nyb3BzL3BleWFqLmpwZyddKSAgICBXSEVSRSBjcm9wX25hbWU9J+CmquCnh+CmgeCmr+CmvOCmvuCmnCcgICBBTkQgaW1hZ2VzIElTIE5VTEw7ClVQREFURSBjcm9wcyBTRVQgaW1hZ2VzID0gdG9fanNvbmIoQVJSQVlbJy9jcm9wcy9zaG9yaXNoYS5qcGcnXSkgV0hFUkUgY3JvcF9uYW1lPSfgprjgprDgpr/gprfgpr4nICAgIEFORCBpbWFnZXMgSVMgTlVMTDsKVVBEQVRFIGNyb3BzIFNFVCBpbWFnZXMgPSB0b19qc29uYihBUlJBWVsnL2Nyb3BzL211Z2RhbC5qcGcnXSkgICBXSEVSRSBjcm9wX25hbWU9J+CmruCngeCmlyDgpqHgpr7gprInICBBTkQgaW1hZ2VzIElTIE5VTEw7ClVQREFURSBjcm9wcyBTRVQgaW1hZ2VzID0gdG9fanNvbmIoQVJSQVlbJy9jcm9wcy9tb3N1cmRhbC5qcGcnXSkgV0hFUkUgY3JvcF9uYW1lPSfgpq7gprjgp4HgprAg4Kah4Ka+4KayJyBBTkQgaW1hZ2VzIElTIE5VTEw7ClNRTAogIGVjaG8gIiAg4pyTIG51bGwgaW1hZ2VzIHBhdGNoZWQiCmZpCgplY2hvICIiCmVjaG8gIuKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkOKVkCIKZWNobyAiRGVtbyBkYXRhIHJlZnJlc2hlZC4gUmVzdGFydCBiYWNrZW5kIGlmIG5lZWRlZDoiCmVjaG8gIiAgY2QgYmFja2VuZCAmJiBucG0gcnVuIGRldiIKZWNobyAi4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQ4pWQIgo=' | base64 -d > seed/refresh_demo.sh && chmod +x seed/refresh_demo.sh && say 'wrote seed/refresh_demo.sh'

echo "==> [2/2] Fixing hero CTA button (visible text)..."
python3 - frontend/src/pages/Home.jsx << 'PY'
import sys, re
f = sys.argv[1]
s = open(f).read()
if 'HERO_CTA_PATCHED' in s:
    print("  already patched (skip)"); sys.exit(0)

# The button uses className="bg-white text-m1" — force inline style so no CSS conflict can hide text.
# Also add explicit inline style with the green so 'text-m1' being purged from Tailwind can't blank it.
old = '<Button variant="solid" className="bg-white text-m1 hover:bg-white/90">'
new = '<Button variant="solid" className="bg-white hover:bg-white/90" style={{ color: \'#2e7d32\', fontWeight: 700 }}>'
if old in s:
    s = s.replace(old, new, 1)
    s = "// HERO_CTA_PATCHED\n" + s
    open(f, 'w').write(s)
    print("  patched Home.jsx hero button")
else:
    print("  WARNING: expected hero button className not found; leaving Home.jsx untouched")
    print("  If your Home.jsx has been customized, tell me the current state.")
PY

echo ""
echo "════ Done. ════"
echo ""
echo "1. Hard-refresh http://localhost:5173/  — hero button should now show 'Get started' / 'শুরু করুন'"
echo ""
echo "2. Before EACH demo (or if things look stale after a day):"
echo "     bash seed/refresh_demo.sh"
echo "   That re-seeds today's market_prices, verifies crop count + images,"
echo "   and fixes any NULL images that snuck in."
