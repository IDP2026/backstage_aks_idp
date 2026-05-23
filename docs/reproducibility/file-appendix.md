# Dateianhang — Backstage IDP

Dieser Anhang enthält die wichtigsten Dateien des aktuellen Projektstands.
Die Inhalte wurden automatisch aus dem Repository exportiert.


## Datei: /home/koffi/backstage_aks_idp/docs/reproducibility/files/.gitignore

```
# macOS
.DS_Store

# Logs
logs
*.log
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Coverage directory generated when running tests with coverage
coverage

# Dependencies
node_modules/

# Yarn files
.pnp.*
.yarn/*
!.yarn/patches
!.yarn/plugins
!.yarn/releases
!.yarn/sdks
!.yarn/versions

# Node version directives
.nvmrc

# dotenv environment variables file
.env
.env.test

# Build output
dist
dist-types

# Temporary change files created by Vim
*.swp

# MkDocs build output
site

# Local configuration files
*.local.yaml

# Sensitive credentials
*-credentials.yaml

# vscode database functionality support files
*.session.sql

# E2E test reports
e2e-test-report/

# Cache
.cache/
# Backstage local runtime data
packages/backend/data/
*.sqlite
```

## Datei: /home/koffi/backstage_aks_idp/docs/reproducibility/files/Dockerfile

```
# ---------- Deps stage (Yarn workspaces focus) ----------
FROM node:22-bookworm-slim AS deps
WORKDIR /repo

#RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates \
 # && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    python3 \
    make \
    g++ \
    pkg-config \
    libsqlite3-dev \
  && rm -rf /var/lib/apt/lists/*
# Corporate CA (KUKA)
COPY certs/kuka-ca.crt /usr/local/share/ca-certificates/kuka-ca.crt
RUN update-ca-certificates

ENV NODE_EXTRA_CA_CERTS=/etc/ssl/certs/ca-certificates.crt
ENV npm_config_cafile=/etc/ssl/certs/ca-certificates.crt
ENV npm_config_strict_ssl=true
ENV YARN_ENABLE_STRICT_SSL=1

RUN corepack enable

COPY package.json yarn.lock .yarnrc.yml ./
COPY .yarn/ .yarn/
COPY packages/ ./packages/

# Install ONLY production deps for backend workspace
RUN yarn workspaces focus --production backend

# ---------- Runtime stage ----------
FROM node:22-bookworm-slim AS runtime
WORKDIR /app
ENV NODE_ENV=production

RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates \
  && rm -rf /var/lib/apt/lists/*

# Corporate CA (KUKA)
COPY certs/kuka-ca.crt /usr/local/share/ca-certificates/kuka-ca.crt
RUN update-ca-certificates

# Backstage backend build output (must exist locally)
COPY packages/backend/dist/skeleton.tar.gz /tmp/skeleton.tar.gz
RUN tar -xzf /tmp/skeleton.tar.gz -C /app && rm /tmp/skeleton.tar.gz

COPY packages/backend/dist/bundle.tar.gz /tmp/bundle.tar.gz
RUN tar -xzf /tmp/bundle.tar.gz -C /app && rm /tmp/bundle.tar.gz

# Production deps from deps stage
COPY --from=deps /repo/node_modules /app/node_modules

# Configs + catalog entity
COPY app-config.yaml /app/app-config.yaml
COPY app-config.production.yaml /app/app-config.production.yaml
COPY catalog-info.yaml /app/catalog-info.yaml

EXPOSE 7007
CMD ["node", "packages/backend", "--config", "app-config.yaml", "--config", "app-config.production.yaml"]
```

## Datei: /home/koffi/backstage_aks_idp/docs/reproducibility/files/app-config.local.yaml

```
app:
  baseUrl: http://localhost:3000
backend:
  baseUrl: http://localhost:7007
  listen:
    port: 7007
    host: 0.0.0.0
  database:
    client: better-sqlite3
    connection:
      directory: ./data
  cors:
    origin: http://localhost:3000
    methods:
      - GET
      - HEAD
      - PATCH
      - POST
      - PUT
      - DELETE
    credentials: true
auth:
  environment: development
  providers:
    guest: {}
permission:
  enabled: false
catalog:
  rules:
    - allow:
        - Component
        - System
        - API
        - Resource
        - Location
        - User
        - Group
        - Template
  locations:
    - type: file
      target: /home/koffi/backstage_aks_idp/catalog-info.yaml
    - type: file
      target: /home/koffi/backstage_aks_idp/catalog/components/manufacturing-api.yaml
    - type: file
      target: /home/koffi/backstage_aks_idp/catalog/systems/manufacturing-platform.yaml
    - type: file
      target: /home/koffi/backstage_aks_idp/catalog/resources/azdo-manufacturing-dev.yaml
    - type: file
      target: /home/koffi/backstage_aks_idp/catalog/org/platform-team.yaml
    - type: file
      target: /home/koffi/backstage_aks_idp/catalog/org/koffi.yaml
    - type: file
      target: /home/koffi/backstage_aks_idp/packages/app/templates/azure-devops-service-template/template.yaml
      rules:
        - allow:
            - Template
    - type: file
      target: /home/koffi/backstage_aks_idp/packages/app/templates/ado-repository-template/template.yaml
      rules:
        - allow:
            - Template
    - type: file
      target: /home/koffi/backstage_aks_idp/packages/app/templates/ado-pipeline-bootstrap-template/template.yaml
      rules:
        - allow:
            - Template
    - type: file
      target: /home/koffi/backstage_aks_idp/packages/app/templates/ado-permission-request-template/template.yaml
      rules:
        - allow:
            - Template
integrations:
  github:
    - host: github.com
      token: ${GITHUB_TOKEN}
```

