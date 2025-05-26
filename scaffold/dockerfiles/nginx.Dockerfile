FROM nginx:alpine AS dev

# remove default nginx website
RUN rm -rf /usr/share/nginx/html/*

# remove default nginx config
RUN rm /etc/nginx/conf.d/default.conf

# expose http port
EXPOSE 80

# target development
FROM dev AS prod

# copy project public folder
COPY public /var/www/public

# copy default nginx config
COPY docker/nginx/conf/ /etc/nginx/conf.d/
COPY docker/nginx/include/fpm-handler.conf /etc/nginx/include/fpm-handler.conf
