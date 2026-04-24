FROM node:20-alpine AS builder

WORKDIR /app

RUN corepack enable

COPY package.json pnpm-lock.yaml .npmrc ./

RUN pnpm install --no-frozen-lockfile

COPY . .

RUN pnpm build


FROM node:20-alpine AS runner

WORKDIR /app

ENV NODE_ENV=production
ENV PORT=9000

RUN corepack enable

COPY --from=builder /app/.medusa/server ./

RUN pnpm install --prod --no-frozen-lockfile

EXPOSE 9000

CMD ["sh", "-c", "pnpm predeploy && pnpm start"]