## Datei: /home/koffi/backstage_aks_idp/docs/reproducibility/files/app-config.production.yaml

```
app:
  baseUrl: http://localhost:3000

backend:
  baseUrl: http://localhost:7007
  listen:
    port: 7007
    host: 0.0.0.0

  # DB en SQLite (un fichier par plugin dans un dossier)
  database:
    client: better-sqlite3
    connection:
      directory: /app/data
    useNullAsDefault: true

  # TEMP MVP: autoriser les appels sans session (curl)
  auth:
    dangerouslyDisableDefaultAuthPolicy: true

auth:
  providers:
    guest: {}

# IMPORTANT: évite les warnings "file ... does not exist" si /app/examples n'est pas dans l'image
catalog:
  locations:
    - type: file
      target: /app/catalog-info.yaml

kubernetes:
  serviceLocatorMethod:
    type: multiTenant
  clusterLocatorMethods:
    - type: config
      clusters:
        - name: aks
          url: https://kubernetes.default.svc
          authProvider: serviceAccount
          skipTLSVerify: false
```

## Datei: /home/koffi/backstage_aks_idp/docs/reproducibility/files/app-config.yaml

```
app:
  title: Backstage
  baseUrl: http://localhost:3000
backend:
  baseUrl: http://localhost:7007
  listen:
    host: 0.0.0.0
    port: 7007
auth:
  environment: development
  providers:
    guest: {}
permission:
  enabled: false
catalog:
  rules:
    - allow:
        - Component
        - System
        - API
        - Resource
        - Location
        - User
        - Group
        - Template
  locations:
    - type: file
      target: /home/koffi/backstage_aks_idp/catalog-info.yaml
    - type: file
      target: /home/koffi/backstage_aks_idp/catalog/components/manufacturing-api.yaml
    - type: file
      target: /home/koffi/backstage_aks_idp/catalog/systems/manufacturing-platform.yaml
    - type: file
      target: /home/koffi/backstage_aks_idp/catalog/resources/azdo-manufacturing-dev.yaml
    - type: file
      target: /home/koffi/backstage_aks_idp/catalog/org/platform-team.yaml
    - type: file
      target: /home/koffi/backstage_aks_idp/catalog/org/koffi.yaml
    - type: file
      target: /home/koffi/backstage_aks_idp/packages/app/templates/azure-devops-service-template/template.yaml
      rules:
        - allow:
            - Template
    - type: file
      target: /home/koffi/backstage_aks_idp/packages/app/templates/ado-repository-template/template.yaml
      rules:
        - allow:
            - Template
    - type: file
      target: /home/koffi/backstage_aks_idp/packages/app/templates/ado-pipeline-bootstrap-template/template.yaml
      rules:
        - allow:
            - Template
    - type: file
      target: /home/koffi/backstage_aks_idp/packages/app/templates/ado-permission-request-template/template.yaml
      rules:
        - allow:
            - Template
integrations:
  github:
    - host: github.com
      token: ${GITHUB_TOKEN}
```

## Datei: /home/koffi/backstage_aks_idp/docs/reproducibility/files/catalog-info.yaml

```
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: kuka-platform
  description: Backstage platform component
  annotations:
    backstage.io/kubernetes-id: kuka-platform
    backstage.io/kubernetes-namespace: idpapp
spec:
  type: website
  owner: john@example.com
  lifecycle: experimental
```

## Datei: /home/koffi/backstage_aks_idp/docs/reproducibility/files/docker-compose.yml

```
version: "3.8"

services:
  postgres:
    image: postgres:15
    container_name: pg-backstage
    restart: always
    environment:
      POSTGRES_DB: backstage
      POSTGRES_USER: backstage
      POSTGRES_PASSWORD: backstage
    ports:
      - "5432:5432"
    volumes:
      - pgdata:/var/lib/postgresql/data

  backstage:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: backstage-app
    depends_on:
      - postgres
    environment:
      NODE_ENV: production

      # Base URLs wichtig!
      APP_CONFIG_app_baseUrl: "http://localhost:3000"
      APP_CONFIG_backend_baseUrl: "http://localhost:7007"

      # DB Verbindung
      APP_CONFIG_backend_database_client: pg
      APP_CONFIG_backend_database_connection_host: postgres
      APP_CONFIG_backend_database_connection_port: 5432
      APP_CONFIG_backend_database_connection_user: backstage
      APP_CONFIG_backend_database_connection_password: backstage
      APP_CONFIG_backend_database_connection_database: backstage

      GITHUB_TOKEN: ${GITHUB_TOKEN}

    ports:
      - "3000:3000"
      - "7007:7007"
    restart: unless-stopped

volumes:
  pgdata:
```

## Datei: /home/koffi/backstage_aks_idp/docs/reproducibility/files/docs/checkpoints/stable-github-publish-v1.md

```
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
```

## Datei: /home/koffi/backstage_aks_idp/docs/reproducibility/files/package.json

