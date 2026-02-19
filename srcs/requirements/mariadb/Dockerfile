FROM debian:bullseye

RUN apt-get update && apt-get install -y \
    mariadb-server \
    mariadb-client \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /etc/mysql/conf.d
COPY conf/my.cnf /etc/mysql/conf.d/
COPY tools/setup.sql /tmp/

RUN mkdir -p /var/run/mysqld \
    && chown -R mysql:mysql /var/run/mysqld \
    && chmod 755 /var/run/mysqld

EXPOSE 3306

COPY tools/entrypoint.sh /usr/local/bin/
# Replace bind-address in 50-server.cnf to allow external connections
RUN sed -i 's/bind-address\s*=\s*127\.0\.0\.1/bind-address = 0.0.0.0/' /etc/mysql/mariadb.conf.d/50-server.cnf
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["mysqld_safe"]