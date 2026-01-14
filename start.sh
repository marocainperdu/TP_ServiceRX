#!/bin/bash

# Script de démarrage du Campus Platform
# Ce script facilite le lancement de tous les services

set -e

echo "========================================="
echo "🏫 Campus Platform - Démarrage"
echo "========================================="
echo ""

# Vérifier que Docker est installé
if ! command -v docker &> /dev/null; then
    echo "❌ Docker n'est pas installé. Veuillez installer Docker d'abord."
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose n'est pas installé. Veuillez installer Docker Compose d'abord."
    exit 1
fi

# Créer les dossiers de données s'ils n'existent pas
echo "📁 Création des dossiers de données..."
mkdir -p data/{mariadb,bind9,kea,squid/{cache,logs},ftp,ipxe}

# Donner les bonnes permissions
echo "🔐 Configuration des permissions..."
sudo chown -R $USER:$USER data/

# Afficher les informations
echo ""
echo "========================================="
echo "📋 Configuration du système"
echo "========================================="
echo "Réseau Docker: 10.20.0.0/16"
echo "DNS: 10.20.0.10"
echo "Reverse Proxy: 10.20.0.30"
echo "FTP: 10.20.0.20"
echo ""

# Démarrer les services
echo "🚀 Démarrage des conteneurs Docker..."
echo ""

if [ "$1" == "build" ]; then
    echo "🔨 Construction des images..."
    docker-compose up -d --build
else
    docker-compose up -d
fi

echo ""
echo "⏳ Attente du démarrage des services..."
sleep 10

# Afficher l'état des services
echo ""
echo "========================================="
echo "📊 État des services"
echo "========================================="
docker-compose ps

echo ""
echo "========================================="
echo "✅ Campus Platform démarré avec succès!"
echo "========================================="
echo ""
echo "🌐 Accès aux services :"
echo "  • Portal:     http://campus.local"
echo "  • PXE Boot:   http://pxe.campus.local"
echo "  • FTP:        ftp://ftp.campus.local"
echo "  • Proxy:      http://172.20.0.30:3128"
echo ""
echo "🔑 Identifiants par défaut :"
echo "  • FTP: campus / campus123"
echo "  • MariaDB: campus_user / campus_pass"
echo ""
echo "⚙️  Configuration DNS :"
echo "  Ajoutez dans /etc/hosts (ou C:\\Windows\\System32\\drivers\\etc\\hosts) :"
echo "  172.20.0.30  campus.local cloud.campus.local moodle.campus.local wiki.campus.local"
echo ""pxe
echo "📝 Logs: docker-compose logs -f [service]"
echo "🛑 Arrêt: ./stop.sh"
echo ""
