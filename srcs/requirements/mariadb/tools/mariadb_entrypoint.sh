#!/bin/sh

# Exit on error
set -e

# Initialize empty variables
ROOT_PASSWORD=""
USER_PASSWORD=""

# Read ROOT_PASSWORD from secrets
if [ -f "/run/secrets/db_root_password" ]; then
    ROOT_PASSWORD=$(cat /run/secrets/db_root_password)
    echo "Root password loaded from secret"
else
    echo "Error: No root password secret found"
    exit 1
fi

# Read USER_PASSWORD from secrets
if [ -f "/run/secrets/db_password" ]; then
    USER_PASSWORD=$(cat /run/secrets/db_password)
    echo "User password loaded from secret"
else
    echo "Error: No user password secret found"
    exit 1
fi

# Check if database needs initialization
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MariaDB database..."
    
    # Creates the initial MariaDB system databases and tables
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
    
    # Start MariaDB temporarily for setup
	# Wrapper script that monitors and restarts mysqld if it crashes
	# Temporary instance allows setup queries
    mysqld_safe --user=mysql --datadir=/var/lib/mysql &
    mysql_pid=$!
    
    # Wait for MariaDB to start
    echo "Waiting for MariaDB to start..."
    for i in $(seq 30 -1 0); do
		# Sends a simple ping to test connectivity
        if mysqladmin ping >/dev/null 2>&1; then
            break
        fi
        echo "MariaDB is starting... $i"
        sleep 1
    done

	# If loop completes without break (i=0), MariaDB failed to start
	if [ "$i" = 0 ]; then
        echo "MariaDB failed to start"
        exit 1
    fi
    
	# Setup database and users
    mysql -u root <<EOF
-- Set root password (using newer syntax)
ALTER USER 'root'@'localhost' IDENTIFIED BY '${ROOT_PASSWORD}';

-- Remove anonymous users
DELETE FROM mysql.user WHERE User='';

-- Remove remote root (keep only localhost initially)
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');

-- Remove test database
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';

-- Create application database
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;

-- Create application user
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${USER_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';

-- Allow root remote access with password
CREATE USER IF NOT EXISTS 'root'@'%' IDENTIFIED BY '${ROOT_PASSWORD}';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' WITH GRANT OPTION;

FLUSH PRIVILEGES;
EOF

    echo "Database setup completed"
    
    # Stop temporary MariaDB
	# Sends TERM signal to mysqld_safe process
    kill $mysql_pid
	# Ensures process fully stops before continuing
    wait $mysql_pid
fi

# Start MariaDB normally
echo "Starting MariaDB..."
# mysqld becomes PID 1, receives signals directly
exec mysqld --user=mysql --datadir=/var/lib/mysql