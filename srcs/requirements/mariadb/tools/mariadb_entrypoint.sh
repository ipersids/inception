#!/bin/sh
set -e

# Read passwords from secrets
ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
USER_PASSWORD=$(cat /run/secrets/db_password)

# Initialize database if needed
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB database..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
    
    # Start temporary MariaDB for setup
    mysqld_safe --user=mysql --datadir=/var/lib/mysql &
    mysql_pid=$!
    
    # Wait for MariaDB to start
    for i in $(seq 30 -1 0); do
        if mysqladmin ping >/dev/null 2>&1; then
            break
        fi
        sleep 1
    done

    if [ "$i" = 0 ]; then
        echo "MariaDB failed to start"
        exit 1
    fi
    
    # Setup database and users
    mysql -u root <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${ROOT_PASSWORD}';
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${USER_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY '${ROOT_PASSWORD}';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOF

    # Stop temporary MariaDB
    kill $mysql_pid
    wait $mysql_pid
fi

# Start MariaDB normally
exec mysqld --user=mysql --datadir=/var/lib/mysql