# ---------- Stage 1: Builder ----------
FROM node:18-alpine AS builder
WORKDIR /workspace
ENV YARN_CACHE_FOLDER=/workspace/.yarn-cache

COPY . .
RUN corepack enable && corepack prepare yarn@stable --activate
RUN yarn install --frozen-lockfile
RUN yarn tsc
RUN yarn build

# ---------- Stage 2: Runner ----------
FROM node:18-alpine
WORKDIR /app
ENV NODE_ENV=production
ENV PORT=7007

COPY --from=builder /workspace/packages/backend/dist ./packages/backend/dist
COPY --from=builder /workspace/packages/backend/package.json ./packages/backend/package.json
COPY --from=builder /workspace/yarn.lock ./yarn.lock
COPY --from=builder /workspace/package.json ./package.json

RUN corepack enable && corepack prepare yarn@stable --activate
RUN yarn workspaces focus @backstage/backend --production

EXPOSE 7007
CMD ["node", "packages/backend/dist/index.cjs"]
