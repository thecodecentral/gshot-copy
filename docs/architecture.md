````markdown
# gshot-copy

**gshot-copy** is a lightweight, distro-agnostic wrapper script for taking area screenshots on Linux, auto-naming them with timestamps and random suffixes, and copying the resulting file path to the clipboard in one seamless operation.

## Features

- **Multiple screenshot modes**: area selection (default), window capture, or full screen using `scrot`.
- **Timestamp-based filenames** with format `gshot-YYYY-MM-DD-HHMMSS-<4 random letters>.png` to ensure unique, collision-free naming.
- **Configurable output directory**: saves to `~/Pictures/Screenshots/` by default, customizable with `--output-dir` option.
- **Optional delay and pointer inclusion**: supports delayed screenshots and mouse cursor capture.
- **Clipboard integration**: copies the full path of the saved screenshot to the clipboard using `wl-copy`, `xclip`, or `xsel`, depending on your environment.
- **Minimal dependencies**: lightweight X11/imlib2 libraries, no heavy desktop environment dependencies.
- **Portable** across major distributions (Ubuntu/Debian, Fedora/CentOS, Arch, etc.) and display servers (X11 or Wayland).

## Requirements & Dependencies

- **Shell**: POSIX‑compliant (`bash`, `dash`, `zsh`, `fish`, etc.)
- **Screenshot tool**: `scrot`
- **Clipboard utilities**:
  - **Wayland**: `wl-clipboard` (`wl-copy` / `wl-paste`)
  - **X11**: `xclip` or `xsel`
- **Optional**: `xbindkeys` for universal hotkey support

On most distros, installation commands are:

```bash
# Debian/Ubuntu
sudo apt update
sudo apt install scrot wl-clipboard xclip xsel xbindkeys

# Fedora
sudo dnf install scrot wl-clipboard xclip xsel xbindkeys

# Arch
sudo pacman -Syu scrot wl-clipboard xclip xsel xbindkeys
````

## Installation

1. **Copy the script** `gshot-copy` from this repository to `~/bin/` (or any directory in your `$PATH`)

2. **Make it executable**:
   ```bash
   chmod +x ~/bin/gshot-copy
   ```

3. **Ensure `~/bin` is in your `PATH`** (add to `~/.bashrc`/`~/.profile` if needed):
   ```bash
   export PATH="$HOME/bin:$PATH"
   ```

## Shell Compatibility

The script is written to be POSIX-compliant and should work with most shells including:
- **bash** (primary target)
- **dash** (lightweight POSIX shell)
- **zsh** (with POSIX mode)
- **fish** (may require shell-specific adaptations for advanced features)

For Fish shell users, the script should work as-is when called from Fish, since it uses `#!/usr/bin/env bash` shebang. However, if integrating deeply with Fish (like custom Fish functions), consider creating a Fish wrapper function.

## Testing

The filename generation logic can be unit tested by extracting it into a testable function:

```bash
# Testable function for filename generation
generate_filename() {
    local output_dir="$1"
    local timestamp="$2"  # Optional: pass timestamp for testing
    local random_suffix="$3"  # Optional: pass suffix for testing
    
    if [ -z "$timestamp" ]; then
        timestamp=$(date +%Y-%m-%d-%H%M%S)
    fi
    
    if [ -z "$random_suffix" ]; then
        random_suffix=$(tr -dc 'a-zA-Z' < /dev/urandom | head -c 4)
    fi
    
    echo "$output_dir/gshot-${timestamp}-${random_suffix}.png"
}

# Test cases can verify:
# - Correct filename format
# - Directory path handling
# - Timestamp format validation
# - Random suffix length and character set
```

## Usage

* In a terminal, run:

  ```bash
  # Basic area screenshot (default)
  gshot-copy
  
  # Window screenshot
  gshot-copy --mode window
  
  # Full screen screenshot
  gshot-copy --mode screen
  
  # Area screenshot with 3-second delay
  gshot-copy --delay 3
  
  # Include mouse pointer in screenshot
  gshot-copy --include-pointer
  
  # Custom output directory
  gshot-copy --output-dir ~/Desktop
  
  # Combined options
  gshot-copy --mode window --delay 2 --include-pointer --output-dir ~/Desktop
  ```

### Screenshot Modes

- **Area mode** (default): Interactive area selection using mouse drag
- **Window mode**: Click on a window to capture it
- **Screen mode**: Captures the entire screen immediately

* Screenshots are saved as `~/Pictures/Screenshots/gshot-YYYY-MM-DD-HHMMSS-XXXX.png` and the file path is copied to your clipboard.

## Key Binding Examples

### GNOME Shell

1. Settings → Keyboard → Custom Shortcuts → **+**
2. Create multiple shortcuts for different modes:
   - Name: `gshot-copy Area`, Command: `gshot-copy`, Shortcut: **Shift+PrintScreen**
   - Name: `gshot-copy Window`, Command: `gshot-copy --mode window`, Shortcut: **Ctrl+Shift+PrintScreen**
   - Name: `gshot-copy Screen`, Command: `gshot-copy --mode screen`, Shortcut: **Alt+PrintScreen**

### KDE Plasma

1. System Settings → Shortcuts → Custom Shortcuts → **Edit → New → Global Shortcut → Command/URL**
2. Create shortcuts for different modes:
   - Area: Action `gshot-copy`, Trigger **Shift+PrintScreen**
   - Window: Action `gshot-copy --mode window`, Trigger **Ctrl+Shift+PrintScreen**  
   - Screen: Action `gshot-copy --mode screen`, Trigger **Alt+PrintScreen**

### XFCE

1. Settings → Keyboard → Application Shortcuts → **Add**
2. Add multiple commands:
   - `gshot-copy` → **Shift+PrintScreen**
   - `gshot-copy --mode window` → **Ctrl+Shift+PrintScreen**
   - `gshot-copy --mode screen` → **Alt+PrintScreen**

### i3 / Sway

Add to config:

```text
# Area screenshot (note: sleep helps with pointer grab issues)
bindsym Print exec --no-startup-id sleep 0.1 && /home/you/bin/gshot-copy
# Window screenshot  
bindsym Shift+Print exec --no-startup-id /home/you/bin/gshot-copy --mode window
# Screen screenshot
bindsym Ctrl+Print exec --no-startup-id /home/you/bin/gshot-copy --mode screen

# Alternative: use --release flag to avoid pointer conflicts
# bindsym --release Print exec --no-startup-id /home/you/bin/gshot-copy
```

### xbindkeys (Universal)

```bash
# ~/.xbindkeysrc
"/home/you/bin/gshot-copy"
    shift + Print

"/home/you/bin/gshot-copy --mode window"
    control + shift + Print

"/home/you/bin/gshot-copy --mode screen"
    alt + Print
```

Then run:

```bash
xbindkeys
```

## Alternatives & Rationale

* **Flameshot**: offers GUI annotation and clipboard-copy of image data, but lacks timestamp filenames and auto-copy of file paths without scripting.
* **Spectacle**: KDE’s screenshot tool with timestamp-based naming and clipboard image copy, but no random suffix for uniqueness or path-copy.
* **gnome-screenshot**: GUI-focused with poor script control and timing issues as it doesn't block the CLI.
* **maim/grim+slop**: ultra-lightweight but require wrappers for UI and clipboard integration.

No single turnkey utility covers all three of: area pick, timestamp naming with uniqueness, and file-path clipboard copy. **gshot-copy** fills that gap with minimal overhead and maximum portability.

---

*Document generated as a spec for LLM-driven implementation of the `gshot-copy` tool.*


