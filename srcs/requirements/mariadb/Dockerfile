FROM debian:latest

RUN apt update && apt upgrade && apt install -y mariadb-server

COPY 50-server.cnf /etc/mysql/mariadb.conf.d/.


RUN mkdir /run/mysqld

EXPOSE 3306

CMD ["mysqld"]