```
{
  "name": "root",
  "version": "1.0.0",
  "private": true,
  "engines": {
    "node": "22 || 24"
  },
  "scripts": {
    "start": "backstage-cli repo start",
    "build:backend": "yarn workspace backend build",
    "build:all": "backstage-cli repo build --all",
    "build-image": "yarn workspace backend build-image",
    "tsc": "tsc",
    "tsc:full": "tsc --skipLibCheck false --incremental false",
    "clean": "backstage-cli repo clean",
    "test": "backstage-cli repo test",
    "test:all": "backstage-cli repo test --coverage",
    "test:e2e": "playwright test",
    "fix": "backstage-cli repo fix",
    "lint": "backstage-cli repo lint --since origin/main",
    "lint:all": "backstage-cli repo lint",
    "prettier:check": "prettier --check .",
    "new": "backstage-cli new"
  },
  "workspaces": {
    "packages": [
      "packages/*",
      "plugins/*"
    ]
  },
  "devDependencies": {
    "@backstage/cli": "^0.35.4",
    "@backstage/e2e-test-utils": "^0.1.2",
    "@jest/environment-jsdom-abstract": "^30.0.0",
    "@playwright/test": "^1.32.3",
    "@types/jest": "^30.0.0",
    "@types/node": "^25.3.5",
    "@types/react": "^19.2.14",
    "jest": "^30.2.0",
    "jsdom": "^27.1.0",
    "node-gyp": "^10.0.0",
    "prettier": "^2.3.2",
    "typescript": "^5.9.3",
    "webpack": "^5.105.4"
  },
  "resolutions": {
    "@types/react": "^18",
    "@types/react-dom": "^18"
  },
  "prettier": "@backstage/cli/config/prettier",
  "lint-staged": {
    "*.{js,jsx,ts,tsx,mjs,cjs}": [
      "eslint --fix",
      "prettier --write"
    ],
    "*.{json,md}": [
      "prettier --write"
    ]
  },
  "packageManager": "yarn@4.4.1"
}
```

## Datei: /home/koffi/backstage_aks_idp/docs/reproducibility/files/packages/app/templates/ado-permission-request-template/skeleton/README.md

```
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
```

## Datei: /home/koffi/backstage_aks_idp/docs/reproducibility/files/packages/app/templates/ado-permission-request-template/skeleton/catalog-info.yaml

```
apiVersion: backstage.io/v1alpha1
kind: Resource
metadata:
  name: ${{ values.requestName }}
  title: ${{ values.requestName }}
  description: >
    Vorbereitete Azure-DevOps-Berechtigungsanfrage für ${{ values.targetProject }}.
  tags:
    - azure-devops
    - permissions
    - rbac
spec:
  type: permission-request
  owner: ${{ values.owner }}
  system: ${{ values.system }}
```

## Datei: /home/koffi/backstage_aks_idp/docs/reproducibility/files/packages/app/templates/ado-permission-request-template/skeleton/docs/index.md

```
# ${{ values.requestName }}

## Überblick

Diese Dokumentation beschreibt eine vorbereitete Azure-DevOps-Berechtigungsanfrage.

## Ziel

- Projekt: ${{ values.targetProject }}
- Gruppe: ${{ values.targetGroup }}
- Zugriff: ${{ values.accessLevel }}

## Hinweis

Die technische RBAC-Umsetzung wird bewusst nicht über Keycloak realisiert.
```

## Datei: /home/koffi/backstage_aks_idp/docs/reproducibility/files/packages/app/templates/ado-permission-request-template/skeleton/mkdocs.yml

```
site_name: ${{ values.requestName }}
site_description: Dokumentation für Berechtigungsanfrage ${{ values.requestName }}

nav:
  - Überblick: index.md

plugins:
  - techdocs-core
```

## Datei: /home/koffi/backstage_aks_idp/docs/reproducibility/files/packages/app/templates/ado-permission-request-template/skeleton/permission-request.yaml

```
request:
  name: ${{ values.requestName }}
  requester: ${{ values.requester }}
  targetProject: ${{ values.targetProject }}
  targetGroup: ${{ values.targetGroup }}
  accessLevel: ${{ values.accessLevel }}
  justification: >
    ${{ values.justification }}
  status: prepared
```

## Datei: /home/koffi/backstage_aks_idp/docs/reproducibility/files/packages/app/templates/ado-permission-request-template/template.yaml

```
apiVersion: scaffolder.backstage.io/v1beta3
kind: Template
metadata:
  name: ado-permission-request-template
  title: Azure DevOps Permission Request Template
  description: >
    Vorlage zur standardisierten Vorbereitung einer Berechtigungsanfrage
    für Azure-DevOps-Projekte, Gruppen und Zugriffsrollen.
  tags:
    - azure-devops
    - rbac
    - permissions
spec:
  owner: group:default/platform-team
  type: service

  parameters:
    - title: Berechtigungsanfrage
      required:
        - requestName
        - targetProject
        - targetGroup
        - accessLevel
        - justification
      properties:
        requestName:
          title: Name der Anfrage
          type: string
          default: ado-project-access-request
          pattern: '^[a-z0-9]+(-[a-z0-9]+)*$'
        targetProject:
          title: Azure-DevOps-Projekt
          type: string
          default: platform-dev
        targetGroup:
          title: Zielgruppe
          type: string
          default: platform-team
        accessLevel:
          title: Zugriffsebene
          type: string
          default: reader
          enum:
            - reader
            - contributor
            - administrator
        justification:
          title: Begründung
          type: string
          description: Fachliche Begründung für die angeforderte Berechtigung.

    - title: Governance-Zuordnung
      required:
        - requester
        - owner
        - system
      properties:
        requester:
          title: Antragsteller
          type: string
          default: user:default/koffi
        owner:
          title: Verantwortliches Team
          type: string
          default: group:default/platform-team
        system:
          title: Zugehöriges System
          type: string
          default: governance-platform

  steps:
    - id: fetch-template
      name: Berechtigungsanfrage generieren
      action: fetch:template
      input:
        url: ./skeleton
        values:
          requestName: ${{ parameters.requestName }}
          targetProject: ${{ parameters.targetProject }}
          targetGroup: ${{ parameters.targetGroup }}
          accessLevel: ${{ parameters.accessLevel }}
          justification: ${{ parameters.justification }}
          requester: ${{ parameters.requester }}
          owner: ${{ parameters.owner }}
          system: ${{ parameters.system }}

    - id: debug
      name: Ergebnis anzeigen
      action: debug:log
      input:
        message: >
          Berechtigungsanfrage wurde vorbereitet.
          Projekt: ${{ parameters.targetProject }}.
          Gruppe: ${{ parameters.targetGroup }}.
          Zugriff: ${{ parameters.accessLevel }}.

  output:
    text:
      - title: Anfrage
        content: ${{ parameters.requestName }}
      - title: Projekt
        content: ${{ parameters.targetProject }}
      - title: Gruppe
        content: ${{ parameters.targetGroup }}
      - title: Zugriff
        content: ${{ parameters.accessLevel }}
      - title: Status
        content: >
          Die Berechtigungsanfrage wurde vorbereitet.
          Es wurde noch keine echte Azure-DevOps-Berechtigung geändert.
```

