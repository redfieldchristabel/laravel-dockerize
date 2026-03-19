# Define build arguments
ARG PHP_VERSION=8.4
ARG VARIANT=cli-alpine

# Base stage: Start from the normal Octane-Swoole Alpine-based image
FROM ghcr.io/redfieldchristabel/laravel:${PHP_VERSION}-${VARIANT}-octane-swoole AS base
ARG VARIANT

USER root

# Install additional system dependencies for Alpine
RUN apk add --no-cache \
    libzip-dev \
    freetype-dev \
    libjpeg-turbo-dev \
    icu-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install intl zip gd \
    && docker-php-ext-enable intl zip gd \
    && apk del --no-cache freetype-dev libjpeg-turbo-dev \
    && rm -rf /var/cache/apk/*

# Octane target
FROM base AS octane
COPY docker/php/docker-entrypoint-octane-swoole.sh /usr/local/bin/docker-php-entrypoint
RUN chmod +x /usr/local/bin/docker-php-entrypoint
USER ${user}
EXPOSE 8000
ENTRYPOINT ["docker-php-entrypoint"]
