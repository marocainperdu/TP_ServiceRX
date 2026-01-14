#!/bin/bash

###############################################################################
# Script de vérification des services Campus Platform
###############################################################################

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "========================================"
echo "🔍 Vérification des services"
echo "========================================"
echo ""

check_service() {
    local service=$1
    local port=$2
    
    if systemctl is-active --quiet $service; then
        echo -e "${GREEN}✓${NC} $service (actif)"
        if [ -n "$port" ]; then
            if netstat -tuln | grep -q ":$port "; then
                echo -e "  └─ Port $port: ${GREEN}OK${NC}"
            else
                echo -e "  └─ Port $port: ${RED}NON ÉCOUTÉ${NC}"
            fi
        fi
    else
        echo -e "${RED}✗${NC} $service (inactif)"
    fi
}

# Vérifier chaque service
check_service "bind9" "53"
check_service "isc-dhcp-server" "67"
check_service "nginx" "80"
check_service "mariadb" "3306"
check_service "squid" "3128"
check_service "vsftpd" "21"
check_service "tftpd-hpa" "69"

echo ""
echo "========================================"
echo "🌐 Tests de connectivité"
echo "========================================"

# Test DNS
echo -n "DNS (campus.local): "
if host campus.local localhost > /dev/null 2>&1; then
    echo -e "${GREEN}OK${NC}"
else
    echo -e "${RED}ERREUR${NC}"
fi

# Test Web
echo -n "Web (port 80): "
if curl -s http://localhost > /dev/null; then
    echo -e "${GREEN}OK${NC}"
else
    echo -e "${RED}ERREUR${NC}"
fi

# Test Proxy
echo -n "Proxy (port 3128): "
if curl -s -x http://localhost:3128 http://www.google.com > /dev/null 2>&1; then
    echo -e "${GREEN}OK${NC}"
else
    echo -e "${YELLOW}ATTENTION${NC}"
fi

# Test MariaDB
echo -n "MariaDB: "
if mysql -u campus_user -pcampus_pass -e "SELECT 1" > /dev/null 2>&1; then
    echo -e "${GREEN}OK${NC}"
else
    echo -e "${RED}ERREUR${NC}"
fi

echo ""
echo "========================================"
echo "📊 Utilisation des ressources"
echo "========================================"
free -h | grep Mem
df -h / | tail -1

echo ""
