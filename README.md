[![Build and Push Laravel Images to GHCR](https://github.com/redfieldchristabel/laravel-dockerize/actions/workflows/build-and-push.yml/badge.svg)](https://github.com/redfieldchristabel/laravel-dockerize/actions/workflows/build-and-push.yml)

# Laravel-Optimized PHP Images 🎉

Welcome to the **Laravel-Optimized PHP Images** repository! 🚀 These pre-built PHP container images, hosted on the GitHub Container Registry (GHCR), are crafted to supercharge your Laravel development. With essential PHP extensions pre-installed for Laravel 11, they slash setup time and streamline your development and CI/CD workflows. Let’s get your Laravel projects up and running faster! 😄

## Why Choose These Images? 🌟

Official PHP images from Docker Hub often require manual extension installations, slowing down your `Dockerfile` or `docker-compose.yml` setup. Our images come ready-to-go with Laravel’s core PHP extensions, offering:

- **Lightning-Fast Setup** ⚡: Spin up your local environment or CI/CD pipeline in no time.
- **Streamlined CI/CD** 🛠️: Skip repetitive extension installs to save build time.
- **Laravel-Friendly Defaults** 🐘: Pre-configured for Laravel’s needs, so you can focus on coding.

Need extra extensions like `imagick` or `pgsql`? No worries! We’ve got simple customization guides below. 🛠️

## Image Features ✨

### Built on Official PHP Images 🐳

Our images are based on official PHP images from Docker Hub, ensuring rock-solid compatibility and reliability. They follow standard PHP tagging conventions for seamless integration.

### Supported Versions and Variants 📦

We support PHP versions **8.1, 8.2, 8.3, and 8.4** (yep, we’re up to date! 🎉). Tags use major and minor versions (e.g., `8.3`, not `8.3.1`) to deliver the latest security patches and bug fixes via daily builds, avoiding breaking changes. Major version tags (e.g., `8`) point to the latest minor version (currently `8.3`).

Available variants for each PHP version:
- **cli** 🖥️: Command Line Interface PHP (Debian base), perfect for Artisan commands, scripts, or cron jobs.
- **fpm** 🌐: PHP-FPM (Debian base), ideal for web servers like Nginx or Apache.
- **cli-alpine** 🏔️: CLI PHP (Alpine Linux base), lightweight for smaller images.
- **fpm-alpine** 🏔️: PHP-FPM (Alpine Linux base), compact for web servers.

### Filament-Optimized Images 🎨

Building with the Filament PHP framework? We’ve got you covered with tailored images for `php artisan filament` commands, packed with Filament-specific dependencies. Just add the `-filament` suffix, e.g.:
- `ghcr.io/redfieldchristabel/laravel:8.3-cli-filament`
- `ghcr.io/redfieldchristabel/laravel:8.3-fpm-alpine-filament`

### Pre-Installed PHP Extensions 🔧

These images include the **minimum extensions required by Laravel 11**:
- **Required**: `bcmath`, `ctype`, `fileinfo`, `json`, `mbstring`, `openssl`, `pdo`, `pdo_mysql`, `tokenizer`, `xml`

Want more extensions like `gd`, `imagick`, or `redis`? Add them easily with a custom Dockerfile (see Customizing the Images).

### Exposed Ports 🌍

- **fpm variants** 🌐: Expose port 9000 for PHP-FPM, ready for Nginx or Apache.
- **cli variants** 🖥️: No ports exposed, designed for command-line tasks like `php artisan`.

### Default Entrypoint 🚪

Each image comes with a smart default entrypoint:
- **cli variants** 🖥️: `/usr/local/bin/docker-entrypoint-cli.sh` runs `php` with your command (e.g., `php artisan queue:work`).
- **fpm variants** 🌐: `/usr/local/bin/docker-entrypoint-fpm.sh` starts PHP-FPM.

These entrypoints handle setup (permissions, PHP config) and run `composer install` on first startup, so dependencies are ready without extra steps. In development, the `/var/www/vendor` mount keeps `composer update` fast. In production, only `/var/www/vendor` is mounted for security (see Production Deployment). Most Laravel apps don’t need a custom entrypoint! 😊

### Docker Best Practices 🐳

We follow Docker best practices to keep things clean and efficient:
- **One Process Per Container** ✅: Each container runs a single process (e.g., PHP-FPM, queue worker, scheduler), with separate containers for `app`, `queue`, and `scheduler` for optimal isolation and scalability.
- **Unified Logging** 📜: Laravel and PHP-FPM logs are redirected to Docker’s stdout, making log management a breeze with `docker logs`.

## Getting Started 🎬

Pull our images from `ghcr.io/redfieldchristabel/laravel` and use them in your `Dockerfile` or `docker-compose.yml`. Let’s dive in! 🚀

### Development Environment with Docker Compose 🛠️

Set up a Laravel dev environment with this `docker-compose.yml`, featuring volume mounts for real-time code changes. It includes core services (`app`, `nginx`, `mysql`, `redis`), a queue worker, a scheduler, and handy tools (`mailpit`, `phpmyadmin`). Environment variables load from your Laravel `.env` file.

```yaml
version: '3.8'

services:
  app:
    image: ghcr.io/redfieldchristabel/laravel:8.3-fpm
    volumes:
      - .:/var/www # Mount codebase for live edits
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

1. Save as `docker-compose.yml` in your Laravel project root.
2. Create a `.env` file with settings (e.g., `DB_HOST=mysql`, `REDIS_HOST=redis`, `DB_DATABASE=laravel`).
3. Add a `docker/php/php.ini` file for PHP settings (e.g., `memory_limit = 256M`).
4. Create `docker/nginx/nginx.conf` and `docker/nginx/include/fpm-handler.conf` (see below).
5. Run `docker-compose up -d` and visit `http://localhost` (Nginx) or `http://localhost:8081` (phpMyAdmin).

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

- Use `8.3-fpm` for `app` to mimic production with Nginx. For quick dev, swap to `8.3-cli` with `command: php artisan serve --host 0.0.0.0 --port 8000` and expose port `8000`.
- `queue` and `scheduler` use `8.3-cli` in dedicated containers, following Docker’s one-process-per-container rule.
- The `.:/var/www` mount syncs your codebase, including `/var/www/vendor`, for fast `composer update` in dev.
- Set `.env` for Laravel (e.g., `DB_HOST=mysql`, `DB_CONNECTION=mysql`, `DB_USERNAME=laravel`).

### Customizing the Images 🔧

Need extra PHP extensions or PHP tweaks? Extend the base image with a lightweight Dockerfile or use volume mounts for quick changes.

#### Installing Additional Extensions

To add extensions like `imagick` or `pgsql`, create a `Dockerfile`. The default entrypoint runs `composer install`, so skip it in the Dockerfile. Development mounts `/var/www/vendor` for fast updates, while production mounts only `/var/www/vendor` (see Production Deployment).

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

To tweak `php.ini` (e.g., boost `memory_limit`):

1. Create `docker/php/php.ini`:

   ```ini
   memory_limit = 256M
   upload_max_filesize = 64M
   ```
2. Mount it in `docker-compose.yml`:

   ```yaml
   volumes:
     - ./docker/php/php.ini:/usr/local/etc/php/conf.d/custom.ini
   ```

**Note**: Stick with the default entrypoint (`docker-entrypoint-cli.sh`, `docker-entrypoint-fpm.sh`) unless you have unique needs. They handle setup, `composer install`, and log redirection to stdout for easy monitoring! 📜

### Production Deployment 🏭

For production, use `fpm` or `fpm-alpine` with Nginx, mounting only `/var/www/vendor` for dependencies to keep containers secure. We provide two `docker-compose.yml` examples: a standard setup and one with Kong API Gateway for advanced routing and security. Each service (app, queue, scheduler) runs in its own container with logs unified to stdout, per Docker best practices.

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

This setup places your app behind a Kong API Gateway for routing, authentication, and rate-limiting, with Nginx as the backend. Each process runs in a dedicated container with logs to stdout.

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
    volumes:
      - ./public:/var/www/public
      - ./docker/nginx/nginx.conf:/etc/nginx/conf.d/default.conf
      - ./docker/nginx/include:/etc/nginx/include
    depends_on:
      - app
    networks:
      - kong

  kong:
    image: kong:latest
    environment:
      KONG_DATABASE: "off"
      KONG_PROXY_ACCESS_LOG: /dev/stdout
      KONG_ADMIN_ACCESS_LOG: /dev/stdout
      KONG_PROXY_ERROR_LOG: /dev/stderr
      KONG_ADMIN_ERROR_LOG: /dev/stderr
      KONG_ADMIN_LISTEN: "0.0.0.0:8001"
    ports:
      - "80:8000"
      - "443:8443"
      - "8001:8001"
    volumes:
      - ./docker/kong/kong.yml:/usr/local/kong/declarative/kong.yml:ro
    depends_on:
      - nginx
    networks:
      - kong

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

networks:
  kong:
    external: true

volumes:
  mysql-data:
  redis-data:
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

1. Run `composer install --no-dev --optimize-autoloader` locally to generate `vendor`.
2. Copy `vendor`, `public`, `docker/`, and `.env.production` to the production server.
3. For Kong, create `docker/kong/kong.yml` for routing.
4. Use the desired `docker-compose.yml` and run `docker-compose up -d`.
5. Access your app at `http://<server-ip>` (standard) or via Kong’s proxy port.

**Notes**:

- **Standard Setup**: Exposes Nginx on port 80/443 for direct access.
- **Kong Setup**: Uses Kong as an API gateway, proxying to Nginx. Configure `kong.yml` for authentication or rate-limiting.
- Use `.env.production` for settings (e.g., `APP_ENV=production`, `DB_HOST=mysql`).
- Mount only `/var/www/vendor` and `/var/www/public` for security.
- Healthchecks ensure service reliability, with logs unified to stdout.

## Support and Contributions 🤝

Got questions or ideas? Drop an issue on the [redfieldchristabel/laravel-dockerize](https://github.com/redfieldchristabel/laravel-dockerize) repo. Pull requests are super welcome! Let’s make Laravel development even smoother together! 😄

Happy coding with Laravel! 🐘🎉