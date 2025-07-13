#!/bin/sh
set -e

echo "Starting WordPress setup..."

# Read database password from secret
if [ -f "/run/secrets/db_password" ]; then
    DB_PASSWORD=$(cat /run/secrets/db_password)
    echo "Database password loaded from secret"
else
    echo "Error: No database password secret found"
    exit 1
fi

# Wait for MariaDB to be ready
echo "Waiting for MariaDB to be ready..."
while ! nc -z mariadb 3306; do
    echo "MariaDB is not ready yet, waiting..."
    sleep 2
done
echo "MariaDB is ready!"

# Download WordPress if not already present
if [ ! -f "/var/www/html/index.php" ]; then
    echo "Downloading WordPress..."
    
    # Download and extract WordPress
    cd /tmp
    wget https://wordpress.org/latest.tar.gz
    tar -xzf latest.tar.gz
    
    # Move WordPress files to web directory
    cp -r wordpress/* /var/www/html/
    
    # Clean up
    rm -rf /tmp/wordpress /tmp/latest.tar.gz
    
    echo "WordPress downloaded and extracted"
fi

# Create wp-config.php if it doesn't exist
if [ ! -f "/var/www/html/wp-config.php" ]; then
    echo "Creating WordPress configuration..."
    
    # Generate WordPress salts
    SALTS=$(wget -qO- https://api.wordpress.org/secret-key/1.1/salt/)
    
    # Create wp-config.php
    cat > /var/www/html/wp-config.php << EOF
<?php
/**
 * WordPress Database Configuration
 */
define('DB_NAME', '${WORDPRESS_DB_NAME}');
define('DB_USER', '${WORDPRESS_DB_USER}');
define('DB_PASSWORD', '${DB_PASSWORD}');
define('DB_HOST', '${WORDPRESS_DB_HOST}');
define('DB_CHARSET', 'utf8mb4');
define('DB_COLLATE', '');

/**
 * Authentication Unique Keys and Salts
 */
${SALTS}

/**
 * WordPress Table prefix
 */
\$table_prefix = '${WORDPRESS_TABLE_PREFIX}';

/**
 * WordPress Debug mode
 */
define('WP_DEBUG', ${WORDPRESS_DEBUG});

/**
 * WordPress Additional Configuration
 */
 define('WP_HOME', 'https://${DOMAIN_NAME}');
define('WP_SITEURL', 'https://${DOMAIN_NAME}');
define('FORCE_SSL_ADMIN', false);
define('WP_MEMORY_LIMIT', '256M');

/* That's all, stop editing! Happy publishing. */

/** Absolute path to the WordPress directory. */
if ( ! defined( 'ABSPATH' ) ) {
    define( 'ABSPATH', __DIR__ . '/' );
}

/** Sets up WordPress vars and included files. */
require_once ABSPATH . 'wp-settings.php';
EOF


    echo "WordPress configuration created"
fi

# Test database connection
echo "Testing database connection..."
php -r "
\$conn = new mysqli('${WORDPRESS_DB_HOST}', '${WORDPRESS_DB_USER}', '${DB_PASSWORD}', '${WORDPRESS_DB_NAME}');
if (\$conn->connect_error) {
    echo 'Database connection failed: ' . \$conn->connect_error . PHP_EOL;
    exit(1);
}
echo 'Database connection successful!' . PHP_EOL;
\$conn->close();
"

echo "WordPress setup completed successfully!"

# Execute the command passed to the container
exec "$@"