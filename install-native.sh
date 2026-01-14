#!/bin/bash

###############################################################################
# Script d'installation CAMPUS PLATFORM - Version Native (Sans Docker)
# Compatible : Ubuntu 20.04/22.04/24.04, Debian 11/12
###############################################################################

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}"
cat << "EOF"
╔════════════════════════════════════════════════════════════╗
║        🏫 CAMPUS PLATFORM - Installation Native            ║
║        Installation complète sans Docker                   ║
╚════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Vérifier les privilèges root
if [[ $EUID -ne 0 ]]; then
   echo -e "${RED}❌ Ce script doit être exécuté en tant que root (sudo)${NC}"
   exit 1
fi

echo -e "${GREEN}✓${NC} Exécution en tant que root"

# Configuration réseau
SUBNET="10.20.0.0/16"
SERVER_IP="10.20.0.1"
DNS_IP="10.20.0.10"
DOMAIN="campus.local"

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}📋 Configuration du système${NC}"
echo -e "${BLUE}========================================${NC}"
echo "Réseau: $SUBNET"
echo "IP Serveur: $SERVER_IP"
echo "DNS: $DNS_IP"
echo "Domaine: $DOMAIN"
echo ""

read -p "Continuer l'installation ? (o/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Oo]$ ]]; then
    echo "Installation annulée."
    exit 1
fi

###############################################################################
# 1. MISE À JOUR DU SYSTÈME
###############################################################################
echo ""
echo -e "${BLUE}[1/8]${NC} ${YELLOW}Mise à jour du système...${NC}"
apt update && apt upgrade -y

###############################################################################
# 2. INSTALLATION DES PAQUETS
###############################################################################
echo ""
echo -e "${BLUE}[2/8]${NC} ${YELLOW}Installation des services...${NC}"

# Serveurs de base
apt install -y \
    bind9 bind9utils bind9-doc \
    isc-dhcp-server \
    nginx \
    mariadb-server mariadb-client \
    squid \
    vsftpd \
    tftpd-hpa \
    syslinux pxelinux \
    net-tools \
    curl wget \
    dnsutils \
    vim nano

echo -e "${GREEN}✓${NC} Paquets installés"

###############################################################################
# 3. CONFIGURATION BIND9 (DNS)
###############################################################################
echo ""
echo -e "${BLUE}[3/8]${NC} ${YELLOW}Configuration DNS (Bind9)...${NC}"

# Sauvegarde config originale
cp /etc/bind/named.conf.options /etc/bind/named.conf.options.bak 2>/dev/null || true

# Configuration Bind9
cat > /etc/bind/named.conf.options << 'EOF'
options {
    directory "/var/cache/bind";
    
    allow-query { any; };
    allow-recursion { any; };
    
    forwarders {
        8.8.8.8;
        8.8.4.4;
    };
    
    recursion yes;
    listen-on { any; };
    listen-on-v6 { any; };
    
    dnssec-validation auto;
};
EOF

# Zone campus.local
cat > /etc/bind/named.conf.local << EOF
zone "campus.local" {
    type master;
    file "/etc/bind/zones/db.campus.local";
};

zone "20.10.in-addr.arpa" {
    type master;
    file "/etc/bind/zones/db.10.20";
};
EOF

# Créer dossier zones
mkdir -p /etc/bind/zones

# Fichier de zone
cat > /etc/bind/zones/db.campus.local << EOF
\$TTL    604800
@       IN      SOA     ns1.campus.local. admin.campus.local. (
                              $(date +%Y%m%d)01         ; Serial
                              604800         ; Refresh
                              86400         ; Retry
                              2419200         ; Expire
                              604800 )       ; Negative Cache TTL
;
@       IN      NS      ns1.campus.local.
ns1     IN      A       $DNS_IP

; Services
campus.local.   IN      A       $SERVER_IP
www             IN      A       $SERVER_IP
pxe             IN      A       $SERVER_IP
ftp             IN      A       $SERVER_IP
proxy           IN      A       $SERVER_IP
EOF

# Zone reverse
cat > /etc/bind/zones/db.10.20 << EOF
\$TTL    604800
@       IN      SOA     ns1.campus.local. admin.campus.local. (
                              $(date +%Y%m%d)01         ; Serial
                              604800         ; Refresh
                              86400         ; Retry
                              2419200         ; Expire
                              604800 )       ; Negative Cache TTL
;
@       IN      NS      ns1.campus.local.
1.0     IN      PTR     campus.local.
EOF

