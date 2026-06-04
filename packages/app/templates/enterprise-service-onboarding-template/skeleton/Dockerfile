FROM node:22-bookworm-slim

WORKDIR /app

COPY src ./src

ENV NODE_ENV=production
ENV PORT=${{ values.containerPort }}

EXPOSE ${{ values.containerPort }}

CMD ["node", "src/index.ts"]
