#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}=== WordPress & Docker Stack Testing Script ===${NC}\n"

# Test 1: Check if all containers are running
echo -e "${YELLOW}[1] Checking container status...${NC}"
if docker ps | grep -q mariadb && docker ps | grep -q wordpress && docker ps | grep -q nginx; then
    echo -e "${GREEN}✓ All containers are running${NC}"
    docker ps --filter "name=mariadb\|wordpress\|nginx" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
else
    echo -e "${RED}✗ Some containers are not running${NC}"
    docker ps -a --filter "name=mariadb\|wordpress\|nginx"
    exit 1
fi

echo ""

# Test 2: Check MariaDB connection
echo -e "${YELLOW}[2] Testing MariaDB connection...${NC}"
if docker exec mariadb mysqladmin ping -h localhost --silent 2>/dev/null; then
    echo -e "${GREEN}✓ MariaDB is responding to ping${NC}"
else
    echo -e "${RED}✗ MariaDB is not responding${NC}"
    exit 1
fi

echo ""

# Test 3: Check database exists
echo -e "${YELLOW}[3] Checking WordPress database...${NC}"
if docker exec mariadb mysql -uroot -e "USE wordpress;" 2>/dev/null || docker exec mariadb mysql -uroot -p$MYSQL_ROOT_PASSWORD -e "USE wordpress;" 2>/dev/null; then
    echo -e "${GREEN}✓ WordPress database exists${NC}"
    # Check if tables exist
    TABLE_COUNT=$(docker exec mariadb mysql -uroot -e "USE wordpress; SHOW TABLES;" 2>/dev/null | wc -l)
    if [ "$TABLE_COUNT" -gt 1 ]; then
        echo -e "${GREEN}✓ Database contains tables ($((TABLE_COUNT-1)) tables)${NC}"
    else
        echo -e "${YELLOW}⚠ Database exists but no tables found (WordPress may need installation)${NC}"
    fi
else
    echo -e "${RED}✗ WordPress database not found${NC}"
fi

echo ""

# Test 4: Check WordPress files
echo -e "${YELLOW}[4] Checking WordPress installation...${NC}"
if docker exec wordpress test -f /var/www/html/wp-config.php || docker exec wordpress test -d /var/www/html/wp-admin; then
    echo -e "${GREEN}✓ WordPress files are present${NC}"
    docker exec wordpress ls -la /var/www/html/ | head -10
else
    echo -e "${YELLOW}⚠ WordPress files not found in /var/www/html${NC}"
fi

echo ""

# Test 5: Check PHP-FPM
echo -e "${YELLOW}[5] Testing PHP-FPM...${NC}"
if docker exec wordpress php-fpm7.4 -v > /dev/null 2>&1; then
    echo -e "${GREEN}✓ PHP-FPM is installed${NC}"
    docker exec wordpress php-fpm7.4 -v | head -1
else
    echo -e "${RED}✗ PHP-FPM is not working${NC}"
fi

echo ""

# Test 6: Check Nginx configuration
echo -e "${YELLOW}[6] Testing Nginx configuration...${NC}"
if docker exec nginx nginx -t > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Nginx configuration is valid${NC}"
else
    echo -e "${RED}✗ Nginx configuration has errors${NC}"
    docker exec nginx nginx -t
fi

echo ""