## Datei: /home/koffi/backstage_aks_idp/docs/reproducibility/files/packages/app/templates/ado-pipeline-bootstrap-template/skeleton/README.md

```
# ${{ values.pipelineName }}

## Zweck

Diese Pipeline-Struktur wurde über Backstage vorbereitet.

## Zugehörigkeit

- Service: ${{ values.serviceName }}
- Repository: ${{ values.repositoryName }}
- Owner: ${{ values.owner }}
- System: ${{ values.system }}

## Azure DevOps

- Organisation: ${{ values.azureDevOpsOrganization }}
- Projekt: ${{ values.azureDevOpsProjectName }}

## Status

Die echte Pipeline-Erstellung wird in einer späteren Automatisierungsphase ergänzt.
```

## Datei: /home/koffi/backstage_aks_idp/docs/reproducibility/files/packages/app/templates/ado-pipeline-bootstrap-template/skeleton/azure-pipelines.yml

```
trigger:
  branches:
    include:
      - main

pool:
  vmImage: ubuntu-latest

variables:
  serviceName: ${{ values.serviceName }}
  pipelineName: ${{ values.pipelineName }}
  repositoryName: ${{ values.repositoryName }}

stages:
  - stage: Validate
    displayName: Validierung
    jobs:
      - job: Validate
        steps:
          - script: |
              echo "Service: $(serviceName)"
              echo "Pipeline: $(pipelineName)"
              echo "Repository: $(repositoryName)"
            displayName: Pipeline-Kontext anzeigen

  - stage: Build
    displayName: Build
    dependsOn: Validate
    jobs:
      - job: Build
        steps:
          - script: |
              echo "Build-Platzhalter für $(serviceName)"
            displayName: Build vorbereiten
```

## Datei: /home/koffi/backstage_aks_idp/docs/reproducibility/files/packages/app/templates/ado-pipeline-bootstrap-template/skeleton/catalog-info.yaml

```
apiVersion: backstage.io/v1alpha1
kind: Resource
metadata:
  name: ${{ values.pipelineName }}
  title: ${{ values.pipelineName }}
  description: >
    ${{ values.description }}
  tags:
    - azure-devops
    - pipeline
    - generated
spec:
  type: ci-cd-pipeline
  lifecycle: ${{ values.lifecycle }}
  owner: ${{ values.owner }}
  system: ${{ values.system }}
```

## Datei: /home/koffi/backstage_aks_idp/docs/reproducibility/files/packages/app/templates/ado-pipeline-bootstrap-template/skeleton/docs/index.md

```
# ${{ values.pipelineName }}

## Überblick

Diese Dokumentation beschreibt die vorbereitete Azure-DevOps-Pipeline.

## Service

${{ values.serviceName }}

## Repository

${{ values.repositoryName }}

## Status

Die Pipeline ist aktuell ein Platzhalter und wird später technisch angebunden.
```

## Datei: /home/koffi/backstage_aks_idp/docs/reproducibility/files/packages/app/templates/ado-pipeline-bootstrap-template/skeleton/mkdocs.yml

```
site_name: ${{ values.pipelineName }}
site_description: Dokumentation für Pipeline ${{ values.pipelineName }}

nav:
  - Überblick: index.md

plugins:
  - techdocs-core
```

## Datei: /home/koffi/backstage_aks_idp/docs/reproducibility/files/packages/app/templates/ado-pipeline-bootstrap-template/template.yaml

