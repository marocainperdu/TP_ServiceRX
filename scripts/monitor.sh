#!/bin/bash

# Script de monitoring du Campus Platform

echo "========================================="
echo "📊 Campus Platform - Monitoring"
echo "========================================="
echo ""

# Vérifier l'état des conteneurs
echo "🔍 État des conteneurs :"
docker-compose ps

echo ""
echo "========================================="
echo "💾 Utilisation du disque par conteneur"
echo "========================================="
docker ps -a --format "table {{.Names}}\t{{.Size}}"

echo ""
echo "========================================="
echo "🌐 Connectivité réseau"
echo "========================================="

# Tester les services
services=("campus.local" "cloud.campus.local" "moodle.campus.local" "wiki.campus.local")

for service in "${services[@]}"; do
    if curl -s --head --request GET http://$service > /dev/null; then
        echo "✅ $service - OK"
    else
        echo "❌ $service - ERREUR"
    fi
done

echo ""
echo "========================================="
echo "📈 Utilisation des ressources"
echo "========================================="
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}"

echo ""
echo "💡 Pour voir les logs: docker-compose logs -f [service]"
echo "💡 Pour redémarrer un service: docker-compose restart [service]"
