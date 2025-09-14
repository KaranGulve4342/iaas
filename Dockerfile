# Multi-stage Dockerfile for Node.js IAAS application

# Base image with Node.js 20 (required for @neondatabase/serverless)
FROM node:20-alpine AS base

# Set working directory
WORKDIR /app

# Copy Package files
COPY package*.json ./

# Generate package-lock.json if it doesn't exist, then install dependencies
RUN if [ ! -f package-lock.json ]; then npm install --package-lock-only; fi && \
    npm ci --only=production && \
    npm cache clean --force

# Copy source code
COPY . .

# Create non-root user for security
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# Change ownership of the app directory
RUN chown -R nodejs:nodejs /app
USER nodejs

# Expose the PORT
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD node -e "require('http').get('http://localhost:3000/health', (res) => { process.exit(res.statusCode === 200 ? 0 : 1) }).on('error', () => { process.exit(1)})"

# Development stage
FROM base AS development
USER root
RUN npm ci && npm cache clean --force
USER nodejs
CMD ["npm", "run", "dev"]

# Production stage
FROM base AS production
CMD ["npm", "start"]