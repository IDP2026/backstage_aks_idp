#!/usr/bin/env bash
set -e

# Zum Projektverzeichnis wechseln
cd ~/backstage_aks_idp

echo "=== Backstage Start mit GitHub-Integration ==="

# Prüfen, ob GitHub CLI installiert ist
if ! command -v gh >/dev/null 2>&1; then
  echo "FEHLER: GitHub CLI ist nicht installiert."
  exit 1
fi

# Alte oder ungültige Token-Variablen entfernen
unset GITHUB_TOKEN
unset GH_TOKEN

# Prüfen, ob GitHub CLI ohne Environment-Token funktioniert
if ! gh auth status >/dev/null 2>&1; then
  echo "FEHLER: GitHub CLI ist nicht korrekt authentifiziert."
  echo "Bitte ausführen: gh auth login"
  exit 1
fi

# GitHub Login testen
GITHUB_LOGIN="$(gh api user --jq '.login' 2>/dev/null || true)"

if [ -z "$GITHUB_LOGIN" ]; then
  echo "FEHLER: GitHub API-Test ist fehlgeschlagen."
  echo "Bitte GitHub Authentifizierung prüfen: gh auth status"
  exit 1
fi

echo "OK: GitHub CLI authentifiziert als $GITHUB_LOGIN"

# Gültigen Token aus GitHub CLI laden
export GITHUB_TOKEN="$(gh auth token)"

if [ -z "$GITHUB_TOKEN" ]; then
  echo "FEHLER: GITHUB_TOKEN konnte nicht geladen werden."
  exit 1
fi

echo "OK: GitHub Token wurde geladen."

# GitHub-Integration für Backstage zur Laufzeit setzen
export APP_CONFIG_integrations_github="[{\"host\":\"github.com\",\"token\":\"$GITHUB_TOKEN\"}]"

if [ -z "$APP_CONFIG_integrations_github" ]; then
  echo "FEHLER: Backstage GitHub-Konfiguration konnte nicht gesetzt werden."
  exit 1
fi

echo "OK: Backstage GitHub-Konfiguration wurde gesetzt."

# Alte Prozesse auf den Backstage-Ports beenden
fuser -k 3000/tcp 2>/dev/null || true
fuser -k 7007/tcp 2>/dev/null || true

echo "OK: Alte Backstage-Prozesse wurden beendet."

# Backstage starten
echo "Starte Backstage..."
yarn start
