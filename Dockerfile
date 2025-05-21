# Define build arguments
ARG PHP_VERSION=8.4
ARG VARIANT=cli

# Base stage: Common setup for all variants
FROM php:${PHP_VERSION}-${VARIANT} AS base
ARG VARIANT

# Hardcode user and uid
ENV user=laravel
ENV uid=1000

# Install system dependencies and PHP extensions
RUN if [ "${VARIANT}" = "alpine" ] || [ "${VARIANT}" = "fpm-alpine" ]; then \
        apk add --no-cache \
            libxml2-dev \
            oniguruma-dev \
        && docker-php-ext-install pdo pdo_mysql mbstring bcmath xml \
        && docker-php-ext-enable pdo pdo_mysql mbstring bcmath xml \
        && apk del --no-cache libxml2-dev oniguruma-dev \
        && rm -rf /var/cache/apk/*; \
    else \
        apt-get update && apt-get install -y \
            libxml2-dev \
            libonig-dev \
        && docker-php-ext-install pdo pdo_mysql mbstring bcmath xml \
        && docker-php-ext-enable pdo pdo_mysql mbstring bcmath xml \
        && apt-get clean && rm -rf /var/lib/apt/lists/*; \
    fi

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Create system user and group
RUN if [ "${VARIANT}" = "alpine" ] || [ "${VARIANT}" = "fpm-alpine" ]; then \
        addgroup -S www-data && \
        adduser -S -G www-data -u ${uid} -h /home/${user} ${user}; \
    else \
        groupadd -r www-data && \
        useradd -r -G www-data -u ${uid} -d /home/${user} ${user}; \
    fi \
    && mkdir -p /home/${user}/.composer \
    && chown -R ${user}:www-data /home/${user}

# Set working directory
WORKDIR /var/www

# Copy codebase (assuming Laravel project root)
COPY . /var/www

# Change ownership
RUN chown -R ${user}:www-data /var/www

# FPM target
FROM base AS fpm
COPY docker/php/docker-entrypoint-fpm.sh /usr/local/bin/docker-php-entrypoint
RUN chmod +x /usr/local/bin/docker-php-entrypoint
USER ${user}
EXPOSE 9000
ENTRYPOINT ["docker-php-entrypoint"]

# CLI target (used for cli and alpine)
FROM base AS cli
COPY docker/php/docker-entrypoint-cli.sh /usr/local/bin/docker-php-entrypoint
RUN chmod +x /usr/local/bin/docker-php-entrypoint
USER ${user}
ENTRYPOINT ["docker-php-entrypoint"]