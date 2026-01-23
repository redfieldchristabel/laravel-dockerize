FROM ghcr.io/redfieldchristabel/laravel:8.4-cli-filament-octane-swoole AS base

# Please configure any dependecy you need in this base image.
# It is recommended to use CICD to build base image and use that as the base for bellow images and delete this step.

FROM base AS dev

ENV DOCKER_ENV=development

# Switch to root to perform system-level changes
USER root

# 1. Copy the Node binary
COPY --from=node:22 /usr/local/bin/node /usr/local/bin/node

# 2. Copy the actual NPM source files
COPY --from=node:22 /usr/local/lib/node_modules /usr/local/lib/node_modules

# 3. Re-create the symlinks for npm and npx
# We use -sf (force) to ensure it overwrites if anything exists
RUN ln -sf /usr/local/lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm \
    && ln -sf /usr/local/lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx

# 4. Install Chokidar (Required for Octane --watch)
RUN npm install -g chokidar

# 5. Verify immediately during build
RUN node -v && npm -v

USER $user

# Please configure any dependecy you need in the base image

# target prod
FROM base AS prod

ENV DOCKER_ENV=production

USER root

# copy codebase
COPY . /var/www

COPY ./docker/php/file.ini /usr/local/etc/php/conf.d/file.ini


RUN mkdir -p /var/www/vendor

# Change owner of working directory folder
RUN chown -R $user:$user /var/www

# change user back to executor
USER $user

