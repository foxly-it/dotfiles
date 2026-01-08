# Changelog

Dieses Dokument beschreibt die Entwicklung der **Foxly AdGuard Blockpage**.  
This document describes the evolution of the **Foxly AdGuard Blockpage**.

Das Projekt folgt **keiner semantischen Versionierung**, sondern einer
technischen, nachvollziehbaren Evolutionshistorie.  
The project does **not** follow semantic versioning, but a technical,
traceable evolution history.

---

## [Unreleased] / [Unveröffentlicht]

### Geplant / Planned
- optionale Auslagerung des Theme-Systems in eine gemeinsame CSS-Datei  
  optional extraction of the theme system into a shared CSS file
- Vereinheitlichung des Theme-Storage-Keys über alle Seiten hinweg  
  unify the theme storage key across all pages
- optionale SVG-Icon-Variante ohne Icon-Font  
  optional SVG icon variant without icon fonts

---

## [2026-01] – Theme-System Refactor (Referenzstand / Reference State)

### Added / Hinzugefügt
- Systemweites Auto Dark / Light Mode über  
  `@media (prefers-color-scheme: dark)`
- Konsistente Theme-Logik für:
  - Haupt-Blockpage  
    main blockpage
  - Info-Unterseite  
    info subpage
- Persistente manuelle Theme-Auswahl via `localStorage`
- Klare Trennung der Zustände:
  - Auto = kein `data-theme`  
    Auto = no `data-theme`
  - Manuell = `data-theme="light"` / `data-theme="dark"`

### Changed / Geändert
- Entfernung von `data-theme="auto"` (bewusste Designentscheidung)  
  removal of `data-theme="auto"` (intentional design decision)
- Vereinheitlichung des Theme-Verhaltens über alle Seiten hinweg  
  unified theme behavior across all pages
- Dokumentation des Theme-Systems als verbindliche Projektregel  
  documentation of the theme system as a binding project rule

### Fixed / Behoben
- Auto-Theme funktionierte zuvor nicht zuverlässig unter  
  macOS, Windows und mobilen Systemen  
  auto theme previously did not work reliably on macOS, Windows and mobile
- Inkonsistentes Theme-Verhalten zwischen Haupt- und Unterseite  
  inconsistent theme behavior between main page and subpage
- Fehlende Dark-Assets bei aktivem System-Dark-Mode  
  missing dark assets when system dark mode was enabled

---

## [2026-01] – Font Awesome Bereinigung / Cleanup

### Changed / Geändert
- Umstellung auf **Font Awesome Free – Solid only**
- Entfernung aller nicht benötigten Komponenten:
  - brands, regular
  - JavaScript, SVG, SCSS, LESS
  - Legacy-Fonts (ttf, eot, svg)
- Nutzung ausschließlich moderner `woff2`-Fonts

### Fixed / Behoben
- Überdimensionierter Asset-Ordner mit mehreren hundert Dateien  
  oversized asset directory with several hundred files
- Unklare Lizenzlage durch unnötige Pro-/Fallback-Dateien  
  unclear licensing situation caused by unnecessary assets

---

## [2026-01] – Info-Unterseite hinzugefügt / Info Subpage Added

### Added / Hinzugefügt
- `/info/` Unterseite mit:
  - Erklärung der Blockierungsgründe  
    explanation of blocking reasons
  - Sicherheits- und Hintergrundinformationen  
    security and background information
  - Verlinkung auf offizielle externe Quellen (z. B. BSI, Malpedia)
- Sticky Control Dock:
  - Theme-Switch
  - Zurück-zur-Blockpage / back-to-blockpage

### Changed / Geändert
- Design-Variablen vollständig identisch zur Hauptseite  
  design variables fully aligned with the main page
- Einheitliches Card-Layout für alle Inhalte  
  unified card layout for all content

---

## [2025-12] – Initiale Veröffentlichung / Initial Release

### Added / Hinzugefügt
- Statische Blockpage für AdGuard Home  
  static blockpage for AdGuard Home
- Docker-Setup
- nginx Bare-Metal Unterstützung  
  nginx bare-metal support
- Lokale Asset- und Font-Einbindung  
  local asset and font hosting
- Sachliche, technische Nutzeransprache statt Warnbanner  
  factual, technical user messaging instead of scare banners