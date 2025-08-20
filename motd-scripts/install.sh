#!/usr/bin/env bash
set -euo pipefail

# ===================== Konfiguration / CLI =====================
REPO_URL="${1:-}"            # optional: ./install.sh https://github.com/<user>/dotfiles.git
BRANCH="${BRANCH:-main}"     # Branch für Clone (nur wenn REPO_URL genutzt wird)
DISABLE_UBUNTU="${DISABLE_UBUNTU:-false}"  # true -> 80/90/91-* deaktivieren

# ===================== Hilfsfunktionen =========================
need_apt() { command -v "$1" >/dev/null 2>&1 || sudo apt-get install -y "$1"; }
confirm() {
  local prompt="${1:-Weiter? [Y/n]}"; local default_yes="${2:-y}"
  local ans; read -r -p "$prompt " ans || true
  ans="${ans:-$default_yes}"; [[ "$ans" =~ ^[YyJj]$ ]]
}
msg() { printf "\033[1;36m%s\033[0m\n" "$*"; }    # Cyan bold
ok()  { printf "\033[1;32m%s\033[0m\n" "$*"; }    # Grün bold
warn(){ printf "\033[1;33m%s\033[0m\n" "$*"; }    # Gelb bold
err() { printf "\033[1;31m%s\033[0m\n" "$*"; }    # Rot bold

# ===================== Arbeitsverzeichnis ======================
SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd -P)"
cd "$SCRIPT_DIR"

# Pfade (lokal neben diesem Script erwartet)
LOCAL_SRC_DIR="$SCRIPT_DIR/update-motd.d"
LOCAL_HEADER="$LOCAL_SRC_DIR/00-header"
LOCAL_SYSINFO="$LOCAL_SRC_DIR/10-sysinfo"

# ===================== Distro-Check ============================
if ! command -v apt-get >/dev/null 2>&1; then
  err "Dieses Installscript unterstützt aktuell Debian/Ubuntu (apt-get)."
  exit 1
fi

# ===================== Dependencies ============================
msg "[1/6] Pakete installieren…"
sudo apt-get update -y
need_apt git
need_apt figlet
need_apt ruby
need_apt iproute2
need_apt procps
need_apt util-linux
need_apt lsb-release

# lolcat systemweit (via gem) bereitstellen
if ! command -v /usr/local/bin/lolcat >/dev/null 2>&1; then
  msg "  • lolcat installieren (RubyGems)…"
  sudo gem install lolcat --no-document || true
  if ! command -v /usr/local/bin/lolcat >/dev/null 2>&1; then
    if command -v lolcat >/dev/null 2>&1; then
      sudo ln -sf "$(command -v lolcat)" /usr/local/bin/lolcat
    fi
  fi
fi
ok "Dependencies ok."

# ===================== Quell-Skripte beschaffen =================
SRC_HEADER=""
SRC_SYSINFO=""

if [[ -f "$LOCAL_HEADER" && -f "$LOCAL_SYSINFO" ]]; then
  msg "[2/6] Lokale Skripte gefunden (update-motd.d/*)."
  SRC_HEADER="$LOCAL_HEADER"
  SRC_SYSINFO="$LOCAL_SYSINFO"
else
  msg "[2/6] Lokale Skripte nicht gefunden."
  if [[ -z "$REPO_URL" ]]; then
    read -r -p "Git-Repo-URL angeben (z.B. https://github.com/<user>/dotfiles.git): " REPO_URL || true
  fi
  if [[ -z "$REPO_URL" ]]; then
    err "Keine Skripte vorhanden und keine Repo-URL angegeben. Abbruch."
    exit 1
  fi
  WORKDIR="$(mktemp -d)"
  msg "  • Klone $REPO_URL -> $WORKDIR"
  git clone --depth=1 ${BRANCH:+-b "$BRANCH"} "$REPO_URL" "$WORKDIR"
  # Versuche typische Layouts zu finden:
  CANDIDATES=(
    "$WORKDIR/update-motd.d"
    "$WORKDIR/motd-scripts/update-motd.d"
    "$WORKDIR/motd/update-motd.d"
  )
  found=""
  for d in "${CANDIDATES[@]}"; do
    if [[ -f "$d/00-header" && -f "$d/10-sysinfo" ]]; then found="$d"; break; fi
  done
  if [[ -z "$found" ]]; then
    # generische Suche (max Tiefe 3)
    found="$(find "$WORKDIR" -maxdepth 3 -type f -name '00-header' -printf '%h\n' 2>/dev/null | head -n1 || true)"
    [[ -n "$found" && -f "$found/10-sysinfo" ]] || found=""
  fi
  if [[ -z "$found" ]]; then
    err "Konnte update-motd.d/{00-header,10-sysinfo} im Repo nicht finden."
    exit 1
  fi
  SRC_HEADER="$found/00-header"
  SRC_SYSINFO="$found/10-sysinfo"
  ok "Skripte gefunden: $found"
