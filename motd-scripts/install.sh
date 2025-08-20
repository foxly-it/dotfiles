#!/usr/bin/env bash
set -euo pipefail

# ===================== Konfiguration / CLI =====================
# Optional kannst du eine Repo-URL mitgeben (falls die Skripte NICHT lokal liegen):
#   sudo bash install.sh https://github.com/foxly-it/dotfiles.git
REPO_URL="${1:-}"                 # optional: Repo mit update-motd.d/00-header & 10-sysinfo
BRANCH="${BRANCH:-main}"          # Branch fürs Klonen (nur wenn REPO_URL genutzt wird)
DISABLE_UBUNTU="${DISABLE_UBUNTU:-false}"  # true => 80/90/91-* deaktivieren
WITH_ETC_MOTD="${WITH_ETC_MOTD:-false}"    # true => zusätzlich /etc/motd anzeigen (pam_motd noupdate)

# ===================== Helpers =====================
need_apt() { command -v "$1" >/dev/null 2>&1 || sudo apt-get install -y "$1"; }
confirm()  { local p="${1:-Weiter? [Y/n]}"; local a; read -r -p "$p " a || true; a="${a:-y}"; [[ "$a" =~ ^[YyJj]$ ]]; }
msg() { printf "\033[1;36m%s\033[0m\n" "$*"; }   # Cyan bold
ok()  { printf "\033[1;32m%s\033[0m\n" "$*"; }   # Grün bold
warn(){ printf "\033[1;33m%s\033[0m\n" "$*"; }   # Gelb bold
err() { printf "\033[1;31m%s\033[0m\n" "$*"; }   # Rot bold

# ===================== Arbeitsverzeichnis =====================
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd -P)"
cd "$SCRIPT_DIR"

LOCAL_SRC_DIR="$SCRIPT_DIR/update-motd.d"
LOCAL_HEADER="$LOCAL_SRC_DIR/00-header"
LOCAL_SYSINFO="$LOCAL_SRC_DIR/10-sysinfo"

# ===================== Distro-Check ===========================
if ! command -v apt-get >/dev/null 2>&1; then
  err "Dieses Installscript unterstützt aktuell Debian/Ubuntu (apt-get)."
  exit 1
fi

# ===================== 1) Abhängigkeiten ======================
msg "[1/7] Pakete installieren…"
sudo apt-get update -y
need_apt git
need_apt figlet
need_apt ruby
need_apt iproute2
need_apt procps
need_apt util-linux
need_apt lsb-release

# lolcat (systemweit) über RubyGems
if ! command -v /usr/local/bin/lolcat >/dev/null 2>&1; then
  msg "  • lolcat via RubyGems…"
  sudo gem install lolcat --no-document || true
  if ! command -v /usr/local/bin/lolcat >/dev/null 2>&1 && command -v lolcat >/dev/null 2>&1; then
    sudo ln -sf "$(command -v lolcat)" /usr/local/bin/lolcat
  fi
fi
ok "Dependencies ok."

# ===================== 2) Skripte beschaffen ==================
SRC_HEADER=""
SRC_SYSINFO=""

if [[ -f "$LOCAL_HEADER" && -f "$LOCAL_SYSINFO" ]]; then
  msg "[2/7] Lokale Skripte gefunden."
  SRC_HEADER="$LOCAL_HEADER"
  SRC_SYSINFO="$LOCAL_SYSINFO"
else
  msg "[2/7] Lokale Skripte nicht gefunden – klone Repo."
  if [[ -z "$REPO_URL" ]]; then
    read -r -p "Git-Repo-URL (z. B. https://github.com/foxly-it/dotfiles.git): " REPO_URL || true
  fi
  if [[ -z "$REPO_URL" ]]; then
    err "Keine Skripte vorhanden und keine Repo-URL angegeben. Abbruch."
    exit 1
  fi
  WORKDIR="$(mktemp -d)"
  git clone --depth=1 ${BRANCH:+-b "$BRANCH"} "$REPO_URL" "$WORKDIR"
  # typische Layouts prüfen
  for d in "$WORKDIR/update-motd.d" "$WORKDIR/motd-scripts/update-motd.d" "$WORKDIR/motd/update-motd.d"; do
    if [[ -f "$d/00-header" && -f "$d/10-sysinfo" ]]; then SRC_HEADER="$d/00-header"; SRC_SYSINFO="$d/10-sysinfo"; break; fi
  done
  if [[ -z "$SRC_HEADER" ]]; then
    # generische Suche (max Tiefe 3)
    found="$(find "$WORKDIR" -maxdepth 3 -type f -name '00-header' -printf '%h\n' 2>/dev/null | head -n1 || true)"
    [[ -n "$found" && -f "$found/10-sysinfo" ]] || found=""
    [[ -n "$found" ]] || { err "update-motd.d/{00-header,10-sysinfo} im Repo nicht gefunden."; exit 1; }
    SRC_HEADER="$found/00-header"; SRC_SYSINFO="$found/10-sysinfo"
  fi
fi

# ===================== 3) Installation nach /etc ==============
msg "[3/7] Skripte nach /etc/update-motd.d/ installieren…"
sudo mkdir -p /etc/update-motd.d
for f in 00-header 10-sysinfo; do
  [[ -f "/etc/update-motd.d/$f" ]] && sudo cp -a "/etc/update-motd.d/$f" "/etc/update-motd.d/$f.bak.$(date +%Y%m%d%H%M%S)"
