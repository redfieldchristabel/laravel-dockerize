#!/bin/bash
set -e

# Run composer install to ensure dependencies are installed
composer install --no-dev --optimize-autoloader

# Run php artisan optimize, output to Docker logs
php artisan optimize

# Stream Laravel logs to Docker logs in background
tail -f /var/www/storage/logs/*.log &

# Start Laravel Octane with Swoole as the main process
exec php artisan octane:start --server=swoole --host=0.0.0.0 --port=8000