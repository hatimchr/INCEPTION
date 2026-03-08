#!/bin/bash
cd /var/www/html
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
./wp-cli.phar core download --allow-root

# Wait for MariaDB to be ready
until mysql -h mariadb -u $DB_USER -p$DB_PASS -e "SELECT 1" > /dev/null 2>&1; do
  echo "Waiting for database connection..."
  sleep 2
done

rm -f wp-config.php
./wp-cli.phar config create --dbname=$DB_NAME --dbuser=$DB_USER --dbpass=$DB_PASS --dbhost=mariadb:3306 --allow-root
./wp-cli.phar core install --url=$WP_URL --title=inception --admin_user=$WP_ADMIN_USER --admin_password=$WP_ADMIN_PASS --admin_email=$WP_ADMIN_EMAIL --allow-root
./wp-cli.phar user create $WP_USER $WP_USER_EMAIL --role=subscriber --user_pass=$WP_USER_PASS --allow-root

./wp-cli.phar option update siteurl "https://$WP_URL" --allow-root
./wp-cli.phar option update home "https://$WP_URL" --allow-root
/usr/sbin/php-fpm8.4 -F
