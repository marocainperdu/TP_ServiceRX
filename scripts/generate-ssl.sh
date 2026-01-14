#!/bin/bash

# Script de génération de certificats SSL auto-signés

echo "========================================="
echo "🔒 Génération de certificats SSL"
echo "========================================="
echo ""

CERT_DIR="./configs/nginx/ssl"
mkdir -p "$CERT_DIR"

# Générer une clé privée et un certificat
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout "$CERT_DIR/campus.key" \
    -out "$CERT_DIR/campus.crt" \
    -subj "/C=FR/ST=IDF/L=Paris/O=Campus/OU=IT/CN=campus.local"

# Générer pour les sous-domaines
for domain in cloud.campus.local moodle.campus.local wiki.campus.local; do
    openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
        -keyout "$CERT_DIR/${domain}.key" \
        -out "$CERT_DIR/${domain}.crt" \
        -subj "/C=FR/ST=IDF/L=Paris/O=Campus/OU=IT/CN=${domain}"
done

echo ""
echo "✅ Certificats SSL générés dans: $CERT_DIR"
echo ""
echo "⚠️  Ces certificats sont auto-signés et provoqueront"
echo "   des avertissements dans le navigateur."
echo ""
echo "Pour une utilisation en production, utilisez Let's Encrypt :"
echo "https://letsencrypt.org/"
