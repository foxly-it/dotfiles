# 🦊 Foxly IT — Dotfiles & Server Goodies

![GitHub Repo size](https://img.shields.io/github/repo-size/foxly-it/dotfiles?style=for-the-badge&color=6f42c1)
![GitHub last commit](https://img.shields.io/github/last-commit/foxly-it/dotfiles?style=for-the-badge&color=2b9348)
![GitHub stars](https://img.shields.io/github/stars/foxly-it/dotfiles?style=for-the-badge&color=ffaa00)
![License](https://img.shields.io/badge/license-Foxly%20Open%20License-blueviolet?style=for-the-badge)
![Made with 💜](https://img.shields.io/badge/made%20with-%F0%9F%92%9C-purple?style=for-the-badge)

Dieses Repository enthält eine Sammlung meiner persönlichen Server-Konfigurationen, Skripte und Frontends,  
die in meinem **Homelab / Foxly IT Setup** verwendet werden.

Hier findest du unter anderem meine farbigen **MOTD-Scripts** sowie meine vollständig designte **AdGuard Home Blockpage**.

---

## 📂 Inhalt

| Bereich | Beschreibung |
|----------|---------------|
| 🧠 **motd/** | Farbiges **Systeminfo- und Begrüßungsskript**, das beim Login automatisch ausgeführt wird. Zeigt Hostname, IPs, Laufzeit, Docker-Container, Systemlast u.v.m. |
| 🛡️ **adguard-blockpage/** | Vollständige, responsive **Blockseite für AdGuard Home**, die bei geblockten Domains angezeigt wird. Inklusive rotierender IT-Witze, Docker/Nginx-Integration und Beispiel-Preview. |

---

## 🧠 MOTD / Sysinfo Scripts

**Ort:** [`motd/`](./motd)

Zeigt beim SSH-Login eine dynamische, farbige Statusübersicht:

- ✅ Hostname, Kernel, Uptime, Load  
- 🧰 Containerstatus (Docker)  
- 🧮 Speicher- und Plattennutzung  
- 🌈 Farbverlauf mit `lolcat`  
- 🇩🇪 Ausgabe lokalisiert auf Deutsch  

**Beispielausgabe:**

```
🦊 foxly.homelab — Debian 13 (x86_64)
🕒 Laufzeit: 12 Tage | CPU: 3% | RAM: 42%
🐳 Container aktiv: 17
🌍 IP: 10.100.0.4 | WAN: 49.22.11.27
```

> 💡 Standardmäßig wird das Skript unter `/etc/update-motd.d/10-sysinfo` eingebunden.

---

## 🛡️ AdGuard Home — Custom Blockpage

**Ort:** [`adguard-blockpage/`](./adguard-blockpage)

Zeigt ansprechend gestaltete **Hinweisseite** für geblockte Domains.  
Wird über AdGuard Home → *DNS Settings → Blocked services → Custom IP* eingebunden.

### ✨ Features

- 🦊 **Eigene Blockseite mit Foxly-Branding**
- 🎨 HTML5 + CSS3 mit modernem Layout
- 💬 **Rotierende IT-Witze** (alle 20 Sekunden, zufällig)
- 🧱 Docker- & Nginx-Integration
- 🔒 HTTP-bereit (optional via Zoraxy über HTTPS)

### 🧩 Beispiel-Integration (Nginx)

```nginx
server {
  listen 10.100.0.4:80 default_server;
  server_name _;
  root /opt/adguard-blockpage;
  index index.html;
}
```

Optional über **Zoraxy** als Reverse-Proxy mit Zertifikat erreichbar  
→ z. B. `https://blocked.homelab.foxly.de`

---

## 🧰 Installation (Beispiel)

```bash
git clone https://github.com/foxly-it/dotfiles.git /opt/dotfiles
cd /opt/dotfiles

# MOTD aktivieren
sudo cp motd/10-sysinfo /etc/update-motd.d/
sudo chmod +x /etc/update-motd.d/10-sysinfo

# AdGuard Blockpage bereitstellen
sudo cp -r adguard-blockpage /opt/
sudo nginx -t && sudo systemctl reload nginx
```

---

## 📸 Preview

![Preview](adguard-blockpage/web/img/blocked.gif)

---

## ⚙️ Tools & Umgebung

- Debian 13 / Bookworm  
- Zoraxy (Reverse Proxy)  
- AdGuard Home + Unbound  
- Docker Compose + Nginx  
- lolcat / figlet für CLI-Ausgabe

---

## 📜 Lizenz

© 2025 Foxly IT — Veröffentlicht unter der **Foxly Open License**  
Diese Software darf frei genutzt, verändert und geteilt werden,  
solange der ursprüngliche Autor genannt und keine kommerzielle Nutzung erfolgt.

Siehe [LICENSE](./LICENSE) für weitere Details.

---

## 🦊 Über Foxly IT

> „Homelab, Automation & Style — made with 💜 by Mark Schenk (Foxly).“  
> Mehr unter [https://foxly.de](https://foxly.de)
