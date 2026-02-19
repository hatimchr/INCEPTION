FROM debian:bullseye

RUN apt-get update && apt-get install -y \
    nginx \
    openssl \
    && rm -rf /var/lib/apt/lists/*

# Remove default configuration
RUN rm -rf /etc/nginx/sites-enabled/default

# Copy custom configuration
COPY conf/nginx.conf /etc/nginx/sites-available/
RUN ln -s /etc/nginx/sites-available/nginx.conf /etc/nginx/sites-enabled/

# Create SSL directory
RUN mkdir -p /etc/nginx/ssl

# Generate SSL certificate (you'll replace this with proper certs)
RUN openssl req -newkey rsa:2048 -nodes \
    -keyout /etc/nginx/ssl/nginx.key \
    -x509 -days 365 \
    -out /etc/nginx/ssl/nginx.crt \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost"

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]
