#!/usr/bin/env bash
set -euo pipefail

# ---- Optik & Helpers ----
GREEN="\033[38;5;114m"; BOLD="\033[1m"; RESET="\033[0m"
info(){ printf "${GREEN}ℹ %s${RESET}\n" "$1"; }
ok(){ printf "${GREEN}✔ %s${RESET}\n" "$1"; }
warn(){ printf "\033[33m⚠ %s\033[0m\n" "$1"; }
err(){ printf "\033[31m✖ %s\033[0m\n" "$1"; }
pause(){ read -r -p "Weiter mit [Enter] oder Abbruch mit [Strg+C] … " _; }
ask_yn(){
  local prompt="$1" def="${2:-y}" ans
  local hint="[j/N]"; [[ "$def" =~ ^[Yy]$ ]] && hint="[J/n]"
  while true; do
    read -r -p "$prompt $hint " ans || true
    ans="${ans:-$def}"
    case "$ans" in j|J|y|Y) return 0 ;; n|N) return 1 ;; *) echo "Bitte j/n eingeben.";; esac
  done
}
need_cmd(){ command -v "$1" >/dev/null 2>&1; }

# ---- Ziele & Quellen ----
TMP_DIR="/tmp/motd-banner"
TARGET_DIR="/etc/update-motd.d"
TARGET_SYSINFO="${TARGET_DIR}/10-sysinfo"
TARGET_HEADER="${TARGET_DIR}/00-header"
BACKUP_DIR="/etc/update-motd.d.bak-$(date +%Y%m%d-%H%M%S)"

# Feste RAW-Quellen (dein Repo)
URL_HEADER="https://raw.githubusercontent.com/foxly-it/dotfiles/refs/heads/main/motd-scripts/update-motd.d/00-header"
URL_SYSINFO="https://raw.githubusercontent.com/foxly-it/dotfiles/refs/heads/main/motd-scripts/update-motd.d/10-sysinfo"

# Lokale Defaults (falls Download verneint wird)
SRC_SYSINFO_DEFAULT="./10-sysinfo"
SRC_HEADER_DEFAULT="./00-header"

# ---- sudo/Root Handling ----
SUDO=""; if [ "$(id -u)" -ne 0 ]; then
  warn "Für die Installation werden Root-Rechte benötigt."
  if ask_yn "Mit sudo fortfahren?" y; then
    need_cmd sudo || { err "sudo nicht verfügbar."; exit 1; }
    sudo -v || { err "sudo Authentifizierung fehlgeschlagen."; exit 1; }
    SUDO="sudo"
  else
    err "Installation abgebrochen (keine Root-Rechte)."; exit 1
  fi
fi

# ---- 1) Möchtest du den MOTD-Banner installieren? ----
if ! ask_yn "1) Möchtest du den MOTD-Banner installieren?" y; then
  info "Übersprungen."; exit 0
fi
ok "Installation wird vorbereitet."
pause

# ---- 2) Abhängigkeiten prüfen/installieren (einzeln bestätigen) ----
info "2) Abhängigkeiten werden geprüft:"
need_cmd apt-get || { err "Dieses Skript unterstützt derzeit nur apt-basierte Systeme (Debian/Ubuntu)."; exit 1; }

# Kernabhängigkeiten (10-sysinfo + 00-header + Installer)
declare -A DEPS=(
  [curl]="curl"
  [ip]="iproute2"
  [ss]="iproute2"
  [awk]="gawk"
  [free]="procps"
  [who]="coreutils"
  [figlet]="figlet"
  [run-parts]="debianutils"   # nur für die Vorschau
  # lolcat ist optional, separat
)

for bin in "${!DEPS[@]}"; do
  pkg="${DEPS[$bin]}"
  if need_cmd "$bin"; then
    ok "Bereits vorhanden: ${bin}"
  else
    if ask_yn "Fehlt: ${bin} (Paket: ${pkg}). Jetzt installieren?" y; then
      info "Installiere ${pkg} …"
      $SUDO apt-get update -qq
      $SUDO apt-get install -y -qq "$pkg"
      ok "Installiert: ${pkg}"
    else
      warn "Übersprungen: ${pkg} – Funktionalität ggf. eingeschränkt."
    fi
  fi
  pause
done

# lolcat optional (verschönert Ausgabe)
if ! need_cmd lolcat; then
  if ask_yn "Optional: lolcat zur farbigen Ausgabe installieren?" y; then
    info "Installiere lolcat …"
    $SUDO apt-get update -qq
    $SUDO apt-get install -y -qq lolcat || warn "Konnte lolcat nicht installieren (optional)."
    ok "Optional installiert: lolcat"
  else
    warn "lolcat Installation übersprungen (optional)."
  fi
  pause
fi

