# ---- Builder ----
FROM node:22-bookworm-slim AS builder

ENV PYTHON=/usr/bin/python3
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 g++ build-essential \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app
RUN corepack enable

COPY package.json yarn.lock .yarnrc.yml backstage.json ./
COPY .yarn ./.yarn
COPY packages ./packages
COPY plugins ./plugins
COPY examples ./examples
COPY app-config*.yaml ./

RUN yarn install --immutable
RUN yarn build:backend

# ---- Runtime ----
FROM node:22-bookworm-slim

ENV NODE_ENV=production
ENV NODE_OPTIONS="--no-node-snapshot"
WORKDIR /app
RUN corepack enable

COPY package.json yarn.lock .yarnrc.yml backstage.json ./
COPY .yarn ./.yarn
COPY packages/backend/dist ./packages/backend/dist
COPY app-config*.yaml ./

RUN yarn workspaces focus --all --production

EXPOSE 7007
CMD ["node", "packages/backend", "--config", "app-config.yaml", "--config", "app-config.production.yaml"]
