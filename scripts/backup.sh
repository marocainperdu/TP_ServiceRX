#!/bin/bash

# Script de sauvegarde des données du Campus Platform

BACKUP_DIR="./backups/$(date +%Y%m%d_%H%M%S)"

echo "========================================="
echo "💾 Campus Platform - Sauvegarde"
echo "========================================="
echo ""

mkdir -p "$BACKUP_DIR"

echo "📦 Sauvegarde en cours dans: $BACKUP_DIR"
echo ""

# Sauvegarder les données importantes
echo "🗄️  Sauvegarde de la base de données..."
docker-compose exec -T mariadb mysqldump -u root -pcampus_root_2026 --all-databases > "$BACKUP_DIR/database.sql"

echo "☁️  Sauvegarde de Nextcloud..."
tar -czf "$BACKUP_DIR/nextcloud.tar.gz" data/nextcloud/ 2>/dev/null

echo "📚 Sauvegarde de Moodle..."
tar -czf "$BACKUP_DIR/moodle.tar.gz" data/moodle/ data/moodledata/ 2>/dev/null

echo "📖 Sauvegarde du Wiki..."
tar -czf "$BACKUP_DIR/dokuwiki.tar.gz" data/dokuwiki/ 2>/dev/null

echo "📁 Sauvegarde du FTP..."
tar -czf "$BACKUP_DIR/ftp.tar.gz" data/ftp/ 2>/dev/null

echo "⚙️  Sauvegarde des configurations..."
tar -czf "$BACKUP_DIR/configs.tar.gz" configs/ 2>/dev/null

echo ""
echo "✅ Sauvegarde terminée!"
echo "📂 Emplacement: $BACKUP_DIR"
echo ""

# Afficher la taille
du -sh "$BACKUP_DIR"
