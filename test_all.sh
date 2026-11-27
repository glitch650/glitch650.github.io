#!/bin/bash
echo "===== GLITCH650 FULL TEST - ROUND 2 ====="
echo ""
echo "--- 1. LIVE SITE STATUS ---"
for url in "https://glitch650.github.io/" "https://glitch650.github.io/admin.html"; do
  code=$(curl -s -o /dev/null -w "%{http_code}" "$url?v=$(date +%s)")
  if [ "$code" = "200" ]; then echo "✅ PASS: $url -> 200"; else echo "❌ FAIL: $url -> $code"; fi
done
echo ""
echo "--- 2. FILES ---"
for f in index.html admin.html profile.jpg; do
  [ -f "$f" ] && echo "✅ PASS: $f" || echo "❌ FAIL: $f MISSING"
done
echo ""
echo "--- 3. CONTROL CENTER / G ICON ---"
grep -q "Control Center" admin.html && echo "✅ PASS: Control Center" || echo "❌ FAIL: Control Center missing"
grep -q "fbLogo.*display:none\|display:none.*fbLogo" admin.html && echo "✅ PASS: G icon hidden" || echo "❌ FAIL: G icon NOT hidden"
echo ""
echo "--- 4. SETTINGS LUXURY WHATSAPP ---"
for k in "waSettings" "d4af37" "PREMIUM" "Appearance" "Subscriptions" "Linked devices" "Privacy"; do
  grep -q "$k" admin.html && echo "✅ PASS: $k" || echo "❌ FAIL: $k missing"
done
echo ""
echo "--- 5. THEME SMART ---"
for k in "setThemeSmart" "toggleThemeSmart" "applySmartTheme"; do
  grep -q "$k" admin.html && echo "✅ PASS: $k" || echo "❌ FAIL: $k missing"
done
echo ""
echo "--- 6. BUTTONS ---"
grep -q "UNIVERSAL BUTTON FIX" admin.html && echo "✅ PASS: Universal Button Fix" || echo "❌ FAIL: Button Fix missing"
echo "Buttons: $(grep -o '<button' admin.html | wc -l) | onclick: $(grep -o 'onclick' admin.html | wc -l)"
for k in "openSection" "openOneSettings" "goHome" "logoutSmart" "showToast"; do
  grep -q "$k" admin.html && echo "✅ PASS: $k exists" || echo "❌ FAIL: $k missing"
done
echo ""
echo "--- 7. POSTS BEAR PIC ---"
grep -q "getMyProfilePic" admin.html && echo "✅ PASS: getMyProfilePic Admin" || echo "❌ FAIL: getMyProfilePic Admin"
grep -q "getMyProfilePic" index.html && echo "✅ PASS: getMyProfilePic Index" || echo "❌ FAIL: getMyProfilePic Index"
echo ""
echo "--- 8. VERIFICATION BADGE ---"
echo "metaBadge in index: $(grep -o 'metaBadge' index.html | wc -l) (should be 2-3 = 1 badge)"
echo "Old verifiedBadge in index: $(grep -o 'verifiedBadge' index.html | wc -l) (should be 0)"
[ "$(grep -o 'verifiedBadge' index.html | wc -l)" = "0" ] && echo "✅ PASS: Old badges removed" || echo "❌ FAIL: Old badges still there"
echo ""
echo "--- 9. LIVE vs LOCAL ---"
curl -s "https://glitch650.github.io/admin.html?v=$(date +%s)" -o /tmp/live.html
grep -q "Control Center" /tmp/live.html && echo "✅ PASS: Live has Control Center" || echo "❌ FAIL: Live missing Control Center - NOT PUSHED?"
grep -q "waSettings" /tmp/live.html && echo "✅ PASS: Live has WhatsApp Settings" || echo "❌ FAIL: Live missing Settings"
grep -q "d4af37" /tmp/live.html && echo "✅ PASS: Live has Luxury Gold" || echo "❌ FAIL: Live missing Gold"
echo ""
echo "===== TEST DONE ====="
