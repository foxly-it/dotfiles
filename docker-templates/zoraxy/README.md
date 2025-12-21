# 🔀 Zoraxy Templates

[🇩🇪 Deutsch](#-zoraxy-templates) | [🇬🇧 English](#-zoraxy-templates-english)

[![License: MIT](https://img.shields.io/badge/License-MIT-informational?style=for-the-badge)](LICENSE)
[![Reverse Proxy](https://img.shields.io/badge/Reverse%20Proxy-Zoraxy-blue?style=for-the-badge)](#)
[![Made by Foxly](https://img.shields.io/badge/Made%20by-Foxly%20IT-orange?style=for-the-badge)](https://foxly.de)

---

Dieses Repository enthält praxisnahe Zoraxy-Templates für den Einsatz als Reverse Proxy in Homelab- und vServer-Umgebungen.

Der Fokus liegt auf korrekter Header-Weitergabe, sauberer TLS-Terminierung und einer klaren Trennung interner und externer Dienste.

---

## 🧭 Warum Zoraxy?

Zoraxy vereint Reverse Proxy, Zertifikatsverwaltung inklusive DNS-01 und Header-Handling in einer übersichtlichen Weboberfläche, ohne unnötig komplex zu werden.

Gerade für kontrollierte Setups ist Zoraxy ein sehr ausgewogener Ansatz.

---

## 📁 Struktur

Typischer Aufbau eines Templates:

- docker-compose.yaml  
- .env.example  
- Hinweise zur Proxy-Route  
- empfohlene Header-Konfiguration  

Jedes Template ist eigenständig nutzbar.

---

## 📡 Header-Hinweis

Viele Anwendungen erwarten zwingend korrekte Header, unter anderem:

- Host  
- X-Forwarded-Host  
- X-Forwarded-Proto  
- X-Forwarded-For  

Die Templates setzen diese Header bewusst und explizit, um Redirect-Loops und Authentifizierungsfehler zu vermeiden.

---

## 🚀 Verwendung

Repository klonen:

    git clone https://github.com/<dein-user>/<zoraxy-repo>.git

Template auswählen:

    cd <template-name>

.env anlegen:

    cp .env.example .env

Stack starten:

    docker compose up -d

---

## 🔐 Best Practices

- interne Dienste nicht direkt exponieren  
- DNS-01 für TLS bevorzugen  
- Header gezielt und nicht automatisch setzen  
- Zoraxy selbst nur intern oder über VPN erreichbar machen  

---

## 🧠 Zielsetzung

Dieses Repository dient als Referenz für saubere, reproduzierbare Zoraxy-Setups – ohne Guesswork und ohne Trial-and-Error.

---

## 📄 Lizenz

MIT License

---

# 🔀 Zoraxy Templates (English)

This repository provides practical Zoraxy templates for operating Zoraxy as a reverse proxy in homelab and vServer environments.

The focus is on correct header forwarding, clean TLS termination and a strict separation between internal and external services.

---

## 🧭 Why Zoraxy?

Zoraxy combines reverse proxying, certificate management including DNS-01 and header handling in a simple web interface – without unnecessary complexity.

It is well suited for controlled and security-conscious setups.

---

## 📁 Structure

A typical template contains:

- docker-compose.yaml  
- .env.example  
- proxy route notes  
- recommended header configuration  

Each template can be used independently.

---

## 🚀 Usage

Clone the repository:

    git clone https://github.com/<dein-user>/<zoraxy-repo>.git

Select a template:

    cd <template-name>

Create the environment file:

    cp .env.example .env

Start the stack:

    docker compose up -d

---

## 🔐 Best Practices

- do not expose internal services directly  
- prefer DNS-01 for TLS certificates  
- set headers explicitly instead of relying on defaults  
- keep Zoraxy itself accessible only internally or via VPN  

---

## 🧠 Purpose

This repository acts as a reference for clean, reproducible Zoraxy reverse proxy setups – without guesswork or trial and error.

---

## 📄 License

MIT License

---

Foxly IT  
Reverse proxying without guesswork.
