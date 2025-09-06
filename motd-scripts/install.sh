#!/usr/bin/env bash
set -euo pipefail

<<<<<<< HEAD
# ===================== Konfiguration / CLI =====================
#   sudo bash install.sh https://github.com/foxly-it/dotfiles.git
REPO_URL="${1:-}"                 # optional: Repo mit update-motd.d/00-header & 10-sysinfo
BRANCH="${BRANCH:-main}"          # Branch fürs Klonen
DISABLE_UBUNTU="${DISABLE_UBUNTU:-false}"  # true => 80/90/91-* deaktivieren
WITH_ETC_MOTD="${WITH_ETC_MOTD:-false}"    # true => zusätzlich /etc/motd anzeigen (pam_motd noupdate)
=======
# ===== Optik & Utils =====
GREEN="\033[38;5;114m"; BOLD="\033[1m"; RESET="\033[0m"
info(){ printf "${GREEN}ℹ %s${RESET}\n" "$1"; }
ok(){ printf "${GREEN}✔ %s${RESET}\n" "$1"; }
warn(){ printf "\033[33m⚠ %s\033[0m\n" "$1"; }
err(){ printf "\033[31m✖ %s\033[0m\n" "$1"; }
>>>>>>> d650781fdc0dfe702770c03052eefb935f3d50b7

ask_yn(){ # Enter = Ja
  local prompt="$1"; local def_yes="${2:-y}"; local ans; local hint="[j/N]"; [[ "$def_yes" =~ ^[Yy]$ ]] && hint="[J/n]"
  read -r -p "$prompt $hint " ans || true
  ans="${ans:-$def_yes}"
  case "$ans" in j|J|y|Y) return 0 ;; n|N) return 1 ;; *) echo "Bitte j/n eingeben."; ask_yn "$prompt" "$def_yes";; esac
}

need_cmd(){ command -v "$1" >/dev/null 2>&1; }

# ===== Pfade & Quellen =====
TMP_DIR="/tmp/motd-banner"
TARGET_DIR="/etc/update-motd.d"
TARGET_HEADER="${TARGET_DIR}/00-header"
TARGET_SYSINFO="${TARGET_DIR}/10-sysinfo"
BACKUP_DIR="/etc/update-motd.d.bak-$(date +%Y%m%d-%H%M%S)"

URL_HEADER="https://raw.githubusercontent.com/foxly-it/dotfiles/refs/heads/main/motd-scripts/update-motd.d/00-header"
URL_SYSINFO="https://raw.githubusercontent.com/foxly-it/dotfiles/refs/heads/main/motd-scripts/update-motd.d/10-sysinfo"

SRC_HEADER_LOCAL="./00-header"
SRC_SYSINFO_LOCAL="./10-sysinfo"

# ===== Root/Sudo =====
SUDO=""
if [ "$(id -u)" -ne 0 ]; then
  info "Rootrechte werden benötigt."
  if ask_yn "Mit sudo fortfahren?" y; then
    need_cmd sudo || { err "sudo nicht verfügbar."; exit 1; }
    sudo -v || { err "sudo Authentifizierung fehlgeschlagen."; exit 1; }
    SUDO="sudo"
  else
    err "Abgebrochen (keine Rootrechte)."; exit 1
  fi
fi

echo -e "${BOLD}== Block 1/5: Installation bestätigen ==${RESET}"
if ! ask_yn "Möchtest du den MOTD-Banner installieren?" y; then
  info "Installation übersprungen."; exit 0
fi

echo -e "\n${BOLD}== Block 2/5: Quellen beziehen ==${RESET}"
USE_DOWNLOAD=true
if ! ask_yn "Dateien aus dem Repo nach ${TMP_DIR} herunterladen?" y; then
  USE_DOWNLOAD=false
fi

HEADER_SRC="$SRC_HEADER_LOCAL"; SYSINFO_SRC="$SRC_SYSINFO_LOCAL"
if $USE_DOWNLOAD; then
  need_cmd curl || { err "curl fehlt (wird in Block 3 installiert). Bitte erneut ausführen."; }
  mkdir -p "$TMP_DIR"
  info "Lade 00-header …"
  curl -fL --retry 3 -o "${TMP_DIR}/00-header" "$URL_HEADER"
  info "Lade 10-sysinfo …"
  curl -fL --retry 3 -o "${TMP_DIR}/10-sysinfo" "$URL_SYSINFO"
  chmod +x "${TMP_DIR}/00-header" "${TMP_DIR}/10-sysinfo" || true
  HEADER_SRC="${TMP_DIR}/00-header"
  SYSINFO_SRC="${TMP_DIR}/10-sysinfo"
else
  [ -f "$HEADER_SRC" ]  || { err "Lokale Quelle fehlt: $HEADER_SRC"; exit 1; }
  [ -f "$SYSINFO_SRC" ] || { err "Lokale Quelle fehlt: $SYSINFO_SRC"; exit 1; }
fi
ok "Quellen bereit."

echo -e "\n${BOLD}== Block 3/5: Abhängigkeiten installieren ==${RESET}"
need_cmd apt-get || { err "Nur apt-basierte Systeme (Debian/Ubuntu) werden unterstützt."; exit 1; }

