FROM nginx:1.27.2

COPY html /usr/share/nginx/html

RUN rm /etc/nginx/conf.d/default.conf

# created dynamically, so this will be mounted as a volume:
# COPY config/backends.conf /etc/nginx/conf.d/backend-upstream.conf
COPY config/backend-proxy.conf /etc/nginx/conf.d/default.conf
