# Reproduzierbarkeits-Snapshot — Backstage IDP

Dieser Snapshot wurde automatisch aus dem lokalen Projektverzeichnis erzeugt.

Projektpfad:

```text
/home/koffi/backstage_aks_idp
```

Erzeugt am:

```text
2026-05-23T11:45:12+02:00
```


## 1. Betriebssystem

```text
Distributor ID:	Ubuntu
Description:	Ubuntu 24.04.1 LTS
Release:	24.04
Codename:	noble
```

## 2. Benutzer und Arbeitsverzeichnis

```text
koffi
/home/koffi/backstage_aks_idp
```

## 3. Tool-Versionen

```text
node: v22.22.0
npm: 10.9.4
yarn: 4.4.1
git: git version 2.43.0
docker: Docker version 29.2.1, build a5c7197
gh: gh version 2.45.0 (2025-07-18 Ubuntu 2.45.0-1ubuntu0.3)
kubectl: Client Version: v1.35.2
helm: nicht installiert
az: {
  "azure-cli": "2.84.0",
  "azure-cli-core": "2.84.0",
  "azure-cli-telemetry": "1.1.0",
  "extensions": {}
```

## 4. Git-Zustand

```text
Repository Root:
/home/koffi/backstage_aks_idp

Branch:
main

Status:
## main...origin/main
 M scripts/start-backstage-with-github.sh
?? docs/reproducibility/
?? scripts/export-reproducibility-snapshot.sh

Remote:
origin	https://github.com/IDP2026/backstage_aks_idp.git (fetch)
origin	https://github.com/IDP2026/backstage_aks_idp.git (push)

Letzte Commits:
bddc6f8 (HEAD -> main, tag: checkpoint-startup-github-20260506-1937, origin/main, origin/HEAD) chore: add Backstage GitHub startup script
c995ccf (tag: checkpoint-github-publish-v1-20260506-1914) feat: enable GitHub publishing for repository template
e73e9dc chore: ignore Backstage local runtime files
8c36203 chore: ignore local Backstage runtime data
2a398af checkpoint: add validated multi-template scaffolder v2
3507ec3 Fix Docker build and GHCR image flow
6ab346c Add complete Golden Path: Python service, Docker, Kubernetes, Catalog and TechDocs
9fb0741 Add minimal golden path scaffolder template
1212f18 Fix Docker build and GHCR image flow
e4f8e0d Update doccumentation.md
b44f3a4 Update doccumentation.md
c4906ae Add plugins folder
abf55a1 Fix GHCR image name lowercase
4de280b Fix lockfile for CI
1781ef1 Fix GHCR image name (lowercase)
62fb6be Apply local changes after rebase
487a56a Fix Dockerfile for Backstage build
c004aeb Fix Dockerfile for Backstage build
c02adf2 Update doccumentation.md
24e4911 Fix yarn.lock

Tags:
checkpoint-startup-github-20260506-1937
checkpoint-github-publish-v1-20260506-1914
checkpoint-scaffolder-v2-20260506-1538
```

## 5. Projektstruktur