```
apiVersion: scaffolder.backstage.io/v1beta3
kind: Template
metadata:
  name: ado-pipeline-bootstrap-template
  title: Azure DevOps Pipeline Bootstrap Template
  description: >
    Vorlage zur standardisierten Vorbereitung einer Azure-DevOps-Pipeline
    mit Validierungs- und Build-Struktur.
  tags:
    - azure-devops
    - pipeline
    - ci-cd
spec:
  owner: group:default/platform-team
  type: service

  parameters:
    - title: Pipeline-Informationen
      required:
        - pipelineName
        - serviceName
        - description
      properties:
        pipelineName:
          title: Pipeline-Name
          type: string
          default: platform-service-ci
          pattern: '^[a-z0-9]+(-[a-z0-9]+)*$'
        serviceName:
          title: Service-Name
          type: string
          default: platform-service
          pattern: '^[a-z0-9]+(-[a-z0-9]+)*$'
        description:
          title: Beschreibung
          type: string
          description: Beschreibung der Pipeline.

    - title: Governance-Zuordnung
      required:
        - owner
        - system
        - lifecycle
      properties:
        owner:
          title: Verantwortliches Team
          type: string
          default: group:default/platform-team
        system:
          title: Zugehöriges System
          type: string
          default: developer-platform
        lifecycle:
          title: Lebenszyklus
          type: string
          default: experimental
          enum:
            - experimental
            - production
            - deprecated

    - title: Azure-DevOps-Metadaten
      required:
        - azureDevOpsOrganization
        - azureDevOpsProjectName
        - repositoryName
      properties:
        azureDevOpsOrganization:
          title: Azure-DevOps-Organisation
          type: string
          default: my-organization
        azureDevOpsProjectName:
          title: Azure-DevOps-Projektname
          type: string
          default: platform-dev
        repositoryName:
          title: Repository-Name
          type: string
          default: platform-service
          pattern: '^[a-z0-9]+(-[a-z0-9]+)*$'

  steps:
    - id: fetch-template
      name: Pipeline-Struktur generieren
      action: fetch:template
      input:
        url: ./skeleton
        values:
          pipelineName: ${{ parameters.pipelineName }}
          serviceName: ${{ parameters.serviceName }}
          description: ${{ parameters.description }}
          owner: ${{ parameters.owner }}
          system: ${{ parameters.system }}
          lifecycle: ${{ parameters.lifecycle }}
          azureDevOpsOrganization: ${{ parameters.azureDevOpsOrganization }}
          azureDevOpsProjectName: ${{ parameters.azureDevOpsProjectName }}
          repositoryName: ${{ parameters.repositoryName }}

    - id: debug
      name: Ergebnis anzeigen
      action: debug:log
      input:
        message: >
          Pipeline-Struktur wurde vorbereitet.
          Pipeline: ${{ parameters.pipelineName }}.
          Repository: ${{ parameters.repositoryName }}.

  output:
    text:
      - title: Pipeline
        content: ${{ parameters.pipelineName }}
      - title: Repository
        content: ${{ parameters.repositoryName }}
      - title: Owner
        content: ${{ parameters.owner }}
      - title: Status
        content: >
          Die Pipeline-Struktur wurde vorbereitet.
          Es wurde noch keine echte Azure-DevOps-Pipeline erstellt.
```

## Datei: /home/koffi/backstage_aks_idp/docs/reproducibility/files/packages/app/templates/ado-repository-template/skeleton/.gitignore

```
node_modules/
dist/
build/
.env
.env.local
coverage/
```

## Datei: /home/koffi/backstage_aks_idp/docs/reproducibility/files/packages/app/templates/ado-repository-template/skeleton/README.md

```
# ${{ values.repositoryTitle }}

## Zweck

Dieses Repository wurde über den Backstage Azure DevOps Repository Template vorbereitet.

## Beschreibung

${{ values.description }}

## Governance

- Owner: ${{ values.owner }}
- System: ${{ values.system }}
- Azure DevOps Resource: ${{ values.azureDevOpsProject }}
- Lifecycle: ${{ values.lifecycle }}

## Azure DevOps

- Organisation: ${{ values.azureDevOpsOrganization }}
- Projekt: ${{ values.azureDevOpsProjectName }}
- Pipeline: ${{ values.pipelineName }}

## Nächste Schritte

- Repository in Azure DevOps erstellen
- Dateien in das Repository pushen
- Pipeline aktivieren
- Component im Backstage Catalog registrieren
```

## Datei: /home/koffi/backstage_aks_idp/docs/reproducibility/files/packages/app/templates/ado-repository-template/skeleton/azure-pipelines.yml

```
trigger:
  branches:
    include:
      - main

pool:
  vmImage: ubuntu-latest

variables:
  repositoryName: ${{ values.repositoryName }}
  pipelineName: ${{ values.pipelineName }}
  owner: ${{ values.owner }}
  system: ${{ values.system }}

stages:
  - stage: Validate
    displayName: Repository validieren
    jobs:
      - job: ValidateRepository
        displayName: Repository-Metadaten prüfen
        steps:
          - script: |
              echo "Repository: $(repositoryName)"
              echo "Pipeline: $(pipelineName)"
              echo "Owner: $(owner)"
              echo "System: $(system)"
            displayName: Metadaten anzeigen
```

## Datei: /home/koffi/backstage_aks_idp/docs/reproducibility/files/packages/app/templates/ado-repository-template/skeleton/catalog-info.yaml

```
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: ${{ values.repositoryName }}
  title: ${{ values.repositoryTitle }}
  description: >
    ${{ values.description }}
  annotations:
    backstage.io/techdocs-ref: dir:.
  tags:
    - azure-devops
    - repository
    - generated
spec:
  type: service
  lifecycle: ${{ values.lifecycle }}
  owner: ${{ values.owner }}
  system: ${{ values.system }}
  dependsOn:
    - resource:default/${{ values.azureDevOpsProject }}
```

## Datei: /home/koffi/backstage_aks_idp/docs/reproducibility/files/packages/app/templates/ado-repository-template/skeleton/docs/index.md

```
# ${{ values.repositoryTitle }}

## Überblick

Diese Dokumentation beschreibt das vorbereitete Azure-DevOps-Repository `${{ values.repositoryName }}`.

## Governance

- Owner: ${{ values.owner }}
- System: ${{ values.system }}
- Azure DevOps Resource: ${{ values.azureDevOpsProject }}

## Status

Die echte Repository-Erstellung wird in einer späteren Automatisierungsphase ergänzt.
```

