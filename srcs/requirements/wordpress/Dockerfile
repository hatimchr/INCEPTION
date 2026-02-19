FROM debian:bullseye

RUN apt-get update && apt-get install -y \
    php \
    php-fpm \
    php-mysql \
    php-curl \
    php-json \
    php-mbstring \
    php-xml \
    php-zip \
    php-gd \
    php-xmlrpc \
    curl \
    wget \
    ca-certificates \
    sudo \
    tar \
    less \
    grep \
    && rm -rf /var/lib/apt/lists/*

# Install WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

# Create WordPress directory
RUN mkdir -p /var/www/html

# Download and extract WordPress
RUN cd /tmp && \
    wget https://wordpress.org/latest.tar.gz && \
    tar -xzf latest.tar.gz && \
    cp -r wordpress/* /var/www/html/ && \
    rm -rf /tmp/wordpress* && \
    chown -R www-data:www-data /var/www/html && \
    chmod -R 755 /var/www/html

# Keep backward-compatible path
RUN ln -s /var/www/html /var/www/wordpress || true

# Create necessary directories for PHP-FPM
RUN mkdir -p /run/php && \
    mkdir -p /var/lib/php/sessions && \
    chown -R www-data:www-data /var/lib/php/sessions

# Copy configuration files
COPY tools/wp-config.php /var/www/html/
COPY conf/www.conf /etc/php/7.4/fpm/pool.d/
COPY tools/wordpress_start.sh /usr/local/bin/wordpress-entrypoint.sh

RUN chmod +x /usr/local/bin/wordpress-entrypoint.sh

WORKDIR /var/www/html

EXPOSE 9000

ENTRYPOINT ["/usr/local/bin/wordpress-entrypoint.sh"]
CMD ["php-fpm7.4", "-F"]
