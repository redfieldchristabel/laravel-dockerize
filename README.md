[![Build and Push Laravel Images to GHCR](https://github.com/redfieldchristabel/laravel-dockerize/actions/workflows/build-and-push-laravel.yml/badge.svg)](https://github.com/redfieldchristabel/laravel-dockerize/actions/workflows/build-and-push-laravel.yml)
[![Build and Push Laravel Installer Image to GHCR](https://github.com/redfieldchristabel/laravel-dockerize/actions/workflows/build-and-push-installer.yml/badge.svg)](https://github.com/redfieldchristabel/laravel-dockerize/actions/workflows/build-and-push-installer.yml)
[![Build and Push Octane-Swoole Images](https://github.com/redfieldchristabel/laravel-dockerize/actions/workflows/build-and-push-octane-swoole.yml/badge.svg)](https://github.com/redfieldchristabel/laravel-dockerize/actions/workflows/build-and-push-octane-swoole.yml)
[![release](https://github.com/redfieldchristabel/laravel-dockerize/actions/workflows/release.yml/badge.svg)](https://github.com/redfieldchristabel/laravel-dockerize/actions/workflows/release.yml)

# Laravel-Optimized PHP Images 🎉

Welcome to the **Laravel-Optimized PHP Images** repository! 🚀 These pre-built Docker images, hosted on the GitHub Container Registry (GHCR), are your fast track to Laravel awesomeness. Whether you’re scaffolding a new app with our [Laravel installer](#creating-a-new-laravel-app-%EF%B8%8F) (no local PHP needed!) or running Laravel 10, 11, or 12 with our [PHP-optimized images](#running-your-laravel-app), we’ve got you covered. Packed with essential [PHP extensions](#pre-installed-php-extensions), running as a [non-root `laravel` user](#non-root-laravel-user-by-default), and optimized for [production](#production-deployment), these images make development secure, fast, and fun. Let’s build something amazing! 😄

## Why Choose These Images? 🌟

Forget wrestling with PHP setups or complex Docker configs. Our images are tailor-made for Laravel developers, offering:

- **Zero-Setup Scaffolding** 🏗️: Create Laravel 10, 11, or 12 apps with just Docker using our [installer package](#creating-a-new-laravel-app)—no PHP or Composer required locally.
- **Top-Notch Security** 🔒: Run as the [non-root `laravel` user](#non-root-laravel-user-by-default) for safer development and [production](#production-deployment).
- **Blazing-Fast Setup** ⚡: Pre-installed [PHP extensions](#pre-installed-php-extensions) for instant local and CI/CD environments.
- **Streamlined Workflows** 🛠️: Focus on coding, not configuring, with Laravel-friendly defaults.
- **Filament Support** 🎨: Dedicated images for Filament projects (see [Filament-Optimized Images](#filament-optimized-images)).
- **Laravel Octane Support** 🚀: High-performance images with Swoole for Octane (see [Octane-Optimized Images](#octane-optimized-images)).
- **Flexible Deployment** 🌍: Copy code into images for [production](#production-deployment) speed, with minimal mounts for security.

Need `imagick`, `pgsql`, or custom tweaks? Our [customization guides](#customizing-the-images) make it a breeze! 🛠️

## Getting Started 🎬

Pull images from `ghcr.io/redfieldchristabel/laravel` and jump in! Start by [creating a new app](#creating-a-new-laravel-app) or [scaffolding a Docker environment](#scaffolding-a-docker-environment-for-existing-projects) for an existing project, then [run your app](#running-your-laravel-app). Let’s go! 🚀

### Creating a New Laravel App 🏗️

Kick off your project with our `laravel-installer` package! This lightweight image (~120-150 MB) includes the latest Laravel CLI and scaffolds Laravel 10, 11, or 12 apps with just Docker—no local PHP or Composer needed. Perfect for Linux, Mac, or Windows (with WSL2)!

**Example**:
```bash
docker run -it -v $(pwd):/app ghcr.io/redfieldchristabel/laravel-installer:latest new example-app
```
This creates a Laravel 12 app (latest) in `./example-app/`. The image runs `laravel` directly, so you just add `new example-app`.

**Older Versions**:
- Use `--version` to create Laravel 10 or 11.
- Example: `docker run -v $(pwd):/app ghcr.io/redfieldchristabel/laravel-installer:latest new example-app --version=11` (Laravel 11 app).

**Customize Your App**:
- Add stacks: `--breeze` (Blade), `--jet` (Livewire/Inertia), or `--api` for API-only apps.
- Example: `docker run -v $(pwd):/app ghcr.io/redfieldchristabel/laravel-installer:latest new example-app --breeze --version=11`

**Notes**:
- Saves output to a volume (e.g., `./:/app`), accessible locally.
- Runs as a [non-root `laravel` user](#non-root-laravel-user-by-default) for security.
- No PHP extensions installed, keeping it lean for scaffolding.
- For more on how to use the Laravel installer, see the [official Laravel documentation](https://laravel.com/docs/13.x/installation#creating-an-application).

After scaffolding, use our [PHP-based images](#running-your-laravel-app) (e.g., `laravel:8.3-fpm`) to run your app or [scaffold a Docker environment](#scaffolding-a-docker-environment-for-existing-projects).

### Scaffolding a Docker Environment for Existing Projects 🛠️

For existing Laravel projects, you can use our interactive CLI tool to set up a complete Docker environment for development and production. The CLI wizard will guide you through selecting the PHP version, Database, WebSockets, Base Image, and more! It will then generate all necessary Docker files, including `docker-compose.yml` for development and production, Nginx configurations, and PHP settings. It also configures environment variables so you are ready to go.

**Usage**:
Run the script in your Laravel project directory (must contain `artisan` and `app/`):
```bash
(curl -fsSL https://github.com/redfieldchristabel/laravel-dockerize/releases/latest/download/cli.sh > /tmp/cli && chmod +x /tmp/cli && /tmp/cli scaffold)
```

**Platform Notes**:
- **Linux**: Run the command directly in your terminal.
- **Mac**: Run the command directly in Terminal or iTerm2.
- **Windows**: Run the command in WSL2 (Windows Subsystem for Linux 2). Install WSL2 with `wsl --install` and enable Docker Desktop’s WSL2 integration. Git Bash is not recommended due to potential compatibility issues.

**What the Script Does**:
- **Interactive Wizard**: Guides you through selecting options.
- **Creates Docker Files**: Generates `docker-compose.yml` (development), `build.docker-compose.yml`, `prod.docker-compose.yml`, and Dockerfiles for PHP, Nginx, and Vite.
- **Configures Nginx and PHP**: Adds `docker/nginx/conf/app.conf`, `docker/nginx/include/fpm-handler.conf`, and `docker/php/file.ini` for seamless integration.
- **Sets Up Tools**: Downloads helper scripts (`art`, `cmpsr`, `pint`, `nd`, `iart`, `box`) for Artisan, Composer, Node, and more.
- **Vite Compatibility**: Generates Vite-specific components if chosen during the wizard.
- **Environment Setup**: Configures your `.env` to work with the generated Docker services.
- **Requirements**: Needs `curl` installed. Must be run in a Laravel project directory.

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
- Run this tool after creating your Laravel app (e.g., via `laravel-installer`).
- The generated `docker-compose.yml` matches the [Development Environment](#development-environment-with-docker-compose) section.
- Production files align with the [Production Deployment](#production-deployment) section.
- The wizard uses images from `ghcr.io/redfieldchristabel/laravel` (e.g., `laravel:8.3-fpm`).

Proceed to [Running Your Laravel App](#running-your-laravel-app) to start your Dockerized environment with `docker-compose up -d`.

### Running Your Laravel App 🐘

Our PHP-based images are pre-loaded with Laravel’s essential [extensions](#pre-installed-php-extensions) and optimized for Laravel 10, 11, and 12. Use them for development, CI/CD, or [production](#production-deployment).

**Supported PHP Versions**:
- **8.1, 8.2, 8.3, 8.4** (latest patches via daily builds).
- Tags: `laravel:<version>` (e.g., `ghcr.io/redfieldchristabel/laravel:8.3`, defaults to `fpm`) or `<version>-<variant>` (e.g., `laravel:8.3-cli`).

**Variants**:
- **cli** 🖥️: CLI PHP (Debian), great for Artisan, scripts, or cron jobs.
- **fpm** 🌐: PHP-FPM (Debian), ideal for Nginx or Apache.
- **cli-alpine** 🏔️: CLI PHP (Alpine), lightweight.
- **fpm-alpine** 🏔️: PHP-FPM (Alpine), compact.
- **filament** 🎨: CLI/FPM with Filament dependencies (e.g., `laravel:8.3-cli-filament`).
- **octane-swoole** 🚀: CLI with Swoole for Laravel Octane (e.g., `laravel:8.3-cli-alpine-octane-swoole`).

**Example** (Development):
Use the `docker-compose.yml` from the [Development Environment](#development-environment-with-docker-compose) section (or generated by the [scaffolding script](#scaffolding-a-docker-environment-for-existing-projects)) to spin up a Laravel app with Nginx, MySQL, Redis, and more.

## Image Features ✨

### Non-Root `laravel` User by Default 🔒

All images run as the non-root `laravel` user, reducing risks in development and [production](#production-deployment). No root privileges needed, keeping your apps secure! 😊

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

Add more (e.g., `gd`, `imagick`) via [customization](#customizing-the-images).

### Exposed Ports 🌍

- **fpm variants** 🌐: Port 9000 for PHP-FPM (Nginx/Apache).
- **cli variants** 🖥️: No ports, for command-line tasks.
- **installer image** 🏗️: No ports, for scaffolding.
- **octane-swoole** 🚀: Port 8000 for Laravel Octane with Swoole.

### Default Entrypoint 🚪

Smart entrypoints for each image:
- **cli variants** 🖥️: Runs `php` (e.g., `php artisan queue:work`) via `/usr/local/bin/docker-entrypoint.sh`.
- **fpm variants** 🌐: Starts PHP-FPM via `/usr/local/bin/docker-entrypoint.sh`.
- **installer image** 🏗️: Runs `laravel` directly (e.g., `new example-app`).
- **octane-swoole** 🚀: Runs `php artisan octane:start` via `/usr/local/bin/docker-php-entrypoint`.

PHP images handle setup (permissions, `composer install`) and sync code in development (`./:/var/www`) or mount only `vendor` in [production](#production-deployment) (`./vendor:/var/www/vendor`). The installer simplifies scaffolding to one command. Most apps don’t need custom entrypoints! 😊

### Filament-Optimized Images 🎨

Filament projects? Use `-filament` images with pre-installed dependencies:
- `ghcr.io/redfieldchristabel/laravel:8.3-cli-filament`
- `ghcr.io/redfieldchristabel/laravel:8.3-fpm-alpine-filament`

### Octane-Optimized Images 🚀

For high-performance Laravel apps, use our Octane images with Swoole, the most popular and fastest server for Laravel Octane. These images include the Swoole binary pre-installed, so you don’t need to wait for a lengthy `pecl install swoole`. Laravel CLI is not pre-installed; create your app with the [Laravel installer](#creating-a-new-laravel-app) first.

- Available for PHP **8.2, 8.3, 8.4** (Swoole requires minimum PHP 8.2).
- Tags: `laravel:<version>-cli-<variant>-octane-swoole` (e.g., `laravel:8.3-cli-alpine-octane-swoole`, `laravel:8.3-cli-debian-octane-swoole`).
- **Note**: Currently supports only Swoole (no RoadRunner). SSL support requires extending the image (no `openssl` by default for minimal size). For security and performance, it is best practice to use a reverse proxy (like NGINX) for SSL termination to handle encryption/decryption at the proxy level.

**How to Use**:
1. Scaffold your environment using the [Interactive CLI](#scaffolding-a-docker-environment-for-existing-projects) and choose an **Octane-Swoole** image.
2. Install the Octane package (required for official Laravel installation):
   ```bash
   ./cmpsr require laravel/octane
   ```
3. Set up Octane and select **swoole** as your server:
   ```bash
   ./art octane:install
   ```
4. Start your environment:
   ```bash
   docker-compose up -d
   ```
5. Your app is now running on `http://localhost:8000`.

### Docker Best Practices 🐳

We follow best practices for efficient containers:
- **One Process Per Container** ✅: Separate containers for `app`, `queue`, `scheduler` (no bundled Nginx/Apache).
- **Unified Logging** 📜: Logs to stdout for easy `docker logs` monitoring.

## Development Environment with Docker Compose 🛠️

Our [scaffolding script](#scaffolding-a-docker-environment-for-existing-projects) automatically generates a `docker-compose.yml` tailored to your project.

**Usage**:
1. Run the [Interactive CLI](#scaffolding-a-docker-environment-for-existing-projects) and select your preferred development services.
2. Once the script finishes, you will have a `docker-compose.yml` file in your project root.
3. Start your environment:
   ```sh
   docker-compose up -d
   ```

**Services Typically Included**:
- **app**: Your Laravel application (FPM or CLI).
- **nginx**: Configured for Laravel and optionally Vite/WebSockets.
- **mysql/pgsql**: Your chosen database.
- **redis**: For caching and queues.
- **queue/scheduler**: Dedicated containers for background tasks.
- **mailpit**: For local email testing.
- **phpmyadmin**: Web interface for database management.

## Customizing the Images 🔧

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

**Example** (Octane with SSL):
```dockerfile
FROM ghcr.io/redfieldchristabel/laravel:8.3-cli-alpine-octane-swoole

USER root
RUN apk add --no-cache openssl-dev && \
    pecl install swoole --enable-openssl=yes && \
    docker-php-ext-enable swoole && \
    rm -rf /var/cache/apk/*
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

**Note**: Use default entrypoints for PHP images (`docker-entrypoint.sh`) to handle setup and logging. The installer uses `laravel` directly, and Octane uses `docker-php-entrypoint` for `octane:start`.

## Production Deployment 🏭

For [production](#production-deployment), we recommend using specialized configurations generated by our [scaffolding script](#scaffolding-a-docker-environment-for-existing-projects) as `prod.docker-compose.yml`. These are optimized for security and performance, running as the [non-root `laravel` user](#non-root-laravel-user-by-default) and utilizing minimal mounts.

**Usage**:
1. Run the [Interactive CLI](#scaffolding-a-docker-environment-for-existing-projects) and select the production options that match your infrastructure (e.g., standard Nginx or Kong API Gateway).
2. If a `prod.docker-compose.yml` is generated, **please ensure you change the registry URL** to your project's specific container registry.
3. Prepare your environment:
   ```bash
   composer install --no-dev --optimize-autoloader
   ```
4. Deploy your configuration and start the environment:
   ```bash
   docker-compose -f prod.docker-compose.yml up -d
   ```

> [!IMPORTANT]
> **Never commit production `.env` files (e.g., `.env.production`, `.env.prod`) to version control.** As a best practice, copy `.env.example` from Laravel and configure it directly on the server. Since environment variables change infrequently, it is safer to handle this manually rather than including sensitive secrets in your CI/CD configuration.

## Support and Contributions 🤝

Questions or ideas? Open an issue at [redfieldchristabel/laravel-dockerize](https://github.com/redfieldchristabel/laravel-dockerize). Pull requests are welcome! Join us to make Laravel + Docker even better! 😄

Happy coding with Laravel! 🐘🎉