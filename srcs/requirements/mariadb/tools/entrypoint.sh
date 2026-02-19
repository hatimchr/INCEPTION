#!/bin/bash
set -e

echo "Starting MariaDB initialization..."

# Create necessary directories
mkdir -p /var/run/mysqld
chown -R mysql:mysql /var/run/mysqld

# Initialize database if it doesn't exist
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "First-time setup: Initializing database..."
    
    # Install database
    mysql_install_db --user=mysql --datadir=/var/lib/mysql
    
    # Start temporary server
    mysqld_safe --skip-networking &
    sleep 10
    
    # Set root password and create database
    mysql << EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
CREATE USER IF NOT EXISTS '${WP_ADMIN_USER}'@'%' IDENTIFIED BY '${WP_ADMIN_PASSWORD}';
GRANT ALL ON \`${MYSQL_DATABASE}\`.* TO '${WP_ADMIN_USER}'@'%';
FLUSH PRIVILEGES;
EOF
    
    # Stop temporary server
    mysqladmin -uroot -p${MYSQL_ROOT_PASSWORD} shutdown
    sleep 5
fi

echo "Starting MariaDB server..."
exec "$@"