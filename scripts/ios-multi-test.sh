#!/bin/bash
# iOS Multi-Destination Test Runner
# Runs tests on multiple device types and iOS versions simultaneously.
#
# Usage:
#   ./scripts/ios-multi-test.sh              # Default: iPhone + iPad + iPhone small
#   ./scripts/ios-multi-test.sh --quick      # Quick: iPhone only
#   ./scripts/ios-multi-test.sh --full       # Full: all available devices
#   ./scripts/ios-multi-test.sh --ci         # CI mode: iPhone + iPad (parallel)
#
# Prerequisites:
#   - Xcode installed with simulators
#   - xcodegen installed (brew install xcodegen)

set -euo pipefail

SCHEME="XiriGoEcommerce"
PROJECT_DIR="$(cd "$(dirname "$0")/../ios" && pwd)"
RESULTS_DIR="${PROJECT_DIR}/TestResults"
MODE="${1:---default}"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${BLUE}[test]${NC} $1"; }
success() { echo -e "${GREEN}[PASS]${NC} $1"; }
fail() { echo -e "${RED}[FAIL]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }

# ── Detect Available Simulators ──────────────────────────────────────

detect_simulators() {
    local available
    available=$(xcrun simctl list devices available 2>/dev/null)

    # Find best iPhone (latest model)
    IPHONE=$(echo "$available" | grep -m1 'iPhone 1[67]' | sed 's/^ *//;s/ (.*//' || true)
    [ -z "$IPHONE" ] && IPHONE=$(echo "$available" | grep -m1 'iPhone' | sed 's/^ *//;s/ (.*//' || true)

    # Find small iPhone (SE or 16e)
    IPHONE_SMALL=$(echo "$available" | grep -m1 'iPhone 16e\|iPhone SE' | sed 's/^ *//;s/ (.*//' || true)
    [ -z "$IPHONE_SMALL" ] && IPHONE_SMALL="$IPHONE"

    # Find iPad
    IPAD=$(echo "$available" | grep -m1 'iPad Pro 1[13]' | sed 's/^ *//;s/ (.*//' || true)
    [ -z "$IPAD" ] && IPAD=$(echo "$available" | grep -m1 'iPad' | sed 's/^ *//;s/ (.*//' || true)

    # Find oldest available iOS runtime (for compat testing)
    OLDEST_IOS=$(xcrun simctl list runtimes available 2>/dev/null | grep 'iOS' | head -1 | sed 's/.*iOS \([0-9.]*\).*/\1/' || true)
    LATEST_IOS=$(xcrun simctl list runtimes available 2>/dev/null | grep 'iOS' | tail -1 | sed 's/.*iOS \([0-9.]*\).*/\1/' || true)

    log "Detected simulators:"
    log "  iPhone:       ${IPHONE:-none}"
    log "  iPhone Small: ${IPHONE_SMALL:-none}"
    log "  iPad:         ${IPAD:-none}"
    log "  iOS versions: ${OLDEST_IOS:-?} — ${LATEST_IOS:-?}"
}

# ── Build Destination Flags ──────────────────────────────────────────

build_destinations() {
    DESTINATIONS=()

    case "$MODE" in
        --quick)
            log "Mode: Quick (iPhone only)"
            DESTINATIONS+=("-destination" "platform=iOS Simulator,name=${IPHONE}")
            ;;
        --ci)
            log "Mode: CI (iPhone + iPad, parallel)"
            DESTINATIONS+=("-destination" "platform=iOS Simulator,name=${IPHONE}")
            if [ -n "$IPAD" ] && [ "$IPAD" != "$IPHONE" ]; then
                DESTINATIONS+=("-destination" "platform=iOS Simulator,name=${IPAD}")
            fi
            ;;
        --full)
            log "Mode: Full (all device types + oldest iOS)"
            DESTINATIONS+=("-destination" "platform=iOS Simulator,name=${IPHONE}")
            if [ -n "$IPHONE_SMALL" ] && [ "$IPHONE_SMALL" != "$IPHONE" ]; then
                DESTINATIONS+=("-destination" "platform=iOS Simulator,name=${IPHONE_SMALL}")
            fi
            if [ -n "$IPAD" ]; then
                DESTINATIONS+=("-destination" "platform=iOS Simulator,name=${IPAD}")
            fi
            # Add oldest iOS version test if different from latest
            if [ -n "$OLDEST_IOS" ] && [ "$OLDEST_IOS" != "$LATEST_IOS" ]; then
                DESTINATIONS+=("-destination" "platform=iOS Simulator,name=${IPHONE},OS=${OLDEST_IOS}")
            fi
            ;;
        *)
            log "Mode: Default (iPhone + iPhone Small + iPad)"
            DESTINATIONS+=("-destination" "platform=iOS Simulator,name=${IPHONE}")
            if [ -n "$IPHONE_SMALL" ] && [ "$IPHONE_SMALL" != "$IPHONE" ]; then
                DESTINATIONS+=("-destination" "platform=iOS Simulator,name=${IPHONE_SMALL}")
            fi
            if [ -n "$IPAD" ]; then
                DESTINATIONS+=("-destination" "platform=iOS Simulator,name=${IPAD}")
            fi
            ;;
    esac

    log "Testing on ${#DESTINATIONS[@]/2} destination(s)"
}

# ── Generate Project ─────────────────────────────────────────────────

generate_project() {
    if command -v xcodegen &>/dev/null; then
        log "Generating Xcode project..."
        (cd "$PROJECT_DIR" && xcodegen generate --quiet 2>/dev/null) || true
    fi
}

# ── Run Tests ────────────────────────────────────────────────────────

run_tests() {
    mkdir -p "$RESULTS_DIR"

    log "Running tests..."
    echo ""

    local start_time
    start_time=$(date +%s)

    set +e
    (cd "$PROJECT_DIR" && xcodebuild test \
        -scheme "$SCHEME" \
        "${DESTINATIONS[@]}" \
        -parallel-testing-enabled YES \
        -skipPackagePluginValidation \
        -enableCodeCoverage YES \
        -resultBundlePath "$RESULTS_DIR/MultiDevice.xcresult" \
        CODE_SIGNING_ALLOWED=NO \
        2>&1 | tail -30)
    local exit_code=$?
    set -e

    local end_time
    end_time=$(date +%s)
    local duration=$((end_time - start_time))

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    if [ $exit_code -eq 0 ]; then
        success "All tests passed on all destinations (${duration}s)"
    else
        fail "Tests failed on one or more destinations (${duration}s)"
    fi

    # Extract coverage
    if [ -d "$RESULTS_DIR/MultiDevice.xcresult" ]; then
        log "Coverage report:"
        xcrun xccov view --report "$RESULTS_DIR/MultiDevice.xcresult" --json 2>/dev/null | \
            python3 -c "
import json, sys
try:
    data = json.load(sys.stdin)
    for t in data.get('targets', []):
        name = t.get('name', '')
        if name == 'XiriGoEcommerce':
            pct = t.get('lineCoverage', 0) * 100
            status = 'PASS' if pct >= 80 else 'WARNING' if pct >= 70 else 'FAIL'
            print(f'  {name}: {pct:.1f}% [{status}]')
except: pass
" 2>/dev/null || true
    fi

    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    return $exit_code
}

# ── Main ─────────────────────────────────────────────────────────────

echo ""
echo "╔═══════════════════════════════════════════╗"
echo "║  iOS Multi-Destination Test Runner        ║"
echo "╚═══════════════════════════════════════════╝"
echo ""

detect_simulators
build_destinations
generate_project
run_tests