## Datei: /home/koffi/backstage_aks_idp/docs/reproducibility/files/packages/app/templates/ado-repository-template/skeleton/mkdocs.yml

```
site_name: ${{ values.repositoryTitle }}
site_description: Dokumentation für ${{ values.repositoryName }}

nav:
  - Überblick: index.md

plugins:
  - techdocs-core
```

## Datei: /home/koffi/backstage_aks_idp/docs/reproducibility/files/packages/app/templates/ado-repository-template/template.yaml

```
apiVersion: scaffolder.backstage.io/v1beta3
kind: Template
metadata:
  name: ado-repository-template
  title: ADO Repository Template
  description: >
    Vorlage zur standardisierten Vorbereitung und Veröffentlichung eines
    Repository-Grundgerüsts über Backstage. Die generierten Dateien werden
    in einem GitHub-Repository veröffentlicht und können später für
    Azure-DevOps-Automatisierung erweitert werden.
  tags:
    - azure-devops
    - repository
    - github
    - golden-path
spec:
  owner: group:default/platform-team
  type: service

  parameters:
    - title: Repository-Informationen
      required:
        - repositoryName
        - repositoryTitle
        - description
      properties:
        repositoryName:
          title: Repository-Name
          type: string
          description: Technischer Name des zukünftigen Repositories.
          default: demo-platform-repository
          pattern: '^[a-z0-9]+(-[a-z0-9]+)*$'
        repositoryTitle:
          title: Anzeigename
          type: string
          description: Lesbarer Name des Repositories.
          default: Demo Platform Repository
        description:
          title: Beschreibung
          type: string
          description: Fachliche oder technische Beschreibung des Repositories.
          default: Repository zur Validierung der GitHub-Veröffentlichung über Backstage.

    - title: Governance-Zuordnung
      required:
        - owner
        - system
        - azureDevOpsProject
        - lifecycle
      properties:
        owner:
          title: Verantwortliches Team
          type: string
          description: Backstage Owner-Referenz des verantwortlichen Teams.
          default: group:default/platform-team
        system:
          title: Zugehöriges System
          type: string
          description: Backstage System, dem das Repository zugeordnet wird.
          default: developer-platform
        azureDevOpsProject:
          title: Azure-DevOps-Resource im Catalog
          type: string
          description: Backstage Resource, die das Zielprojekt repräsentiert.
          default: azure-devops-project
        lifecycle:
          title: Lebenszyklus
          type: string
          description: Lebenszyklus der Komponente.
          default: experimental
          enum:
            - experimental
            - production
            - deprecated

    - title: Azure-DevOps-Metadaten
      required:
        - azureDevOpsOrganization
        - azureDevOpsProjectName
        - pipelineName
      properties:
        azureDevOpsOrganization:
          title: Azure-DevOps-Organisation
          type: string
          description: Name der Azure-DevOps-Organisation.
          default: my-organization
        azureDevOpsProjectName:
          title: Azure-DevOps-Projektname
          type: string
          description: Name des Azure-DevOps-Projekts.
          default: platform-dev
        pipelineName:
          title: Pipeline-Name
          type: string
          description: Name der vorbereiteten Pipeline.
          default: demo-platform-repository-ci
          pattern: '^[a-z0-9]+(-[a-z0-9]+)*$'


  steps:
    - id: fetch-template
      name: Repository-Struktur generieren
      action: fetch:template
      input:
        url: ./skeleton
        values:
          repositoryName: ${{ parameters.repositoryName }}
          repositoryTitle: ${{ parameters.repositoryTitle }}
          description: ${{ parameters.description }}
          owner: ${{ parameters.owner }}
          system: ${{ parameters.system }}
          azureDevOpsProject: ${{ parameters.azureDevOpsProject }}
          lifecycle: ${{ parameters.lifecycle }}
          azureDevOpsOrganization: ${{ parameters.azureDevOpsOrganization }}
          azureDevOpsProjectName: ${{ parameters.azureDevOpsProjectName }}
          pipelineName: ${{ parameters.pipelineName }}

    - id: publish
      name: Repository nach GitHub veröffentlichen
      action: publish:github
      input:
        repoUrl: github.com?repo=${{ parameters.repositoryName }}&owner=IDP2026
        defaultBranch: main
        repoVisibility: private
        description: ${{ parameters.description }}

    - id: debug
      name: Ergebnis anzeigen
      action: debug:log
      input:
        message: >
          Repository-Struktur wurde generiert und nach GitHub veröffentlicht.
          Repository-Ziel: github.com?repo=${{ parameters.repositoryName }}&owner=IDP2026.

  output:
    text:
      - title: Repository
        content: ${{ parameters.repositoryName }}
      - title: Owner
        content: ${{ parameters.owner }}
      - title: System
        content: ${{ parameters.system }}
      - title: Pipeline
        content: ${{ parameters.pipelineName }}
      - title: GitHub Repository
        content: ${{ steps.publish.output.remoteUrl }}
      - title: Status
        content: >
          Die Repository-Struktur wurde generiert und in GitHub veröffentlicht.
    links:
      - title: GitHub Repository öffnen
        url: ${{ steps.publish.output.remoteUrl }}
```

## Datei: /home/koffi/backstage_aks_idp/docs/reproducibility/files/packages/app/templates/azure-devops-service-template/README.md

