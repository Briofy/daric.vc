FROM node:19.9.0-alpine AS build

# For handling Kernel signals properly
RUN apk add --no-cache git

# Set the default working directory for the app
WORKDIR /usr/src/app

# Copy package.json, package-lock.json
COPY package*.json ./

# Install dependencies.
RUN npm ci

# Necessary to run before adding application code to leverage Docker cache
RUN npm cache clean --force

# Add src project
ADD . .

# Build dist
RUN npm run build

# nginx production environment
FROM nginx:stable-alpine AS deploy

WORKDIR /usr/src/app

# Copy build directory
COPY --from=build /usr/src/app/out /usr/share/nginx/html

# copy nginx confiuration file
COPY .ci/nginx.conf /etc/nginx/conf.d/default.conf

# expose port 80
EXPOSE 3000

# Run nginx
CMD ["nginx", "-g", "daemon off;"]
