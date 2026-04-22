# --- STAGE 1: Build ---
    FROM node:20-alpine AS builder

    # Set the working directory
    WORKDIR /app
    
    # Install pnpm and necessary build tools for native modules
    RUN npm install -g pnpm && apk add --no-cache python3 make g++
    
    # Copy dependency files first for better caching
    COPY package.json pnpm-lock.yaml* ./
    
    # Install ALL dependencies (including devDependencies needed for build)
    # --unsafe-perm ensures that post-install scripts (like @swc/core) run correctly
    RUN pnpm install --frozen-lockfile --unsafe-perm
    
    # Copy the rest of your application source code
    COPY . .
    
    # Build the Medusa backend
    # Note: Added --backend-only to avoid the dashboard build error you hit earlier.
    # If you want the dashboard included, ensure @medusajs/dashboard is in package.json
    RUN npx medusa build --backend-only
    
    # --- STAGE 2: Runtime ---
    FROM node:20-alpine AS runner
    
    # Set production environment
    ENV NODE_ENV=production
    WORKDIR /app
    
    # 1. Copy the compiled server artifacts from the builder
    # Medusa v2 puts the entry point (index.mjs) in .medusa/server
    COPY --from=builder /app/.medusa/server /app
    
    # 2. Copy the configuration files (CRITICAL: Medusa needs these at runtime)
    COPY --from=builder /app/medusa-config.js /app/medusa-config.js
    COPY --from=builder /app/package.json /app/package.json
    
    # 3. Copy the installed node_modules
    COPY --from=builder /app/node_modules /app/node_modules
    
    # Expose the default Medusa port
    EXPOSE 9000
    
    # Start the server using the compiled ESM entry point
    CMD ["node", "index.mjs"]