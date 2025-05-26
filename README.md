[![Build and Push Laravel Images to GHCR](https://github.com/redfieldchristabel/laravel-dockerize/actions/workflows/build-and-push-laravel.yml/badge.svg)](https://github.com/redfieldchristabel/laravel-dockerize/actions/workflows/build-and-push-laravel.yml)
[![Build and Push Laravel Installer Image to GHCR](https://github.com/redfieldchristabel/laravel-dockerize/actions/workflows/build-and-push-installer.yml/badge.svg)](https://github.com/redfieldchristabel/laravel-dockerize/actions/workflows/build-and-push-installer.yml)

# Laravel-Optimized PHP Images 🎉

Welcome to the **Laravel-Optimized PHP Images** repository! 🚀 These pre-built Docker images, hosted on the GitHub Container Registry (GHCR), are your fast track to Laravel awesomeness. Whether you’re scaffolding a new app with our [Laravel installer](#creating-a-new-laravel-app-) (no local PHP needed!) or running Laravel 10, 11, or 12 with our [PHP-optimized images](#running-your-laravel-app-), we’ve got you covered. Packed with essential [PHP extensions](#pre-installed-php-extensions-), running as a [non-root `laravel` user](#non-root-laravel-user-by-default-), and optimized for [production](#production-deployment-), these images make development secure, fast, and fun. Let’s build something amazing! 😄

## Why Choose These Images? 🌟

Forget wrestling with PHP setups or complex Docker configs. Our images are tailor-made for Laravel developers, offering:

- **Zero-Setup Scaffolding** 🏗️: Create Laravel 10, 11, or 12 apps with just Docker using our [installer image](#creating-a-new-laravel-app-)—no PHP or Composer required locally.
- **Top-Notch Security** 🔒: Run as the [non-root `laravel` user](#non-root-laravel-user-by-default-) for safer development and [production](#production-deployment-).
- **Blazing-Fast Setup** ⚡: Pre-installed [PHP extensions](#pre-installed-php-extensions-) for instant local and CI/CD environments.
- **Streamlined Workflows** 🛠️: Focus on coding, not configuring, with Laravel-friendly defaults.
- **Filament Support** 🎨: Dedicated images for Filament projects (see [Filament-Optimized Images](#filament-optimized-images-)).
- **Flexible Deployment** 🌍: Copy code into images for [production](#production-deployment-) speed, with minimal mounts for security.

Need `imagick`, `pgsql`, or custom tweaks? Our [customization guides](#customizing-the-images-) make it a breeze! 🛠️

## Getting Started 🎬

Pull images from `ghcr.io/redfieldchristabel/laravel` and jump in! Start by [creating a new app](#creating-a-new-laravel-app-) or [scaffolding a Docker environment](#scaffolding-a-docker-environment-for-existing-projects-) for an existing project, then [run your app](#running-your-laravel-app-). Let’s go! 🚀

### Creating a New Laravel App 🏗️

Kick off your project with our `laravel:installer` image! This lightweight image (PHP 8.3, ~120-150 MB) includes the latest Laravel CLI and scaffolds Laravel 10, 11, or 12 apps with just Docker—no local PHP or Composer needed. Perfect for Linux, Mac, or Windows (with WSL2)!

**Example**:
```bash
docker run -v $(pwd):/app ghcr.io/redfieldchristabel/laravel:installer new example-app
```
This creates a Laravel 12 app (latest) in `./example-app/`. The image runs `laravel` directly, so you just add `new example-app`.

**Older Versions**:
- Use `--version` to scaffold Laravel 10 or 11.
- Example: `docker run -v $(pwd):/app ghcr.io/redfieldchristabel/laravel:installer new example-app --version=11` (Laravel 11 app).

**Customize Your App**:
- Add stacks: `--breeze` (Blade), `--jet` (Livewire/Inertia), or `--api` for API-only apps.
- Example: `docker run -v $(pwd):/app ghcr.io/redfieldchristabel/laravel:installer new example-app --breeze --version=11`

**Notes**:
- Uses PHP 8.3, compatible with Laravel 10 (PHP 8.0+), 11 (PHP 8.2+), and 12 (likely 8.2+).
- Saves output to a volume (e.g., `./:/app`), accessible locally.
- Runs as a [non-root `laravel` user](#non-root-laravel-user-by-default-) for security.
- No PHP extensions installed, keeping it lean for scaffolding.

After scaffolding, use our [PHP-based images](#running-your-laravel-app-) (e.g., `laravel:8.3-fpm`) to run your app or [scaffold a Docker environment](#scaffolding-a-docker-environment-for-existing-projects-).

### Scaffolding a Docker Environment for Existing Projects 🛠️

For existing Laravel projects, you can use our optional bash script to set up a complete Docker environment for development and production. This script, designed to run after your Laravel project is created, generates all necessary Docker files, including `docker-compose.yml` for development and production, Nginx configurations, and PHP settings. It also ensures Vite is Docker-ready by setting `server.host` to `"0.0.0.0"` in `vite.config.js`.

**Usage**:
Run the script in your Laravel project directory (must contain `artisan` and `app/`):
```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/redfieldchristabel/laravel-dockerize/main/scaffold/setup.sh)"
```

**Platform Notes**:
- **Linux**: Run the script directly in your terminal.
- **Mac**: Run the script directly in Terminal or iTerm2.
- **Windows**: Run the script in WSL2 (Windows Subsystem for Linux 2). Install WSL2 with `wsl --install` and enable Docker Desktop’s WSL2 integration. Git Bash is not recommended due to potential compatibility issues.

**What the Script Does**:
- **Creates Docker Files**: Generates `docker-compose.yml` (development), `build.docker-compose.yml`, `prod.docker-compose.yml`, and Dockerfiles for PHP, Nginx, and Vite.
- **Configures Nginx and PHP**: Adds `docker/nginx/conf/app.conf`, `docker/nginx/include/fpm-handler.conf`, and `docker/php/file.ini` for seamless integration.
- **Sets Up Tools**: Downloads helper scripts (`art`, `cmpsr`, `pint`, `nd`, `iart`) for Artisan, Composer, Node, and more.
- **Vite Compatibility**: Modifies `vite.config.js` to set `server.host` to `"0.0.0.0"` (required for Docker), updating existing `server` blocks or adding a new one.
- **Environment Setup**: Copies `.env.example` to `.env` if `.env` is missing.
- **Requirements**: Needs `curl` and `docker` installed. Must be run in a Laravel project directory.

**Using Helper Scripts**:
The script generates the following helper scripts in your project root to simplify running commands in Docker containers:
- **`art`**: Run Artisan commands in the `app` container (uses `laravel:8.3-cli`).
  ```bash
  ./art migrate
  ./art queue:work --queue=high,default
  ```
- **`cmpsr`**: Run Composer commands in the `app` container.
  ```bash
  ./cmpsr install
  ./cmpsr require laravel/ui
  ```
- **`pint`**: Run Laravel Pint (code style fixer) in the `app` container.
  ```bash
  ./pint
  ./pint --test
  ```
- **`nd`**: Run Node.js or npm commands in the `vite` container (for Vite-based projects).
  ```bash
  ./nd npm install
  ./nd npm run dev
  ```
- **`iart`**: A shortcut for the `php artisan` command, primarily used when you are already inside the container shell (e.g., via `docker exec` or Portainer CLI).
  ```bash
  ./iart tinker
  ```

**Example Output**:
After running, you’ll have:
- `docker-compose.yml`: Development setup with `app`, `nginx`, `mysql`, `redis`, and more.
- `prod.docker-compose.yml`: Production setup with minimal mounts (`vendor`, `public`).
- `vite.config.js`: Updated with `server: { host: "0.0.0.0" }` for Vite in Docker.
- Helper scripts (`art`, `cmpsr`, `pint`, `nd`, `iart`) in the project root for easy Artisan/Composer/Node commands.

**Notes**:
- Run this script after creating your Laravel app (e.g., via `laravel:installer`).
- The generated `docker-compose.yml` matches the [Development Environment](#development-environment-with-docker-compose-) section.
- Production files align with the [Production Deployment](#production-deployment-) section.
- The script uses images from `ghcr.io/redfieldchristabel/laravel` (e.g., `laravel:8.3-fpm`).
- If `vite.config.js` is missing, the script skips Vite configuration.

Proceed to [Running Your Laravel App](#running-your-laravel-app-) to start your Dockerized environment with `docker-compose up -d`.

### Running Your Laravel App 🐘

Our PHP-based images are pre-loaded with Laravel’s essential [extensions](#pre-installed-php-extensions-) and optimized for Laravel 10, 11, and 12. Use them for development, CI/CD, or [production](#production-deployment-).

**Supported PHP Versions**:
- **8.1, 8.2, 8.3, 8.4** (latest patches via daily builds).
- Tags: `laravel:<version>` (e.g., `ghcr.io/redfieldchristabel/laravel:8.3`, defaults to `fpm`) or `<version>-<variant>` (e.g., `laravel:8.3-cli`).

**Variants**:
- **cli** 🖥️: CLI PHP (Debian), great for Artisan, scripts, or cron jobs.
- **fpm** 🌐: PHP-FPM (Debian), ideal for Nginx or Apache.
- **cli-alpine** 🏔️: CLI PHP (Alpine), lightweight.
- **fpm-alpine** 🏔️: PHP-FPM (Alpine), compact.
- **filament** 🎨: CLI/FPM with Filament dependencies (e.g., `laravel:8.3-cli-filament`).

**Example** (Development):
Use the `docker-compose.yml` from the [Development Environment](#development-environment-with-docker-compose-) section (or generated by the [scaffolding script](#scaffolding-a-docker-environment-for-existing-projects-)) to spin up a Laravel app with Nginx, MySQL, Redis, and more.

## Image Features ✨

### Non-Root `laravel` User by Default 🔒

All images run as the non-root `laravel` user, reducing risks in development and [production](#production-deployment-). No root privileges needed, keeping your apps secure! 😊

### Built on Official PHP Images 🐳

Based on Docker Hub’s official PHP images, ensuring compatibility and reliability with standard tagging conventions.

### Pre-Installed PHP Extensions 🔧

Includes Laravel 11/12’s minimum extensions:
- `bcmath`
- `ctype`
- `fileinfo`
- `json`
- `mbstring`
- `openssl`
- `pdo`
- `pdo_mysql`
- `tokenizer`
- `xml`

Add more (e.g., `gd`, `imagick`) via [customization](#customizing-the-images-).

### Exposed Ports 🌍

- **fpm variants** 🌐: Port 9000 for PHP-FPM (Nginx/Apache).
- **cli variants** 🖥️: No ports, for command-line tasks.
- **installer image** 🏗️: No ports, for scaffolding.

### Default Entrypoint 🚪

Smart entrypoints for each image:
- **cli variants** 🖥️: Runs `php` (e.g., `php artisan queue:work`) via `/usr/local/bin/docker-entrypoint.sh`.
- **fpm variants** 🌐: Starts PHP-FPM via `/usr/local/bin/docker-entrypoint.sh`.
- **installer image** 🏗️: Runs `laravel` directly (e.g., `new example-app`).

PHP images handle setup (permissions, `composer install`) and sync code in development (`./:/var/www`) or mount only `vendor` in [production](#production-deployment-) (`./vendor:/var/www/vendor`). The installer simplifies scaffolding to one command. Most apps don’t need custom entrypoints! 😊

### Filament-Optimized Images 🎨

Filament projects? Use `-filament` images with pre-installed dependencies:
- `ghcr.io/redfieldchristabel/laravel:8.3-cli-filament`
- `ghcr.io/redfieldchristabel/laravel:8.3-fpm-alpine-filament`

### Docker Best Practices 🐳

We follow best practices for efficient containers:
- **One Process Per Container** ✅: Separate containers for `app`, `queue`, `scheduler` (no bundled Nginx/Apache).
- **Unified Logging** 📜: Logs to stdout for easy `docker logs` monitoring.

## Development Environment with Docker Compose 🛠️

Set up a dev environment with this `docker-compose.yml`, syncing code for real-time edits. Includes `app`, `nginx`, `mysql`, `redis`, `queue`, `scheduler`, `mailpit`, and `phpmyadmin`. This file is automatically generated by the [scaffolding script](#scaffolding-a-docker-environment-for-existing-projects-).

```yaml
version: '3.8'

services:
  app:
    image: ghcr.io/redfieldchristabel/laravel:8.3-fpm
    volumes:
      - .:/var/www # Sync codebase
      - ./docker/php/php.ini:/usr/local/etc/php/conf.d/custom.ini
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
      - .:/var/www
      - ./docker/nginx/nginx.conf:/etc/nginx/conf.d/default.conf
      - ./docker/nginx/include:/etc/nginx/include
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
1. Save as `docker-compose.yml` in your project root (or use the one generated by the [scaffolding script](#scaffolding-a-docker-environment-for-existing-projects-)).
2. Create `.env` (e.g., `DB_HOST=mysql`, `REDIS_HOST=redis`, `DB_DATABASE=laravel`).
3. Add `docker/php/php.ini` (e.g., `memory_limit = 256M`).
4. Create `docker/nginx/nginx.conf` and `docker/nginx/include/fpm-handler.conf` (below, or use script-generated versions).
5. Run `docker-compose up -d` and visit `http://localhost` or `http://localhost:8081` (phpMyAdmin).

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
- Use `8.3-fpm` for `app` to match [production](#production-deployment-). For quick dev, try `8.3-cli` with `command: php artisan serve --host 0.0.0.0 --port 8000` and port `8000`.
- `queue` and `scheduler` use `8.3-cli` in separate containers, per [Docker best practices](#docker-best-practices-).
- `.:/var/www` syncs code for fast `composer update`.
- The [scaffolding script](#scaffolding-a-docker-environment-for-existing-projects-) generates these files automatically.

### Customizing the Images 🔧

Add extensions or tweak PHP settings with a custom `Dockerfile` or volume mounts.

#### Installing Additional Extensions
Extend images for extensions like `imagick` or `pgsql`. Switch to `root` for installs, then revert to `$user`.

**Example** (Alpine):
```dockerfile
FROM ghcr.io/redfieldchristabel/laravel:8.3-cli-alpine

USER root
RUN apk add --no-cache imagemagick-dev && \
    pecl install imagick && \
    docker-php-ext-enable imagick && \
    rm -rf /var/cache/apk/*
USER $user
```

**Example** (Debian):
```dockerfile
FROM ghcr.io/redfieldchristabel/laravel:8.3-cli

USER root
RUN apt-get update && apt-get install -y libpq-dev && \
    docker-php-ext-install pgsql && \
    apt-get clean && rm -rf /var/lib/apt/lists/*
USER $user
```

**Usage**:
1. Save `Dockerfile` in project root.
2. Update `docker-compose.yml`:
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
Tweak `php.ini` (e.g., `memory_limit`):
1. Create `docker/php/php.ini`:
   ```ini
   memory_limit = 256M
   upload_max_filesize = 64M
   ```
2. Mount in `docker-compose.yml`:
   ```yaml
   volumes:
     - ./docker/php/php.ini:/usr/local/etc/php/conf.d/custom.ini
   ```

**Note**: Use default entrypoints for PHP images (`docker-entrypoint.sh`) to handle setup and logging. The installer uses `laravel` directly.

### Production Deployment 🏭

For [production](#production-deployment-), use `fpm` or `fpm-alpine` with Nginx, copying the codebase into the image for speed and mounting only `./vendor:/var/www/vendor`. The [non-root `laravel` user](#non-root-laravel-user-by-default-) ensures safety. Two `docker-compose.yml` options: standard or with Kong API Gateway. These files are generated by the [scaffolding script](#scaffolding-a-docker-environment-for-existing-projects-) as `prod.docker-compose.yml`.

#### Production Docker Compose (Standard)
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
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./public:/var/www/public
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
Uses Kong for routing, authentication, and rate-limiting, with Nginx as the backend.
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
2. Copy `vendor`, `public`, `docker/`, `.env.production` to the server.
3. For Kong, add `docker/kong/kong.yml`.
4. Run `docker-compose -f prod.docker-compose.yml up -d` (generated by the [scaffolding script](#scaffolding-a-docker-environment-for-existing-projects-)).
5. Access at `http://<server-ip>` (standard) or Kong’s proxy.

**Notes**:
- **Standard**: Nginx on ports 80/443.
- **Kong**: Proxies via Kong; configure `kong.yml` for auth/rate-limiting.
- Use `.env.production` (e.g., `APP_ENV=production`, `DB_HOST=mysql`).
- Mount only `./vendor:/var/www/vendor`, `./public:/var/www/public` for security.
- Healthchecks and stdout logs ensure reliability.
- The [scaffolding script](#scaffolding-a-docker-environment-for-existing-projects-) generates `prod.docker-compose.yml` for this setup.

## Support and Contributions 🤝

Questions or ideas? Open an issue at [redfieldchristabel/laravel-dockerize](https://github.com/redfieldchristabel/laravel-dockerize). Pull requests are welcome! Join us to make Laravel + Docker even better! 😄

Happy coding with Laravel! 🐘🎉