#!/bin/bash

echo "=============================="
echo " INCEPTION PROJECT TEST SUITE "
echo "=============================="
echo

ERROR=0

ok()  { echo -e "✅ $1"; }
fail(){ echo -e "❌ $1"; ERROR=1; }

# -----------------------------
# 1. Docker checks
# -----------------------------
echo "[1] Docker checks"

docker --version >/dev/null 2>&1 && ok "Docker installed" || fail "Docker missing"
docker compose version >/dev/null 2>&1 && ok "Docker Compose installed" || fail "Docker Compose missing"

# -----------------------------
# 2. Containers running
# -----------------------------
echo
echo "[2] Containers running"

REQUIRED_CONTAINERS=("nginx" "wordpress" "mariadb")

for c in "${REQUIRED_CONTAINERS[@]}"; do
    docker ps --format '{{.Names}}' | grep -q "$c" \
        && ok "$c container running" \
        || fail "$c container NOT running"
done

# -----------------------------
# 3. Ports exposure
# -----------------------------
echo
echo "[3] Port exposure"

if docker ps --format '{{.Ports}}' | grep -q ":443->"; then
    ok "Port 443 exposed"
else
    fail "Port 443 NOT exposed"
fi

if docker ps --format '{{.Ports}}' | grep -q ":80->"; then
    fail "Port 80 must NOT be exposed"
else
    ok "Port 80 not exposed"
fi

# -----------------------------
# 4. TLS check
# -----------------------------
echo
echo "[4] TLS version"

echo | openssl s_client -connect localhost:443 -tls1_2 >/dev/null 2>&1 \
    && ok "TLS 1.2 supported" \
    || fail "TLS 1.2 NOT supported"

# -----------------------------
# 5. Docker network
# -----------------------------
echo
echo "[5] Docker network"

NETWORK_COUNT=$(docker network ls | grep -v bridge | grep -v host | grep -v none | wc -l)
[ "$NETWORK_COUNT" -ge 1 ] && ok "Custom Docker network exists" || fail "No custom Docker network"

# -----------------------------
# 6. Volumes
# -----------------------------
echo
echo "[6] Volumes"

docker volume ls | grep -q wordpress && ok "WordPress volume exists" || fail "WordPress volume missing"
docker volume ls | grep -q db && ok "MariaDB volume exists" || fail "MariaDB volume missing"

# -----------------------------
# 7. Restart policy
# -----------------------------
echo
echo "[7] Restart policy"

for c in "${REQUIRED_CONTAINERS[@]}"; do
    POLICY=$(docker inspect -f '{{.HostConfig.RestartPolicy.Name}}' "$c")
    [ "$POLICY" = "always" ] \
        && ok "$c restart policy = always" \
        || fail "$c restart policy incorrect"
done

# -----------------------------
# 8. Forbidden images
# -----------------------------
echo
echo "[8] Forbidden images"

docker images | grep -q latest \
    && fail "Found image using 'latest' tag" \
    || ok "No 'latest' tags used"

# -----------------------------
# 9. Credentials safety
# -----------------------------
echo
echo "[9] Credentials safety"

if grep -R "password" srcs/requirements/*/Dockerfile; then
    fail "Passwords found in Dockerfiles"
else
    ok "No passwords in Dockerfiles"
fi

# -----------------------------
# 10. WordPress DB connection
# -----------------------------
echo
echo "[10] WordPress ↔ MariaDB"

docker exec wordpress php -r "mysqli_connect(getenv('MYSQL_HOST'), getenv('MYSQL_USER'), getenv('MYSQL_PASSWORD'));" \
    >/dev/null 2>&1 \
    && ok "WordPress connected to MariaDB" \
    || fail "WordPress cannot connect to MariaDB"

# -----------------------------
# Final result
# -----------------------------
echo
echo "=============================="

if [ $ERROR -eq 0 ]; then
    echo "🎉 ALL MANDATORY TESTS PASSED"
else
    echo "⚠️ SOME TESTS FAILED"
fi

echo "=============================="
exit $ERROR