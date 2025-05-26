FROM ghcr.io/redfieldchristabel/laravel:8.4-fpm-filament AS dev

# Arguments defined in docker-compose.yml
ARG appVersion

# php env
ENV PHP_MEMORY_LIMIT=1024M


# # configure gd
# RUN docker-php-ext-configure gd --with-freetype --with-jpeg

# Install PHP extensions
# RUN docker-php-ext-install pdo_mysql mbstring zip intl gd xml simplexml xmlreader iconv

# target prod
FROM dev AS prod

ENV APP_VERSION=$appVersion

USER root

# copy codebase
COPY . /var/www

RUN mkdir -p /var/www/vendor

# Change owner of working directory folder
RUN chown -R $user:$user /var/www

# change user back to executor
USER $user

