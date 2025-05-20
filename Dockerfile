# Define build arguments for PHP version and variant
ARG PHP_VERSION=8.4
ARG VARIANT=cli
ARG BASE_IMAGE=php:${PHP_VERSION}-${VARIANT}

# Use the specified base image (defaults to php:8.4-cli for 'latest')
FROM ${BASE_IMAGE}

# Define arguments for user and UID with fallbacks
ARG user=laravel
ARG uid=1000

# Install system dependencies and PHP extensions
# Alpine uses apk, Debian uses apt-get
RUN if [ "${VARIANT}" = "alpine" ]; then \
        apk add --no-cache \
            libxml2-dev \
        && docker-php-ext-install pdo pdo_mysql mbstring bcmath xml \
        && docker-php-ext-enable pdo pdo_mysql mbstring bcmath xml \
        && apk del --no-cache libxml2-dev \
        && rm -rf /var/cache/apk/*; \
    else \
        apt-get update && apt-get install -y \
            libxml2-dev \
        && docker-php-ext-install pdo pdo_mysql mbstring bcmath xml \
        && docker-php-ext-enable pdo pdo_mysql mbstring bcmath xml \
        && apt-get clean && rm -rf /var/lib/apt/lists/*; \
    fi

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Create system user to run Composer and Artisan commands
# For FPM, add user to www-data group; for CLI/Alpine, no group
RUN if [ "${VARIANT}" = "fpm" ]; then \
        useradd -G www-data -u ${uid} -d /home/${user} ${user}; \
    else \
        useradd -u ${uid} -d /home/${user} ${user}; \
    fi \
    && mkdir -p /home/${user}/.composer \
    && chown -R ${user}:${user} /home/${user}

# Copy and configure custom entrypoint
COPY docker/php/docker-entrypoint.sh /usr/local/bin/docker-php-entrypoint
RUN chmod +x /usr/local/bin/docker-php-entrypoint

# Set working directory
WORKDIR /var/www

# Change ownership of working directory
RUN chown -R ${user}:${user} /var/www

# Switch to non-root user
USER ${user}

# Expose port based on variant (8000 for CLI/Alpine, 9000 for FPM)
ARG PORT=0000
RUN if [ "${VARIANT}" = "fpm" ]; then \
        export PORT=9000; \
    fi
EXPOSE ${PORT}

# Use custom entrypoint
ENTRYPOINT ["docker-php-entrypoint"]