# ---- 3) Quellen beziehen (Download nach /tmp oder lokale Dateien nutzen) ----
SRC_SYSINFO="$SRC_SYSINFO_DEFAULT"
SRC_HEADER="$SRC_HEADER_DEFAULT"

if ask_yn "Sollen die Dateien jetzt aus dem Internet nach ${TMP_DIR} geladen werden?" y; then
  mkdir -p "$TMP_DIR"
  info "Lade 00-header …"
  curl -fL --retry 3 -o "${TMP_DIR}/00-header" "$URL_HEADER" || { err "Download 00-header fehlgeschlagen."; exit 1; }
  info "Lade 10-sysinfo …"
  curl -fL --retry 3 -o "${TMP_DIR}/10-sysinfo" "$URL_SYSINFO" || { err "Download 10-sysinfo fehlgeschlagen."; exit 1; }
  chmod +x "${TMP_DIR}/00-header" "${TMP_DIR}/10-sysinfo" || true
  SRC_HEADER="${TMP_DIR}/00-header"
  SRC_SYSINFO="${TMP_DIR}/10-sysinfo"
  ok "Dateien in ${TMP_DIR} bereit."
else
  info "Verwende lokale Quellen: ${SRC_HEADER} & ${SRC_SYSINFO}"
fi
pause

# ---- 4) Installation mit Bestätigung pro Schritt ----
info "3) Dateien werden installiert und konfiguriert."

# 4a) Backup vorhandener MOTD-Skripte
if ask_yn "Bestehende MOTD-Skripte nach ${BACKUP_DIR} sichern?" y; then
  $SUDO mkdir -p "$BACKUP_DIR"
  if [ -d "$TARGET_DIR" ]; then
    $SUDO cp -a "${TARGET_DIR}/." "$BACKUP_DIR/" || true
  fi
  ok "Backup erstellt: ${BACKUP_DIR}"
else
  warn "Backup übersprungen."
fi
pause

# 4b) Zielverzeichnis anlegen
if ask_yn "Zielverzeichnis ${TARGET_DIR} anlegen/sicherstellen?" y; then
  $SUDO mkdir -p "$TARGET_DIR"
  ok "Verzeichnis bereit: ${TARGET_DIR}"
fi
pause

# 4c) Quellen prüfen
[ -f "$SRC_HEADER" ]  || { err "Quelle nicht gefunden: ${SRC_HEADER}";  exit 1; }
[ -f "$SRC_SYSINFO" ] || { err "Quelle nicht gefunden: ${SRC_SYSINFO}"; exit 1; }

# 4d) 00-header installieren
if ask_yn "00-header nach ${TARGET_HEADER} installieren?" y; then
  $SUDO install -m 0755 "$SRC_HEADER" "$TARGET_HEADER"
  $SUDO chown root:root "$TARGET_HEADER" || true
  ok "Installiert: ${TARGET_HEADER}"
fi
pause

# 4e) 10-sysinfo installieren
if ask_yn "10-sysinfo nach ${TARGET_SYSINFO} installieren?" y; then
  $SUDO install -m 0755 "$SRC_SYSINFO" "$TARGET_SYSINFO"
  $SUDO chown root:root "$TARGET_SYSINFO" || true
  ok "Installiert: ${TARGET_SYSINFO}"
fi
pause

# 4f) Andere MOTD-Skripte deaktivieren (optional)
DISABLED_LIST=()
if ask_yn "Andere MOTD-Skripte im Verzeichnis deaktivieren (außer 00-header/10-sysinfo)?" n; then
  while IFS= read -r f; do
    base="$(basename "$f")"
    case "$base" in 00-header|10-sysinfo) continue ;; esac
    if ask_yn "  Deaktivieren: ${base}?" y; then
      $SUDO chmod -x "$f" || true
      DISABLED_LIST+=("$base")
    fi
  done < <(find "$TARGET_DIR" -maxdepth 1 -type f -perm -u+x -print 2>/dev/null | sort)
  ok "Deaktiviert: ${DISABLED_LIST[*]:-keine}"
else
  warn "Keine Änderungen an anderen MOTD-Skripten."
fi
pause

# 4g) Testlauf (optional)
if ask_yn "Testlauf: MOTD jetzt erzeugen (run-parts ${TARGET_DIR})?" y; then
  if need_cmd run-parts && [ -d "$TARGET_DIR" ]; then
    echo -e "\n${BOLD}--- Vorschau ---${RESET}"
    run-parts "$TARGET_DIR" || true
    echo -e "${BOLD}--- Ende Vorschau ---${RESET}\n"
  else
    warn "run-parts oder ${TARGET_DIR} nicht verfügbar – Vorschau übersprungen."
  fi
fi
pause

ok "Installation abgeschlossen. Beim nächsten Login wird der neue MOTD-Banner angezeigt."
