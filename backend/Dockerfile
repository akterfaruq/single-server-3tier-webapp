# Use official Node.js image
FROM node:18-slim

# Install Postgres client for running migrations
RUN apt-get update && apt-get install -y postgresql-client && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies
RUN npm install --production

# Copy the rest of the app
COPY . .

# Copy entrypoint script
COPY entrypoint.sh /app/entrypoint.sh
RUN chmod +x /app/entrypoint.sh

# Expose the port your app runs on
EXPOSE 3000

# Start the backend via entrypoint (runs migrations first)
ENTRYPOINT ["/app/entrypoint.sh"]
