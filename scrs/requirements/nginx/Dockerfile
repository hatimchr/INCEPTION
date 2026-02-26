FROM	debian:buster

# Debian Buster is EOL - use archive.debian.org
RUN sed -i 's|deb.debian.org|archive.debian.org|g' /etc/apt/sources.list \
    && sed -i 's|security.debian.org|archive.debian.org|g' /etc/apt/sources.list \
    && sed -i '/buster-updates/d' /etc/apt/sources.list

#install all the program
RUN apt-get -o Acquire::Check-Valid-Until=false update
RUN apt-get install -y nginx \
                openssl

# nginx SSL
RUN mkdir /etc/nginx/ssl
RUN openssl req -newkey rsa:4096 -x509 -sha256 -days 365 -nodes \
       -out /etc/nginx/ssl/hchair.crt \
       -keyout /etc/nginx/ssl/hchair.key \
       -subj "/C=FR/ST=Paris/L=Paris/O=42 School/OU=hchair/CN=hchair/"

COPY ./conf/nginx.conf /etc/nginx/conf.d

# nginx config
RUN mkdir -p /run/nginx

#the only port allowed
EXPOSE	443

# Start nginx
CMD ["nginx", "-g", "daemon off;"]