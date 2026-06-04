# Security

## Data Classification

`${{ values.dataClassification }}`

## Business Criticality

`${{ values.businessCriticality }}`

## Security Requirements

- Keine Secrets im Repository speichern.
- Secrets über sichere Secret-Management-Systeme bereitstellen.
- Container-Images vor produktivem Einsatz scannen.
- Zugriff über CODEOWNERS und Pull Requests kontrollieren.
- Kubernetes-Ressourcen vor Produktion durch Platform Team prüfen.
