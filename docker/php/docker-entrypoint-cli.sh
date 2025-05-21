#!/bin/bash
set -e

# Run composer install
composer install

# Run php artisan optimize, output to Docker logs
php artisan optimize

# Check if this is an Artisan command container
if [[ "$1" == "php" && "$2" == "artisan" ]]; then
  exec "$@"
fi

# Stream Laravel logs to Docker logs as main process
exec tail -f /var/www/storage/logs/*.log