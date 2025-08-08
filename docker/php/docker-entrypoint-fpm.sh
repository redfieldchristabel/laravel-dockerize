#!/bin/bash
set -e

# Check if the container is running in a development environment
# In development, we include dev dependencies like testing and debugging tools
if [[ "$DOCKER_ENV" == "development" ]]; then
  echo "Running composer install with development dependencies..."
  composer install
else
  # In production, we exclude dev dependencies and optimize the autoloader for performance
  echo "Running composer install without dev dependencies and with optimized autoloader..."
  composer install --no-dev --optimize-autoloader
fi

# Run php artisan optimize, output to Docker logs
php artisan optimize:clear
php artisan optimize

# Check if this is an Artisan command container
if [[ "$1" == "php" && "$2" == "artisan" ]]; then
  exec "$@"
fi

# Stream Laravel logs to Docker logs in background
tail -n 0 -f /var/www/storage/logs/*.log &

# Start PHP-FPM in foreground to ensure logs go to Docker logs
exec php-fpm