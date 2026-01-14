# 🏫 Campus Platform - Infrastructure Réseau Éducative

Plateforme d'infrastructure réseau basée sur Docker pour campus, écoles et centres de formation.

## 📋 Vue d'ensemble

Ce projet fournit une infrastructure réseau complète avec :

- **🗄️ MariaDB** - Base de données relationnelle pour stockage des métadonnées
- **🔍 Bind9** - Serveur DNS pour résolution locale (campus.local)
- **📡 Kea DHCP** - Attribution automatique d'adresses IP
- **🖥️ iPXE** - Serveur de boot réseau pour installation d'OS
- **🚀 Squid** - Proxy cache HTTP pour optimiser la navigation
- **🌐 Nginx** - Reverse proxy comme point d'entrée unique
- **📁 vsftpd** - Serveur FTP pour partage de fichiers lourds (ISO, docs, vidéos)

## 🚀 Installation rapide

### Prérequis

```bash
# Vérifier que Docker est installé
docker --version

# Vérifier Docker Compose
docker-compose --version
```

Si Docker n'est pas installé :

```bash
# Ubuntu/Debian
sudo apt update
sudo apt install docker.io docker-compose

# Ajouter votre utilisateur au groupe docker
sudo usermod -aG docker $USER
newgrp docker
```

### Démarrage

```bash
# Rendre les scripts exécutables
chmod +x start.sh stop.sh scripts/*.sh

# Démarrer tous les services
./start.sh
```

Le script va :
1. Créer les dossiers de données nécessaires
2. Configurer les permissions
3. Démarrer tous les conteneurs Docker
4. Afficher les informations de connexion

## 🌐 Accès aux services

### Configuration DNS locale

Ajoutez ces lignes dans votre fichier `/etc/hosts` (Linux/Mac) ou `C:\Windows\System32\drivers\etc\hosts` (Windows) :

```
10.20.0.30  campus.local
10.20.0.30  pxe.campus.local
10.20.0.20  ftp.campus.local
```

### URLs des services

| Service | URL | Description |
|---------|-----|-------------|
| **Portal** | http://campus.local | Page d'accueil principale |
| **PXE Boot** | http://pxe.campus.local | Interface de boot réseau |
| **FTP** | ftp://ftp.campus.local | Serveur de fichiers |
| **Proxy Squid** | http://10.20.0.30:3128 | Cache HTTP |

### 🔑 Identifiants par défaut

**FTP :**
- Utilisateur : `campus`
- Mot de passe : `campus123`

**Base de données (MariaDB) :**
- Root password : `campus_root_2026`
- User : `campus_user`
- Password : `campus_pass`

> ⚠️ **Sécurité** : Changez ces mots de passe en production !

## 🏗️ Architecture

### Réseaux Docker

```
campus-network (172.20.0.0/16)
├── Nginx (172.20.0.30) - Reverse Proxy
├── Bind9 (172.20.0.10) - DNS
├── FTP (172.20.0.20) - Serveur de fichiers
├── Squid - Proxy cache
├── Nextcloud - Cloud storage
├── Moodle - LMS
└── DokuWiki - Wiki

campus-backend (réseau interne)
└── iPXE (172.20.0.15) - Boot Server
├── Bind9 (172.20.0.10) - DNS Server
├── FTP (172.20.0.20) - File Server
└── Squid - HTTP Proxy Cache

campus-backend (réseau interne)
└── MariaDB - Base de données

Host Network
└── Kea DHCP - DHCP Server (nécessite accès réseau physique)
```

### Services et ports

| Service | Port(s) | Réseau | IP |
|---------|---------|--------|-----|
| Nginx | 80, 443 | Public | 10.20.0.30 |
| Bind9 | 53/tcp, 53/udp | Public | 10.20.0.10 |
| iPXE | 69/udp (TFTP), 8080 (HTTP) | Public | 10.20.0.15 |
| Kea DHCP | 67/udp | Host | - |
| Squid | 3128 | Public | Dynamic |
| FTP | 20, 21, 21100-21110 | Public | 10.20.0.20 |
| MariaDB | 3306 | Backend | Dynamic