```text
.
./.dockerignore
./.eslintignore
./.eslintrc.js
./.github
./.github/workflows
./.github/workflows/build-backstage.yml
./.gitignore
./.kuka-idp.swp
./.prettierignore
./.yarn
./.yarn/install-state.gz
./.yarn/releases
./.yarn/releases/yarn-4.4.1.cjs
./.yarnrc.yml
./Dockerfile
./README.md
./app-config.local.yaml
./app-config.production.yaml
./app-config.yaml
./app-config.yaml.bak
./backstage-deployment.yaml
./backstage-service.yaml
./backstage.json
./catalog-info.yaml
./certs
./certs/chain-1.pem
./certs/chain-2.pem
./certs/chain-3.pem
./certs/chain-4.pem
./certs/chain-5.pem
./certs/kuka-ca.crt
./dist-types
./dist-types/packages
./dist-types/packages/app
./dist-types/packages/app/src
./dist-types/packages/backend
./dist-types/packages/backend/src
./dist-types/tsconfig.tsbuildinfo
./doccumentation.md
./docker-compose.yml
./docs
./docs/checkpoints
./docs/checkpoints/stable-github-publish-v1.md
./docs/checkpoints/stable-multi-template-scaffolder-v2.md
./docs/reproducibility
./docs/reproducibility/file-appendix.md
./docs/reproducibility/files
./docs/reproducibility/reproducibility-snapshot.md
./examples
./examples/entities.yaml
./examples/org.yaml
./examples/template
./examples/template/content
./examples/template/content/catalog-info.yaml
./examples/template/content/index.js
./examples/template/content/package.json
./examples/template/template.yaml
./package.json
./packages
./packages/README.md
./packages/app
./packages/app/.eslintignore
./packages/app/.eslintrc.js
./packages/app/dist
./packages/app/dist/.config-schema.json
./packages/app/dist/android-chrome-192x192.png
./packages/app/dist/apple-touch-icon.png
./packages/app/dist/favicon-16x16.png
./packages/app/dist/favicon-32x32.png
./packages/app/dist/favicon.ico
./packages/app/dist/index.html
./packages/app/dist/index.html.tmpl
./packages/app/dist/manifest.json
./packages/app/dist/robots.txt
./packages/app/dist/safari-pinned-tab.svg
./packages/app/dist/static
./packages/app/e2e-tests
./packages/app/e2e-tests/app.test.ts
./packages/app/node_modules
./packages/app/node_modules/__backstage-module-federation-runtime-shared-dependencies__.js
./packages/app/package.json
./packages/app/public
./packages/app/public/android-chrome-192x192.png
./packages/app/public/apple-touch-icon.png
./packages/app/public/favicon-16x16.png
./packages/app/public/favicon-32x32.png
./packages/app/public/favicon.ico
./packages/app/public/index.html
./packages/app/public/manifest.json
./packages/app/public/robots.txt
./packages/app/public/safari-pinned-tab.svg
./packages/app/src
./packages/app/src/App.test.tsx
./packages/app/src/App.tsx
./packages/app/src/apis.ts
./packages/app/src/components
./packages/app/src/index.tsx
./packages/app/src/setupTests.ts
./packages/app/templates
./packages/app/templates/ado-permission-request-template
./packages/app/templates/ado-pipeline-bootstrap-template
./packages/app/templates/ado-repository-template
./packages/app/templates/azure-devops-service-template
./packages/backend
./packages/backend/.eslintrc.js
./packages/backend/Dockerfile
./packages/backend/README.md
./packages/backend/config.yaml
./packages/backend/dist
./packages/backend/dist/bundle.tar.gz
./packages/backend/dist/skeleton.tar.gz
./packages/backend/node_modules
./packages/backend/node_modules/app
./packages/backend/package.json
./packages/backend/src
./packages/backend/src/app.ts
./packages/backend/src/index.ts
./packages/backend/src/plugins
./playwright.config.ts
./plugins
./plugins/.gitkeep
./plugins/README.md
./scripts
./scripts/check-scaffolder-v2.sh
./scripts/export-reproducibility-snapshot.sh
./scripts/start-backstage-with-github.sh
./templates
./templates/golden-path-python
./templates/golden-path-python/skeleton
./templates/golden-path-python/skeleton/Dockerfile
./templates/golden-path-python/skeleton/README.md
./templates/golden-path-python/skeleton/app
./templates/golden-path-python/skeleton/catalog-info.yaml
./templates/golden-path-python/skeleton/docs
./templates/golden-path-python/skeleton/k8s
./templates/golden-path-python/skeleton/mkdocs.yml
./templates/golden-path-python/template.yaml
./tsconfig.json
./yarn.lock
```