# Permissions
chown -R bind:bind /etc/bind/zones
chmod 755 /etc/bind/zones
chmod 644 /etc/bind/zones/*

# Redémarrer Bind9
systemctl restart bind9
systemctl enable bind9

echo -e "${GREEN}✓${NC} DNS configuré"

###############################################################################
# 4. CONFIGURATION DHCP
###############################################################################
echo ""
echo -e "${BLUE}[4/8]${NC} ${YELLOW}Configuration DHCP...${NC}"

# Détection interface réseau principale
INTERFACE=$(ip route | grep default | awk '{print $5}' | head -n1)
echo "Interface détectée: $INTERFACE"

# Configuration DHCP
cat > /etc/dhcp/dhcpd.conf << EOF
default-lease-time 3600;
max-lease-time 7200;
ddns-update-style none;

subnet 10.20.0.0 netmask 255.255.0.0 {
  option routers $SERVER_IP;
  option subnet-mask 255.255.0.0;
  option domain-name "campus.local";
  option domain-name-servers $DNS_IP;
  
  range 10.20.100.0 10.20.200.254;
}
EOF

# Configuration interface
cat > /etc/default/isc-dhcp-server << EOF
INTERFACESv4="$INTERFACE"
INTERFACESv6=""
EOF

# Note: DHCP nécessite une IP statique configurée manuellement
echo -e "${YELLOW}⚠${NC}  IMPORTANT: Configurez une IP statique sur $INTERFACE avant de démarrer DHCP"
systemctl enable isc-dhcp-server

echo -e "${GREEN}✓${NC} DHCP configuré (à démarrer manuellement après config IP statique)"

###############################################################################
# 5. CONFIGURATION MARIADB
###############################################################################
echo ""
echo -e "${BLUE}[5/8]${NC} ${YELLOW}Configuration MariaDB...${NC}"

systemctl start mariadb
systemctl enable mariadb

# Sécurisation et création base
mysql -e "CREATE DATABASE IF NOT EXISTS campus_users CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mysql -e "CREATE USER IF NOT EXISTS 'campus_user'@'localhost' IDENTIFIED BY 'campus_pass';"
mysql -e "GRANT ALL PRIVILEGES ON campus_users.* TO 'campus_user'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"

# Table utilisateurs
mysql campus_users << 'EOF'
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    full_name VARCHAR(100),
    role ENUM('student', 'teacher', 'admin') DEFAULT 'student',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP NULL,
    active BOOLEAN DEFAULT TRUE
);

INSERT IGNORE INTO users (username, email, full_name, role) VALUES
('admin', 'admin@campus.local', 'Administrateur Campus', 'admin'),
('prof1', 'prof1@campus.local', 'Professeur Martin', 'teacher'),
('etudiant1', 'etudiant1@campus.local', 'Étudiant Dupont', 'student');
EOF

echo -e "${GREEN}✓${NC} MariaDB configurée"

###############################################################################
# 6. CONFIGURATION NGINX
###############################################################################
echo ""
echo -e "${BLUE}[6/8]${NC} ${YELLOW}Configuration Nginx...${NC}"

# Page d'accueil
mkdir -p /var/www/campus

cat > /var/www/campus/index.html << 'HTMLEOF'
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Campus Platform</title>
    <style>
        body { font-family: Arial; margin: 40px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; }
        .container { max-width: 800px; margin: 0 auto; background: rgba(0,0,0,0.5); padding: 30px; border-radius: 10px; }
        h1 { text-align: center; }
        .service { background: rgba(255,255,255,0.1); margin: 15px 0; padding: 20px; border-radius: 8px; }
        .service h2 { margin-top: 0; }
        a { color: #fff; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🏫 Campus Platform</h1>
        <p>Plateforme d'infrastructure réseau pour campus éducatif</p>
        
        <div class="service">
            <h2>📁 Serveur FTP</h2>
            <p>ftp://campus.local (campus/campus123)</p>
        </div>
        
        <div class="service">
            <h2>🌐 Proxy Cache Squid</h2>
            <p>Proxy: campus.local:3128</p>
        </div>
        
        <div class="service">
            <h2>🖥️ Boot PXE</h2>
            <p>Démarrez en réseau pour installer un OS</p>
        </div>
        
        <div class="service">
            <h2>📊 Services</h2>
            <p>DNS: 10.20.0.10 | DHCP: Activé | Base de données: MariaDB</p>
        </div>
    </div>
</body>
</html>
HTMLEOF

# Configuration Nginx
cat > /etc/nginx/sites-available/campus << 'EOF'
server {
    listen 80 default_server;
    server_name campus.local;
    
    root /var/www/campus;
    index index.html;
    
    location / {
        try_files $uri $uri/ =404;
    }
}
EOF

# Activer le site
rm -f /etc/nginx/sites-enabled/default
ln -sf /etc/nginx/sites-available/campus /etc/nginx/sites-enabled/

systemctl restart nginx
systemctl enable nginx

echo -e "${GREEN}✓${NC} Nginx configuré"

###############################################################################
# 7. CONFIGURATION SQUID
###############################################################################
echo ""
echo -e "${BLUE}[7/8]${NC} ${YELLOW}Configuration Squid (Proxy Cache)...${NC}"

cp /etc/squid/squid.conf /etc/squid/squid.conf.bak

cat > /etc/squid/squid.conf << 'EOF'
http_port 3128

visible_hostname campus-proxy

cache_dir ufs /var/spool/squid 10000 16 256
maximum_object_size 512 MB
cache_mem 256 MB

acl localnet src 10.20.0.0/16
acl SSL_ports port 443
acl Safe_ports port 80 21 443 70 210 1025-65535 280 488 591 777
acl CONNECT method CONNECT

http_access deny !Safe_ports
http_access deny CONNECT !SSL_ports
http_access allow localhost manager
http_access deny manager
http_access allow localnet
http_access allow localhost
http_access deny all

refresh_pattern ^ftp:           1440    20%     10080
refresh_pattern ^gopher:        1440    0%      1440
refresh_pattern -i (/cgi-bin/|\?) 0     0%      0
refresh_pattern \.(jpg|png|gif|mp3|mp4|pdf|zip|tar|gz|iso)$ 10080 90% 43200
refresh_pattern .               0       20%     4320
EOF

systemctl restart squid
systemctl enable squid

echo -e "${GREEN}✓${NC} Squid configuré"

###############################################################################
# 8. CONFIGURATION FTP
###############################################################################
echo ""
echo -e "${BLUE}[8/8]${NC} ${YELLOW}Configuration FTP (vsftpd)...${NC}"

# Créer utilisateur FTP
useradd -m -s /bin/bash campus 2>/dev/null || true
echo "campus:campus123" | chpasswd

# Dossier FTP
mkdir -p /home/campus/ftp/{iso,docs,downloads}
chown -R campus:campus /home/campus/ftp

# Configuration vsftpd
cat > /etc/vsftpd.conf << 'EOF'
listen=YES
listen_ipv6=NO
anonymous_enable=NO
local_enable=YES
write_enable=YES
local_umask=022
dirmessage_enable=YES
use_localtime=YES
xferlog_enable=YES
connect_from_port_20=YES
chroot_local_user=YES
allow_writeable_chroot=YES
secure_chroot_dir=/var/run/vsftpd/empty
pam_service_name=vsftpd
pasv_enable=YES
pasv_min_port=21100
pasv_max_port=21110
user_sub_token=$USER
local_root=/home/$USER/ftp
EOF

systemctl restart vsftpd
systemctl enable vsftpd

echo -e "${GREEN}✓${NC} FTP configuré"

###############################################################################
# CONFIGURATION TFTP (pour PXE)
###############################################################################
echo ""
echo -e "${YELLOW}Configuration TFTP/PXE...${NC}"

mkdir -p /var/lib/tftpboot/pxelinux.cfg

# Copier fichiers PXE
cp /usr/lib/PXELINUX/pxelinux.0 /var/lib/tftpboot/ 2>/dev/null || true
cp /usr/lib/syslinux/modules/bios/*.c32 /var/lib/tftpboot/ 2>/dev/null || true

# Menu PXE
cat > /var/lib/tftpboot/pxelinux.cfg/default << 'EOF'
DEFAULT menu.c32
PROMPT 0
TIMEOUT 300

MENU TITLE Campus Platform - Boot PXE

LABEL local
    MENU LABEL ^Boot depuis le disque local
    LOCALBOOT 0

LABEL ubuntu
    MENU LABEL ^Ubuntu 22.04 Installation
    KERNEL ubuntu/vmlinuz
    APPEND initrd=ubuntu/initrd.gz

EOF

systemctl restart tftpd-hpa
systemctl enable tftpd-hpa

echo -e "${GREEN}✓${NC} TFTP/PXE configuré"

###############################################################################
# RÉSUMÉ ET FINALISATION
###############################################################################
echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}✅ Installation terminée !${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "${YELLOW}Services installés :${NC}"
echo "  ✓ Bind9 (DNS)           - Port 53"
echo "  ✓ ISC DHCP Server       - Port 67"
echo "  ✓ Nginx (Web)           - Port 80"
echo "  ✓ MariaDB               - Port 3306"
echo "  ✓ Squid (Proxy)         - Port 3128"
echo "  ✓ vsftpd (FTP)          - Ports 20-21, 21100-21110"
echo "  ✓ TFTP (PXE)            - Port 69"
echo ""
echo -e "${YELLOW}Prochaines étapes :${NC}"
echo "  1. Configurer une IP statique : sudo nano /etc/netplan/00-installer-config.yaml"
echo "  2. Démarrer DHCP : sudo systemctl start isc-dhcp-server"
echo "  3. Vérifier les services : sudo ./check-services.sh"
echo ""
echo -e "${YELLOW}Identifiants par défaut :${NC}"
echo "  FTP     : campus / campus123"
echo "  MariaDB : campus_user / campus_pass"
echo ""
echo -e "${YELLOW}URLs d'accès :${NC}"
echo "  Portal  : http://$(hostname -I | awk '{print $1}')"
echo "  Proxy   : http://$(hostname -I | awk '{print $1}'):3128"
echo ""
echo -e "${GREEN}🎓 Plateforme Campus prête !${NC}"
echo ""
