FROM --platform=linux/arm64 alpine:3.20

# Install PHP-FPM and required extensions
RUN apk add --no-cache \
    php82 \
    php82-fpm \
    php82-mysqli \
    php82-json \
    php82-openssl \
    php82-curl \
    php82-zlib \
    php82-xml \
    php82-phar \
    php82-intl \
    php82-dom \
    php82-xmlreader \
    php82-ctype \
    php82-session \
    php82-mbstring \
    php82-gd \
    php82-zip \
    php82-exif \
    php82-fileinfo \
    php82-tokenizer \
    wget \
    tar \
    netcat-openbsd

# Create symlink for php command
RUN ln -sf /usr/bin/php82 /usr/bin/php

# Check if www-data exists, if not create it
RUN if ! getent group www-data > /dev/null 2>&1; then \
        addgroup -g 82 www-data; \
    fi && \
    if ! getent passwd www-data > /dev/null 2>&1; then \
        adduser -D -u 82 -G www-data -h /var/www -s /bin/sh www-data; \
    fi

# Use existing www-data user that comes with PHP packages
# Just ensure directories exist and have correct permissions
RUN mkdir -p /var/www/html /run/php /var/log/php82 \
    && chown -R www-data:www-data /var/www/html /run/php /var/log/php82 \
    && chmod 755 /var/www/html

# Set permissions
RUN chown -R www-data:www-data /var/www/html /run/php /var/log/php82

# Copy PHP-FPM configuration
COPY conf/php-fpm.conf /etc/php82/php-fpm.conf
COPY conf/www.conf /etc/php82/php-fpm.d/www.conf
COPY conf/php.ini /etc/php82/php.ini

# Copy WordPress setup script
COPY tools/wordpress_entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/wordpress_entrypoint.sh

WORKDIR /var/www/html

# Expose PHP-FPM port
EXPOSE 9000

# Switch to www-data user for security
USER www-data

# Start WordPress setup and PHP-FPM
ENTRYPOINT ["/usr/local/bin/wordpress_entrypoint.sh"]
CMD ["php-fpm82", "-F"]