FROM alpine:3.20

ARG DOMAIN_NAME

RUN apk update && apk add --no-cache nginx openssl && rm -rf /var/cache/apk/*

RUN mkdir -p /var/run/nginx /etc/nginx/ssl

RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/nginx/ssl/nginx.key \
    -out /etc/nginx/ssl/nginx.crt \
    -subj "/C=FI/ST=Helsinki/L=Helsinki/O=42School/OU=Inception/CN=${DOMAIN_NAME}"

COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY tools/nginx_entrypoint.sh /usr/local/bin/nginx_entrypoint.sh
RUN chmod +x /usr/local/bin/nginx_entrypoint.sh

EXPOSE 443
ENTRYPOINT ["/usr/local/bin/nginx_entrypoint.sh"]