## 6. Backstage-spezifische Dateien

```text
./.github/workflows/build-backstage.yml
./.yarnrc.yml
./Dockerfile
./README.md
./app-config.local.yaml
./app-config.production.yaml
./app-config.yaml
./backstage-deployment.yaml
./backstage-service.yaml
./catalog-info.yaml
./doccumentation.md
./docker-compose.yml
./docs/checkpoints/stable-github-publish-v1.md
./docs/checkpoints/stable-multi-template-scaffolder-v2.md
./docs/reproducibility/file-appendix.md
./docs/reproducibility/reproducibility-snapshot.md
./examples/entities.yaml
./examples/org.yaml
./examples/template/content/catalog-info.yaml
./examples/template/content/package.json
./examples/template/template.yaml
./package.json
./packages/README.md
./packages/app/package.json
./packages/app/templates/ado-permission-request-template/skeleton/README.md
./packages/app/templates/ado-permission-request-template/skeleton/catalog-info.yaml
./packages/app/templates/ado-permission-request-template/skeleton/docs/index.md
./packages/app/templates/ado-permission-request-template/skeleton/mkdocs.yml
./packages/app/templates/ado-permission-request-template/skeleton/permission-request.yaml
./packages/app/templates/ado-permission-request-template/template.yaml
./packages/app/templates/ado-pipeline-bootstrap-template/skeleton/README.md
./packages/app/templates/ado-pipeline-bootstrap-template/skeleton/azure-pipelines.yml
./packages/app/templates/ado-pipeline-bootstrap-template/skeleton/catalog-info.yaml
./packages/app/templates/ado-pipeline-bootstrap-template/skeleton/docs/index.md
./packages/app/templates/ado-pipeline-bootstrap-template/skeleton/mkdocs.yml
./packages/app/templates/ado-pipeline-bootstrap-template/template.yaml
./packages/app/templates/ado-repository-template/skeleton/README.md
./packages/app/templates/ado-repository-template/skeleton/azure-pipelines.yml
./packages/app/templates/ado-repository-template/skeleton/catalog-info.yaml
./packages/app/templates/ado-repository-template/skeleton/docs/index.md
./packages/app/templates/ado-repository-template/skeleton/mkdocs.yml
./packages/app/templates/ado-repository-template/template.yaml
./packages/app/templates/azure-devops-service-template/README.md
./packages/app/templates/azure-devops-service-template/skeleton/README.md
./packages/app/templates/azure-devops-service-template/skeleton/azure-pipelines.yml
./packages/app/templates/azure-devops-service-template/skeleton/catalog-info.yaml
./packages/app/templates/azure-devops-service-template/skeleton/docs/index.md
./packages/app/templates/azure-devops-service-template/skeleton/mkdocs.yml
./packages/app/templates/azure-devops-service-template/template.yaml
./packages/backend/Dockerfile
./packages/backend/README.md
./packages/backend/config.yaml
./packages/backend/package.json
./plugins/README.md
./scripts/check-scaffolder-v2.sh
./scripts/export-reproducibility-snapshot.sh
./scripts/start-backstage-with-github.sh
./templates/golden-path-python/skeleton/Dockerfile
./templates/golden-path-python/skeleton/README.md
./templates/golden-path-python/skeleton/catalog-info.yaml
./templates/golden-path-python/skeleton/docs/index.md
./templates/golden-path-python/skeleton/k8s/deployment.yaml
./templates/golden-path-python/skeleton/k8s/service.yaml
./templates/golden-path-python/skeleton/mkdocs.yml
./templates/golden-path-python/template.yaml
```

## 7. Sicherheitsprüfung auf versehentliche Tokens

```text
scripts/export-reproducibility-snapshot.sh:  if grep -R "ghp_\|gho_\|github_pat_" \
OK: Keine offensichtlichen GitHub Tokens in den geprüften Projektdateien gefunden.
```
