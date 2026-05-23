#!/usr/bin/env bash
set -euo pipefail

# ==========================================================
# Reproduzierbarkeits-Snapshot für die Masterarbeit
# Dieses Script sammelt den aktuellen technischen Zustand
# des Backstage-IDP-Prototyps.
# ==========================================================

PROJECT_ROOT="$HOME/backstage_aks_idp"
OUTPUT_DIR="$PROJECT_ROOT/docs/reproducibility"
SNAPSHOT_FILE="$OUTPUT_DIR/reproducibility-snapshot.md"
FILES_DIR="$OUTPUT_DIR/files"

cd "$PROJECT_ROOT"

# Alte Snapshot-Dateien entfernen, damit keine veralteten Inhalte bleiben
rm -rf "$FILES_DIR"
mkdir -p "$FILES_DIR"

cat > "$SNAPSHOT_FILE" <<HEADER
# Reproduzierbarkeits-Snapshot — Backstage IDP

Dieser Snapshot wurde automatisch aus dem lokalen Projektverzeichnis erzeugt.

Projektpfad:

\`\`\`text
$PROJECT_ROOT
\`\`\`

Erzeugt am:

\`\`\`text
$(date -Iseconds)
\`\`\`

HEADER

{
  echo ""
  echo "## 1. Betriebssystem"
  echo ""
  echo '```text'
  lsb_release -a 2>/dev/null || cat /etc/os-release
  echo '```'

  echo ""
  echo "## 2. Benutzer und Arbeitsverzeichnis"
  echo ""
  echo '```text'
  whoami
  pwd
  echo '```'

  echo ""
  echo "## 3. Tool-Versionen"
  echo ""
  echo '```text'
  echo "node: $(node --version 2>/dev/null || echo 'nicht installiert')"
  echo "npm: $(npm --version 2>/dev/null || echo 'nicht installiert')"
  echo "yarn: $(yarn --version 2>/dev/null || echo 'nicht installiert')"
  echo "git: $(git --version 2>/dev/null || echo 'nicht installiert')"
  echo "docker: $(docker --version 2>/dev/null || echo 'nicht installiert')"
  echo "gh: $(gh --version 2>/dev/null | head -1 || echo 'nicht installiert')"
  echo "kubectl: $(kubectl version --client 2>/dev/null | head -1 || echo 'nicht installiert')"
  echo "helm: $(helm version --short 2>/dev/null || echo 'nicht installiert')"
  echo "az: $(az version 2>/dev/null | head -5 || echo 'nicht installiert')"
  echo '```'

  echo ""
  echo "## 4. Git-Zustand"
  echo ""
  echo '```text'
  echo "Repository Root:"
  git rev-parse --show-toplevel
  echo ""
  echo "Branch:"
  git branch --show-current
  echo ""
  echo "Status:"
  git status -sb
  echo ""
  echo "Remote:"
  git remote -v
  echo ""
  echo "Letzte Commits:"
  git log --oneline --decorate -20
  echo ""
  echo "Tags:"
  git tag --sort=-creatordate | head -20
  echo '```'

  echo ""
  echo "## 5. Projektstruktur"
  echo ""
  echo '```text'
  find . \
    -maxdepth 4 \
    -path './node_modules' -prune -o \
    -path './.git' -prune -o \
    -path './packages/backend/data' -prune -o \
    -print | sort
  echo '```'

  echo ""
  echo "## 6. Backstage-spezifische Dateien"
  echo ""
  echo '```text'
  find . \
    -path './node_modules' -prune -o \
    -path './.git' -prune -o \
    \( -name 'app-config*.yaml' \
       -o -name 'catalog-info.yaml' \
       -o -name 'package.json' \
       -o -name 'Dockerfile' \
       -o -name 'docker-compose*.yml' \
       -o -name 'template.yaml' \
       -o -name '*.sh' \
       -o -name '*.md' \
       -o -name '*.yaml' \
       -o -name '*.yml' \) \
    -print | sort
  echo '```'
} >> "$SNAPSHOT_FILE"

# Relevante Dateien für den technischen Anhang kopieren
FILES_TO_COPY=(
  "package.json"
  "app-config.yaml"
  "app-config.local.yaml"
  "app-config.production.yaml"
  "catalog-info.yaml"
  "Dockerfile"
  "docker-compose.yml"
  ".gitignore"
  "scripts/start-backstage-with-github.sh"
  "scripts/check-scaffolder-v2.sh"
  "packages/app/templates/azure-devops-service-template/template.yaml"
  "packages/app/templates/ado-repository-template/template.yaml"
  "packages/app/templates/ado-pipeline-bootstrap-template/template.yaml"
  "packages/app/templates/ado-permission-request-template/template.yaml"
  "docs/checkpoints/stable-github-publish-v1.md"
)

for file in "${FILES_TO_COPY[@]}"; do
  if [ -f "$file" ]; then
    target="$FILES_DIR/$file"
    mkdir -p "$(dirname "$target")"
    cp "$file" "$target"
  fi
done

# Catalog-Dateien kopieren, falls vorhanden
if [ -d "catalog" ]; then
  mkdir -p "$FILES_DIR/catalog"
  cp -R catalog "$FILES_DIR/"
fi

# Template-Skeletons kopieren, falls vorhanden
if [ -d "packages/app/templates" ]; then
  mkdir -p "$FILES_DIR/packages/app"
  cp -R packages/app/templates "$FILES_DIR/packages/app/"
fi

# Sicherheitsprüfung: Es dürfen keine GitHub Tokens im Repo stehen
{
  echo ""
  echo "## 7. Sicherheitsprüfung auf versehentliche Tokens"
  echo ""
  echo '```text'
  if grep -R "ghp_\|gho_\|github_pat_" \
      app-config.yaml \
      app-config.production.yaml \
      catalog-info.yaml \
      packages/app/templates \
      scripts \
      docs 2>/dev/null; then
    echo "WARNUNG: Potenzieller GitHub Token gefunden."
  else
    echo "OK: Keine offensichtlichen GitHub Tokens in den geprüften Projektdateien gefunden."
  fi
  echo '```'
} >> "$SNAPSHOT_FILE"

# Technischen Dateianhang erzeugen
APPENDIX_FILE="$OUTPUT_DIR/file-appendix.md"

cat > "$APPENDIX_FILE" <<'HEADER'
# Dateianhang — Backstage IDP

Dieser Anhang enthält die wichtigsten Dateien des aktuellen Projektstands.
Die Inhalte wurden automatisch aus dem Repository exportiert.

HEADER

while IFS= read -r file; do
  if [ -f "$file" ]; then
    {
      echo ""
      echo "## Datei: $file"
      echo ""
      echo '```'
      cat "$file"
      echo '```'
    } >> "$APPENDIX_FILE"
  fi
done < <(
  find "$FILES_DIR" -type f | sort
)

echo "OK: Snapshot erzeugt:"
echo "$SNAPSHOT_FILE"
echo "$APPENDIX_FILE"
