#!/usr/bin/env bash
set -e

cd ~/backstage_aks_idp

echo "=== Überprüfung der vier Scaffolder-Templates ==="

TEMPLATES=(
  "packages/app/templates/azure-devops-service-template/template.yaml"
  "packages/app/templates/ado-repository-template/template.yaml"
  "packages/app/templates/ado-pipeline-bootstrap-template/template.yaml"
  "packages/app/templates/ado-permission-request-template/template.yaml"
)

for template in "${TEMPLATES[@]}"; do
  if [ -f "$template" ]; then
    echo "OK: $template vorhanden"
  else
    echo "FEHLER: $template fehlt"
    exit 1
  fi
done

echo ""
echo "=== Überprüfung der Registrierung in app-config.yaml ==="

grep -q "azure-devops-service-template/template.yaml" app-config.yaml && \
echo "OK: Azure DevOps Service Template in app-config.yaml registriert" || \
{ echo "FEHLER: Azure DevOps Service Template fehlt in app-config.yaml"; exit 1; }

grep -q "ado-repository-template/template.yaml" app-config.yaml && \
echo "OK: Azure DevOps Repository Template in app-config.yaml registriert" || \
{ echo "FEHLER: Azure DevOps Repository Template fehlt in app-config.yaml"; exit 1; }

grep -q "ado-pipeline-bootstrap-template/template.yaml" app-config.yaml && \
echo "OK: Azure DevOps Pipeline Bootstrap Template in app-config.yaml registriert" || \
{ echo "FEHLER: Azure DevOps Pipeline Bootstrap Template fehlt in app-config.yaml"; exit 1; }

grep -q "ado-permission-request-template/template.yaml" app-config.yaml && \
echo "OK: Azure DevOps Permission Request Template in app-config.yaml registriert" || \
{ echo "FEHLER: Azure DevOps Permission Request Template fehlt in app-config.yaml"; exit 1; }

echo ""
echo "=== Überprüfung der Registrierung in app-config.local.yaml ==="

grep -q "azure-devops-service-template/template.yaml" app-config.local.yaml && \
echo "OK: Azure DevOps Service Template in app-config.local.yaml registriert" || \
{ echo "FEHLER: Azure DevOps Service Template fehlt in app-config.local.yaml"; exit 1; }

grep -q "ado-repository-template/template.yaml" app-config.local.yaml && \
echo "OK: Azure DevOps Repository Template in app-config.local.yaml registriert" || \
{ echo "FEHLER: Azure DevOps Repository Template fehlt in app-config.local.yaml"; exit 1; }

grep -q "ado-pipeline-bootstrap-template/template.yaml" app-config.local.yaml && \
echo "OK: Azure DevOps Pipeline Bootstrap Template in app-config.local.yaml registriert" || \
{ echo "FEHLER: Azure DevOps Pipeline Bootstrap Template fehlt in app-config.local.yaml"; exit 1; }

grep -q "ado-permission-request-template/template.yaml" app-config.local.yaml && \
echo "OK: Azure DevOps Permission Request Template in app-config.local.yaml registriert" || \
{ echo "FEHLER: Azure DevOps Permission Request Template fehlt in app-config.local.yaml"; exit 1; }

echo ""
echo "=== Validierung der Template-YAML-Struktur ==="

node - <<'NODE'
const fs = require('fs');
const yaml = require('yaml');

const files = [
  'packages/app/templates/azure-devops-service-template/template.yaml',
  'packages/app/templates/ado-repository-template/template.yaml',
  'packages/app/templates/ado-pipeline-bootstrap-template/template.yaml',
  'packages/app/templates/ado-permission-request-template/template.yaml',
];

for (const file of files) {
  const doc = yaml.parse(fs.readFileSync(file, 'utf8'));

  if (doc.kind !== 'Template') {
    throw new Error(`${file}: Ungültiger kind-Wert`);
  }

  if (!doc.metadata?.name) {
    throw new Error(`${file}: metadata.name fehlt`);
  }

  if (!Array.isArray(doc.spec?.parameters)) {
    throw new Error(`${file}: spec.parameters fehlt`);
  }

  if (!Array.isArray(doc.spec?.steps)) {
    throw new Error(`${file}: spec.steps fehlt`);
  }

  console.log(`OK: ${doc.metadata.name} | Parameter=${doc.spec.parameters.length} | Steps=${doc.spec.steps.length}`);
}
NODE

echo ""
echo "=== Überprüfung des Service-Template-Skeletons ==="

test -f packages/app/templates/azure-devops-service-template/skeleton/catalog-info.yaml && echo "OK: 서비스 catalog-info.yaml" || { echo "FEHLER: catalog-info.yaml fehlt"; exit 1; }
test -f packages/app/templates/azure-devops-service-template/skeleton/README.md && echo "OK: README.md" || { echo "FEHLER: README.md fehlt"; exit 1; }
test -f packages/app/templates/azure-devops-service-template/skeleton/azure-pipelines.yml && echo "OK: azure-pipelines.yml" || { echo "FEHLER: azure-pipelines.yml fehlt"; exit 1; }
test -f packages/app/templates/azure-devops-service-template/skeleton/docs/index.md && echo "OK: docs/index.md" || { echo "FEHLER: docs/index.md fehlt"; exit 1; }

echo ""
echo "=== Überprüfung der Repository-, Pipeline- und Permission-Skeletons ==="

SKELETON_FILES=(
  "packages/app/templates/ado-repository-template/skeleton/azure-pipelines.yml"
  "packages/app/templates/ado-pipeline-bootstrap-template/skeleton/azure-pipelines.yml"
  "packages/app/templates/ado-permission-request-template/skeleton/permission-request.yaml"
)

for file in "${SKELETON_FILES[@]}"; do
  test -f "$file" && echo "OK: $file" || { echo "FEHLER: $file fehlt"; exit 1; }
done

echo ""
echo "=== YAML-Validierung der Pipelines und Permission-Definitionen ==="

node - <<'NODE'
const fs = require('fs');
const yaml = require('yaml');

const files = [
  'packages/app/templates/azure-devops-service-template/skeleton/azure-pipelines.yml',
  'packages/app/templates/ado-repository-template/skeleton/azure-pipelines.yml',
  'packages/app/templates/ado-pipeline-bootstrap-template/skeleton/azure-pipelines.yml',
  'packages/app/templates/ado-permission-request-template/skeleton/permission-request.yaml',
];

for (const file of files) {
  yaml.parse(fs.readFileSync(file, 'utf8'));
  console.log(`OK: ${file} ist gültiges YAML`);
}
NODE

echo ""
echo "=== Endergebnis ==="
echo "OK: Scaffolder v2 ist vollständig, konsistent und einsatzbereit"
