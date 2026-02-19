#!/bin/bash

set -e

echo "[WordPress] Starting initialization..."

# Set permissions
echo "[WordPress] Setting up permissions..."
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html
mkdir -p /run/php/

# Wait for database to be ready
echo "[WordPress] Waiting for MariaDB to be ready..."
max_attempts=30
attempts=0
while [ $attempts -lt $max_attempts ]; do
    if wp db check --allow-root 2>/dev/null; then
        echo "[WordPress] Database is ready!"
        break
    fi
    attempts=$((attempts + 1))
    echo "[WordPress] Attempt $attempts/$max_attempts - waiting for database..."
    sleep 2
done

if [ $attempts -eq $max_attempts ]; then
    echo "[WordPress] ERROR: Database failed to initialize"
    exit 1
fi

# Check if WordPress is already installed
if ! wp core is-installed --allow-root 2>/dev/null; then
    echo "[WordPress] Installing WordPress..."
    
    # Install WordPress core
    wp core install \
        --allow-root \
        --url="${WP_URL:-http://localhost}" \
        --title="${WP_TITLE:-My Awesome Site}" \
        --admin_user="${WP_ADMIN_LOGIN:-admin}" \
        --admin_password="${WP_ADMIN_PASSWORD:-admin123}" \
        --admin_email="${WP_ADMIN_EMAIL:-admin@example.com}" \
        --skip-email
    
    echo "[WordPress] Creating additional user..."
    wp user create \
        --allow-root \
        "${WP_USER_LOGIN:-user}" \
        "${WP_USER_EMAIL:-user@example.com}" \
        --user_pass="${WP_USER_PASSWORD:-user123}" \
        --role=editor || true
    
    echo "[WordPress] Installing and activating Twentytwentyfour theme..."
    wp theme install twentytwentyfour --allow-root || true
    wp theme activate twentytwentyfour --allow-root || true
    
    echo "[WordPress] Installing useful plugins..."
    wp plugin install classic-editor --allow-root --activate || true
    wp plugin install jetpack --allow-root || true
    
    echo "[WordPress] Installation complete!"
else
    echo "[WordPress] Already installed, skipping setup"
fi

echo "[WordPress] Starting PHP-FPM..."
exec "$@"