#!/usr/bin/env bats

# Unit tests for filename generation functionality

load '../test_helper'

setup() {
    setup_test_env
}

teardown() {
    teardown_test_env
}

@test "generate_filename with fixed timestamp and suffix" {
    result=$(generate_filename "/tmp" "2023-12-25-143000" "ABCD")
    [ "$result" = "/tmp/gshot-2023-12-25-143000-ABCD.png" ]
}

@test "generate_filename with different directory" {
    result=$(generate_filename "/home/user/screenshots" "2023-12-25-143000" "ABCD")
    [ "$result" = "/home/user/screenshots/gshot-2023-12-25-143000-ABCD.png" ]
}

@test "generate_filename with empty directory uses current path" {
    result=$(generate_filename "" "2023-12-25-143000" "ABCD")
    [ "$result" = "/gshot-2023-12-25-143000-ABCD.png" ]
}

@test "generate_filename with auto timestamp has correct format" {
    result=$(generate_filename "/tmp" "" "ABCD")
    validate_filename_format "$result"
}

@test "generate_filename with auto suffix has correct format" {
    result=$(generate_filename "/tmp" "2023-12-25-143000" "")
    validate_filename_format "$result"
}

@test "generate_filename with auto timestamp and suffix has correct format" {
    result=$(generate_filename "/tmp")
    validate_filename_format "$result"
}

@test "generated timestamp is current" {
    # Generate filename and extract timestamp
    result=$(generate_filename "/tmp")
    extracted_timestamp=$(extract_timestamp "$result")
    
    # Get current timestamp
    current_timestamp=$(date +%Y-%m-%d-%H%M%S)
    
    # Timestamps should be within 1-2 seconds of each other
    # Convert to epoch for comparison
    extracted_epoch=$(date -d "${extracted_timestamp:0:10} ${extracted_timestamp:11:2}:${extracted_timestamp:13:2}:${extracted_timestamp:15:2}" +%s)
    current_epoch=$(date +%s)
    
    diff=$((current_epoch - extracted_epoch))
    [ "$diff" -ge -2 ] && [ "$diff" -le 2 ]
}

@test "generated suffix is 4 letters" {
    result=$(generate_filename "/tmp")
    suffix=$(extract_suffix "$result")
    
    # Check length
    [ ${#suffix} -eq 4 ]
    
    # Check all characters are letters
    [[ "$suffix" =~ ^[a-zA-Z]{4}$ ]]
}

@test "multiple calls generate different suffixes" {
    result1=$(generate_filename "/tmp")
    result2=$(generate_filename "/tmp")
    
    suffix1=$(extract_suffix "$result1")
    suffix2=$(extract_suffix "$result2")
    
    # Different calls should generate different suffixes (very high probability)
    [ "$suffix1" != "$suffix2" ]
}

@test "validate_filename_format accepts valid names" {
    validate_filename_format "/tmp/gshot-2023-12-25-143000-ABCD.png"
    validate_filename_format "gshot-2023-01-01-000000-abcd.png"
    validate_filename_format "/home/user/gshot-2024-06-15-235959-XyZw.png"
}

@test "validate_filename_format rejects invalid names" {
    run validate_filename_format "invalid-filename.png"
    [ "$status" -eq 1 ]
    
    run validate_filename_format "gshot-2023-12-25-ABCD.png"  # Missing time
    [ "$status" -eq 1 ]
    
    run validate_filename_format "gshot-2023-12-25-143000-ABC.png"  # Short suffix
    [ "$status" -eq 1 ]
    
    run validate_filename_format "gshot-2023-12-25-143000-ABCDE.png"  # Long suffix
    [ "$status" -eq 1 ]
    
    run validate_filename_format "gshot-2023-12-25-143000-ABC1.png"  # Number in suffix
    [ "$status" -eq 1 ]
}