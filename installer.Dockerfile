# Use official PHP 8.3 Alpine CLI base for Laravel CLI
FROM php:8.3-cli-alpine

# Metadata
LABEL maintainer="redfieldchristabel <your-email@example.com>"
LABEL description="Laravel CLI installer for scaffolding Laravel 10, 11, and 12 apps"

# Set working directory
WORKDIR /app

# Create non-root user
ARG USER=laravel
RUN adduser -D -u 1000 $USER

# Install Composer from official image
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Install latest Laravel CLI globally as laravel user
USER $USER
RUN composer global require laravel/installer

USER root
    # Ensure /usr/local/bin is writable by laravel user
RUN  mkdir -p /usr/local/bin && \
     chown $USER:$USER /usr/local/bin && \
    # Symlink binary to /usr/local/bin
    ln -sf /home/laravel/.composer/vendor/bin/laravel /usr/local/bin/laravel && \
    # Ensure binary is executable
    chmod +x /usr/local/bin/laravel && \
    # Verify installation
    /usr/local/bin/laravel --version && \
    # Clean up
    rm -rf /home/laravel/.composer/cache

# Stay as non-root user
USER $USER

# Set entrypoint to execute laravel directly
ENTRYPOINT ["laravel"]