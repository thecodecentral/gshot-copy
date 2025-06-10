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
Extract filename generation into a testable function that accepts optional timestamp and random suffix parameters for deterministic testing.

### Shell Compatibility
Script uses `#!/usr/bin/env bash` shebang and should be POSIX-compliant. Works with bash, dash, zsh, and fish shells.

### Error Handling
- Validate mode parameter (area/window/screen)
- Handle missing clipboard utilities gracefully
- Provide proper exit codes and error messages
- Handle cancelled screenshots

The script builds `gnome-screenshot` commands dynamically based on user options and uses `eval` for execution.