# Kernabhängigkeiten (00-header + 10-sysinfo + Preview)
declare -A REQS=(
  [ip]="iproute2"
  [ss]="iproute2"
  [awk]="gawk"
  [free]="procps"
  [who]="coreutils"
  [figlet]="figlet"
  [run-parts]="debianutils"
  [curl]="curl"
)
MISSING=()
for bin in "${!REQS[@]}"; do command -v "$bin" >/dev/null 2>&1 || MISSING+=("${REQS[$bin]}"); done
# Doppelte Pakete entfernen
if [ "${#MISSING[@]}" -gt 0 ]; then
  mapfile -t MISSING < <(printf "%s\n" "${MISSING[@]}" | awk '!seen[$0]++')
  if ask_yn "Fehlende Pakete installieren: ${MISSING[*]} ?" y; then
    $SUDO apt-get update -qq
    $SUDO apt-get install -y -qq "${MISSING[@]}"
    ok "Abhängigkeiten installiert."
  else
    warn "Abhängigkeiten nicht vollständig – ggf. eingeschränkte Funktion."
  fi
else
  ok "Alle Abhängigkeiten vorhanden."
fi

# Lolcat optional + Symlink für /usr/local/bin/lolcat (wie dein 00-header erwartet)
if ! need_cmd lolcat; then
  if ask_yn "Optional: lolcat installieren (schöne Farben)?" y; then
    $SUDO apt-get update -qq
    $SUDO apt-get install -y -qq lolcat || warn "Konnte lolcat nicht installieren (optional)."
  fi
fi
if command -v lolcat >/dev/null 2>&1; then
  LOLCAT_BIN="$(command -v lolcat)"
  if [ "$LOLCAT_BIN" != "/usr/local/bin/lolcat" ] && ask_yn "Symlink /usr/local/bin/lolcat -> ${LOLCAT_BIN} anlegen?" y; then
    $SUDO mkdir -p /usr/local/bin
    $SUDO ln -sf "$LOLCAT_BIN" /usr/local/bin/lolcat
    ok "Symlink gesetzt."
  fi
fi

echo -e "\n${BOLD}== Block 4/5: Deployment ==${RESET}"
# Backup
if ask_yn "Bestehende MOTD-Skripte nach ${BACKUP_DIR} sichern?" y; then
  $SUDO mkdir -p "$BACKUP_DIR"
  [ -d "$TARGET_DIR" ] && $SUDO cp -a "${TARGET_DIR}/." "$BACKUP_DIR/" || true
  ok "Backup: ${BACKUP_DIR}"
fi

# Zielverzeichnis
$SUDO mkdir -p "$TARGET_DIR"

# Installieren
$SUDO install -m 0755 "$HEADER_SRC" "$TARGET_HEADER"
$SUDO install -m 0755 "$SYSINFO_SRC" "$TARGET_SYSINFO"
$SUDO chown root:root "$TARGET_HEADER" "$TARGET_SYSINFO" || true
ok "Installiert: ${TARGET_HEADER}, ${TARGET_SYSINFO}"

# Andere Skripte optional deaktivieren
if ask_yn "Andere MOTD-Skripte im Verzeichnis deaktivieren (außer 00-header/10-sysinfo)?" y; then
  while IFS= read -r f; do
    base="$(basename "$f")"
    case "$base" in 00-header|10-sysinfo) continue ;; esac
    $SUDO chmod -x "$f" || true
  done < <(find "$TARGET_DIR" -maxdepth 1 -type f -perm -u+x -print 2>/dev/null | sort)
  ok "Andere Skripte deaktiviert."
fi

echo -e "\n${BOLD}== Block 5/5: Standardmeldungen bereinigen (Debian) ==${RESET}"
# 5a) Standard-/etc/motd leeren (zeigt sonst den langen Debian-Hinweis)
if ask_yn "Standardmeldung aus /etc/motd entfernen (Backup + leeren)?" y; then
  if [ -f /etc/motd ]; then
    $SUDO cp -a /etc/motd "/etc/motd.bak-$(date +%Y%m%d-%H%M%S)" || true
  fi
  echo "" | $SUDO tee /etc/motd >/dev/null
  ok "/etc/motd geleert."
fi

# 5b) „Last login:“ entfernen (nur SSH) – wirkt sich auf Auditing aus!
if ask_yn "„Last login:“-Zeile unter SSH deaktivieren (sshd_config: PrintLastLog no)?" n; then
  if [ -f /etc/ssh/sshd_config ]; then
    if grep -qiE '^\s*PrintLastLog\s+' /etc/ssh/sshd_config; then
      $SUDO sed -i 's/^\s*#\?\s*PrintLastLog\s\+.*/PrintLastLog no/i' /etc/ssh/sshd_config
    else
      echo "PrintLastLog no" | $SUDO tee -a /etc/ssh/sshd_config >/dev/null
    fi
    $SUDO systemctl reload sshd 2>/dev/null || $SUDO service ssh reload 2>/dev/null || true
    ok "„Last login:“ unter SSH deaktiviert."
  else
    warn "/etc/ssh/sshd_config nicht gefunden – Schritt übersprungen."
  fi
fi

# Vorschau (optional)
if ask_yn "Vorschau jetzt anzeigen (run-parts ${TARGET_DIR})?" y; then
  if need_cmd run-parts && [ -d "$TARGET_DIR" ]; then
    echo -e "\n${BOLD}--- Vorschau ---${RESET}"
    run-parts "$TARGET_DIR" || true
    echo -e "${BOLD}--- Ende Vorschau ---${RESET}\n"
  else
    warn "run-parts oder ${TARGET_DIR} nicht verfügbar – Vorschau übersprungen."
  fi
fi

ok "Fertig. Beim nächsten Login erscheint dein MOTD."
