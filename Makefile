.PHONY: help build up down restart logs test clean init status

# Variables
PROJECT_NAME=smartcampus
DOCKER_DIR=./docker
COMPOSE=docker-compose -f $(DOCKER_DIR)/docker-compose.yml

# Couleurs
RED=\033[0;31m
GREEN=\033[0;32m
YELLOW=\033[1;33m
NC=\033[0m

help: ## Affiche l'aide
	@echo "$(GREEN)SmartCampus Infrastructure - Makefile$(NC)"
	@echo ""
	@echo "Commandes disponibles:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(YELLOW)%-20s$(NC) %s\n", $$1, $$2}'

init: ## Initialise le projet (volumes, permissions)
	@echo "$(YELLOW)Initialisation du projet...$(NC)"
	mkdir -p $(DOCKER_DIR)/volumes/{mysql,named,squid,ftp}
	chmod 755 $(DOCKER_DIR)/volumes/*
	@echo "$(GREEN)✓ Projet initialisé$(NC)"

build: ## Construit les images Docker
	@echo "$(YELLOW)Construction des images...$(NC)"
	$(COMPOSE) build --no-cache
	@echo "$(GREEN)✓ Images construites$(NC)"

up: ## Démarre tous les services
	@echo "$(YELLOW)Démarrage des services...$(NC)"
	$(COMPOSE) up -d
	@echo "$(GREEN)✓ Services démarrés$(NC)"
	@echo ""
	@echo "Accès aux services:"
	@echo "  📱 Portal: https://localhost"
	@echo "  🔧 Admin: https://admin.smartcampus.local"
	@echo "  📁 FTP: ftp://ftp.smartcampus.local"

down: ## Arrête tous les services
	@echo "$(YELLOW)Arrêt des services...$(NC)"
	$(COMPOSE) down
	@echo "$(GREEN)✓ Services arrêtés$(NC)"

restart: ## Redémarre tous les services
	@echo "$(YELLOW)Redémarrage des services...$(NC)"
	$(COMPOSE) restart
	@echo "$(GREEN)✓ Services redémarrés$(NC)"

stop: ## Arrête les services sans supprimer les volumes
	@echo "$(YELLOW)Arrêt des services...$(NC)"
	$(COMPOSE) stop
	@echo "$(GREEN)✓ Services arrêtés (données préservées)$(NC)"

start: ## Redémarre les services arrêtés
	@echo "$(YELLOW)Démarrage des services arrêtés...$(NC)"
	$(COMPOSE) start
	@echo "$(GREEN)✓ Services démarrés$(NC)"

logs: ## Affiche les logs en temps réel
	$(COMPOSE) logs -f

logs-db: ## Affiche les logs MySQL
	docker logs -f smartcampus-db

logs-dns: ## Affiche les logs DNS
	docker logs -f smartcampus-dns

logs-nginx: ## Affiche les logs Nginx
	docker logs -f smartcampus-nginx

logs-proxy: ## Affiche les logs Squid Proxy
	docker logs -f smartcampus-proxy

logs-ftp: ## Affiche les logs FTP
	docker logs -f smartcampus-ftp

status: ## Affiche le statut des services
	@echo "$(YELLOW)Statut des services:$(NC)"
	$(COMPOSE) ps

ps: ## Alias pour status
	@$(MAKE) status

test: ## Exécute la suite de tests d'intégration
	@echo "$(YELLOW)Exécution des tests d'intégration...$(NC)"
	bash $(DOCKER_DIR)/test-integration.sh

shell-db: ## Ouvre un shell MySQL
	docker exec -it smartcampus-db mysql -u smartcampus_user -psecure_password_123 smartcampus

shell-dns: ## Ouvre un shell BIND9
	docker exec -it smartcampus-dns bash

shell-nginx: ## Ouvre un shell Nginx
	docker exec -it smartcampus-nginx sh

shell-proxy: ## Ouvre un shell Squid
	docker exec -it smartcampus-proxy bash

clean: ## Supprime les conteneurs ET les volumes (attention!)
	@echo "$(RED)⚠️  Cet action supprimera TOUS les volumes et données!$(NC)"
	@read -p "Êtes-vous sûr? (y/n) " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		echo "$(YELLOW)Suppression...$(NC)"; \
		$(COMPOSE) down -v; \
		echo "$(GREEN)✓ Nettoyage terminé$(NC)"; \
	else \
		echo "$(YELLOW)Annulation$(NC)"; \
	fi

prune: ## Nettoie les ressources Docker inutilisées
	@echo "$(YELLOW)Nettoyage des ressources Docker...$(NC)"
	docker system prune -f
	@echo "$(GREEN)✓ Nettoyage terminé$(NC)"

user-add: ## Ajoute un nouvel utilisateur (USER=name, ROLE=role)
	@if [ -z "$(USER)" ] || [ -z "$(ROLE)" ]; then \
		echo "$(RED)Erreur: USER et ROLE requis$(NC)"; \
		echo "Usage: make user-add USER=student-003 ROLE=student"; \
		exit 1; \
	fi
	@echo "$(YELLOW)Ajout utilisateur $(USER)...$(NC)"
	docker exec smartcampus-db mysql -u smartcampus_user -psecure_password_123 smartcampus -e \
		"INSERT INTO users (username, email, password_hash, role, vlan_id) VALUES ('$(USER)', '$(USER)@smartcampus.local', '\$$2y\$$10\$$...', '$(ROLE)', 100);"
	@echo "$(GREEN)✓ Utilisateur ajouté$(NC)"

db-backup: ## Sauvegarde la base de données
	@mkdir -p backups
	@echo "$(YELLOW)Sauvegarde de la base de données...$(NC)"
	docker exec smartcampus-db mysqldump -u smartcampus_user -psecure_password_123 smartcampus \
		> backups/smartcampus-$$(date +%Y%m%d-%H%M%S).sql
	@echo "$(GREEN)✓ Sauvegarde terminée$(NC)"

db-restore: ## Restaure la base de données (FILE=path/to/backup.sql)
	@if [ -z "$(FILE)" ]; then \
		echo "$(RED)Erreur: FILE requis$(NC)"; \
		echo "Usage: make db-restore FILE=backups/smartcampus-20240113.sql"; \
		exit 1; \
	fi
	@echo "$(YELLOW)Restauration de la base de données...$(NC)"
	docker exec -i smartcampus-db mysql -u smartcampus_user -psecure_password_123 smartcampus < $(FILE)
	@echo "$(GREEN)✓ Restauration terminée$(NC)"

docs: ## Ouvre la documentation
	@echo "$(YELLOW)Documentation disponible:$(NC)"
	@echo "  📚 Architecture: docs/ARCHITECTURE.md"
	@echo "  🚀 Déploiement: docs/DEPLOYMENT.md"
	@echo "  📖 README: README.md"

dns-reload: ## Recharge la configuration DNS
	@echo "$(YELLOW)Rechargement DNS...$(NC)"
	docker exec smartcampus-dns rndc reload
	@echo "$(GREEN)✓ DNS rechargé$(NC)"

nginx-reload: ## Recharge la configuration Nginx
	@echo "$(YELLOW)Rechargement Nginx...$(NC)"
	docker exec smartcampus-nginx nginx -s reload
	@echo "$(GREEN)✓ Nginx rechargé$(NC)"

all: init up ## Initialise et démarre complètement le projet

full-clean: clean ## Alias pour clean

.PHONY: help init build up down restart logs status test clean prune
