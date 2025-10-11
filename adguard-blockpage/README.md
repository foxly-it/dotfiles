<!-- Foxly IT MOTD / Sysinfo -->
![Made by Foxly IT](https://img.shields.io/badge/Made%20by-Foxly%20IT-6f42c1?style=for-the-badge&logo=github&logoColor=white)
![Shell Script](https://img.shields.io/badge/Bash-Script-2b9348?style=for-the-badge&logo=gnu-bash&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-Linux-lightgrey?style=for-the-badge&logo=linux&logoColor=white)
![License](https://img.shields.io/badge/license-Foxly%20Open%20License%20(FOL--1.0)-6f42c1?style=for-the-badge)

# 🦊 Foxly's AdGuard Blockpage

Eine anpassbare Block-Seite für AdGuard Home – modern, humorvoll und mit rotierenden IT-Witzen.

![Preview](web/AdGuard-Blocked-site.webp)

## 🚀 Schnellstart (Docker)

```bash
cd adguard-blockpage
docker compose up -d
```

Öffne danach: `http://<server-ip>:8080`

## 🧩 AdGuard Home Integration

**Option 1: Globale Umleitung**  
Settings → DNS blocking → **Use custom IP for blocked hosts** → IP dieses Servers eintragen.  
Hinweis: Bei HTTPS kommt technisch bedingt eine Zertifikatswarnung – normal und erwartbar.

**Option 2: Per Regel (Feintuning)**
```
||example.com^$dnsrewrite=NOERROR;A;10.100.0.20
```

## ⚙️ Bare-Metal nginx

```bash
sudo mkdir -p /opt/adguard-blockpage
sudo rsync -a web/ /opt/adguard-blockpage/
sudo cp nginx/adguard-blockpage.conf /etc/nginx/conf.d/adguard-blockpage.conf
sudo nginx -t && sudo systemctl reload nginx
```

## 📜 Lizenz

MIT © 2025 Foxly IT
