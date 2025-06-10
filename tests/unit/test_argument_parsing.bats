#!/usr/bin/env bats

# Unit tests for argument parsing functionality

load '../test_helper'

setup() {
    setup_test_env
}

teardown() {
    teardown_test_env
}

@test "validate_mode accepts valid modes" {
    validate_mode "area"
    validate_mode "window" 
    validate_mode "screen"
}

@test "validate_mode rejects invalid modes" {
    run validate_mode "invalid"
    [ "$status" -eq 1 ]
    [[ "$output" == *"Invalid mode"* ]]
    
    run validate_mode ""
    [ "$status" -eq 1 ]
    
    run validate_mode "fullscreen"
    [ "$status" -eq 1 ]
}

@test "validate_delay accepts valid delays" {
    validate_delay "0"
    validate_delay "5"
    validate_delay "100"
}

@test "validate_delay rejects invalid delays" {
    run validate_delay "-1"
    [ "$status" -eq 1 ]
    [[ "$output" == *"non-negative integer"* ]]
    
    run validate_delay "abc"
    [ "$status" -eq 1 ]
    
    run validate_delay "3.5"
    [ "$status" -eq 1 ]
    
    run validate_delay ""
    [ "$status" -eq 1 ]
}

@test "build_screenshot_command for area mode" {
    result=$(build_screenshot_command "area" "0" "false" "/tmp/test.png")
    [[ "$result" == *"gnome-screenshot -a"* ]]
    [[ "$result" == *"-f \"/tmp/test.png\""* ]]
    [[ "$result" != *"-w"* ]]
    [[ "$result" != *"-d"* ]]
    [[ "$result" != *"-p"* ]]
}

@test "build_screenshot_command for window mode" {
    result=$(build_screenshot_command "window" "0" "false" "/tmp/test.png")
    [[ "$result" == *"gnome-screenshot -w"* ]]
    [[ "$result" == *"-f \"/tmp/test.png\""* ]]
    [[ "$result" != *"-a"* ]]
}

@test "build_screenshot_command for screen mode" {
    result=$(build_screenshot_command "screen" "0" "false" "/tmp/test.png")
    [[ "$result" == *"gnome-screenshot"* ]]
    [[ "$result" == *"-f \"/tmp/test.png\""* ]]
    [[ "$result" != *"-a"* ]]
    [[ "$result" != *"-w"* ]]
}

@test "build_screenshot_command with delay" {
    result=$(build_screenshot_command "area" "5" "false" "/tmp/test.png")
    [[ "$result" == *"-d 5"* ]]
}

@test "build_screenshot_command with pointer" {
    result=$(build_screenshot_command "area" "0" "true" "/tmp/test.png")
    [[ "$result" == *"-p"* ]]
}

@test "build_screenshot_command with all options" {
    result=$(build_screenshot_command "window" "3" "true" "/tmp/test.png")
    [[ "$result" == *"gnome-screenshot -w"* ]]
    [[ "$result" == *"-d 3"* ]]
    [[ "$result" == *"-p"* ]]
    [[ "$result" == *"-f \"/tmp/test.png\""* ]]
}

@test "build_screenshot_command with zero delay omits delay flag" {
    result=$(build_screenshot_command "area" "0" "false" "/tmp/test.png")
    [[ "$result" != *"-d"* ]]
}

@test "parse_arguments sets default values" {
    # Reset globals
    OUTPUT_DIR=""
    MODE=""
    DELAY=""
    INCLUDE_POINTER=""
    
    # Set defaults
    OUTPUT_DIR="${HOME}/Pictures/Screenshots"
    MODE="area"
    DELAY="0"
    INCLUDE_POINTER="false"
    
    # Parse empty arguments (should keep defaults)
    parse_arguments
    
    [ "$OUTPUT_DIR" = "${HOME}/Pictures/Screenshots" ]
    [ "$MODE" = "area" ]
    [ "$DELAY" = "0" ]
    [ "$INCLUDE_POINTER" = "false" ]
}

@test "parse_arguments handles output-dir" {
    OUTPUT_DIR=""
    parse_arguments --output-dir "/custom/path"
    [ "$OUTPUT_DIR" = "/custom/path" ]
}

@test "parse_arguments handles mode" {
    MODE=""
    parse_arguments --mode "window"
    [ "$MODE" = "window" ]
}

@test "parse_arguments handles delay" {
    DELAY=""
    parse_arguments --delay "5"
    [ "$DELAY" = "5" ]
}

@test "parse_arguments handles include-pointer" {
    INCLUDE_POINTER=""
    parse_arguments --include-pointer
    [ "$INCLUDE_POINTER" = "true" ]
}

@test "parse_arguments handles multiple options" {
    OUTPUT_DIR=""
    MODE=""
    DELAY=""
    INCLUDE_POINTER=""
    
    parse_arguments --output-dir "/tmp" --mode "screen" --delay "3" --include-pointer
    
    [ "$OUTPUT_DIR" = "/tmp" ]
    [ "$MODE" = "screen" ]
    [ "$DELAY" = "3" ]
    [ "$INCLUDE_POINTER" = "true" ]
}

@test "parse_arguments rejects invalid mode" {
    run parse_arguments --mode "invalid"
    [ "$status" -eq 1 ]
}

@test "parse_arguments rejects invalid delay" {
    run parse_arguments --delay "-1"
    [ "$status" -eq 1 ]
}

@test "parse_arguments rejects unknown options" {
    run parse_arguments --unknown-option
    [ "$status" -eq 1 ]
    [[ "$output" == *"Unknown option"* ]]
}

@test "parse_arguments requires values for options" {
    run parse_arguments --output-dir
    [ "$status" -eq 1 ]
    [[ "$output" == *"requires a directory path"* ]]
    
    run parse_arguments --mode
    [ "$status" -eq 1 ]
    [[ "$output" == *"requires a value"* ]]
    
    run parse_arguments --delay
    [ "$status" -eq 1 ]
    [[ "$output" == *"requires a number"* ]]
}