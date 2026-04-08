#!/bin/bash
# Tackworks Stack Health Check
# Usage: bash healthcheck.sh [base_url]
# Default: checks localhost ports 8795-8797

BASE=${1:-"http://localhost"}
PASS=0
FAIL=0

check() {
    local name=$1 url=$2
    status=$(curl -sf -o /dev/null -w "%{http_code}" "$url" 2>/dev/null)
    if [ "$status" = "200" ]; then
        echo "  [OK] $name ($url)"
        PASS=$((PASS + 1))
    else
        echo "  [FAIL] $name ($url) — got $status"
        FAIL=$((FAIL + 1))
    fi
}

echo "Tackworks Stack Health Check"
echo "============================"
echo ""

echo "Services:"
check "Tack health"  "$BASE:8795/health"
check "Chock health" "$BASE:8796/health"
check "Spur health"  "$BASE:8797/health"
echo ""

echo "Web UIs:"
check "Tack UI"  "$BASE:8795/"
check "Chock UI" "$BASE:8796/"
check "Spur UI"  "$BASE:8797/"
echo ""

echo "APIs:"
check "Tack board"    "$BASE:8795/api/board"
check "Chock pending" "$BASE:8796/api/pending"
check "Spur routes"   "$BASE:8797/api/routes"
check "Spur stats"    "$BASE:8797/api/events/stats"
echo ""

echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ] && echo "All checks passed." || echo "Some checks failed."
exit $FAIL
