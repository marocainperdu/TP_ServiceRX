#!/bin/bash

# Script d'arrêt du Campus Platform

echo "========================================="
echo "🛑 Campus Platform - Arrêt"
echo "========================================="
echo ""

read -p "Voulez-vous arrêter tous les services ? (o/N) " -n 1 -r
echo ""

if [[ $REPLY =~ ^[Oo]$ ]]; then
    echo "🔻 Arrêt des conteneurs..."
    docker-compose down
    
    echo ""
    echo "✅ Tous les services sont arrêtés."
    echo ""
    echo "Pour redémarrer: ./start.sh"
else
    echo "❌ Annulé."
fi
