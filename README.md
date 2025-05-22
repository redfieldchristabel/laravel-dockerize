# GitHub Package Container Registry - Laravel Optimized PHP Images

This repository provides pre-built PHP container images optimized for Laravel development, aiming to significantly accelerate your development workflow, especially during initial project setup and within Continuous Integration/Continuous Deployment (CI/CD) pipelines.

## Why Use These Images?

Traditional Docker setups for Laravel often require manual installation of numerous PHP extensions within your Dockerfile. This process can be time-consuming and adds overhead to builds, particularly in CI/CD environments.

These images come with the essential PHP extensions required by most Laravel applications pre-installed. This means you can use these images directly in your `Dockerfile` or `docker-compose.yml` without the need for extensive `apt-get install` or `pecl install` commands, leading to:

- **Faster Initial Setup:** Get your local development environment up and running quicker.
- **Accelerated CI/CD Pipelines:** Reduced build times for your testing and deployment workflows.
- **Simplified Dockerfiles:** Your application Dockerfiles become cleaner and easier to maintain.

## Based on Official PHP Images

These images are built on top of the official PHP images available on Docker Hub. They follow the same standard PHP image tagging conventions, making it easy to switch to these optimized versions.

## Supported Versions and Variants

We support major and minor PHP versions (two octets), such as `8.2`, `8.3`, and `8.4`. Patch versions (e.g., `8.2.3`) are not explicitly tagged for simpler maintenance and to ensure you benefit from the latest security patches and bug fixes through daily builds without introducing breaking changes tied to specific patch versions.

The following variants are available for each supported PHP version:

- `fpm`: PHP-FPM with a Debian base. Ideal for web servers like Nginx or Apache.
- `alpine`: PHP with an Alpine Linux base. Smaller image size, good for resource-constrained environments.
- `fpm-alpine`: PHP-FPM with an Alpine Linux base. Combines the benefits of FPM and Alpine.
- `cli`: Command Line Interface PHP with a Debian base. Useful for running Artisan commands, scripts, and cron jobs.
- `cli-alpine`: Command Line Interface PHP with an Alpine Linux base. CLI variant with a smaller image size.

## Filament-Tailored Images

For projects utilizing the Filament PHP framework, we also offer specialized images optimized for running `php artisan filament` commands. These images are built with Filament-specific dependencies and configurations.

To use a Filament-tailored image, simply append `-filament` to the standard image tag. For example:

- `8.3-cli-filament`
- `8.4-fpm-alpine-filament`

These images ensure a smooth and efficient experience when working with Filament commands within your Dockerized environment.

## How to Use

To use these images, replace the standard official PHP image tag in your `Dockerfile` or `docker-compose.yml` with the desired tag from this registry.

**Example `Dockerfile`:**
```
dockerfile
FROM ghcr.io/your-github-username/laravel-php:8.3-fpm-alpine

# Copy your Laravel application
COPY . /var/www/html

# Install application dependencies (if not in the image)
# RUN composer install --no-dev --optimize-autoloader

# Expose the FPM port
EXPOSE 9000

CMD ["php-fpm"]
```
**Example `docker-compose.yml`:**
```
yaml
version: '3.8'

services:
  app:
    image: ghcr.io/your-github-username/laravel-php:8.3-cli
    volumes:
      - .:/var/www/html
    working_dir: /var/www/html
    command: php artisan serve --host 0.0.0.0 --port 8000
    ports:
      - "8000:8000"
    # other configurations
```
Remember to replace `your-github-username` with your actual GitHub username or organization name where the package is hosted.

By leveraging these pre-configured images, you can streamline your Laravel development workflow and focus more on building your application.