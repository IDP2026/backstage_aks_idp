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
