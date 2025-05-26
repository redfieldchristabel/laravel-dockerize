#!/bin/bash

# Laravel Docker Scaffold Initializer
# Run with: bash -c "$(curl -fsSL https://raw.githubusercontent.com/redfieldchristabel/laravel-dockerize/main/scaffold/setup.sh)"

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Check for curl and docker
command -v curl >/dev/null 2>&1 || { echo -e "${RED}Error: curl is required but not installed.${NC}"; exit 1; }
command -v docker >/dev/null 2>&1 || { echo -e "${RED}Error: docker is required but not installed.${NC}"; exit 1; }

# Check if current directory is a Laravel project
if [ ! -f "artisan" ] || [ ! -d "app" ]; then
    echo -e "${RED}Error: This is not a Laravel project. Please run in a Laravel project directory (must contain 'artisan' and 'app/').${NC}"
    exit 1
fi

# Create docker directories
mkdir -p docker/nginx/conf docker/nginx/include docker/php

# Base URL for scaffold files
BASE_URL="https://raw.githubusercontent.com/redfieldchristabel/laravel-dockerize/main/scaffold"

# Download scaffold files
echo -e "${GREEN}Downloading scaffold files...${NC}"
curl -fsSL "$BASE_URL/tools/art" -o art && chmod +x art
curl -fsSL "$BASE_URL/tools/cmpsr" -o cmpsr && chmod +x cmpsr
curl -fsSL "$BASE_URL/tools/pint" -o pint && chmod +x pint
curl -fsSL "$BASE_URL/tools/nd" -o nd && chmod +x nd
curl -fsSL "$BASE_URL/tools/iart" -o iart && chmod +x iart

curl -fsSL "$BASE_URL/composes/docker-compose.yml" -o docker-compose.yml
curl -fsSL "$BASE_URL/composes/build.docker-compose.yml" -o build.docker-compose.yml
curl -fsSL "$BASE_URL/composes/prod.docker-compose.yml" -o prod.docker-compose.yml

curl -fsSL "$BASE_URL/dockerfiles/Dockerfile" -o Dockerfile
curl -fsSL "$BASE_URL/dockerfiles/cli.Dockerfile" -o cli.Dockerfile
curl -fsSL "$BASE_URL/dockerfiles/nginx.Dockerfile" -o nginx.Dockerfile
curl -fsSL "$BASE_URL/dockerfiles/vite.Dockerfile" -o vite.Dockerfile

curl -fsSL "$BASE_URL/php/file.ini" -o docker/php/file.ini
curl -fsSL "$BASE_URL/nginx/conf/app.conf" -o docker/nginx/conf/app.conf
curl -fsSL "$BASE_URL/nginx/include/fpm-handler.conf" -o docker/nginx/include/fpm-handler.conf

# Copy .env.example to .env if .env doesn't exist
if [ ! -f ".env" ]; then
    cp .env.example .env
    echo -e "${GREEN}Created .env from .env.example${NC}"
fi

# Update vite.config.js to set server.host to 0.0.0.0
if [ -f "vite.config.js" ]; then
    echo -e "${GREEN}Checking vite.config.js for server host configuration...${NC}"
    if grep -q "server:" vite.config.js; then
        sed -i '/server: {/,/}/ s/host: "[^"]*"/host: "0.0.0.0"/' vite.config.js
        echo -e "${GREEN}Updated server.host to 0.0.0.0 in vite.config.js${NC}"
    else
        sed -i "/^});/i \ \ \ \ server: {\n\ \ \ \ \ \ \ \ host: \"0.0.0.0\"\n\ \ \ \ }," vite.config.js
        echo -e "${GREEN}Added server.host: 0.0.0.0 to vite.config.js${NC}"
    fi
else
    echo -e "${RED}vite.config.js not found. Skipping server host configuration.${NC}"
fi

echo -e "${GREEN}Laravel Docker scaffold initialized successfully!${NC}"