```
# Azure DevOps Service Template

## Zweck

Dieses Verzeichnis enthält den zukünftigen Backstage Scaffolder Template
für die standardisierte Erstellung von Services innerhalb der Internal Developer Platform.

## Status

Der Template ist vorbereitet, aber noch nicht im Backstage Catalog registriert.

## Geplante Funktion

Der Template soll später:

- eine neue Backstage Component erzeugen,
- die Component einem bestehenden System zuordnen,
- die Component einem bestehenden Owner zuordnen,
- die Component mit einer Azure-DevOps-Resource verbinden,
- später Repository- und Pipeline-Automatisierung vorbereiten.

## Bestehende Ziel-Entitäten

- System: manufacturing-platform
- Resource: azdo-manufacturing-dev
- Group: platform-team

## Nicht aktiv

Dieser Template ist aktuell noch nicht aktiv und wird noch nicht von Backstage geladen.
```

## Datei: /home/koffi/backstage_aks_idp/docs/reproducibility/files/packages/app/templates/azure-devops-service-template/skeleton/.gitignore

```
node_modules/
dist/
build/
.env
.env.local
.DS_Store
coverage/
```

## Datei: /home/koffi/backstage_aks_idp/docs/reproducibility/files/packages/app/templates/azure-devops-service-template/skeleton/.gitkeep

```
```

## Datei: /home/koffi/backstage_aks_idp/docs/reproducibility/files/packages/app/templates/azure-devops-service-template/skeleton/README.md

```
# ${{ values.componentTitle }}

## Zweck

Dieser Service wurde über den Backstage Azure DevOps Service Template vorbereitet.

## Beschreibung

${{ values.description }}

## Governance

- Owner: ${{ values.owner }}
- System: ${{ values.system }}
- Azure DevOps Resource: ${{ values.azureDevOpsProject }}
- Lifecycle: ${{ values.lifecycle }}

## Azure DevOps

- Organisation: ${{ values.azureDevOpsOrganization }}
- Projekt: ${{ values.azureDevOpsProjectName }}
- Repository: ${{ values.repositoryName }}
- Pipeline: ${{ values.pipelineName }}

## Nächste Schritte

- Repository in Azure DevOps erstellen
- Pipeline-Konfiguration ergänzen
- Service im Backstage Catalog registrieren
- Technische Dokumentation erweitern
```

## Datei: /home/koffi/backstage_aks_idp/docs/reproducibility/files/packages/app/templates/azure-devops-service-template/skeleton/azure-pipelines.yml

```
# Pipeline-Platzhalter für den generierten Service.
# Diese Datei dient als Ausgangspunkt für eine spätere Azure-DevOps-CI/CD-Integration.

trigger:
  branches:
    include:
      - main

pool:
  vmImage: ubuntu-latest

variables:
  serviceName: ${{ values.componentName }}
  serviceOwner: ${{ values.owner }}
  serviceSystem: ${{ values.system }}
  azureDevOpsOrganization: ${{ values.azureDevOpsOrganization }}
  azureDevOpsProject: ${{ values.azureDevOpsProjectName }}
  repositoryName: ${{ values.repositoryName }}
  pipelineName: ${{ values.pipelineName }}

stages:
  - stage: Validate
    displayName: Service validieren
    jobs:
      - job: ValidateService
        displayName: Struktur und Metadaten prüfen
        steps:
          - script: |
              echo "Service: $(serviceName)"
              echo "Owner: $(serviceOwner)"
              echo "System: $(serviceSystem)"
              echo "Azure DevOps Organization: $(azureDevOpsOrganization)"
              echo "Azure DevOps Project: $(azureDevOpsProject)"
              echo "Repository: $(repositoryName)"
              echo "Pipeline: $(pipelineName)"
              echo "Validierung erfolgreich abgeschlossen."
            displayName: Service-Metadaten anzeigen

  - stage: Build
    displayName: Service bauen
    dependsOn: Validate
    jobs:
      - job: BuildService
        displayName: Build-Platzhalter
        steps:
          - script: |
              echo "Build-Schritt für $(serviceName) wird vorbereitet."
              echo "Hier wird später der echte Build-Prozess ergänzt."
            displayName: Build vorbereiten
```

## Datei: /home/koffi/backstage_aks_idp/docs/reproducibility/files/packages/app/templates/azure-devops-service-template/skeleton/catalog-info.yaml

```
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: ${{ values.componentName }}
  title: ${{ values.componentTitle }}
  description: >
    ${{ values.description }}
  annotations:
    backstage.io/techdocs-ref: dir:.
  tags:
    - azure-devops
    - generated
    - service
spec:
  type: service
  lifecycle: ${{ values.lifecycle }}
  owner: ${{ values.owner }}
  system: ${{ values.system }}
  dependsOn:
    - resource:default/${{ values.azureDevOpsProject }}
```

## Datei: /home/koffi/backstage_aks_idp/docs/reproducibility/files/packages/app/templates/azure-devops-service-template/skeleton/docs/index.md

```
# ${{ values.componentTitle }}

## Überblick

Diese Dokumentation beschreibt den generierten Service `${{ values.componentName }}`.

## Zweck

${{ values.description }}

## Verantwortlichkeit

- Owner: ${{ values.owner }}
- System: ${{ values.system }}
- Azure DevOps Resource: ${{ values.azureDevOpsProject }}
- Lifecycle: ${{ values.lifecycle }}

## Betrieb

Die Betriebsdokumentation wird im weiteren Projektverlauf ergänzt.

## Architektur

Die Architekturdetails werden nach der technischen Implementierung ergänzt.

## Deployment

Die Deployment-Informationen werden nach der Pipeline-Integration ergänzt.
```

## Datei: /home/koffi/backstage_aks_idp/docs/reproducibility/files/packages/app/templates/azure-devops-service-template/skeleton/mkdocs.yml

