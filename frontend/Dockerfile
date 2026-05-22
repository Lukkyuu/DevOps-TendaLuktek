# Build stage
FROM node:20-alpine AS build
WORKDIR /app

# Copy package files and install dependencies
COPY package*.json ./
RUN npm install

# Copy application files and build static assets
COPY . .
RUN npm run build

# Run stage
FROM nginx:alpine

# Copy compiled static files
COPY --from=build /app/dist /usr/share/nginx/html

# Copy the Nginx template configuration
# The official Nginx docker entrypoint will automatically process this template,
# replace environment variables (like ${BACKEND_HOST}), and output to /etc/nginx/conf.d/default.conf
COPY nginx.conf.template /etc/nginx/templates/default.conf.template

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
