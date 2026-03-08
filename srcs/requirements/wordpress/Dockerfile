FROM debian:latest

RUN apt update && apt upgrade && apt install -y php-fpm php-mysqli curl mariadb-client

COPY www.conf /etc/php/8.4/fpm/pool.d/.
COPY script.sh .
RUN chmod +x script.sh

CMD ["./script.sh"]
#CMD ["./script.sh"]
