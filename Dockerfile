# ---------- Stage 1: Builder ----------
FROM node:18-alpine AS builder
WORKDIR /workspace

# Enable corepack and yarn
RUN corepack enable && corepack prepare yarn@stable --activate

# Copy all files
COPY . .

# Install dependencies (Yarn 4 way)
RUN yarn install --immutable

# Build TypeScript & packages
RUN yarn tsc

# Build backend bundle
RUN yarn workspace backend build
RUN yarn workspace backend bundle

# ---------- Stage 2: Runner ----------
FROM node:18-alpine
WORKDIR /app
ENV NODE_ENV=production
ENV PORT=7007

# Copy only the backend artifact
COPY --from=builder /workspace/packages/backend/dist ./packages/backend/dist
COPY --from=builder /workspace/packages/backend/package.json ./packages/backend/package.json
COPY --from=builder /workspace/package.json ./package.json
COPY --from=builder /workspace/yarn.lock ./yarn.lock

RUN corepack enable && corepack prepare yarn@stable --activate

# Install only production deps for backend
RUN yarn workspaces focus backend --production

EXPOSE 7007
CMD ["node", "packages/backend/dist/index.cjs"]