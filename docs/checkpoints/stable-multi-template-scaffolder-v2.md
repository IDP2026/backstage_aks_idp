# Stabiler Checkpoint – Multi-Template Backstage Scaffolder v2

## Validierter Stand

Der Backstage-IDP-Proof-of-Concept umfasst inzwischen vier vollständig funktionsfähige Scaffolder-Templates.

## Validierte Templates

- Azure DevOps Service Template
- Azure DevOps Repository Template
- Azure DevOps Pipeline Bootstrap Template
- Azure DevOps Permission Request Template

## Ergebnis

Alle vier Templates sind in Backstage unter folgender URL verfügbar:

http://localhost:3000/create

Jedes Template wurde erfolgreich über die Backstage-Benutzeroberfläche ausgeführt.

## Abgedeckte Funktionalitäten

### Azure DevOps Service Template
Erzeugung einer standardisierten Service-Struktur mit:
- catalog-info.yaml
- README.md
- TechDocs
- azure-pipelines.yml
- Azure-DevOps-Metadaten

### Azure DevOps Repository Template
Vorbereitung einer standardisierten Repository-Struktur für Azure DevOps.

### Azure DevOps Pipeline Bootstrap Template
Bereitstellung einer Azure-DevOps-Standardpipeline mit den Phasen Validate und Build.

### Azure DevOps Permission Request Template
Erstellung einer dokumentierten Azure-DevOps-Berechtigungsanfrage ohne tatsächliche Änderung von Zugriffsrechten.

## Aktuelle Einschränkungen

- Es werden derzeit keine realen Repositories in GitHub oder Azure DevOps angelegt.
- Es werden keine produktiven Pipelines in Azure DevOps erstellt.
- Es werden keine tatsächlichen Berechtigungen geändert.
- Keycloak ist aktuell nicht integriert.
- Die Authentifizierung erfolgt bewusst im Guest-Modus zur Wahrung der Stabilität des Proof of Concept.

## Fazit

Der Backstage Scaffolder ist nun erweitert und stabil nutzbar und bildet eine konsistente Grundlage für eine Azure-DevOps-basierte Self-Service-Entwicklerplattform.
