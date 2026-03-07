#!/bin/bash
cd /var/www/html
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
chmod +x wp-cli.phar
./wp-cli.phar core download --allow-root
./wp-cli.phar config create --dbname=wordpress --dbuser=wpuser --dbpass=password --dbhost=mariadb:3306 --allow-root
./wp-cli.phar core install --url=hchair.42.fr --title=inception --admin_user=hchair --admin_password=hchair --admin_email=hchair@hchair.com --allow-root
./wp-cli.phar user create karim karim@example.com --role=subscriber --user_pass=karim --allow-root

./wp-cli.phar option update siteurl 'http://hchair.42.fr' --allow-root
./wp-cli.phar option update home 'http://hchair.42.fr' --allow-root
php-fpm8.2 -F
