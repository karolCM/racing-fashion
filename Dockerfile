FROM node:20-alpine AS builder
WORKDIR /app

RUN npm install -g pnpm

COPY package.json pnpm-lock.yaml .npmrc* ./
RUN pnpm install --frozen-lockfile

COPY . .
RUN pnpm run build

FROM node:20-alpine
WORKDIR /app

RUN npm install -g pnpm

COPY --from=builder /app/.medusa/server /app
COPY --from=builder /app/node_modules /app/node_modules

EXPOSE 9000

CMD ["node", "index.mjs"]
