#!/bin/sh
set -e

# Read database password from secret
DB_PASSWORD=$(cat /run/secrets/db_password)

# Wait for MariaDB
while ! nc -z mariadb 3306; do
    sleep 2
done

# Download WordPress if not present
if [ ! -f "/var/www/html/index.php" ]; then
    cd /tmp
    wget https://wordpress.org/latest.tar.gz
    tar -xzf latest.tar.gz
    cp -r wordpress/* /var/www/html/
    rm -rf /tmp/wordpress /tmp/latest.tar.gz
fi

# Create wp-config.php if not exists
if [ ! -f "/var/www/html/wp-config.php" ]; then
    SALTS=$(wget -qO- https://api.wordpress.org/secret-key/1.1/salt/)
    
    cat > /var/www/html/wp-config.php << EOF
<?php
define('DB_NAME', '${WORDPRESS_DB_NAME}');
define('DB_USER', '${WORDPRESS_DB_USER}');
define('DB_PASSWORD', '${DB_PASSWORD}');
define('DB_HOST', '${WORDPRESS_DB_HOST}');
define('DB_CHARSET', 'utf8mb4');
define('DB_COLLATE', '');

${SALTS}

\$table_prefix = '${WORDPRESS_TABLE_PREFIX}';
define('WP_DEBUG', ${WORDPRESS_DEBUG});
define('WP_HOME', 'https://${DOMAIN_NAME}');
define('WP_SITEURL', 'https://${DOMAIN_NAME}');

if ( ! defined( 'ABSPATH' ) ) {
    define( 'ABSPATH', __DIR__ . '/' );
}

require_once ABSPATH . 'wp-settings.php';
EOF
fi

# Test database connection
php -r "
\$conn = new mysqli('${WORDPRESS_DB_HOST}', '${WORDPRESS_DB_USER}', '${DB_PASSWORD}', '${WORDPRESS_DB_NAME}');
if (\$conn->connect_error) {
    exit(1);
}
\$conn->close();
"

exec "$@"