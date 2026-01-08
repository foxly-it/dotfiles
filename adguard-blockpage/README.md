<!-- Foxly IT – AdGuard Blockpage -->

![Made by Foxly IT](https://img.shields.io/badge/Made%20by-Foxly%20IT-6f42c1?style=for-the-badge&logo=github&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-Linux-lightgrey?style=for-the-badge&logo=linux&logoColor=white)
![Type](https://img.shields.io/badge/Type-Static%20Webpage-2b9348?style=for-the-badge)
![License](https://img.shields.io/badge/license-Foxly%20Open%20License%20(FOL--1.0)-6f42c1?style=for-the-badge)

# 🦊 Foxly AdGuard Blockpage

Eine moderne, selbstgehostete **Blockpage für AdGuard Home** – reduziert, technisch sauber und vollständig unter eigener Kontrolle.  
A modern, self-hosted **blockpage for AdGuard Home** – minimal, predictable, and fully under your control.

![Preview](web/AdGuard-Blocked-site.webp)

---

## 🇩🇪 Deutsch

### ✨ Features
- **Auto Dark / Light Mode** (Systemsteuerung via `prefers-color-scheme`)
- **Manuelle Theme-Umschaltung** mit Persistenz (`localStorage`)
- **Hauptseite + Info-Unterseite** (`/info/`)
- **Keine externen Abhängigkeiten** (kein CDN, kein Tracking)
- **Font Awesome Free – minimal** (Solid only, lokal gehostet)
- **Docker & Bare-Metal** (nginx) geeignet

### 📁 Projektstruktur (vereinfacht)
```text
adguard-blockpage/
├─ web/
│  ├─ index.html
│  ├─ info/
│  │  └─ index.html
│  ├─ img/
│  │  ├─ blocked-light.webp
│  │  └─ blocked-dark.webp
│  ├─ assets/
│  │  └─ fontawesome/
│  └─ AdGuard-Blocked-site.webp
├─ nginx/
│  └─ adguard-blockpage.conf
└─ docker-compose.yml
```

---

### 🚀 Schnellstart (Docker)

```bash
git clone https://github.com/foxly-it/adguard-blockpage.git
cd adguard-blockpage
docker compose up -d
```

Aufruf:
```
http://<server-ip>:8080
```

---

### 🧩 AdGuard Home Integration

**Option 1: Globale Umleitung (empfohlen)**  
AdGuard Home → Settings → DNS blocking → **Use custom IP for blocked hosts**  
→ IP oder Hostname dieses Servers eintragen.

Hinweis:  
Bei HTTPS-Domains erscheint technisch bedingt eine Zertifikatswarnung.  
DNS-Blocking kann kein gültiges TLS-Zertifikat für fremde Domains ausstellen.

**Option 2: Per Regel (Feintuning)**
```text
||example.com^$dnsrewrite=NOERROR;A;10.100.0.20
```

---

### ⚙️ Bare-Metal Installation (nginx)

#### Dateien bereitstellen
```bash
sudo mkdir -p /opt/adguard-blockpage
sudo rsync -a web/ /opt/adguard-blockpage/
```

#### nginx-Konfiguration aktivieren
```bash
sudo cp nginx/adguard-blockpage.conf /etc/nginx/conf.d/adguard-blockpage.conf
sudo nginx -t && sudo systemctl reload nginx
```

#### Was macht diese nginx-Konfiguration?

- **`root /usr/share/nginx/html;`**  
  → statischer Webroot für die Blockpage  
  (bei Bedarf anpassen, z. B. auf `/opt/adguard-blockpage`)

- **`try_files $uri /index.html;`**  
  → erlaubt clientseitiges Routing und Unterseiten wie `/info/`

- **`/clientip.txt`**  
  → liefert die Client-IP im Klartext  
  → wird von der Blockpage für Anzeigezwecke genutzt

- **`/img/`**  
  → statische Assets (WebP-Grafiken)

- **Security Header**
  - `X-Frame-Options`
  - `X-Content-Type-Options`
  - `Referrer-Policy`

Die Konfiguration ist bewusst **minimal, statisch und sicher** gehalten.

---

### 🎨 Theme-System (Referenzstand – verbindlich)

- **Auto**
  - kein `data-theme` Attribut
  - Umschaltung über `@media (prefers-color-scheme: dark)`
- **Manuell**
  - `data-theme="light"` / `data-theme="dark"`
  - Persistenz via `localStorage`
- `data-theme="auto"` wird bewusst **nicht verwendet**

---

## 🇬🇧 English

### ✨ Features
- **Automatic Dark / Light Mode** (system-based via `prefers-color-scheme`)
- **Manual theme override** with persistence (`localStorage`)
- **Main page + info subpage** (`/info/`)
- **No external dependencies**
- **Font Awesome Free – minimal**
- Works with **Docker** and **bare-metal nginx**

---

### ⚙️ Bare-metal installation (nginx)

The provided nginx configuration is intentionally minimal and static.

Key aspects:
- static root directory
- `try_files` fallback to `index.html` for subpages
- `/clientip.txt` endpoint to expose client IP
- basic security headers

Adjust the `root` directive if you deploy the files outside
of `/usr/share/nginx/html`.

---

## 📜 License

**Foxly Open License (FOL-1.0)**  
© 2025–2026 Foxly IT

Font Awesome Free  
Licensed under SIL Open Font License 1.1 (license file included)