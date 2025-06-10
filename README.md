# gshot-copy

A lightweight, distro-agnostic screenshot utility for Linux that automatically names files with timestamps and copies the file path to your clipboard. This is especially userful for [Claude Code](https://www.anthropic.com/claude-code) where you want to share screenshots with the terminal.

## Features

- **Multiple screenshot modes**: area selection (default), window capture, or full screen
- **Timestamp-based filenames**: `gshot-YYYY-MM-DD-HHMMSS-XXXX.png` format ensures unique, sortable names
- **Configurable output directory**: defaults to `~/Pictures/Screenshots/`, customizable with `--output-dir`
- **Optional delay and pointer inclusion**: supports delayed screenshots and mouse cursor capture
- **Clipboard integration**: automatically copies the full file path to clipboard
- **Minimal dependencies**: only requires `scrot` and clipboard utilities
- **Cross-shell compatibility**: works with bash, dash, zsh, and fish

## Installation


### Prerequisites

Install the required dependencies:

**Ubuntu/Debian**:

```bash
sudo apt install scrot
```

**Fedora**:

```bash
sudo dnf install scrot
```

**Arch**:

```bash
sudo pacman -Syu scrot
```

**Clipboard utilities** 

This is for copying the screenshot path to the clipboard. Install **one** of the following:
  - `xclip` (X11)
  - `xsel` (X11 fallback)
  - `wl-copy` (Wayland)

**Standard tools**: `date`, `tr`, `/dev/urandom` (included in most Linux distributions)



### Install gshot-copy

1. **Download the script**:
   Download the [gshot-copy](https://raw.githubusercontent.com/thecodecentral/gshot-copy/main/gshot-copy) script from this repository and save it to your desired location, e.g., `~/.local/bin/gshot-copy`.

   Or CURL it directly:
   ```bash
   curl -L 'https://raw.githubusercontent.com/thecodecentral/gshot-copy/main/gshot-copy' -o ~/.local/bin/gshot-copy
   ```

   Or use `wget`:
   ```bash
   wget -O ~/.local/bin/gshot-copy 'https://raw.githubusercontent.com/thecodecentral/gshot-copy/main/gshot-copy'
   ```

2. **Make it executable and install**:
   ```bash
   chmod +x ~/.local/bin/gshot-copy
   ```

## Usage

### Use with Claude Code

* Bind `~/.local/bin/gshot-copy` to a keyboard shortcut. 
* Press the shortcut to take a screenshot, and paste the URL in Claude Code.

See the [Keyboard Shortcuts](#keyboard-shortcuts) section for setup instructions.

### Basic Usage

```bash
# Take area screenshot (default)
gshot-copy

# Window screenshot - click on a window
gshot-copy --mode window

# Full screen screenshot
gshot-copy --mode screen
```

### Advanced Options

```bash
# Custom output directory
gshot-copy --output-dir ~/Desktop

# Delayed screenshot (3 seconds)
gshot-copy --delay 3

# Include mouse pointer
gshot-copy --include-pointer

# Combine multiple options
gshot-copy --mode window --delay 2 --include-pointer --output-dir ~/Desktop
```

### Command Line Options

```
--output-dir DIR      Output directory (default: ~/Pictures/Screenshots/)
--mode MODE          Screenshot mode: area, window, screen (default: area)
--delay SECONDS      Delay before screenshot (default: 0)
--include-pointer    Include mouse pointer in screenshot
--help              Show help message
```

### Screenshot Modes

- **area** (default): Interactive area selection using mouse drag
- **window**: Click on a window to capture it
- **screen**: Captures the entire screen immediately

## Keyboard Shortcuts

Set up keyboard shortcuts in your desktop environment:

### GNOME Shell

1. Settings → Keyboard → Custom Shortcuts → **+**
2. Create shortcuts:
   - Area: `gshot-copy` → **Shift+PrintScreen**
   - Window: `gshot-copy --mode window` → **Ctrl+Shift+PrintScreen**
   - Screen: `gshot-copy --mode screen` → **Alt+PrintScreen**

### KDE Plasma

1. System Settings → Shortcuts → Custom Shortcuts → **Edit → New → Global Shortcut → Command/URL**
2. Set up the same commands and shortcuts as above

### i3 / Sway

Add to your config file:

```
# Area screenshot (note: sleep helps with pointer grab issues)
bindsym Print exec --no-startup-id sleep 0.1 && gshot-copy
# Window screenshot  
bindsym Shift+Print exec --no-startup-id gshot-copy --mode window
# Screen screenshot
bindsym Ctrl+Print exec --no-startup-id gshot-copy --mode screen
```

## Development

### Testing

The project includes unit tests for core functions using the [bats](https://github.com/bats-core/bats-core) testing framework.

#### Install bats (optional)

```bash
# Ubuntu/Debian
sudo apt install bats

# macOS
brew install bats-core
```

#### Run unit tests

```bash
./run_tests.sh               # Run unit tests for core functions
```

The unit tests cover filename generation and argument parsing logic. For full functionality testing, manually verify the different screenshot modes and options work as expected on your system.

## Troubleshooting

### Common Issues

**"scrot is required but not installed"**
```bash
sudo apt install scrot  # Ubuntu/Debian
sudo dnf install scrot  # Fedora
sudo pacman -S scrot    # Arch
```

**"No clipboard utility found"**
```bash
sudo apt install wl-clipboard xclip xsel  # Install clipboard tools
```

**"Screenshot cancelled or failed"**
- This is normal if you press Escape during area selection
- Check that you have sufficient permissions to write to the output directory

**"Another scrot instance is already running"**
- Wait for the current screenshot operation to complete
- This prevents conflicts between multiple screenshot attempts

**Window manager keybinding issues (scrot: couldn't grab pointer)**
- Add a small delay: `sleep 0.1 && gshot-copy`
- Or use `--release` flag in i3/sway: `bindsym --release Print exec gshot-copy`

**Permission denied when creating directory**
- Ensure you have write access to the output directory
- Try using a different output directory: `gshot-copy --output-dir ~/Desktop`

### File Naming

Screenshots are saved with the format: `gshot-YYYY-MM-DD-HHMMSS-XXXX.png`

Example: `gshot-2023-12-25-143052-AbCd.png`
- `2023-12-25`: Date
- `143052`: Time (14:30:52)
- `AbCd`: Random 4-letter suffix for uniqueness

## Alternatives

- **Flameshot**: Feature-rich with annotation, but no automatic file path copying
- **Spectacle**: KDE's tool with some timestamp naming, but lacks uniqueness guarantees
- **maim/grim**: Lightweight but require additional scripting for UI and clipboard integration

**gshot-copy** fills the gap by providing timestamp naming with uniqueness guarantees, multiple screenshot modes, and automatic file path clipboard integration in a single, portable script.

## License

Zero-Clause BSD - see LICENSE file for details.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Ensure all tests pass: `./run_tests.sh`
5. Submit a pull request

Issues and feature requests are welcome!