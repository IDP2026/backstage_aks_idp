#!/usr/bin/env bash
set -e

echo "=== Überprüfung Enterprise Service Onboarding Template ==="

TEMPLATE="packages/app/templates/enterprise-service-onboarding-template/template.yaml"
SKELETON="packages/app/templates/enterprise-service-onboarding-template/skeleton"

test -f "$TEMPLATE" && echo "OK: Template-Datei vorhanden" || { echo "FEHLER: Template-Datei fehlt"; exit 1; }

for file in \
  "$SKELETON/README.md" \
  "$SKELETON/catalog-info.yaml" \
  "$SKELETON/mkdocs.yml" \
  "$SKELETON/docs/index.md" \
  "$SKELETON/docs/architecture.md" \
  "$SKELETON/docs/runbook.md" \
  "$SKELETON/src/index.ts" \
  "$SKELETON/Dockerfile" \
  "$SKELETON/azure-pipelines.yml" \
  "$SKELETON/k8s/deployment.yaml" \
  "$SKELETON/k8s/service.yaml" \
  "$SKELETON/k8s/ingress.yaml" \
  "$SKELETON/.github/CODEOWNERS" \
  "$SKELETON/SECURITY.md" \
  "$SKELETON/readiness-checklist.md"
do
  test -f "$file" && echo "OK: $file" || { echo "FEHLER: $file fehlt"; exit 1; }
done

grep -q "enterprise-service-onboarding-template/template.yaml" app-config.yaml \
  && echo "OK: Registrierung in app-config.yaml" \
  || { echo "FEHLER: Registrierung in app-config.yaml fehlt"; exit 1; }

grep -q "enterprise-service-onboarding-template/template.yaml" app-config.local.yaml \
  && echo "OK: Registrierung in app-config.local.yaml" \
  || { echo "FEHLER: Registrierung in app-config.local.yaml fehlt"; exit 1; }

echo "=== Endergebnis ==="
echo "OK: Enterprise Service Onboarding Template ist vollständig vorbereitet"
