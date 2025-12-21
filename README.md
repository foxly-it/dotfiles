# 🦊 Foxly IT — Dotfiles & Server Goodies

[🇩🇪 Deutsch](#-deutsch) | [🇬🇧 English](#-english)

![GitHub Repo size](https://img.shields.io/github/repo-size/foxly-it/dotfiles?style=for-the-badge&color=6f42c1)
![GitHub last commit](https://img.shields.io/github/last-commit/foxly-it/dotfiles?style=for-the-badge&color=2b9348)
![GitHub stars](https://img.shields.io/github/stars/foxly-it/dotfiles?style=for-the-badge&color=ffaa00)
![License](https://img.shields.io/badge/license-Foxly%20Open%20License-blueviolet?style=for-the-badge)
![Made with 💜](https://img.shields.io/badge/made%20with-%F0%9F%92%9C-purple?style=for-the-badge)

---

## 🇩🇪 Deutsch

Dieses Repository ist eine kuratierte Sammlung meiner persönlichen **Dotfiles, Server-Konfigurationen, Shell-Skripte und Frontends**,  
die produktiv in meinem **Foxly-IT-Homelab** und auf mehreren vServern eingesetzt werden.

Der Fokus liegt auf:

- sauber strukturierter Infrastruktur
- reproduzierbaren Docker- und Proxy-Setups
- verständlicher, wartbarer Konfiguration
- technischer Klarheit statt „Magie“
- konsistentem Design bis in CLI und Weboberflächen

Dieses Repository dient gleichzeitig als **Arbeitsgrundlage**, **Referenz** und **Dokumentation**.

---

## 📂 Inhalt

| Bereich | Beschreibung |
|--------|--------------|
| 🧠 **motd/** | Farbiges Systeminfo- & Login-Skript (MOTD) für SSH-Logins. Zeigt Hostname, IPs, Uptime, Docker-Status, Systemlast u. v. m. |
| 🛡️ **adguard-blockpage/** | Vollständig designte, responsive Blockseite für AdGuard Home mit IT-Witz-Rotation, Docker- & Nginx-Integration. |
| 🐳 **docker-templates/** | Wiederverwendbare Docker- & Docker-Compose-Templates für Homelab- und Server-Stacks. |
| 🔀 **docker-templates/zoraxy/** | Zoraxy-Templates mit Fokus auf Reverse Proxy, Header-Handling, TLS und sichere Exposition von Diensten. |

---

## 🧠 MOTD / Sysinfo Scripts

**Pfad:** `motd/`

Beim SSH-Login wird eine dynamische Statusübersicht angezeigt, u. a.:

- Hostname, Kernel, Uptime, Load
- Docker-Container-Status
- RAM- und Plattennutzung
- optionale Farbverläufe (`lolcat`)
- deutsch lokalisierte Ausgabe

Standard-Einbindung über `/etc/update-motd.d/10-sysinfo`.

---

## 🛡️ AdGuard Home — Custom Blockpage

**Pfad:** `adguard-blockpage/`

Diese Blockpage ersetzt die Standard-Hinweisseite von AdGuard Home durch eine moderne, markenkonforme HTML-Seite  
für geblockte Domains.

### Features

- Foxly-Branding
- modernes HTML5- & CSS-Layout
- rotierende IT-Witze
- Docker- & Nginx-fähig
- optionaler HTTPS-Betrieb über Zoraxy

### Beispiel (Nginx)

    server {
      listen 10.100.0.4:80 default_server;
      server_name _;
      root /opt/adguard-blockpage;
      index index.html;
    }

---

## 🧰 Installation (Kurzbeispiel)

    git clone https://github.com/foxly-it/dotfiles.git /opt/dotfiles
    cd /opt/dotfiles

    sudo cp motd/10-sysinfo /etc/update-motd.d/
    sudo chmod +x /etc/update-motd.d/10-sysinfo

    sudo cp -r adguard-blockpage /opt/
    sudo nginx -t && sudo systemctl reload nginx

---

## ⚙️ Tools & Umgebung

- Debian 13 (Bookworm)
- Docker & Docker Compose
- Zoraxy (Reverse Proxy)
- AdGuard Home + Unbound
- Nginx
- lolcat / figlet

---

## 🇬🇧 English

This repository is a curated collection of my personal **dotfiles, server configurations, shell scripts, and frontends**,  
used productively in my **Foxly IT homelab** and on multiple VPS systems.

The focus is on:

- clean and structured infrastructure
- reproducible Docker and proxy setups
- maintainable and transparent configuration
- technical clarity instead of hidden magic
- consistent design from CLI to web interfaces

This repository serves as a **working base**, **reference**, and **documentation**.

---

## 📂 Contents

| Area | Description |
|------|-------------|
| 🧠 **motd/** | Colored system info & login script (MOTD) for SSH logins. Displays hostname, IPs, uptime, Docker status, system load, and more. |
| 🛡️ **adguard-blockpage/** | Fully designed, responsive custom block page for AdGuard Home with IT joke rotation and Docker/Nginx support. |
| 🐳 **docker-templates/** | Reusable Docker and Docker Compose templates for homelab and server stacks. |
| 🔀 **docker-templates/zoraxy/** | Zoraxy reverse proxy templates focusing on header handling, TLS, and secure service exposure. |

---

## 🧠 MOTD / Sysinfo Scripts

**Path:** `motd/`

Displays a dynamic system overview on SSH login, including:

- hostname, kernel, uptime, load
- Docker container status
- memory and disk usage
- optional color gradients via `lolcat`

---

## 🛡️ AdGuard Home — Custom Blockpage

**Path:** `adguard-blockpage/`

Replaces the default AdGuard Home block page with a modern, branded HTML page  
shown when domains are blocked.

---

## ⚙️ Environment

- Debian Linux
- Docker & Docker Compose
- Zoraxy Reverse Proxy
- AdGuard Home with Unbound
- Nginx

---

## 📜 License

© 2025 Foxly IT — released under the **Foxly Open License**.

Free to use, modify and share,  
as long as attribution is given and no commercial use is made.

See [LICENSE](./LICENSE) for details.

---

## 🦊 About Foxly IT

> “Homelab, automation & style — made with 💜 by Mark Schenk (Foxly).”  
> https://foxly.de
