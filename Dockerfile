FROM node:20-alpine

WORKDIR /app

ENV NODE_ENV=production
ENV HOST=0.0.0.0
ENV PORT=9000

RUN apk add --no-cache python3 make g++ && npm install -g pnpm

COPY package.json pnpm-lock.yaml .npmrc* ./

# Medusa's build needs full dependencies, including admin tooling.
RUN pnpm install --frozen-lockfile --unsafe-perm

COPY . .

RUN pnpm run build

EXPOSE 9000

CMD ["sh", "-c", "pnpm medusa db:migrate && pnpm start"]