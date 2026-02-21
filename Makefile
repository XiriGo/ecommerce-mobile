# =============================================================================
# Molt Marketplace — Build, Lint & Test
# =============================================================================
# Usage:  make help
# =============================================================================

SHELL := /bin/bash
.DEFAULT_GOAL := help

# ---------------------------------------------------------------------------
# Config
# ---------------------------------------------------------------------------
ANDROID_DIR  := android
IOS_DIR      := ios
IOS_SCHEME   := MoltMarketplace

# Auto-detect first available iPhone simulator (fallback: iPhone 16)
IOS_SIM := $(shell xcrun simctl list devices available 2>/dev/null \
	| grep -m1 'iPhone' | sed 's/^ *//;s/ [(].*[)]//;s/ *$$//')
ifeq ($(IOS_SIM),)
IOS_SIM := iPhone 16
endif
IOS_DEST := platform=iOS Simulator,name=$(IOS_SIM)

# Colors
GREEN  := \033[0;32m
RED    := \033[0;31m
YELLOW := \033[0;33m
CYAN   := \033[0;36m
BOLD   := \033[1m
NC     := \033[0m

# ---------------------------------------------------------------------------
# Phony targets
# ---------------------------------------------------------------------------
.PHONY: help all android ios \
	build build-android build-ios \
	lint lint-android lint-ios \
	test test-android test-ios \
	check-suppress setup clean

# ---------------------------------------------------------------------------
# Help
# ---------------------------------------------------------------------------
help: ## Show this help
	@echo ""
	@echo -e "$(BOLD)Molt Marketplace$(NC) — Build & Test"
	@echo -e "iOS Simulator: $(CYAN)$(IOS_SIM)$(NC)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "  $(CYAN)%-20s$(NC) %s\n", $$1, $$2}'
	@echo ""

# ---------------------------------------------------------------------------
# Combo targets
# ---------------------------------------------------------------------------
all: android ios ## Build + lint + test both platforms

android: build-android lint-android test-android ## Build + lint + test Android
	@echo -e "\n$(GREEN)$(BOLD)Android: ALL CHECKS PASSED$(NC)"

ios: build-ios lint-ios test-ios ## Build + lint + test iOS
	@echo -e "\n$(GREEN)$(BOLD)iOS: ALL CHECKS PASSED$(NC)"

build: build-android build-ios ## Build both platforms

lint: lint-android lint-ios check-suppress ## Lint both platforms + suppress check

test: test-android test-ios ## Test both platforms

# ---------------------------------------------------------------------------
# Android
# ---------------------------------------------------------------------------
build-android: ## Build Android debug APK
	@echo -e "$(YELLOW)[android]$(NC) Building..."
	cd $(ANDROID_DIR) && ./gradlew assembleDebug
	@echo -e "$(GREEN)[android] Build PASSED$(NC)"

lint-android: ## Run ktlint + detekt
	@echo -e "$(YELLOW)[android]$(NC) Running ktlint..."
	cd $(ANDROID_DIR) && ./gradlew ktlintCheck
	@echo -e "$(YELLOW)[android]$(NC) Running detekt..."
	cd $(ANDROID_DIR) && ./gradlew detekt
	@echo -e "$(GREEN)[android] Lint PASSED$(NC)"

test-android: ## Run Android unit tests
	@echo -e "$(YELLOW)[android]$(NC) Running tests..."
	cd $(ANDROID_DIR) && ./gradlew test
	@echo -e "$(GREEN)[android] Tests PASSED$(NC)"

# ---------------------------------------------------------------------------
# iOS
# ---------------------------------------------------------------------------
build-ios: ## Build iOS for simulator
	@echo -e "$(YELLOW)[ios]$(NC) Building for $(IOS_SIM)..."
	cd $(IOS_DIR) && xcodebuild build \
		-scheme $(IOS_SCHEME) \
		-destination '$(IOS_DEST)' \
		-quiet
	@echo -e "$(GREEN)[ios] Build PASSED$(NC)"

lint-ios: ## Run SwiftLint (strict)
	@echo -e "$(YELLOW)[ios]$(NC) Running SwiftLint..."
	cd $(IOS_DIR) && swiftlint lint --strict
	@echo -e "$(GREEN)[ios] Lint PASSED$(NC)"

test-ios: ## Run iOS unit tests
	@echo -e "$(YELLOW)[ios]$(NC) Running tests on $(IOS_SIM)..."
	cd $(IOS_DIR) && xcodebuild test \
		-scheme $(IOS_SCHEME) \
		-destination '$(IOS_DEST)' \
		-quiet
	@echo -e "$(GREEN)[ios] Tests PASSED$(NC)"

# ---------------------------------------------------------------------------
# Suppress check
# ---------------------------------------------------------------------------
check-suppress: ## Verify zero @Suppress / swiftlint:disable
	@echo -e "$(YELLOW)[suppress]$(NC) Checking for banned suppression markers..."
	@FOUND=0; \
	if grep -rn '@Suppress(' --include='*.kt' $(ANDROID_DIR)/app/src/ 2>/dev/null; then \
		echo -e "$(RED)[suppress] Found @Suppress in Android code$(NC)"; FOUND=1; \
	fi; \
	if grep -rn 'swiftlint:disable' --include='*.swift' $(IOS_DIR)/ 2>/dev/null; then \
		echo -e "$(RED)[suppress] Found swiftlint:disable in iOS code$(NC)"; FOUND=1; \
	fi; \
	if [ $$FOUND -ne 0 ]; then exit 1; fi
	@echo -e "$(GREEN)[suppress] Zero suppressions$(NC)"

# ---------------------------------------------------------------------------
# Utilities
# ---------------------------------------------------------------------------
setup: ## Install pre-commit hooks
	./scripts/setup-hooks.sh

clean: ## Clean build artifacts
	@echo -e "$(YELLOW)[clean]$(NC) Cleaning Android..."
	cd $(ANDROID_DIR) && ./gradlew clean
	@echo -e "$(YELLOW)[clean]$(NC) Cleaning iOS..."
	cd $(IOS_DIR) && xcodebuild clean \
		-scheme $(IOS_SCHEME) \
		-destination '$(IOS_DEST)' \
		-quiet 2>/dev/null || true
	@echo -e "$(GREEN)[clean] Done$(NC)"
