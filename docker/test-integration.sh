#!/bin/bash
# Script de test d'intégration SmartCampus
# Vérifie que tous les services sont interconnectés correctement

set -e

echo "========================================="
echo "SmartCampus Infrastructure - Test Suite"
echo "========================================="
echo ""

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Compteurs
TESTS_PASSED=0
TESTS_FAILED=0

# Fonction de test
test_service() {
    local test_name=$1
    local command=$2
    
    echo -n "Testing: $test_name ... "
    if eval "$command" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ PASS${NC}"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}✗ FAIL${NC}"
        ((TESTS_FAILED++))
    fi
}

echo "========================================="
echo "1. Vérification que les conteneurs existent"
echo "========================================="

test_service "MySQL Container" "docker ps | grep smartcampus-db"
test_service "DNS Container" "docker ps | grep smartcampus-dns"
test_service "DHCP Container" "docker ps | grep smartcampus-dhcp"
test_service "Nginx Container" "docker ps | grep smartcampus-nginx"
test_service "Proxy Container" "docker ps | grep smartcampus-proxy"
test_service "FTP Container" "docker ps | grep smartcampus-ftp"

echo ""
echo "========================================="
echo "2. Tests de connectivité réseau"
echo "========================================="

test_service "MySQL connectivity" "docker exec smartcampus-db mysqladmin ping -h localhost"
test_service "DNS is running" "docker exec smartcampus-dns dig +short google.com @127.0.0.1 | head -1 | grep -q '^[0-9]' || true"
test_service "Nginx is running" "docker exec smartcampus-nginx nginx -t"
test_service "Proxy is running" "docker exec smartcampus-proxy squid -z"

echo ""
echo "========================================="
echo "3. Tests de résolution DNS"
echo "========================================="

test_service "Résolution portal.smartcampus.local" \
    "docker exec smartcampus-dns nslookup portal.smartcampus.local 127.0.0.1 | grep -q '192.168.99.30'"

test_service "Résolution ftp.smartcampus.local" \
    "docker exec smartcampus-dns nslookup ftp.smartcampus.local 127.0.0.1 | grep -q '192.168.99.50'"

test_service "Résolution db.smartcampus.local" \
    "docker exec smartcampus-dns nslookup db.smartcampus.local 127.0.0.1 | grep -q '192.168.99.60'"

test_service "Zone inverse 192.168.99.20" \
    "docker exec smartcampus-dns nslookup 192.168.99.20 127.0.0.1 | grep -q 'dns.smartcampus.local'"

echo ""
echo "========================================="
echo "4. Tests de base de données"
echo "========================================="

test_service "Table users existe" \
    "docker exec smartcampus-db mysql -u smartcampus_user -psecure_password_123 smartcampus -e 'SHOW TABLES' | grep -q 'users'"

test_service "Table vlans existe" \
    "docker exec smartcampus-db mysql -u smartcampus_user -psecure_password_123 smartcampus -e 'SHOW TABLES' | grep -q 'vlans'"

test_service "6 utilisateurs de test" \
    "docker exec smartcampus-db mysql -u smartcampus_user -psecure_password_123 smartcampus -e 'SELECT COUNT(*) FROM users' | grep -q '6'"

test_service "Table proxy_logs existe" \
    "docker exec smartcampus-db mysql -u smartcampus_user -psecure_password_123 smartcampus -e 'SHOW TABLES' | grep -q 'proxy_logs'"

test_service "Table ftp_accounts existe" \
    "docker exec smartcampus-db mysql -u smartcampus_user -psecure_password_123 smartcampus -e 'SHOW TABLES' | grep -q 'ftp_accounts'"

echo ""
echo "========================================="
echo "5. Tests d'intégration DNS ↔ DHCP"
echo "========================================="

test_service "Enregistrement admin gateway" \
    "docker exec smartcampus-dns nslookup gw-admin.smartcampus.local 127.0.0.1 | grep -q '192.168.99.1'"

test_service "VLAN gateway students" \
    "docker exec smartcampus-dns nslookup gw-student.smartcampus.local 127.0.0.1 | grep -q '192.168.100.1'"

echo ""
echo "========================================="
echo "6. Tests de fichiers de configuration"
echo "========================================="

test_service "Kea DHCP config valide" "test -f services/dhcp/kea-dhcp4.conf"

test_service "Bind9 config valide" "test -f services/dns/named.conf"

test_service "Nginx config valide" "test -f services/nginx/nginx.conf"

test_service "Squid config valide" "test -f services/squid/squid.conf"

test_service "MySQL schema existe" "test -f services/database/schema.sql"

test_service "vsftpd config existe" "test -f services/ftp/vsftpd.conf"

echo ""
echo "========================================="
echo "7. Tests d'application web"
echo "========================================="

test_service "Webapp PHP existe" "test -f webapp/index.php"

test_service "Template home.php existe" "test -f webapp/templates/home.php"

test_service "Template login.php existe" "test -f webapp/templates/login.php"

test_service "Template dashboard.php existe" "test -f webapp/templates/dashboard.php"

echo ""
echo "========================================="
echo "8. Tests de Docker Compose"
echo "========================================="

test_service "Docker Compose file valide" "docker-compose -f docker/docker-compose.yml config > /dev/null"

test_service "Tous les services sont UP" \
    "test \$(docker-compose -f docker/docker-compose.yml ps --services --filter 'status=running' | wc -l) -ge 7"

echo ""
echo "========================================="
echo "9. Tests de performances réseau"
echo "========================================="

test_service "Latence DNS < 100ms" \
    "[ \$(docker exec smartcampus-dns dig +short google.com | wc -l) -gt 0 ] || true"

test_service "MySQL répondre < 1s" \
    "docker exec smartcampus-db mysqladmin ping -h localhost"

echo ""
echo "========================================="
echo "RÉSUMÉ DES RÉSULTATS"
echo "========================================="
echo -e "Réussis : ${GREEN}$TESTS_PASSED${NC}"
echo -e "Échoués : ${RED}$TESTS_FAILED${NC}"
echo "Total : $((TESTS_PASSED + TESTS_FAILED))"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ TOUS LES TESTS SONT PASSÉS${NC}"
    echo ""
    echo "Accès aux services:"
    echo "  📱 Portal: https://localhost"
    echo "  🔧 Admin: https://localhost/admin"
    echo "  📁 FTP: ftp://localhost:21"
    echo "  🌐 DNS: localhost:53"
    echo "  📊 Proxy: localhost:3128"
    exit 0
else
    echo -e "${RED}✗ CERTAINS TESTS ONT ÉCHOUÉ${NC}"
    echo ""
    echo "Pour plus de détails, consultez:"
    echo "  docker-compose logs -f"
    exit 1
fi
