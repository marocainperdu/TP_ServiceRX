#!/bin/bash

###############################################################################
# Script d'arrêt des services Campus Platform
###############################################################################

echo "🛑 Arrêt des services Campus Platform..."

sudo systemctl stop bind9
sudo systemctl stop isc-dhcp-server
sudo systemctl stop nginx
sudo systemctl stop mariadb
sudo systemctl stop squid
sudo systemctl stop vsftpd
sudo systemctl stop tftpd-hpa

echo "✓ Tous les services sont arrêtés"
