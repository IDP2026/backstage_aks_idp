# ---- Builder ----
FROM node:22-bookworm-slim AS builder

ENV PYTHON=/usr/bin/python3
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 g++ build-essential \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Enable yarn via corepack
RUN corepack enable

# Copy only what we need first (better cache)
COPY package.json yarn.lock .yarnrc.yml backstage.json ./
COPY .yarn ./.yarn
COPY packages ./packages
COPY plugins ./plugins
COPY examples ./examples
COPY app-config*.yaml ./

# Install deps
RUN yarn install --immutable

# Build backend bundle (what we need for runtime image)
RUN yarn build:backend

# ---- Runtime ----
FROM node:22-bookworm-slim

ENV NODE_ENV=production
ENV NODE_OPTIONS="--no-node-snapshot"
WORKDIR /app

# Enable yarn via corepack (for workspace focus)
RUN corepack enable

# Copy yarn setup and skeleton/bundle artifacts
COPY --from=builder /app/package.json /app/yarn.lock /app/.yarnrc.yml /app/backstage.json ./
COPY --from=builder /app/.yarn ./.yarn
COPY --from=builder /app/packages/backend/dist ./packages/backend/dist
COPY --from=builder /app/app-config*.yaml ./

# Install only production deps
RUN yarn workspaces focus --all --production

EXPOSE 7007
CMD ["node", "packages/backend", "--config", "app-config.yaml", "--config", "app-config.production.yaml"]