fi

# ===================== Zielverzeichnis & Kopie ==================
msg "[3/6] Skripte nach /etc/update-motd.d/ installieren…"
sudo mkdir -p /etc/update-motd.d
# Backups vorhandener Dateien
for f in 00-header 10-sysinfo; do
  if [[ -f "/etc/update-motd.d/$f" ]]; then
    sudo cp -a "/etc/update-motd.d/$f" "/etc/update-motd.d/$f.bak.$(date +%Y%m%d%H%M%S)"
  fi
done
sudo install -m 0755 -o root -g root "$SRC_HEADER"  /etc/update-motd.d/00-header
sudo install -m 0755 -o root -g root "$SRC_SYSINFO" /etc/update-motd.d/10-sysinfo
ok "Installiert."

# ===================== PAM/MOTD aktivieren =====================
msg "[4/6] PAM/MOTD prüfen…"
PAM_FILE="/etc/pam.d/sshd"
need_lines=(
  "session optional pam_motd.so motd=/run/motd.dynamic"
  "session optional pam_motd.so noupdate"
)
changed=false
for line in "${need_lines[@]}"; do
  if ! sudo grep -Fq "$line" "$PAM_FILE"; then
    if ! $changed; then
      sudo cp -a "$PAM_FILE" "$PAM_FILE.bak.$(date +%Y%m%d%H%M%S)"
      changed=true
    fi
    echo "$line" | sudo tee -a "$PAM_FILE" >/dev/null
  fi
done
$changed && ok "PAM angepasst (Backup: ${PAM_FILE}.bak.*)" || ok "PAM ok."

# ===================== sshd_config (mit Rückfrage) ==============
msg "[5/6] sshd_config prüfen/anpassen…"
SSHD="/etc/ssh/sshd_config"
fix_sshd=false

# Vorschläge: UsePAM yes, PrintMotd no (da PAM ausgibt)
if ! sudo grep -Eq '^\s*UsePAM\s+yes\b' "$SSHD"; then fix_sshd=true; fi
if ! sudo grep -Eq '^\s*PrintMotd\s+no\b' "$SSHD"; then fix_sshd=true; fi

if $fix_sshd; then
  if confirm "sshd_config anpassen (UsePAM yes, PrintMotd no)? [Y/n]" "y"; then
    sudo cp -a "$SSHD" "$SSHD.bak.$(date +%Y%m%d%H%M%S)"
    # Setzen/Ergänzen
    if sudo grep -Eq '^\s*UsePAM\b' "$SSHD"; then
      sudo sed -i -E 's/^\s*UsePAM\s+.*/UsePAM yes/' "$SSHD"
    else
      echo "UsePAM yes" | sudo tee -a "$SSHD" >/dev/null
    fi
    if sudo grep -Eq '^\s*PrintMotd\b' "$SSHD"; then
      sudo sed -i -E 's/^\s*PrintMotd\s+.*/PrintMotd no/' "$SSHD"
    else
      echo "PrintMotd no" | sudo tee -a "$SSHD" >/dev/null
    fi
    ok "sshd_config angepasst (Backup: ${SSHD}.bak.*)"
  else
    warn "sshd_config unverändert gelassen."
  fi
else
  ok "sshd_config ok."
fi

# ===================== Ubuntu-Default-MOTDs (optional) =========
if [[ "${DISABLE_UBUNTU}" == "true" ]]; then
  msg "[optional] Ubuntu-Standard-MOTD-Skripte deaktivieren…"
  sudo bash -c 'chmod -x /etc/update-motd.d/80-* /etc/update-motd.d/90-* /etc/update-motd.d/91-* 2>/dev/null || true'
  ok "Deaktiviert."
fi

# ===================== Dienst neu laden & Test =================
msg "[6/6] SSH neu laden & Testlauf…"
# Service-Namen heuristisch:
if systemctl list-unit-files | grep -q '^ssh\.service'; then
  sudo systemctl reload ssh || sudo systemctl restart ssh || true
elif systemctl list-unit-files | grep -q '^sshd\.service'; then
  sudo systemctl reload sshd || sudo systemctl restart sshd || true
else
  sudo service ssh reload 2>/dev/null || sudo service ssh restart 2>/dev/null || true
fi

ok "Testausgabe (run-parts):"
sudo run-parts /etc/update-motd.d || true

ok "Fertig! Logge dich per SSH neu ein, um das MOTD zu sehen."
