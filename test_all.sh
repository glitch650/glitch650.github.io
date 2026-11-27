#!/bin/bash
echo "===== GLITCH650 FULL TEST ====="
echo ""

# LIVE SITE TEST
echo "--- 1. LIVE SITE ---"
for url in "https://glitch650.github.io/" "https://glitch650.github.io/admin.html" "https://glitch650.github.io/index.html"; do
  code=$(curl -s -o /dev/null -w "%{http_code}" "$url")
  if [ "$code" = "200" ]; then echo "✅ PASS: $url -> 200"; else echo "❌ FAIL: $url -> $code"; fi
done
echo ""

# LOCAL FILE TEST
echo "--- 2. FILES EXIST ---"
for f in index.html admin.html profile.jpg; do
  if [ -f "$f" ]; then echo "✅ PASS: $f exists"; else echo "❌ FAIL: $f MISSING"; fi
done
echo ""

echo "--- 3. CONTROL CENTER ---"
grep -q "Control Center" admin.html && echo "✅ PASS: Control Center heading" || echo "❌ FAIL: No Control Center"
grep -q "onlyControlCenter" admin.html && echo "✅ PASS: Only Control Center ID" || echo "⚠️ WARN: Only Control Center ID not found"
echo ""

echo "--- 4. G ICON + ADMIN REMOVED ---"
# G icon should be hidden via CSS
grep -q "fbLogo.*display:none\|logoG.*display:none" admin.html && echo "✅ PASS: G icon hidden via CSS" || echo "❌ FAIL: G icon not hidden"
grep -q "glitch650.*Admin" admin.html && echo "⚠️ CHECK: glitch650 Admin text still in file (may be in JS to hide it)" || echo "✅ PASS: glitch650 Admin removed"
echo ""

echo "--- 5. SETTINGS - WHATSAPP LUXURY ---"
grep -q "waSettings" admin.html && echo "✅ PASS: WhatsApp Settings found" || echo "❌ FAIL: WhatsApp Settings missing"
grep -q "d4af37" admin.html && echo "✅ PASS: Luxury Gold #d4af37 found" || echo "❌ FAIL: Luxury Gold missing"
grep -q "PREMIUM" admin.html && echo "✅ PASS: PREMIUM badge found" || echo "❌ FAIL: PREMIUM badge missing"
grep -q "Appearance" admin.html && echo "✅ PASS: Appearance setting" || echo "❌ FAIL: Appearance missing"
grep -q "Subscriptions" admin.html && echo "✅ PASS: Subscriptions" || echo "❌ FAIL: Subscriptions missing"
grep -q "Linked devices" admin.html && echo "✅ PASS: Linked devices" || echo "❌ FAIL: Linked devices missing"
grep -q "Privacy" admin.html && echo "✅ PASS: Privacy" || echo "❌ FAIL: Privacy missing"
echo ""

echo "--- 6. THEME - SMART ---"
grep -q "setThemeSmart" admin.html && echo "✅ PASS: setThemeSmart function" || echo "❌ FAIL: setThemeSmart missing"
grep -q "toggleThemeSmart" admin.html && echo "✅ PASS: toggleThemeSmart function" || echo "❌ FAIL: toggleThemeSmart missing"
grep -q "applySmartTheme" admin.html && echo "✅ PASS: applySmartTheme - Auto Smart" || echo "❌ FAIL: Auto Smart missing"
echo ""

echo "--- 7. BUTTONS - UNIVERSAL FIX ---"
grep -q "UNIVERSAL BUTTON FIX" admin.html && echo "✅ PASS: Universal Button Fix installed" || echo "❌ FAIL: Button Fix missing"
grep -q "fixAllButtons" admin.html && echo "✅ PASS: fixAllButtons" || echo "❌ FAIL: fixAllButtons missing"
grep -q "showToast" admin.html && echo "✅ PASS: Toast feedback" || echo "❌ FAIL: Toast missing"
echo "Buttons count in admin.html:"
grep -o "<button" admin.html | wc -l
grep -o "onclick" admin.html | wc -l
echo "onclick handlers count above ^"
echo ""

echo "--- 8. POSTS BEAR PROFILE PIC ---"
grep -q "ALL POSTS BEAR PROFILE PICTURE" admin.html && echo "✅ PASS: Posts bear pic - Admin" || echo "❌ FAIL: Posts pic - Admin missing"
grep -q "ALL POSTS BEAR PROFILE PICTURE" index.html && echo "✅ PASS: Posts bear pic - Index" || echo "❌ FAIL: Posts pic - Index missing"
grep -q "getMyProfilePic" admin.html && echo "✅ PASS: getMyProfilePic" || echo "❌ FAIL: getMyProfilePic missing"
echo ""

echo "--- 9. VERIFICATION BADGE - ONLY 1 ---"
count=$(grep -o "metaBadge" index.html | wc -l)
echo "metaBadge occurrences in index.html: $count"
if [ "$count" -ge 1 ] && [ "$count" -le 3 ]; then echo "✅ PASS: Only 1 badge (CSS + 1 HTML = 2-3 occurrences is OK)"; else echo "⚠️ CHECK: Badge count $count"; fi
count2=$(grep -o "verifiedBadge" index.html | wc -l)
echo "Old verifiedBadge count: $count2 (should be 0)"
if [ "$count2" = "0" ]; then echo "✅ PASS: Old badges removed"; else echo "❌ FAIL: Old badges still there"; fi
echo ""

echo "--- 10. LIVE SITE CONTENT CHECK ---"
curl -s "https://glitch650.github.io/admin.html" | grep -q "Control Center" && echo "✅ PASS: Live Admin has Control Center" || echo "❌ FAIL: Live Admin missing Control Center (maybe not pushed / cache)"
curl -s "https://glitch650.github.io/" | grep -q "glitch650" && echo "✅ PASS: Live Home has glitch650" || echo "❌ FAIL: Live Home missing glitch650"
curl -s "https://glitch650.github.io/admin.html" | grep -q "waSettings" && echo "✅ PASS: Live Admin has WhatsApp Settings" || echo "❌ FAIL: Live Admin missing WhatsApp Settings"
echo ""

echo "===== TEST DONE ====="
