#!/usr/bin/env bash
set -euo pipefail

need() { command -v "$1" >/dev/null 2>&1 || sudo apt-get install -y "$1"; }

sudo apt-get update
need figlet
need ruby
need iproute2
need procps
need util-linux

# lolcat per gem (systemweit)
if ! command -v /usr/local/bin/lolcat >/dev/null 2>&1; then
  sudo gem install lolcat --no-document || true
  command -v /usr/local/bin/lolcat >/dev/null 2>&1 || {
    # Fallback: symlink, falls lolcat woanders liegt
    if command -v lolcat >/dev/null 2>&1; then
      sudo ln -sf "$(command -v lolcat)" /usr/local/bin/lolcat
    fi
  }
fi

# Zielordner
sudo mkdir -p /etc/update-motd.d

# Kopieren
sudo install -m 0755 -o root -g root update-motd.d/00-header /etc/update-motd.d/00-header
sudo install -m 0755 -o root -g root update-motd.d/10-sysinfo /etc/update-motd.d/10-sysinfo

echo "Done. Test mit: sudo run-parts /etc/update-motd.d"
