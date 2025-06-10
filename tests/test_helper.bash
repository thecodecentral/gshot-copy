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
    local script_path
    if [ -f "${BATS_TEST_DIRNAME}/../../gshot-copy" ]; then
        script_path="${BATS_TEST_DIRNAME}/../../gshot-copy"
    elif [ -f "${PWD}/gshot-copy" ]; then
        script_path="${PWD}/gshot-copy"
    else
        echo "Error: Cannot find gshot-copy script" >&2
        return 1
    fi
    # shellcheck disable=SC1090,SC1091
    source "$script_path"
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

# Mock scrot command for testing
mock_scrot() {
    local output_file=""
    local mode="screen"
    local delay=""
    local include_pointer=false
    
    # Parse arguments to extract filename
    while [[ $# -gt 0 ]]; do
        case $1 in
            -s)
                mode="selection"
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
                # Last argument is typically the output file
                if [[ "$1" != -* ]]; then
                    output_file="$1"
                fi
                shift
                ;;
        esac
    done
    
    # Create mock screenshot file
    if [ -n "$output_file" ]; then
        echo "Mock screenshot content" > "$output_file"
        echo "Mock scrot: mode=${mode}, delay=${delay:-0}, pointer=${include_pointer}, file=${output_file}" >&2
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
    eval 'scrot() { mock_scrot "$@"; }'
    eval 'wl-copy() { mock_wl_copy "$@"; }'
    eval 'xclip() { mock_xclip "$@"; }'
    eval 'xsel() { mock_xsel "$@"; }'
    
    # Export mock functions
    export -f scrot wl-copy xclip xsel
    export -f mock_scrot mock_wl_copy mock_xclip mock_xsel
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