# Arrêter les services
./stop.sh

# Voir l'état et les statistiques
./scripts/monitor.sh

# Sauvegarder les données
./scripts/backup.sh

# Voir les logs d'un service
docker-compose logs -f nextcloud

# Redémarrer un service spécifique
docker-compose restart nginx

# Accéder au shell d'un conteneur
docker-compose exec nextginx

# Redémarrer un service spécifique
docker-compose restart nginx

# Accéder au shell d'un conteneur
docker-compose exec mariadb
- Utilisation du disque
- Connectivité réseau
- Utilisation CPU/RAM

### Sauvegardes

LeFichiers FTP
- Configurations (Bind9, Kea, Nginx, Squid, iPXE)i
- Fichiers FTP
- Configurations

Les sauvegardes sont stockées dans `./backups/YYYYMMDD_HHMMSS/`

## 🔧 Configuration avancée

### Personnaliser le réseau

Modifiez dans [docker-compose.yml](docker-compose.yml) :

```yaml
networks:
  campus-network:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.0.0/16  # Changez le sous-réseau ici
```

### Ajouter un service

1. Ajoutez le service dans `docker-compose.yml`
2. Créez la configuration dans `configs/[service]/`
3. Ajoutez la route dans `configs/nginx/conf.d/campus.conf`
4. Ajoutez l'entrée DNS dans `configs/bind9/zones/db.campus.local`

### Configuration du proxy Squid

Pour utiliser le cache web sur les postes clients :

**Linux :**
```bash
export http_proxy=http://172.20.0.30:3128
export https_proxy=http://172.20.0.30:3128
```

**Windows :**
Paramètres → Réseau → Proxy → Configuration manuelle
- Adresse : 172.20.0.30
- Port : 3128

### Boot PXE (à venir)


Le service iPXE est déjà configuré avec un menu de démarrage pour :
- Ubuntu 22.04 Desktop
- Ubuntu 22.04 Server
- Debian 12
- Mode Rescue

**Configuration BIOS :**
1. Activez le boot réseau (PXE) (zones, named.conf)
│   ├── kea/                 # DHCP (kea-dhcp4.conf)
│   ├── nginx/               # Reverse proxy (nginx.conf, conf.d/)
│   ├── squid/               # Cache proxy (squid.conf)
│   ├── ipxe/                # Boot réseau (boot.ipxe, index.html)
│   └── mariadb/             # Base de données (init.sql)
├── data/                    # Données persistantes (généré au démarrage)
│   ├── mariadb/            # Données MariaDB
│   ├── bind9/              # Cache DNS
│   ├── kea/                # Leases DHCP
│   ├── squid/              # Cache HTTP
│   ├── ipxe/               # Images ISO et boot files
│   └── ftp/                # Fichiers FTP
├── scripts/                 # Scripts utilitaires
│   ├── monitor.sh          # Monitoring des services
│   ├── backup.sh           # Sauvegardes automatiques
│   └── generate-ssl.sh     # Génération certificats SSL
├── web/                    # Site du portail
│   └── index.html          # Page d'accueil
├── docker-compose.yml      # Orchestration des conteneurs
├── start.sh               # Script de démarrage
├── stop.sh                # Script d'arrêt
├── .env.example           # Variables d'environnemennnées persistantes (généré au démarrage)
│   ├── mariadb/
│   ├── nextcloud/
│   ├── moodle/
│   ├── dokuwiki/
│   └── ftp/
├── scripts/                 # Scripts utilitaires
│   ├── monitor.sh          # Monitoring
│   └── backup.sh           # Sauvegardes
├── web/                    # Site du portail
│   └── index.html
├── docker-compose.yml      # Orchestration
├── start.sh               # Démarrage
├── stop.sh                # Arrêt
└── README.md              # Documentation
```

## 🔍 Dépannage

### Les services ne démarrent pas

```bash
# Vérifier les logs
docker-compose logs

