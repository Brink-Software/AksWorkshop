FROM nginx:stable-alpine
COPY default.conf /etc/nginx/conf.d/
COPY index.html /usr/share/nginx/html
COPY ./entrypoint.sh /docker-entrypoint.d

