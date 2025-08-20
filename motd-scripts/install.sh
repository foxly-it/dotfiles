#!/usr/bin/env bash
set -euo pipefail

# ---------- 0) In das Verzeichnis wechseln, in dem dieses Script liegt ----------
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd -P)"
cd "$SCRIPT_DIR"

# Erwartete Dateien prüfen (relativ zum SCRIPT_DIR)
[ -f "update-motd.d/00-header" ]  || { echo "Fehlt: update-motd.d/00-header"; exit 1; }
[ -f "update-motd.d/10-sysinfo" ] || { echo "Fehlt: update-motd.d/10-sysinfo"; exit 1; }

# Optionaler Schalter
DISABLE_UBUNTU=false
for arg in "${@:-}"; do
  [[ "$arg" == "--disable-ubuntu-motd" ]] && DISABLE_UBUNTU=true
done

# ---------- 1) Dependencies ----------
if ! command -v apt-get >/dev/null 2>&1; then
  echo "Dieses Installscript ist für Debian/Ubuntu (apt-get). Abbruch." >&2
  exit 1
fi

need() { command -v "$1" >/dev/null 2>&1 || sudo apt-get install -y "$1"; }

echo "[1/4] Pakete installieren…"
sudo apt-get update -y
need figlet
need ruby
need iproute2
need procps
need util-linux
need lsb-release

echo "[2/4] lolcat installieren…"
if ! command -v /usr/local/bin/lolcat >/dev/null 2>&1; then
  sudo gem install lolcat --no-document || true
  # Falls lolcat woanders liegt, verlinken
  if ! command -v /usr/local/bin/lolcat >/dev/null 2>&1 && command -v lolcat >/dev/null 2>&1; then
    sudo ln -sf "$(command -v lolcat)" /usr/local/bin/lolcat
  fi
fi

# ---------- 3) Dateien kopieren ----------
echo "[3/4] Skripte nach /etc/update-motd.d/ kopieren…"
sudo mkdir -p /etc/update-motd.d
sudo install -m 0755 -o root -g root update-motd.d/00-header  /etc/update-motd.d/00-header
sudo install -m 0755 -o root -g root update-motd.d/10-sysinfo /etc/update-motd.d/10-sysinfo

if $DISABLE_UBUNTU; then
  echo "[optional] Ubuntu-Standard-MOTD-Skripte deaktivieren…"
  sudo bash -c 'chmod -x /etc/update-motd.d/80-* /etc/update-motd.d/90-* /etc/update-motd.d/91-* 2>/dev/null || true'
fi

# ---------- 4) Test ----------
echo "[4/4] Testlauf:"
sudo run-parts /etc/update-motd.d || true

echo "✅ Fertig. Neu einloggen oder 'sudo run-parts /etc/update-motd.d' ausführen."
