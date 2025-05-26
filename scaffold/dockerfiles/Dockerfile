FROM ghcr.io/redfieldchristabel/laravel:8.4-fpm-filament AS dev

# # configure gd
# RUN docker-php-ext-configure gd --with-freetype --with-jpeg

# Install PHP extensions
# RUN docker-php-ext-install pdo_mysql mbstring zip intl gd xml simplexml xmlreader iconv

# target prod
FROM dev AS prod

USER root

# copy codebase
COPY . /var/www

COPY ./docker/php/file.ini /usr/local/etc/php/conf.d/file.ini


RUN mkdir -p /var/www/vendor

# Change owner of working directory folder
RUN chown -R $user:$user /var/www

# change user back to executor
USER $user

