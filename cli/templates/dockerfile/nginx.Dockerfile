FROM nginx:alpine AS dev

# remove default nginx website & config
RUN rm -rf /usr/share/nginx/html/*  \
    && rm /etc/nginx/conf.d/default.conf
 \
    # expose http port
EXPOSE 80

# target development
FROM dev AS prod

# copy project public folder
COPY public /var/www/public

# copy default nginx config
COPY docker/nginx/app.conf /etc/nginx/conf.d/app.conf
COPY docker/nginx/include/app_handler.conf /etc/nginx/include/app_handler.conf
COPY docker/nginx/include/web-socket_handler.conf /etc/nginx/include/web-socket_handler.conf
