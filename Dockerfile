# --- STAGE 1: Build ---
    FROM node:20-alpine AS builder 
    WORKDIR /app
    
    # Install dependencies (pnpm example)
    RUN npm install -g pnpm
    COPY package.json pnpm-lock.yaml* ./
    RUN pnpm install
    
    # Copy source and build
    COPY . .
    RUN pnpm run build 
    
    # --- STAGE 2: Run ---
    FROM node:20-alpine AS runner
    WORKDIR /app
    
    ENV NODE_ENV=production
    
    # Now Docker knows what "builder" refers to
    COPY --from=builder /app/.medusa/server /app
    COPY --from=builder /app/medusa-config.js /app/medusa-config.js
    COPY --from=builder /app/package.json /app/package.json
    COPY --from=builder /app/node_modules /app/node_modules
    
    EXPOSE 9000
    
    CMD ["node", "index.mjs"]