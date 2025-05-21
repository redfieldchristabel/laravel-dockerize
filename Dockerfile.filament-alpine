# Define build arguments
ARG PHP_VERSION=8.3
ARG VARIANT=fpm-alpine

# Base stage: Start from the normal Laravel Alpine-based image
FROM ghcr.io/redfieldchristabel/laravel:${PHP_VERSION}-${VARIANT} AS base
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


# FPM target
FROM base AS fpm
COPY docker/php/docker-entrypoint-fpm.sh /usr/local/bin/docker-php-entrypoint
RUN chmod +x /usr/local/bin/docker-php-entrypoint
USER $user
EXPOSE 9000
ENTRYPOINT ["docker-php-entrypoint"]

# CLI target
FROM base AS cli
COPY docker/php/docker-entrypoint-cli.sh /usr/local/bin/docker-php-entrypoint
RUN chmod +x /usr/local/bin/docker-php-entrypoint
USER $user
ENTRYPOINT ["docker-php-entrypoint"]