#!/bin/bash
# setup-hooks.sh — Install git pre-commit hook for the Molt Marketplace project
#
# Usage: ./scripts/setup-hooks.sh
#
# This script creates a symlink from .git/hooks/pre-commit to scripts/pre-commit
# so that code quality checks run automatically before each commit.

set -euo pipefail

# Resolve the project root (parent of scripts/)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

HOOKS_DIR="$PROJECT_ROOT/.git/hooks"
HOOK_SOURCE="$PROJECT_ROOT/scripts/pre-commit"
HOOK_TARGET="$HOOKS_DIR/pre-commit"

# Verify we are inside a git repository
if [ ! -d "$PROJECT_ROOT/.git" ]; then
    echo -e "\033[31mError: Not a git repository. Run this script from the project root.\033[0m"
    exit 1
fi

# Verify the pre-commit script exists
if [ ! -f "$HOOK_SOURCE" ]; then
    echo -e "\033[31mError: scripts/pre-commit not found.\033[0m"
    exit 1
fi

# Ensure the hooks directory exists
mkdir -p "$HOOKS_DIR"

# Remove existing hook if present (file or symlink)
if [ -e "$HOOK_TARGET" ] || [ -L "$HOOK_TARGET" ]; then
    rm "$HOOK_TARGET"
fi

# Create symlink (relative path so it works if repo is moved)
ln -s "../../scripts/pre-commit" "$HOOK_TARGET"

# Ensure the source script is executable
chmod +x "$HOOK_SOURCE"

echo -e "\033[32mPre-commit hook installed successfully.\033[0m"
echo "  Symlink: .git/hooks/pre-commit -> scripts/pre-commit"
