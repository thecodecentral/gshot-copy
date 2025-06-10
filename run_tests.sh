#!/usr/bin/env bash

# Simple test runner for gshot-copy unit tests
# Requires bats-core to be installed

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TESTS_DIR="$SCRIPT_DIR/tests/unit"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    local color="$1"
    local message="$2"
    echo -e "${color}${message}${NC}"
}

# Check if bats is available
check_bats() {
    if ! command -v bats >/dev/null 2>&1; then
        print_status "$RED" "Error: bats is not installed"
        echo "Please install bats-core:"
        echo "  Ubuntu/Debian: sudo apt install bats"
        echo "  macOS: brew install bats-core"
        echo "  Or see: https://github.com/bats-core/bats-core"
        exit 1
    fi
}

# Main function
main() {
    print_status "$GREEN" "gshot-copy Unit Tests"
    echo "═══════════════════════════════════════════════════════════════════════════"
    
    # Check dependencies
    check_bats
    
    # Change to script directory so relative paths work
    cd "$SCRIPT_DIR"
    
    if [ ! -d "$TESTS_DIR" ]; then
        print_status "$RED" "Error: Test directory $TESTS_DIR does not exist"
        exit 1
    fi
    
    local test_files=("$TESTS_DIR"/*.bats)
    if [ ! -f "${test_files[0]}" ]; then
        print_status "$RED" "Error: No test files found in $TESTS_DIR"
        exit 1
    fi
    
    print_status "$YELLOW" "Running unit tests..."
    echo "───────────────────────────────────────────────────────────────────────────"
    
    if bats "$TESTS_DIR"/*.bats; then
        echo
        print_status "$GREEN" "🎉 All unit tests passed!"
        echo
        echo "For full testing, manually verify:"
        echo "  • gshot-copy --help"
        echo "  • gshot-copy (area screenshot)"
        echo "  • gshot-copy --mode window"
        echo "  • gshot-copy --mode screen"
        echo "  • Check that files are created and paths copied to clipboard"
    else
        echo
        print_status "$RED" "❌ Some unit tests failed!"
        exit 1
    fi
}

# Run main function
main "$@"