# Stabiler Checkpoint – GitHub Publish v1

## Validierter Zustand

Das Backstage-Template `ADO Repository Template` ist nun in der Lage, eine Repository-Struktur zu generieren und diese über die Scaffolder-Aktion `publish:github` in GitHub zu veröffentlichen.

## Validiertes Ergebnis

Der folgende Workflow ist erfolgreich validiert:

Backstage `/create`
→ ADO Repository Template
→ Generierung der Repository-Struktur
→ Veröffentlichung nach GitHub
→ Erstellung eines realen GitHub-Repositories

## Validierte Elemente

- Betroffenes Template: `ado-repository-template`
- Verwendete Aktion: `publish:github`
- Ziel-GitHub-Konto: `IDP2026`
- Authentifizierung: `GITHUB_TOKEN`
- Verifizierte Runtime-Injektion: `APP_CONFIG_integrations_github`

## Wichtiger Hinweis

Der GitHub-Token wird nicht im Quellcode gespeichert.
Er wird beim Start von Backstage ausschließlich über eine Umgebungsvariable injiziert.

## Aktuelle Einschränkungen

- Ausschließlich das Template `ADO Repository Template` veröffentlicht Repositories nach GitHub.
- Alle weiteren Templates arbeiten weiterhin im lokalen Scaffolder-Generierungsmodus.
- In der produktiven AKS-Konfiguration muss der Token über ein Kubernetes Secret oder Azure Key Vault bereitgestellt werden.
