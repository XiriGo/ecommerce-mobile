#!/bin/bash
# ci-local.sh — Run the same checks GitHub Actions CI runs, locally.
#
# Usage:
#   ./scripts/ci-local.sh              # Run all checks (lint + build + test)
#   ./scripts/ci-local.sh lint         # Lint only (fast)
#   ./scripts/ci-local.sh build        # Build only
#   ./scripts/ci-local.sh test         # Test only
#   ./scripts/ci-local.sh android      # Android only (lint + build + test)
#   ./scripts/ci-local.sh ios          # iOS only (lint + build + test)
#   ./scripts/ci-local.sh android lint # Android lint only
#   ./scripts/ci-local.sh ios test     # iOS test only

set -uo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FAILED=0
PASS_COUNT=0
FAIL_COUNT=0
SKIP_COUNT=0

# Parse arguments
PLATFORM="${1:-all}"   # all, android, ios
STEP="${2:-all}"       # all, lint, build, test

# If first arg is a step name (not a platform), adjust
if [[ "$PLATFORM" == "lint" || "$PLATFORM" == "build" || "$PLATFORM" == "test" ]]; then
    STEP="$PLATFORM"
    PLATFORM="all"
fi

run_step() {
    local name="$1"
    local cmd="$2"
    local dir="${3:-$PROJECT_ROOT}"

    echo ""
    echo -e "${BLUE}${BOLD}━━━ $name ━━━${NC}"
    if (cd "$dir" && eval "$cmd"); then
        echo -e "${GREEN}✓ $name passed${NC}"
        PASS_COUNT=$((PASS_COUNT + 1))
    else
        echo -e "${RED}✗ $name failed${NC}"
        FAIL_COUNT=$((FAIL_COUNT + 1))
        FAILED=1
    fi
}

skip_step() {
    local name="$1"
    local reason="$2"
    echo ""
    echo -e "${YELLOW}⊘ $name — skipped ($reason)${NC}"
    SKIP_COUNT=$((SKIP_COUNT + 1))
}

# =========================================================================
# Android
# =========================================================================
run_android() {
    local step="${1:-all}"

    if [ ! -f "$PROJECT_ROOT/android/gradlew" ]; then
        skip_step "Android" "android/gradlew not found"
        return
    fi

    if [[ "$step" == "all" || "$step" == "lint" ]]; then
        run_step "Android: ktlint" "./gradlew ktlintCheck" "$PROJECT_ROOT/android"
        run_step "Android: detekt" "./gradlew detekt" "$PROJECT_ROOT/android"
    fi

    if [[ "$step" == "all" || "$step" == "build" ]]; then
        run_step "Android: build (assembleDebug)" "./gradlew assembleDebug" "$PROJECT_ROOT/android"
    fi

    if [[ "$step" == "all" || "$step" == "test" ]]; then
        run_step "Android: unit tests" "./gradlew test --no-daemon" "$PROJECT_ROOT/android"
    fi
}

# =========================================================================
# iOS
# =========================================================================
run_ios() {
    local step="${1:-all}"
    local scheme="XiriGoEcommerce"
    local destination="platform=iOS Simulator,name=iPhone 16,OS=latest"

    if [[ "$step" == "all" || "$step" == "lint" ]]; then
        if command -v swiftlint &> /dev/null; then
            run_step "iOS: SwiftLint" "swiftlint lint --strict" "$PROJECT_ROOT/ios"
        else
            skip_step "iOS: SwiftLint" "not installed — brew install swiftlint"
        fi

        if command -v swiftformat &> /dev/null; then
            run_step "iOS: SwiftFormat" "swiftformat --lint . --config .swiftformat" "$PROJECT_ROOT/ios"
        else
            skip_step "iOS: SwiftFormat" "not installed — brew install swiftformat"
        fi
    fi

    if [[ "$step" == "all" || "$step" == "build" || "$step" == "test" ]]; then
        # Generate Xcode project if xcodegen is available
        if command -v xcodegen &> /dev/null; then
            run_step "iOS: xcodegen" "xcodegen generate" "$PROJECT_ROOT/ios"
        else
            skip_step "iOS: xcodegen" "not installed — brew install xcodegen"
            if [[ "$step" == "build" || "$step" == "test" ]]; then
                skip_step "iOS: build" "xcodegen required"
                skip_step "iOS: test" "xcodegen required"
                return
            fi
        fi
    fi

    if [[ "$step" == "all" || "$step" == "build" ]]; then
        run_step "iOS: build" \
            "xcodebuild build -scheme $scheme -destination '$destination' -skipPackagePluginValidation CODE_SIGNING_ALLOWED=NO 2>&1 | tail -20" \
            "$PROJECT_ROOT/ios"
    fi

    if [[ "$step" == "all" || "$step" == "test" ]]; then
        run_step "iOS: unit tests" \
            "xcodebuild test -scheme $scheme -destination '$destination' -skipPackagePluginValidation CODE_SIGNING_ALLOWED=NO 2>&1 | tail -30" \
            "$PROJECT_ROOT/ios"
    fi
}

# =========================================================================
# Main
# =========================================================================
echo -e "${BOLD}╔═══════════════════════════════════════╗${NC}"
echo -e "${BOLD}║   XiriGo CI — Local Runner            ║${NC}"
echo -e "${BOLD}║   Platform: $PLATFORM  Step: $STEP$(printf '%*s' $((14 - ${#PLATFORM} - ${#STEP})) '')║${NC}"
echo -e "${BOLD}╚═══════════════════════════════════════╝${NC}"

START_TIME=$(date +%s)

if [[ "$PLATFORM" == "all" || "$PLATFORM" == "android" ]]; then
    run_android "$STEP"
fi

if [[ "$PLATFORM" == "all" || "$PLATFORM" == "ios" ]]; then
    run_ios "$STEP"
fi

END_TIME=$(date +%s)
ELAPSED=$((END_TIME - START_TIME))
MINUTES=$((ELAPSED / 60))
SECONDS=$((ELAPSED % 60))

echo ""
echo -e "${BOLD}═══════════════════════════════════════${NC}"
echo -e "  ${GREEN}✓ Passed: $PASS_COUNT${NC}  ${RED}✗ Failed: $FAIL_COUNT${NC}  ${YELLOW}⊘ Skipped: $SKIP_COUNT${NC}"
echo -e "  Time: ${MINUTES}m ${SECONDS}s"
echo -e "${BOLD}═══════════════════════════════════════${NC}"

if [ "$FAILED" -ne 0 ]; then
    echo -e "${RED}${BOLD}CI checks failed.${NC}"
    exit 1
fi

echo -e "${GREEN}${BOLD}All CI checks passed!${NC}"
exit 0
