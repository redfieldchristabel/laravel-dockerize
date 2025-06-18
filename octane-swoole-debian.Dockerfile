# Define build arguments
ARG PHP_VERSION=8.4
ARG VARIANT=cli-debian

# Base stage: Start from the CLI Debian variant of the Laravel base image
FROM ghcr.io/redfieldchristabel/laravel:${PHP_VERSION}-${VARIANT} AS base
ARG VARIANT

USER root

# Install system dependencies for Swoole
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpcre2-dev \
    libssl-dev \
    && apt-get install -y --no-install-recommends \
    build-essential \
    autoconf \
    && pecl install swoole \
    && docker-php-ext-enable swoole \
    && apt-get purge -y --auto-remove build-essential autoconf \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /var/www

# Octane target
FROM base AS octane
COPY docker/php/docker-entrypoint-octane.sh /usr/local/bin/docker-php-entrypoint
RUN chmod +x /usr/local/bin/docker-php-entrypoint
USER ${user}
EXPOSE 8000
ENTRYPOINT ["docker-php-entrypoint"]