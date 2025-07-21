FROM alpine:3.20

RUN apk add --no-cache \
    php82 php82-fpm php82-mysqli php82-json php82-openssl \
    php82-curl php82-zlib php82-xml php82-phar php82-intl \
    php82-dom php82-xmlreader php82-ctype php82-session \
    php82-mbstring php82-gd php82-zip php82-exif \
    php82-fileinfo php82-tokenizer php82-opcache \
	mariadb-client \
    wget tar netcat-openbsd curl \
    && rm -rf /var/cache/apk/*

RUN ln -sf /usr/bin/php82 /usr/bin/php

RUN wget -q https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar -O /usr/local/bin/wp \
    && chmod +x /usr/local/bin/wp \
	&& wp --info --allow-root

# www-data user/group if not exists
RUN if ! getent group www-data > /dev/null 2>&1; then \
        addgroup -g 82 www-data; \
    fi && \
    if ! getent passwd www-data > /dev/null 2>&1; then \
        adduser -D -u 82 -G www-data -h /var/www -s /bin/sh www-data; \
    fi

# required directories
RUN mkdir -p /var/www/html /run/php /var/log/php82 \
    && chown -R www-data:www-data /var/www/html /run/php /var/log/php82 \
    && chmod 755 /var/www/html

COPY conf/php-fpm.conf /etc/php82/php-fpm.conf
COPY conf/www.conf /etc/php82/php-fpm.d/www.conf
COPY conf/php.ini /etc/php82/php.ini

COPY tools/wordpress_entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/wordpress_entrypoint.sh

WORKDIR /var/www/html
USER www-data
EXPOSE 9000

CMD ["/usr/local/bin/wordpress_entrypoint.sh"]