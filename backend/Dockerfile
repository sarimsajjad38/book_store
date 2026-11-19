# Production Multi-Stage or Slim Node.js 18 Container
FROM node:18-alpine

# Set working directory
WORKDIR /app

# Set production environment
ENV NODE_ENV=production

# Install production dependencies first (layer caching)
COPY package*.json ./
RUN npm ci --omit=dev

# Copy application source
COPY . .

# Ensure upload directory exists with proper permissions
RUN mkdir -p uploads/covers && chown -R node:node /app

# Switch to non-root node user for container security
USER node

# Expose standard container port (can be overridden by cloud platform)
EXPOSE 5001

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:5001/health || exit 1

CMD ["node", "server.js"]
