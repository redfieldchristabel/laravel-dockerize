[![Build and Push Laravel Images to GHCR](https://github.com/redfieldchristabel/laravel-dockerize/actions/workflows/build-and-push.yml/badge.svg)](https://github.com/redfieldchristabel/laravel-dockerize/actions/workflows/build-and-push.yml)

# Laravel-Optimized PHP Images

This repository provides pre-built PHP container images optimized for Laravel development, hosted on the GitHub Container Registry (GHCR). These images streamline your Laravel project setup by including the essential PHP extensions required for Laravel, reducing build times and simplifying your development and CI/CD workflows.

## Why Use These Images?

Official PHP images from Docker Hub require manual installation of PHP extensions in your `Dockerfile` or `docker-compose.yml`, which can slow down development and CI/CD pipelines. These images come pre-configured with the minimum PHP extensions needed for a fresh Laravel application (based on Laravel 11 requirements), allowing you to:

- **Accelerate Development**: Get your local environment running quickly with minimal setup.
- **Optimize CI/CD**: Reduce build times by avoiding repetitive extension installations.
- **Simplify Configuration**: Use pre-installed extensions and sensible defaults tailored for Laravel.

While these images cover Laravel’s core requirements, you may need to install additional extensions for specific project dependencies (e.g., `imagick`, `pgsql`). This README provides guidance on customizing the images using a lightweight Dockerfile.

## Image Features

### Based on Official PHP Images

These images are built on top of official PHP images from Docker Hub, ensuring compatibility and reliability. They follow standard PHP tagging conventions for easy integration.

### Supported Versions and Variants

We support PHP versions `8.1`, `8.2`, `8.3`, and `8.4`. Tags use major and minor versions (e.g., `8.3`, not `8.3.1`) to provide the latest security patches and bug fixes via daily builds, avoiding breaking changes from specific patch versions. Major version tags (e.g., `8`) point to the latest minor version (e.g., `8.3` as of now).

Available variants for each PHP version:

- `cli`: Command Line Interface PHP (Debian base), ideal for Artisan commands, scripts, or cron jobs.
- `fpm`: PHP-FPM (Debian base), designed for web servers like Nginx or Apache.
- `cli-alpine`: CLI PHP (Alpine Linux base), smaller image size for lightweight environments.
- `fpm-alpine`: PHP-FPM (Alpine Linux base), smaller image size for web servers.

### Filament-Optimized Images

For projects using the Filament PHP framework, we offer images tailored for `php artisan filament` commands. These include Filament-specific dependencies and configurations. Use the `-filament` suffix, e.g.:

- `ghcr.io/redfieldchristabel/laravel:8.3-cli-filament`
- `ghcr.io/redfieldchristabel/laravel:8.3-fpm-alpine-filament`

### Pre-Installed PHP Extensions

The images include the minimum extensions required by Laravel 11:

- **Required**: `bcmath`, `ctype`, `fileinfo`, `json`, `mbstring`, `openssl`, `pdo`, `pdo_mysql`, `tokenizer`, `xml`

Additional extensions (e.g., `gd`, `imagick`, `redis`) are not included but can be added via a custom Dockerfile (see Customizing the Images).

### Exposed Ports

- `fpm` **variants**: Expose port 9000 for PHP-FPM, compatible with web servers like Nginx.
- `cli` **variants**: Do not expose ports, as they’re meant for command-line tasks (e.g., `php artisan`).

### Default Entrypoint

Each image includes a default entrypoint to simplify usage:

- `cli` **variants**: `/usr/local/bin/docker-entrypoint-cli.sh` runs `php` with your command (e.g., `php artisan queue:work`).
- `fpm` **variants**: `/usr/local/bin/docker-entrypoint-fpm.sh` starts PHP-FPM.

These entrypoints handle environment setup (e.g., permissions, PHP configuration) and run `composer install` automatically on first startup. This ensures dependencies are installed without manual intervention. In development, the `/var/www/vendor` directory is mounted, so subsequent updates via `composer update` are fast. In production, only `/var/www/vendor` is mounted to optimize security (see Production Deployment). Most Laravel applications don’t need a custom entrypoint.

## Getting Started

The images are available at `ghcr.io/redfieldchristabel/laravel`. Pull them using Docker or reference them in your `Dockerfile` or `docker-compose.yml`.

### Development Environment with Docker Compose

For local development, use the following `docker-compose.yml` to set up a Laravel environment with volume mounts for your codebase, allowing real-time code changes. This setup includes core services (`app`, `nginx`, `mysql`, `redis`), a queue worker, a scheduler, and optional tools (`mailpit`, `phpmyadmin`). Environment variables are loaded from your Laravel `.env` file.

```yaml
version: '3.8'

services:
  app:
    image: ghcr.io/redfieldchristabel/laravel:8.3-fpm
    volumes:
      - .:/var/www # Mount host codebase for live edits
      - ./docker/php/php.ini:/usr/local/etc/php/conf.d/custom.ini # Custom PHP settings
    depends_on:
      - mysql
      - redis
    env_file:
      - .env

  queue:
    image: ghcr.io/redfieldchristabel/laravel:8.3-cli
    command: ["php", "artisan", "queue:work", "--queue=high,default"]
    volumes:
      - .:/var/www
      - ./docker/php/php.ini:/usr/local/etc/php/conf.d/custom.ini
    depends_on:
      - app
      - mysql
      - redis
    env_file:
      - .env

  scheduler:
    image: ghcr.io/redfieldchristabel/laravel:8.3-cli
    command: ["php", "artisan", "schedule:work"]
    volumes:
      - .:/var/www
      - ./docker/php/php.ini:/usr/local/etc/php/conf.d/custom.ini
    depends_on:
      - app
      - mysql
      - redis
    env_file:
      - .env

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
    volumes:
      - .:/var/www # Mount codebase for static files
      - ./docker/nginx/nginx.conf:/etc/nginx/conf.d/default.conf # Custom Nginx config
      - ./docker/nginx/include:/etc/nginx/include # Include files
    depends_on:
      - app

  mysql:
    image: mysql:8.0
    volumes:
      - mysql-data:/var/lib/mysql
    env_file:
      - .env
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      interval: 10s
      retries: 3
      timeout: 5s

  redis:
    image: redis:alpine
    volumes:
      - redis-data:/data
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      retries: 3
      timeout: 5s

  mailpit:
    image: axllent/mailpit
    ports:
      - "8025:8025" # Web UI
      - "1025:1025" # SMTP
    environment:
      MP_MAX_MESSAGES: 5000
      MP_SMTP_AUTH_ACCEPT_ANY: 1
      MP_SMTP_AUTH_ALLOW_INSECURE: 1

  phpmyadmin:
    image: phpmyadmin
    ports:
      - "8081:80"
    environment:
      PMA_HOST: mysql
    depends_on:
      - mysql

volumes:
  mysql-data:
  redis-data:
```

**Usage**:

1. Save the above as `docker-compose.yml` in your Laravel project root.
2. Create a `.env` file with Laravel settings (e.g., `DB_HOST=mysql`, `REDIS_HOST=redis`, `DB_DATABASE=laravel`).
3. Create a `docker/php/php.ini` file for custom PHP settings (e.g., `memory_limit = 256M`).
4. Create a `docker/nginx/nginx.conf` file and `docker/nginx/include/fpm-handler.conf` (examples below).
5. Run `docker-compose up -d` to start the services.
6. Access your app at `http://localhost` (Nginx) and phpMyAdmin at `http://localhost:8081`.

**Example** `docker/nginx/nginx.conf`:

```nginx
server {
    listen 80 default_server;
    server_name localhost;
    client_max_body_size 120M;

    access_log /dev/stderr;
    error_log /dev/stderr;

    root /var/www/public;
    index index.php;

    # Remove trailing slash
    location ~ ^(.+)/$ {
        return 301 $1$is_args$args;
    }

    # Serve static files
    location ~* \.(css|js|gif|jpeg|jpg|png|webp|woff2|woff|ico)$ {
        root /var/www/public;
        add_header X-Serve-Type 'static';
    }

    # Soketi WebSocket
    location /app {
        proxy_pass http://soketi:6001;
        proxy_read_timeout 60;
        proxy_connect_timeout 60;
        proxy_redirect off;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }

    location / {
        include include/fpm-handler.conf;
    }
}
```

**Example** `docker/nginx/include/fpm-handler.conf`:

```nginx
add_header X-Serve-Type 'php';
add_header X-Serve-Uri '$uri';
fastcgi_pass app:9000;
fastcgi_index index.php;
include fastcgi_params;
fastcgi_param SCRIPT_FILENAME $document_root/index.php;
fastcgi_param PATH_INFO $fastcgi_path_info;
```

**Notes**:

- The `app` service uses `8.3-fpm` for a production-like setup with Nginx. For simpler development, switch to `8.3-cli` with `command: php artisan serve --host 0.0.0.0 --port 8000` and expose port `8000`.
- The `queue` and `scheduler` services use `8.3-cli` for background tasks.
- Volume mounts (`.:/var/www`) sync your host codebase, including `/var/www/vendor`, for live edits and fast `composer update` in development.
- Use `.env` for Laravel settings (e.g., `DB_HOST=mysql`, `DB_CONNECTION=mysql`, `DB_USERNAME=laravel`).

### Customizing the Images

You may need to install additional PHP extensions or modify PHP settings for your project. Use a lightweight Dockerfile to extend the base image, or adjust settings via volume mounts.

#### Installing Additional Extensions

To install extensions like `imagick` or `pgsql`, create a `Dockerfile` in your project root. The default entrypoint runs `composer install`, so you don’t need to include it in the Dockerfile. In development, the `/var/www/vendor` mount ensures updates are fast. In production, only `/var/www/vendor` is mounted to optimize security (see Production Deployment).

**Example** `Dockerfile` **(Alpine-based)**:

```dockerfile
FROM ghcr.io/redfieldchristabel/laravel:8.3-cli-alpine

RUN apk add --no-cache imagemagick-dev && \
    pecl install imagick && \
    docker-php-ext-enable imagick && \
    rm -rf /var/cache/apk/*
```

**Example** `Dockerfile` **(Debian-based)**:

```dockerfile
FROM ghcr.io/redfieldchristabel/laravel:8.3-cli

RUN apt-get update && apt-get install -y libpq-dev && \
    docker-php-ext-install pgsql && \
    apt-get clean && rm -rf /var/lib/apt/lists/*
```

**Usage**:

1. Save the `Dockerfile` in your project root.
2. Update `docker-compose.yml` to build the image:

   ```yaml
   services:
     app:
       build:
         context: .
         dockerfile: Dockerfile
       volumes:
         - .:/var/www
   ```
3. Run `docker-compose up -d --build`.

#### Modifying PHP Settings

To customize `php.ini` (e.g., increase `memory_limit`):

1. Create a `docker/php/php.ini` file:

   ```ini
   memory_limit = 256M
   upload_max_filesize = 64M
   ```
2. Mount it in `docker-compose.yml`:

   ```yaml
   volumes:
     - ./docker/php/php.ini:/usr/local/etc/php/conf.d/custom.ini
   ```

**Note**: Avoid modifying the image’s default entrypoint unless necessary, as `docker-entrypoint-cli.sh` and `docker-entrypoint-fpm.sh` handle Laravel’s environment setup (e.g., permissions, FPM startup, `composer install`).

### Production Deployment

For production, use the `fpm` or `fpm-alpine` variants with Nginx, and mount only the `/var/www/vendor` directory to include dependencies while keeping the container secure. Below are two `docker-compose.yml` examples: one for a standard setup and another using a Kong API Gateway for advanced routing and security.

#### Production Docker Compose (Standard)

```yaml
version: '3.8'

services:
  app:
    image: ghcr.io/redfieldchristabel/laravel:8.3-fpm
    volumes:
      - ./vendor:/var/www/vendor # Mount only vendor for dependencies
      - ./docker/php/php.ini:/usr/local/etc/php/conf.d/custom.ini
    depends_on:
      - mysql
      - redis
    env_file:
      - .env.production
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:9000"]
      interval: 30s
      retries: 3
      timeout: 10s

  queue:
    image: ghcr.io/redfieldchristabel/laravel:8.3-cli
    command: ["php", "artisan", "queue:work", "--queue=high,default"]
    volumes:
      - ./vendor:/var/www/vendor
      - ./docker/php/php.ini:/usr/local/etc/php/conf.d/custom.ini
    depends_on:
      - app
      - mysql
      - redis
    env_file:
      - .env.production

  scheduler:
    image: ghcr.io/redfieldchristabel/laravel:8.3-cli
    command: ["php", "artisan", "schedule:work"]
    volumes:
      - ./vendor:/var/www/vendor
      - ./docker/php/php.ini:/usr/local/etc/php/conf.d/custom.ini
    depends_on:
      - app
      - mysql
      - redis
    env_file:
      - .env.production

  nginx:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./public:/var/www/public # Mount public directory for static files
      - ./docker/nginx/nginx.conf:/etc/nginx/conf.d/default.conf
      - ./docker/nginx/include:/etc/nginx/include
    depends_on:
      - app

  mysql:
    image: mysql:8.0
    volumes:
      - mysql-data:/var/lib/mysql
    env_file:
      - .env.production
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      interval: 30s
      retries: 3
      timeout: 10s

  redis:
    image: redis:alpine
    volumes:
      - redis-data:/data
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 30s
      retries: 3
      timeout: 10s

volumes:
  mysql-data:
  redis-data:
```

#### Production Docker Compose (with Kong API Gateway)

This example places the application behind a Kong API Gateway for routing, authentication, and rate-limiting, with Nginx as the backend server.

```yaml
version: '3.8'

services:
  app:
    image: ghcr.io/redfieldchristabel/laravel:8.3-fpm
    volumes:
      - ./vendor:/var/www/vendor
      - ./docker/php/php.ini:/usr/local/etc/php/conf.d/custom.ini
    depends_on:
      - mysql
      - redis
    networks:
      - default
    env_file:
      - .env.production
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:9000"]
      interval: 30s
      retries: 3
      timeout: 10s

  queue:
    image: ghcr.io/redfieldchristabel/laravel:8.3-cli
    command: ["php", "artisan", "queue:work", "--queue=high,default"]
    volumes:
      - ./vendor:/var/www/vendor
      - ./docker/php/php.ini:/usr/local/etc/php/conf.d/custom.ini
    depends_on:
      - app
      - mysql
      - redis
    networks:
      - default
    env_file:
      - .env.production

  scheduler:
    image: ghcr.io/redfieldchristabel/laravel:8.3-cli
    command: ["php", "artisan", "schedule:work"]
    volumes:
      - ./vendor:/var/www/vendor
      - ./docker/php/php.ini:/usr/local/etc/php/conf.d/custom.ini
    depends_on:
      - app
      - mysql
      - redis
    networks:
      - default
    env_file:
      - .env.production

  nginx:
    image: nginx:alpine
    volumes:
      - ./public:/var/www/public
      - ./docker/nginx/nginx.conf:/etc/nginx/conf.d/default.conf
      - ./docker/nginx/include:/etc/nginx/include
    depends_on:
      - app
    networks:
      - default
      - kong

  mysql:
    image: mysql:8.0
    volumes:
      - mysql-data:/var/lib/mysql
    networks:
      - default
    env_file:
      - .env.production
    healthcheck:
      test: ["CMD", "mysqladmin", "ping", "-h", "localhost"]
      interval: 30s
      retries: 3
      timeout: 10s

  redis:
    image: redis:alpine
    volumes:
      - redis-data:/data
    networks:
      - default
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 30s
      retries: 3
      timeout: 10s
    

volumes:
  vendor:
  storage:
  public:
  published:
  redis:

networks:
  default:
  kong:
    external: true
```

**Example** `docker/kong/kong.yml`:

```yaml
_format_version: "3.0"
services:
  - name: laravel-app
    url: http://nginx:80
    routes:
      - name: laravel-route
        paths:
          - /
```

**Production Usage**:

1. Run `composer install --no-dev --optimize-autoloader` locally to generate the `vendor` directory.
2. Copy `vendor`, `public`, `docker/`, and `.env.production` to the production server.
3. For Kong, create `docker/kong/kong.yml` to define routes.
4. Use `docker-compose.yml` (standard or Kong) and run `docker-compose up -d`.
5. Access the app at `http://<server-ip>` (standard) or via Kong’s proxy port.

**Notes**:

- The standard setup exposes Nginx directly on port 80.
- The Kong setup uses Kong as an API gateway, proxying requests to Nginx. Configure Kong routes in `kong.yml` for authentication or rate-limiting.
- Use `.env.production` for settings (e.g., `APP_ENV=production`, `DB_HOST=mysql`).
- Mount only `/var/www/vendor` and `/var/www/public` to minimize attack surface.
- Add healthchecks to ensure service reliability.

## Support and Contributions

For issues or feature requests, create a GitHub issue in the `redfieldchristabel/laravel-dockerize` repository. Contributions are welcome via pull requests.

Happy developing with Laravel!