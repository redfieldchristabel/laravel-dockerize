# Define build arguments
ARG PHP_VERSION=8.4
ARG VARIANT=cli-alpine

# Base stage: Start from the CLI Alpine variant of the Laravel base image
FROM ghcr.io/redfieldchristabel/laravel:${PHP_VERSION}-${VARIANT} AS base
ARG VARIANT

USER root

# Install system dependencies for Swoole
RUN apk add --no-cache \
    libpcre2-dev \
    openssl-dev \
    && apk add --no-cache --virtual .build-deps \
    build-base \
    autoconf \
    && pecl install swoole \
    && docker-php-ext-enable swoole \
    && apk del --no-cache .build-deps \
    && rm -rf /var/cache/apk/*

# Set working directory
WORKDIR /var/www

# Octane target
FROM base AS octane
COPY docker/php/docker-entrypoint-octane.sh /usr/local/bin/docker-php-entrypoint
RUN chmod +x /usr/local/bin/docker-php-entrypoint
USER ${user}
EXPOSE 8000
ENTRYPOINT ["docker-php-entrypoint"]