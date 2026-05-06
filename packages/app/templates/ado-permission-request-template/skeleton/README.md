# ${{ values.requestName }}

## Zweck

Diese Anfrage beschreibt eine vorbereitete Berechtigungsänderung für Azure DevOps.

## Anfrage

- Antragsteller: ${{ values.requester }}
- Projekt: ${{ values.targetProject }}
- Zielgruppe: ${{ values.targetGroup }}
- Zugriffsebene: ${{ values.accessLevel }}

## Begründung

${{ values.justification }}

## Status

Diese Datei ändert keine echten Berechtigungen. Sie dokumentiert nur die geplante Anfrage.
