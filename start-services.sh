#!/bin/bash

###############################################################################
# Script de démarrage des services Campus Platform
###############################################################################

echo "🚀 Démarrage des services Campus Platform..."

sudo systemctl start bind9
sudo systemctl start nginx
sudo systemctl start mariadb
sudo systemctl start squid
sudo systemctl start vsftpd
sudo systemctl start tftpd-hpa

echo ""
echo "⚠️  DHCP non démarré automatiquement"
echo "    Configurez d'abord une IP statique puis lancez:"
echo "    sudo systemctl start isc-dhcp-server"
echo ""
echo "✓ Services démarrés"
./check-services.sh
