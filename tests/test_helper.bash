#!/usr/bin/env bash

# Test helper functions for gshot-copy tests

# Set up test environment
setup_test_env() {
    # Create temporary directory for test output
    local temp_output_dir
    local temp_temp_dir
    temp_output_dir=$(mktemp -d)
    temp_temp_dir=$(mktemp -d)
    export TEST_OUTPUT_DIR="$temp_output_dir"
    export TEST_TEMP_DIR="$temp_temp_dir"
    
    # Source the main script for function testing
    source "${BATS_TEST_DIRNAME}/../../gshot-copy"
}

# Clean up test environment
teardown_test_env() {
    # Clean up temporary directories
    if [ -n "${TEST_OUTPUT_DIR:-}" ] && [ -d "$TEST_OUTPUT_DIR" ]; then
        rm -rf "$TEST_OUTPUT_DIR"
    fi
    if [ -n "${TEST_TEMP_DIR:-}" ] && [ -d "$TEST_TEMP_DIR" ]; then
        rm -rf "$TEST_TEMP_DIR"
    fi
}

# Mock gnome-screenshot command for testing
mock_gnome_screenshot() {
    local output_file=""
    local mode=""
    local delay=""
    local include_pointer=false
    
    # Parse arguments to extract filename
    while [[ $# -gt 0 ]]; do
        case $1 in
            -f)
                output_file="$2"
                shift 2
                ;;
            -a)
                mode="area"
                shift
                ;;
            -w)
                mode="window"
                shift
                ;;
            -d)
                delay="$2"
                shift 2
                ;;
            -p)
                include_pointer=true
                shift
                ;;
            *)
                shift
                ;;
        esac
    done
    
    # Create mock screenshot file
    if [ -n "$output_file" ]; then
        echo "Mock screenshot content" > "$output_file"
        echo "Mock gnome-screenshot: mode=${mode:-screen}, delay=${delay:-0}, pointer=${include_pointer}, file=${output_file}" >&2
    fi
    
    return 0
}

# Mock clipboard utilities
mock_wl_copy() {
    echo "Mock wl-copy received: $(cat)" >&2
    return 0
}

mock_xclip() {
    if [[ "$*" == *"selection clipboard"* ]]; then
        echo "Mock xclip received: $(cat)" >&2
        return 0
    fi
    return 1
}

mock_xsel() {
    if [[ "$*" == *"clipboard"* ]]; then
        echo "Mock xsel received: $(cat)" >&2
        return 0
    fi
    return 1
}

# Set up mocks
setup_mocks() {
    # Override commands with mock functions
    eval 'gnome-screenshot() { mock_gnome_screenshot "$@"; }'
    eval 'wl-copy() { mock_wl_copy "$@"; }'
    eval 'xclip() { mock_xclip "$@"; }'
    eval 'xsel() { mock_xsel "$@"; }'
    
    # Export mock functions
    export -f gnome-screenshot wl-copy xclip xsel
    export -f mock_gnome_screenshot mock_wl_copy mock_xclip mock_xsel
}

# Check if a command exists (for dependency tests)
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Validate filename format
validate_filename_format() {
    local filename="$1"
    local basename
    basename=$(basename "$filename")
    
    # Check format: gshot-YYYY-MM-DD-HHMMSS-XXXX.png
    if [[ "$basename" =~ ^gshot-[0-9]{4}-[0-9]{2}-[0-9]{2}-[0-9]{6}-[a-zA-Z]{4}\.png$ ]]; then
        return 0
    else
        return 1
    fi
}

# Extract timestamp from filename
extract_timestamp() {
    local filename="$1"
    local basename
    basename=$(basename "$filename")
    echo "$basename" | sed -n 's/^gshot-\([0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}-[0-9]\{6\}\)-[a-zA-Z]\{4\}\.png$/\1/p'
}

# Extract random suffix from filename
extract_suffix() {
    local filename="$1"
    local basename
    basename=$(basename "$filename")
    echo "$basename" | sed -n 's/^gshot-[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}-[0-9]\{6\}-\([a-zA-Z]\{4\}\)\.png$/\1/p'
}