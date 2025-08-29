# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

This is a German-language MOTD (Message of the Day) system for Ubuntu/Debian servers that provides:
- Colorized hostname banner using FIGlet and lolcat
- German system information dashboard with system uptime, load, memory usage, and available package updates
- Hardware-only network interface detection (excludes Docker/virtual interfaces)
- Robust remote host detection for SSH connections
- PAM integration for automatic display on SSH login

## Core Architecture

The system consists of two main shell scripts that integrate with the standard `/etc/update-motd.d/` framework:

- **`update-motd.d/00-header`** - Creates the colorized hostname banner and basic OS information
- **`update-motd.d/10-sysinfo`** - Generates a comprehensive German system information table

The installation script (`install.sh`) handles:
- Dependency installation (figlet, lolcat, ruby gems)
- PAM configuration for SSH integration
- SSH daemon configuration via drop-in files
- MOTD generator setup at `/usr/local/sbin/generate-motd`

## Common Development Commands

### Installation and Setup
```bash
# Install the MOTD system
sudo bash install.sh

# Install from remote repository
sudo bash install.sh https://github.com/foxly-it/dotfiles.git

# Install with Ubuntu defaults disabled
DISABLE_UBUNTU=true sudo bash install.sh

# Install with /etc/motd display enabled
WITH_ETC_MOTD=true sudo bash install.sh
```

### Testing and Development
```bash
# Test the MOTD generation manually
sudo run-parts /etc/update-motd.d

# Generate and view the dynamic MOTD
sudo /usr/local/sbin/generate-motd
sudo cat /run/motd.dynamic

# Test individual scripts
sudo /etc/update-motd.d/00-header
sudo /etc/update-motd.d/10-sysinfo

# Check PAM configuration
grep -A5 -B5 pam_motd /etc/pam.d/sshd

# Verify SSH configuration
sudo sshd -T | grep -E "(usepam|printmotd)"
```

### Debugging Network Detection
```bash
# Debug hardware network interface detection
ls -1 /sys/class/net
ip -o -4 addr show scope global

# Debug remote host detection
echo "$SSH_CLIENT" "$SSH_CONNECTION"
who --ips
who -m
ss -Htnp state established
```

### Color and Display Testing
```bash
# Test lolcat availability and colors
command -v /usr/local/bin/lolcat
echo "Test colorization" | /usr/local/bin/lolcat -f

# Test figlet fonts
figlet -f slant "$(hostname)"
```

## Key Implementation Details

### German Localization
- System uptime displays in German (Wochen, Tage, Stunden, Minuten)
- For uptime ≥1 week, hours and minutes are omitted for cleaner display
- Decimal numbers use German comma notation (e.g., "15,7%" instead of "15.7%")

### Network Interface Detection
The system only displays IPs from hardware network interfaces:
- Checks `/sys/class/net/<interface>/device` to identify hardware NICs
- Excludes loopback, Docker (docker0), and virtual interfaces (veth*)
- Prefers UP interfaces but falls back to DOWN interfaces if needed

### Remote Host Detection Strategy
Uses a robust multi-step approach to determine the remote SSH client:
1. SSH environment variables (`$SSH_CLIENT`, `$SSH_CONNECTION`)
2. `who --ips` output matched against current TTY
3. `who -m` for host information in parentheses
4. Socket state inspection via `ss` command matching SSH daemon PID

### Color Scheme
- Base table uses a pleasant green color (`\033[38;5;114m`)
- Only "Aktueller Nutzer" and "Remote Host" values are colorized with lolcat gradient
- Lolcat uses forced color mode (`-f`) for non-TTY PAM execution
- Gradient settings: `-p 1.2 -F 0.3` for subtle, readable transitions

### PAM Integration
The system integrates with SSH logins via PAM modules:
- `pam_exec.so seteuid` executes the MOTD generator
- `pam_motd.so motd=/run/motd.dynamic` displays the generated content
- SSH configuration requires `UsePAM yes` and `PrintMotd no`

## File Structure

```
.
├── update-motd.d/
│   ├── 00-header           # Hostname banner and OS info
│   └── 10-sysinfo          # System information table
├── asset/
│   └── motd.jpg            # Documentation screenshot
├── install.sh              # Automated installation script
├── README.md               # German documentation
└── LICENSE                 # MIT license
```

## Dependencies

Required system packages:
- `figlet` - ASCII art text generation
- `ruby` - Runtime for lolcat gem
- `iproute2` - Network interface utilities (`ip` command)
- `procps` - Process utilities
- `util-linux` - System utilities
- `lsb-release` - OS version detection

Ruby gem:
- `lolcat` - Terminal text colorization

## Installation Locations

- Scripts: `/etc/update-motd.d/00-header`, `/etc/update-motd.d/10-sysinfo`
- Generator: `/usr/local/sbin/generate-motd`
- Output: `/run/motd.dynamic`
- SSH config: `/etc/ssh/sshd_config.d/99-motd.conf`
- PAM config: `/etc/pam.d/sshd` (modified)