done
sudo install -m 0755 -o root -g root "$SRC_HEADER"  /etc/update-motd.d/00-header
sudo install -m 0755 -o root -g root "$SRC_SYSINFO" /etc/update-motd.d/10-sysinfo
ok "Skripte installiert."

# ===================== 4) Generator für /run/motd.dynamic =====
msg "[4/7] Generator /usr/local/sbin/generate-motd einrichten…"
TMP_GEN="$(mktemp)"
cat >"$TMP_GEN" <<'EOF'
#!/bin/sh
set -e
umask 022
OUT="/run/motd.dynamic"
mkdir -p /run
if command -v run-parts >/dev/null 2>&1; then
  run-parts /etc/update-motd.d > "$OUT" 2>/dev/null || true
else
  {
    for f in /etc/update-motd.d/*; do
      [ -x "$f" ] && "$f"
    done
  } > "$OUT" 2>/dev/null || true
fi
exit 0
EOF
sudo install -m 0755 -o root -g root "$TMP_GEN" /usr/local/sbin/generate-motd
rm -f "$TMP_GEN"
ok "Generator bereit."

# ===================== 5) PAM: generieren & anzeigen ==========
msg "[5/7] PAM/MOTD in /etc/pam.d/sshd konfigurieren…"
PAM_FILE="/etc/pam.d/sshd"
sudo cp -a "$PAM_FILE" "$PAM_FILE.bak.$(date +%Y%m%d%H%M%S)"

# Alte/duplizierte Zeilen herausfiltern und exakt EINE korrekte Reihenfolge setzen:
# - pam_exec mit 'seteuid' VOR pam_motd
# - genau EINE pam_motd mit /run/motd.dynamic
# - optional zweite Zeile 'pam_motd.so noupdate' (wenn WITH_ETC_MOTD=true)
sudo awk -v with_motd="$WITH_ETC_MOTD" '
  $0 ~ /pam_exec\.so.*generate-motd/ { next }
  $0 ~ /pam_motd\.so.*motd=\/run\/motd\.dynamic/ { next }
  $0 ~ /pam_motd\.so.*noupdate/ { next }
  { print }
  END {
    print "session optional pam_exec.so seteuid stdout /usr/local/sbin/generate-motd"
    print "session optional pam_motd.so motd=/run/motd.dynamic"
    if (with_motd == "true") {
      print "session optional pam_motd.so noupdate"
    }
  }
' "$PAM_FILE" | sudo tee "$PAM_FILE.tmp" >/dev/null
sudo mv "$PAM_FILE.tmp" "$PAM_FILE"
ok "PAM/MOTD konfiguriert. Backup: ${PAM_FILE}.bak.*"

# ===================== 6) sshd_config per Drop-In (mit Prompt) =
msg "[6/7] sshd_config prüfen…"
SSHD_DROPIN_DIR="/etc/ssh/sshd_config.d"
SSHD_DROPIN_FILE="$SSHD_DROPIN_DIR/99-motd.conf"
set_it=false
# Effektive Werte prüfen
USEPAM="$(sudo sshd -T 2>/dev/null | awk '/^usepam/ {print $2}')"
PRINTMOTD="$(sudo sshd -T 2>/dev/null | awk '/^printmotd/ {print $2}')"
[[ "$USEPAM" != "yes" || "$PRINTMOTD" != "no" ]] && set_it=true

if $set_it; then
  if confirm "Drop-In setzen (UsePAM yes, PrintMotd no)? [Y/n]" "y"; then
    sudo mkdir -p "$SSHD_DROPIN_DIR"
    sudo tee "$SSHD_DROPIN_FILE" >/dev/null <<'EOF'
UsePAM yes
PrintMotd no
EOF
    ok "Drop-In geschrieben: $SSHD_DROPIN_FILE"
  else
    warn "sshd_config unverändert gelassen."
  fi
else
  ok "sshd ist bereits mit usepam=yes & printmotd=no konfiguriert."
fi

# ===================== 7) Optional: Ubuntu-Defaults deaktivieren
if [[ "${DISABLE_UBUNTU}" == "true" ]]; then
  msg "[optional] Ubuntu-Standard-MOTD-Skripte deaktivieren…"
  sudo bash -c 'chmod -x /etc/update-motd.d/80-* /etc/update-motd.d/90-* /etc/update-motd.d/91-* 2>/dev/null || true'
  ok "Deaktiviert."
fi

# ===================== SSH neu laden & Test ====================
msg "[Fin] SSH neu laden & Testlauf…"
if systemctl list-unit-files | grep -q '^ssh\.service'; then
  sudo systemctl reload ssh || sudo systemctl restart ssh || true
elif systemctl list-unit-files | grep -q '^sshd\.service'; then
  sudo systemctl reload sshd || sudo systemctl restart sshd || true
else
  sudo service ssh reload 2>/dev/null || sudo service ssh restart 2>/dev/null || true
fi

# Einmal generieren & Vorschau zeigen
sudo /usr/local/sbin/generate-motd || true
echo "----- MOTD (Preview) -----"
sudo head -n 60 /run/motd.dynamic 2>/dev/null || true
echo "--------------------------"

ok "Fertig! Bitte neu per SSH einloggen, um das MOTD zu sehen."
warn "Falls weiterhin nur der Debian/Ubuntu-Standardtext erscheint: prüfe ~/.hushlogin im Ziel-Account."
