# Build stage
FROM node:20-alpine AS builder
WORKDIR /app

# Install dependencies
COPY package*.json ./
RUN npm install

# Copy source code
COPY . .

# Generate Prisma Client
RUN npx prisma generate

# Build application
RUN npm run build && ls -la /app

# Production stage
FROM node:20-alpine AS production
WORKDIR /app

# Copy built assets and necessary files
COPY --from=builder /app .
# Set environment variables
ENV NODE_ENV=production

# Install production dependencies
RUN npm install --only=production

# Expose the port
EXPOSE 3000

# Create start script
RUN echo '#!/bin/sh' > /app/start.sh && \
    echo 'npx prisma migrate deploy' >> /app/start.sh && \
    echo 'npm start' >> /app/start.sh && \
    chmod +x /app/start.sh

# Start the application
CMD ["/app/start.sh"]