#!/bin/sh
set -e

# Read passwords
DB_PASSWORD=$(cat /run/secrets/db_password)
DB_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)

echo "Waiting for database connection..."
TIMEOUT=30
COUNTER=0

while ! nc -z mariadb 3306; do
    COUNTER=$((COUNTER + 1))
    if [ $COUNTER -gt $TIMEOUT ]; then
        echo "ERROR: Database port not accessible after $TIMEOUT attempts"
        exit 1
    fi
    echo "Waiting for database port... ($COUNTER/$TIMEOUT)"
    sleep 2
done

if [ ! -f "wp-config.php" ]; then
    [ ! -f "wp-load.php" ] && wp core download --allow-root
    cat > wp-config.php << EOF
<?php
define('DB_HOST', '$WORDPRESS_DB_HOST');
define('DB_NAME', '$WORDPRESS_DB_NAME');
define('DB_USER', '$WORDPRESS_DB_USER');
define('DB_PASSWORD', '$DB_PASSWORD');
define('DB_CHARSET', 'utf8mb4');
define('DB_COLLATE', '');
$(cat /run/secrets/credentials)
\$table_prefix = 'wp_';
define('WP_DEBUG', false);
if (!defined('ABSPATH')) define('ABSPATH', __DIR__ . '/');
require_once ABSPATH . 'wp-settings.php';
EOF
    # Install WordPress if not already installed
    if ! wp core is-installed --allow-root 2>/dev/null; then
        wp core install \
            --url="https://$DOMAIN_NAME" \
            --title="$WORDPRESS_TITLE" \
            --admin_user="$WORDPRESS_DB_ADMIN_USER" \
            --admin_password="$DB_ROOT_PASSWORD" \
            --admin_email="$WORDPRESS_DB_ADMIN_USER_EMAIL" \
            --allow-root
        
        wp user create \
            "$WORDPRESS_DB_USER" \
            "$WORDPRESS_DB_USER_EMAIL" \
            --role=author \
            --user_pass="$DB_PASSWORD" \
            --allow-root
    fi
fi
exec php-fpm82 -F