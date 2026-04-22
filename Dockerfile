# --- STAGE 1: Build ---
    FROM node:20-alpine AS builder 
    WORKDIR /app
    
    # 1. Install pnpm and build tools for native dependencies (like @swc/core)
    RUN npm install -g pnpm && apk add --no-cache python3 make g++
    
    # 2. Copy dependency files
    COPY package.json pnpm-lock.yaml* ./
    
    # 3. Install ALL dependencies
    # --unsafe-perm is necessary for Medusa's compiler scripts to run in Alpine
    RUN pnpm install --frozen-lockfile --unsafe-perm
    
    # 4. Copy the rest of your code
    COPY . .
    
    # 5. Build the project (Backend + Admin)
    # If this fails, make sure @medusajs/dashboard is in your package.json
    RUN npx medusa build
    
    # --- STAGE 2: Run ---
    FROM node:20-alpine AS runner
    WORKDIR /app
    
    # Set to production to optimize Medusa's internal performance
    ENV NODE_ENV=production
    
    # 1. Copy the compiled backend artifacts from the .medusa/server folder
    # This includes the index.mjs entry point
    COPY --from=builder /app/.medusa/server /app
    
    # 2. Copy essential configuration and dependencies
    COPY --from=builder /app/medusa-config.js /app/medusa-config.js
    COPY --from=builder /app/package.json /app/package.json
    COPY --from=builder /app/node_modules /app/node_modules
    
    # 3. Copy the admin dashboard build (so the backend can serve it)
    COPY --from=builder /app/.medusa/client /app/.medusa/client
    
    # Expose Medusa's port
    EXPOSE 9000
    
    # Start the server
    CMD ["node", "index.mjs"]