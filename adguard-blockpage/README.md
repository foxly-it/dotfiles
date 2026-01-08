<!-- Foxly IT – AdGuard Blockpage -->

![Made by Foxly IT](https://img.shields.io/badge/Made%20by-Foxly%20IT-6f42c1?style=for-the-badge&logo=github&logoColor=white)
![Platform](https://img.shields.io/badge/Platform-Linux-lightgrey?style=for-the-badge&logo=linux&logoColor=white)
![Type](https://img.shields.io/badge/Type-Static%20Webpage-2b9348?style=for-the-badge)
![License](https://img.shields.io/badge/license-Foxly%20Open%20License%20(FOL--1.0)-6f42c1?style=for-the-badge)

# 🦊 Foxly AdGuard Blockpage

---

## 🇩🇪 Deutsch

Eine moderne, selbstgehostete **Blockpage für AdGuard Home**  
– reduziert, technisch sauber und vollständig unter eigener Kontrolle.

### Features
- Auto Dark / Light Mode (Systemsteuerung)
- Manuelle Theme-Umschaltung mit Persistenz
- Hauptseite + Info-Unterseite
- Keine externen Abhängigkeiten
- Lokale Assets & Fonts
- Docker- & Bare-Metal-fähig

### Theme-System (Referenz)
- **Auto**
  - kein `data-theme`
  - CSS steuert über `prefers-color-scheme`
- **Manuell**
  - `data-theme="light"` / `data-theme="dark"`
- `data-theme="auto"` wird bewusst **nicht verwendet**

### Schnellstart (Docker)

```bash
git clone https://github.com/foxly-it/adguard-blockpage.git
cd adguard-blockpage
docker compose up -d
```

Aufruf:
```
http://<server-ip>:8080
```

### AdGuard Home Integration

**Global:**
- Settings → DNS blocking
- „Use custom IP for blocked hosts“
- IP/Hostname dieses Servers

**Selektiv:**
```text
||example.com^$dnsrewrite=NOERROR;A;10.100.0.20
```

---

## 🇬🇧 English

A modern, self-hosted **blockpage for AdGuard Home**  
– minimal, predictable, and fully under your control.

### Features
- Automatic Dark / Light Mode (system-based)
- Manual theme override with persistence
- Main blockpage + informational subpage
- No external dependencies
- Local assets & fonts
- Docker and bare-metal ready

### Theme System (Reference)
- **Auto**
  - no `data-theme` attribute
  - controlled via `prefers-color-scheme`
- **Manual**
  - `data-theme="light"` / `data-theme="dark"`
- `data-theme="auto"` is intentionally **not used**

### Quick Start (Docker)

```bash
git clone https://github.com/foxly-it/adguard-blockpage.git
cd adguard-blockpage
docker compose up -d
```

Access:
```
http://<server-ip>:8080
```

---

## 📜 License

**Foxly Open License (FOL-1.0)**  
© 2025–2026 Foxly IT

Font Awesome Free  
Licensed under SIL Open Font License 1.1
