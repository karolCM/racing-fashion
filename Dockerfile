FROM node:20-alpine AS runner
WORKDIR /app

# 1. Medusa requires a production environment flag
ENV NODE_ENV=production

# 2. Copy the compiled server artifacts
# This includes the index.mjs you are trying to run
COPY --from=builder /app/.medusa/server /app

# 3. CRITICAL: Copy the config and package.json
# Medusa's loaders look for medusa-config.js in the current WORKDIR
COPY --from=builder /app/medusa-config.js /app/medusa-config.js
COPY --from=builder /app/package.json /app/package.json

# 4. Copy dependencies
COPY --from=builder /app/node_modules /app/node_modules

EXPOSE 9000

# 5. Run the entry point
CMD ["node", "index.mjs"]