```
site_name: ${{ values.componentTitle }}
site_description: Dokumentation für ${{ values.componentName }}

nav:
  - Überblick: index.md

plugins:
  - techdocs-core
```

## Datei: /home/koffi/backstage_aks_idp/docs/reproducibility/files/packages/app/templates/azure-devops-service-template/skeleton/src/index.ts

```
export function startService(): void {
  console.log('Service wurde erfolgreich vorbereitet.');
}

startService();
```

## Datei: /home/koffi/backstage_aks_idp/docs/reproducibility/files/packages/app/templates/azure-devops-service-template/template.yaml

```
apiVersion: scaffolder.backstage.io/v1beta3
kind: Template
metadata:
  name: azure-devops-service-template
  title: Azure DevOps Service Template
  description: >
    Vorlage zur standardisierten Erstellung einer Backstage Component,
    die einem bestehenden System, Owner und Azure-DevOps-Projekt zugeordnet ist.
  tags:
    - azure-devops
    - service
    - golden-path
spec:
  owner: group:default/platform-team
  type: service

  parameters:
    - title: Service-Informationen
      required:
        - componentName
        - componentTitle
        - description
      properties:
        componentName:
          title: Technischer Servicename
          type: string
          description: Kleingeschriebener technischer Name des Services, z.B. manufacturing-api.
          pattern: '^[a-z0-9]+(-[a-z0-9]+)*$'
        componentTitle:
          title: Anzeigename des Services
          type: string
          description: Lesbarer Name des Services, z.B. Manufacturing API.
        description:
          title: Beschreibung
          type: string
          description: Kurze fachliche oder technische Beschreibung des Services.

    - title: Governance-Zuordnung
      required:
        - owner
        - system
        - azureDevOpsProject
        - lifecycle
      properties:
        owner:
          title: Verantwortliches Team
          type: string
          description: Backstage Owner-Referenz des verantwortlichen Teams.
          default: group:default/platform-team
        system:
          title: Zugehöriges System
          type: string
          description: Backstage System, dem der Service zugeordnet wird.
          default: manufacturing-platform
        azureDevOpsProject:
          title: Azure-DevOps-Resource im Catalog
          type: string
          description: Backstage Resource, die das Azure-DevOps-Projekt repräsentiert.
          default: azdo-manufacturing-dev
        lifecycle:
          title: Lebenszyklus
          type: string
          description: Lebenszyklus der Komponente.
          default: experimental
          enum:
            - experimental
            - production
            - deprecated

    - title: Azure-DevOps-Metadaten
      required:
        - azureDevOpsOrganization
        - azureDevOpsProjectName
        - repositoryName
        - pipelineName
      properties:
        azureDevOpsOrganization:
          title: Azure-DevOps-Organisation
          type: string
          description: Name der Azure-DevOps-Organisation.
          default: my-organization
        azureDevOpsProjectName:
          title: Azure-DevOps-Projektname
          type: string
          description: Name des Zielprojekts in Azure DevOps.
          default: manufacturing-dev
        repositoryName:
          title: Repository-Name
          type: string
          description: Name des zukünftigen Azure-DevOps-Repositories.
          default: generated-manufacturing-service
          pattern: '^[a-z0-9]+(-[a-z0-9]+)*$'
        pipelineName:
          title: Pipeline-Name
          type: string
          description: Name der zukünftigen Azure-DevOps-Pipeline.
          default: generated-manufacturing-service-ci
          pattern: '^[a-z0-9]+(-[a-z0-9]+)*$'

  steps:
    - id: fetch-template
      name: Service-Struktur generieren
      action: fetch:template
      input:
        url: ./skeleton
        values:
          componentName: ${{ parameters.componentName }}
          componentTitle: ${{ parameters.componentTitle }}
          description: ${{ parameters.description }}
          owner: ${{ parameters.owner }}
          system: ${{ parameters.system }}
          azureDevOpsProject: ${{ parameters.azureDevOpsProject }}
          lifecycle: ${{ parameters.lifecycle }}
          azureDevOpsOrganization: ${{ parameters.azureDevOpsOrganization }}
          azureDevOpsProjectName: ${{ parameters.azureDevOpsProjectName }}
          repositoryName: ${{ parameters.repositoryName }}
          pipelineName: ${{ parameters.pipelineName }}

    - id: debug
      name: Ergebnis anzeigen
      action: debug:log
      input:
        message: >
          Die Service-Struktur wurde vorbereitet.
          Component: ${{ parameters.componentName }}.
          Repository: ${{ parameters.repositoryName }}.
          Pipeline: ${{ parameters.pipelineName }}.
          Azure DevOps Projekt: ${{ parameters.azureDevOpsProjectName }}.

  output:
    text:
      - title: Generierte Component
        content: ${{ parameters.componentName }}

      - title: Owner
        content: ${{ parameters.owner }}

      - title: System
        content: ${{ parameters.system }}

      - title: Azure DevOps Resource
        content: ${{ parameters.azureDevOpsProject }}

      - title: Repository
        content: ${{ parameters.repositoryName }}

      - title: Pipeline
        content: ${{ parameters.pipelineName }}

      - title: Status
        content: >
          Die Service-Struktur wurde im temporären Scaffolder-Workspace generiert.
          Es wurde noch kein Repository erstellt, keine Pipeline erzeugt und keine
          automatische Registrierung im Catalog durchgeführt.
```

## Datei: /home/koffi/backstage_aks_idp/docs/reproducibility/files/scripts/check-scaffolder-v2.sh

```
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
```

## Datei: /home/koffi/backstage_aks_idp/docs/reproducibility/files/scripts/start-backstage-with-github.sh

```
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
```
