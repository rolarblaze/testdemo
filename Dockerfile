# Stage 1: Build
FROM node:20 AS builder

# Set the working directory
WORKDIR /app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies
RUN npm install --production=false 

# Copy the rest of the application code
COPY . .

# Build the Next.js app
RUN npm run build

# Stage 2: Production
FROM node:20-alpine AS runner

# Install tini
RUN apk add --no-cache tini

# Set NODE_ENV to production
ENV NODE_ENV=production

# Set the working directory
WORKDIR /app

# Copy necessary files from the builder stage
COPY --from=builder /app .

# Install only production dependencies
RUN npm ci --only=production

# Expose the port
EXPOSE 3000

# Use tini as init system to handle PID 1
ENTRYPOINT [ "/sbin/tini", "--" ]

# Start the application
CMD ["npm", "start"]