# Test 7: Check HTTPS connection
echo -e "${YELLOW}[7] Testing HTTPS connection (port 443)...${NC}"
if curl -k -s -o /dev/null -w "%{http_code}" https://localhost:443 | grep -q "200\|301\|302\|404"; then
    HTTP_CODE=$(curl -k -s -o /dev/null -w "%{http_code}" https://localhost:443)
    echo -e "${GREEN}✓ Nginx is responding on port 443 (HTTP $HTTP_CODE)${NC}"
else
    echo -e "${RED}✗ Cannot connect to Nginx on port 443${NC}"
fi

echo ""

# Test 8: Check SSL certificate
echo -e "${YELLOW}[8] Checking SSL certificate...${NC}"
if docker exec nginx test -f /etc/nginx/ssl/nginx.crt; then
    echo -e "${GREEN}✓ SSL certificate exists${NC}"
    CERT_INFO=$(docker exec nginx openssl x509 -in /etc/nginx/ssl/nginx.crt -noout -subject -dates 2>/dev/null)
    echo "$CERT_INFO" | head -3
else
    echo -e "${RED}✗ SSL certificate not found${NC}"
fi

echo ""

# Test 9: Check network connectivity between containers
echo -e "${YELLOW}[9] Testing inter-container connectivity...${NC}"

# Test MySQL connection from WordPress to MariaDB
# First check if we can reach the MariaDB server (network connectivity)
if docker exec wordpress php -r "\$conn = @mysqli_connect('mariadb', 'invalid_user', 'invalid_pass', '', 3306); echo 'reachable';" 2>/dev/null | grep -q "reachable"; then
    echo -e "${GREEN}✓ WordPress can reach MariaDB server (network OK)${NC}"
    # Now test actual connection with credentials
    if docker exec wordpress php -r "\$conn = @mysqli_connect('mariadb', 'wp_user', 'secure_wp_password_123', 'wordpress'); echo \$conn ? 'connected' : 'failed';" 2>/dev/null | grep -q "connected"; then
        echo -e "${GREEN}✓ WordPress can connect to MariaDB database with credentials${NC}"
    else
        echo -e "${YELLOW}⚠ WordPress can reach MariaDB but connection failed (check database/user exists)${NC}"
    fi
else
    # Try checking if hostname resolves
    if docker exec wordpress getent hosts mariadb > /dev/null 2>&1; then
        echo -e "${YELLOW}⚠ WordPress can resolve MariaDB hostname but cannot connect (check MariaDB is running)${NC}"
    else
        echo -e "${RED}✗ WordPress cannot resolve MariaDB hostname${NC}"
    fi
fi

# Test PHP-FPM connection from Nginx to WordPress
# Check if nginx can resolve wordpress hostname
if docker exec nginx getent hosts wordpress > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Nginx can resolve WordPress hostname${NC}"
    # Check if PHP-FPM port is accessible (port 9000)
    if docker exec nginx sh -c "timeout 1 bash -c '</dev/tcp/wordpress/9000' 2>/dev/null" 2>/dev/null; then
        echo -e "${GREEN}✓ Nginx can reach WordPress PHP-FPM on port 9000${NC}"
    else
        echo -e "${YELLOW}⚠ Nginx cannot reach PHP-FPM port (but nginx config may still work)${NC}"
    fi
else
    echo -e "${RED}✗ Nginx cannot resolve WordPress hostname${NC}"
fi

echo ""

# Test 10: Check volumes
echo -e "${YELLOW}[10] Checking volumes...${NC}"
if [ -d "/root/hatim/data/mariadb" ]; then
    echo -e "${GREEN}✓ MariaDB volume exists${NC}"
else
    echo -e "${RED}✗ MariaDB volume directory missing${NC}"
fi

if [ -d "/root/hatim/data/wordpress" ]; then
    echo -e "${GREEN}✓ WordPress volume exists${NC}"
    WP_FILE_COUNT=$(ls -A /root/hatim/data/wordpress 2>/dev/null | wc -l)
    echo "  → Contains $WP_FILE_COUNT files/directories"
else
    echo -e "${RED}✗ WordPress volume directory missing${NC}"
fi

echo ""

# Summary
echo -e "${YELLOW}=== Testing Complete ===${NC}"
echo ""
echo -e "To access WordPress:"
echo -e "  1. Add to /etc/hosts: ${GREEN}127.0.0.1 hchair.42.fr${NC}"
echo -e "  2. Visit: ${GREEN}https://hchair.42.fr${NC} (or https://localhost)"
echo -e "  3. Accept the self-signed SSL certificate warning"
echo ""
echo -e "${YELLOW}Note:${NC} If nginx.conf has a different server_name, use that domain instead."
echo ""

