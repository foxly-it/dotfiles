# 🐳 Docker Templates

[🇩🇪 Deutsch](#-docker-templates) | [🇬🇧 English](#-docker-templates-english)

[![License: MIT](https://img.shields.io/badge/License-MIT-informational?style=for-the-badge)](LICENSE)
[![Stars](https://img.shields.io/github/stars/<dein-user>/<dein-repo>?style=for-the-badge)](https://github.com/<dein-user>/<dein-repo>/stargazers)
[![Issues](https://img.shields.io/github/issues/<dein-user>/<dein-repo>?style=for-the-badge)](https://github.com/<dein-user>/<dein-repo>/issues)
[![Docker](https://img.shields.io/badge/Docker-Compose-blue?style=for-the-badge)](#)
[![Made by Foxly](https://img.shields.io/badge/Made%20by-Foxly%20IT-orange?style=for-the-badge)](https://foxly.de)

---

Dieses Repository enthält strukturierte Docker- und Docker-Compose-Templates, die als saubere Ausgangsbasis für eigene Projekte dienen.

Der Fokus liegt auf nachvollziehbarer Konfiguration, klaren .env-Strukturen und reproduzierbaren Setups – ohne Magie und ohne versteckte Defaults.

---

## 📦 Inhalt

Jedes Verzeichnis bildet einen eigenständigen Docker-Stack ab und enthält in der Regel:

- docker-compose.yaml  
- .env.example  
- optionale Zusatzdateien wie Konfigurationsdateien oder kurze Hinweise  

Die Templates sind bewusst neutral gehalten und nicht sofort produktiv gedacht, sondern als stabile Vorlage.

---

## 🧩 Philosophie

Docker wird hier nicht als Schnellstart verstanden, sondern als Infrastruktur-Baustein.

Grundsätze dieses Repositories:

- keine latest-Images  
- feste und kontrollierbare Versionen  
- Konfiguration vollständig über .env  
- explizite Ports, Volumes und Netzwerke  
- keine impliziten Annahmen  

---

## 🚀 Verwendung

Repository klonen:

    git clone https://github.com/<dein-user>/<dein-repo>.git

Template auswählen:

    cd <template-name>

.env anlegen:

    cp .env.example .env

Stack starten:

    docker compose up -d

---

## 🔐 Sicherheitshinweise

- .env niemals committen  
- Secrets nicht im Klartext ablegen  
- Docker Socket nur verwenden, wenn zwingend erforderlich  
- Dienste standardmäßig nicht öffentlich exponieren  

---

## 🧠 Zielgruppe

Dieses Repository richtet sich an Homelab-Betreiber, Self-Hoster und Admins, die Wert auf saubere, wartbare Docker-Setups legen.

---

## 📄 Lizenz

MIT License

---

# 🐳 Docker Templates (English)

This repository contains structured Docker and Docker Compose templates designed as a clean and reliable starting point for your own projects.

The focus is on transparent configuration, clear .env structures and reproducible setups – without hidden defaults or magic behavior.

---

## 📦 Contents

Each directory represents a self-contained Docker stack and usually includes:

- docker-compose.yaml  
- .env.example  
- optional additional files such as configuration snippets or notes  

The templates are intentionally neutral and not meant to be production-ready out of the box.

---

## 🧩 Philosophy

Docker is treated here as an infrastructure building block, not a quick-start shortcut.

Core principles of this repository:

- no latest image tags  
- fixed and controllable versions  
- configuration via .env only  
- explicit ports, volumes and networks  
- no implicit assumptions  

---

## 🚀 Usage

Clone the repository:

    git clone https://github.com/<dein-user>/<dein-repo>.git

Select a template:

    cd <template-name>

Create the environment file:

    cp .env.example .env

Start the stack:

    docker compose up -d

---

## 🔐 Security Notes

- never commit .env files  
- do not store secrets in plain text  
- only use the Docker socket if absolutely required  
- services should not be publicly exposed by default  

---

## 🧠 Intended Audience

This repository is aimed at homelab users, self-hosters and administrators who value clean and maintainable Docker setups.

---

## 📄 License

MIT License

---

Foxly IT  
Reboot required – but planned.
