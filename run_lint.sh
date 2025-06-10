#!/usr/bin/env bash

# run_lint.sh - Run shellcheck linting on all shell scripts

set -euo pipefail

echo "🔍 Running shellcheck on all shell scripts..."
echo "═══════════════════════════════════════════════════════════════════════════"

# Run shellcheck on all relevant shell scripts
shellcheck -x gshot-copy run_tests.sh tests/test_helper.bash

echo ""
echo "✅ All shell scripts passed shellcheck validation!"