# Vérifier l'état
docker-compose ps

# Redémarrer complètement
docker-compose down
docker-compose up -d
```

### Problème de permissions

```bash
# Réinitialiser les permissions
sudo chown -R $USER:$USER data/
```

### Erreur de connexion à la base de données

```bash
# Vérifier que MariaDB est démarré
docker-compose ps mariadb

# Voir les logs
docker-compose logs mariadb

# Redémarrer MariaDB
docker-compose restart mariadb
```

### Impossible d'accéder aux services web

1. Vérifiez que `/etc/hosts` est correctement configuré
2. Vérifiez que Nginx est démarré : `docker-compose ps nginx`
3. Testez directement avec l'IP : `http://172.20.0.30`

## 🛡️ Sécurité

### Bonnes pratiques

1. 🎓 Cas d'usage pédagogiques

### 1. Installation d'OS en masse via PXE
Installez Ubuntu sur 30 postes simultanément sans clés USB :
- Démarrez les PC en mode PXE
- Sélectionnez "Ubuntu 22.04 Desktop"
- Installation automatique via réseau

### 2. Partage de ressources volumineuses
Le professeur partage 10 Go de vidéos de cours :
- Upload via FTP : `ftp://ftp.campus.local/cours/`
- Les étudiants téléchargent via le cache Squid
- Gain de bande passante : téléchargement unique, puis cache

### 3. Lab réseau isolé
Configuration d'un réseau complet pour TPs :
- DN� Dépannage avancé

### Le boot PXE ne fonctionne pas

```bash
# Vérifier que le serveur TFTP écoute
docker-compose logs ipxe

# Vérifier que le DHCP pointe vers le bon serveur
docker-compose exec kea-dhcp cat /etc/kea/kea-dhcp4.conf | grep next-server
```

### Le proxy Squid ne cache pas

```bash
# Vérifier l'espace disque du cache
docker-compose exec squid df -h /var/spool/squid

# Réinitialiser le cache
docker-compose exec squid squid -z
docker-compose restart squid
```

### DNS ne résout pas les noms

```bash
# Tester la résolution
docker-compose exec bind9 nslookup campus.local localhost

# Vérifier les zones
docker-compose exec bind9 named-checkzone campus.local /etc/bind/zones/db.campus.local
```

## 📝 Licence

Ce projet est open-source et peut être utilisé librement à des fins éducatives.

---

**🏫 Développé pour les campus sociaux, écoles et centres de formation**

**Services inclus :** Kea DHCP • Bind9 DNS • iPXE Boot • Squid Proxy • Nginx • MariaDB • vsftpd

Pour toute question : adminions dans iPXE
- Intégrer des applications web (Moodle, Nextcloud)
- Monitoring avancé (Prometheus/Grafana)
- Automatisation des déploiements
- Interface web pour gestion DHCP/DNS

## 📚 Ressources

- [Documentation Docker](https://docs.docker.com/)
- [Nginx Documentation](https://nginx.org/en/docs/)
- [Bind9 Documentation](https://bind9.readthedocs.io/)
- [Kea DHCP Documentation](https://kea.readthedocs.io/)
- [Squid Documentation](http://www.squid-cache.org/Doc/)
- [iPXE Documentation](https://ipxe.org/docs
## 🤝 Contribution

N'hésitez pas à améliorer ce projet :
- Ajoutez de nouveaux services
- Optimisez les configurations
- Corrigez les bugs
- Améliorez la documentation

## 📚 Ressources

- [Documentation Docker](https://docs.docker.com/)
- [Nextcloud Documentation](https://docs.nextcloud.com/)
- [Moodle Documentation](https://docs.moodle.org/)
- [Nginx Documentation](https://nginx.org/en/docs/)
- [Bind9 Documentation](https://bind9.readthedocs.io/)

## 📝 Licence

Ce projet est open-source et peut être utilisé librement à des fins éducatives.

---

**Développé pour les campus sociaux, écoles et centres de formation** 🎓

Pour toute question : campus@campus.local
