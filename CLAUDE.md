# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is the `gshot-copy` project - a Linux screenshot utility that creates timestamp-based filenames and copies file paths to clipboard. The main deliverable is a single shell script (`gshot-copy`) that wraps `gnome-screenshot` with enhanced functionality.

## Architecture

The project consists of:
- **Documentation**: `docs/architecture.md` contains the complete specification
- **Main script**: `gshot-copy` (to be implemented in project root)
- **No build system**: Single shell script deployment

## Key Implementation Details

### Filename Format
Screenshots use the format: `gshot-YYYY-MM-DD-HHMMSS-<4 random letters>.png`

### Command Line Interface
The script supports:
- `--mode area|window|screen` (default: area)
- `--output-dir DIR` (default: ~/Pictures/Screenshots/)
- `--delay SECONDS` (default: 0)
- `--include-pointer` (flag)
- `--help`

### Dependencies
- `gnome-screenshot` for taking screenshots
- Clipboard utilities: `wl-copy` (Wayland) or `xclip`/`xsel` (X11)
- Standard POSIX tools: `date`, `tr`, `/dev/urandom`

## Development Notes

### Testing Strategy
The project uses [bats-core](https://github.com/bats-core/bats-core) for unit testing core functions:

**Unit Tests** (`tests/unit/`):
- `test_filename_generation.bats`: Tests filename format, timestamp, and random suffix generation
- `test_argument_parsing.bats`: Tests argument validation and command building logic

### Running Tests
```bash
./run_tests.sh              # Run unit tests
```

Manual testing is recommended for full functionality verification since the script interfaces with GUI applications and system clipboard.

### Test Utilities
- `tests/test_helper.bash`: Provides filename validation utilities and test environment setup

### Shell Compatibility
Script uses `#!/usr/bin/env bash` shebang and should be POSIX-compliant. Works with bash, dash, zsh, and fish shells.

### Error Handling
- Validate mode parameter (area/window/screen)
- Handle missing clipboard utilities gracefully
- Provide proper exit codes and error messages
- Handle cancelled screenshots
- Directory creation failures

### Key Functions
- `generate_filename()`: Pure function accepting optional timestamp/suffix for testing
- `validate_mode()` / `validate_delay()`: Input validation with clear error messages
- `build_screenshot_command()`: Command construction based on options
- `copy_to_clipboard()`: Clipboard utility detection and fallback
- `parse_arguments()`: Robust argument parsing with help and error handling

The script builds `gnome-screenshot` commands dynamically based on user options and uses `eval` for execution.