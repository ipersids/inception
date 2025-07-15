FROM --platform="linux/arm64" alpine:3.19

RUN apk update && apk add --no-cache nginx openssl && rm -rf /var/cache/apk/*

RUN mkdir -p /var/run/nginx /etc/nginx/ssl

RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/nginx.key \
    -out /etc/nginx/ssl/nginx.crt \
    -subj "/C=HEL/ST=Development/L=Local/O=42School/OU=Inception/CN=ipersids.42.fr"

COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY tools/nginx_entrypoint.sh /usr/local/bin/nginx_entrypoint.sh
RUN chmod +x /usr/local/bin/nginx_entrypoint.sh

EXPOSE 443
ENTRYPOINT ["/usr/local/bin/nginx_entrypoint.sh"]
