# Define build arguments
ARG PHP_VERSION=8.4
ARG VARIANT=cli

# Base stage: Common setup for Alpine variants
FROM php:${PHP_VERSION}-${VARIANT} AS base
ARG VARIANT
# Pinned tarball: pecl.php.net serves broken REST metadata for redis,
# so `pecl install redis` by name fails. Bump deliberately.
ARG REDIS_VERSION=6.3.0

# Hardcode user and uid
ENV user=laravel
ENV uid=1000

# Install system dependencies and PHP extensions
RUN apk add --no-cache \
        libxml2-dev \
        unzip \
        oniguruma-dev \
        libzip-dev \
        $PHPIZE_DEPS \
    && curl -fsSL --retry 3 -o /tmp/redis.tgz "https://pecl.php.net/get/redis-${REDIS_VERSION}.tgz" \
    && pecl install /tmp/redis.tgz \
    && rm -f /tmp/redis.tgz \
    && docker-php-ext-install pdo pdo_mysql mbstring bcmath xml zip \
    && docker-php-ext-enable pdo pdo_mysql mbstring bcmath xml redis \
    && apk del --no-cache libxml2-dev oniguruma-dev $PHPIZE_DEPS \
    && rm -rf /var/cache/apk/*

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Create system user and group
RUN getent group www-data || addgroup -S www-data; \
    adduser -S -G www-data -u ${uid} -h /home/${user} ${user} && \
    mkdir -p /home/${user}/.composer && \
    chown -R ${user}:www-data /home/${user}

# Set working directory
WORKDIR /var/www

# Change ownership
RUN chown -R ${user}:www-data /var/www

# FPM target
FROM base AS fpm
COPY docker/php/docker-entrypoint-fpm.sh /usr/local/bin/docker-php-entrypoint
RUN chmod +x /usr/local/bin/docker-php-entrypoint
USER ${user}
EXPOSE 9000
ENTRYPOINT ["docker-php-entrypoint"]

# CLI target
FROM base AS cli
COPY docker/php/docker-entrypoint-cli.sh /usr/local/bin/docker-php-entrypoint
RUN chmod +x /usr/local/bin/docker-php-entrypoint
USER ${user}
ENTRYPOINT ["docker-php-entrypoint"]