# Use Node.js 18 LTS as the base image
FROM node:20

# Set working directory
WORKDIR /app

# Copy package.json and package-lock.json first (if available)
COPY backend/package*.json ./

# Ensure npm is up to date
RUN npm install -g npm@latest

# Install dependencies
RUN npm install --legacy-peer-deps

# Copy the entire application (after dependencies are installed)
COPY . .

# Expose the port
EXPOSE 3000

# Start the application
CMD ["node", "index.js"]
