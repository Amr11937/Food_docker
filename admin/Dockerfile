# Use Node.js as the base image
FROM node:18-alpine

# Set working directory inside container
WORKDIR /app

# Copy package files first (for better caching)
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy rest of the project files
COPY . .

# Expose the frontend port
EXPOSE 5174

# Start the dev server (Vite default)
CMD ["npm", "run", "dev", "--", "--host", "--port", "5174"]