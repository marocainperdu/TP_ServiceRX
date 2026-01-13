# Guide de Déploiement - SmartCampus Infrastructure

## 1. Prérequis

- Docker 20.10+
- Docker Compose 2.0+
- Linux (Ubuntu 20.04+) ou macOS
- Minimum 4 GB RAM disponible
- 10 GB espace disque

## 2. Structure du Projet

```
TP_ServiceRX/
├── docs/
│   └── ARCHITECTURE.md          # Documentation architecture
├── services/
│   ├── dhcp/
│   │   └── kea-dhcp4.conf       # Configuration Kea DHCP
│   ├── dns/
│   │   ├── named.conf            # Configuration Bind9
│   │   └── zones/                # Zones DNS
│   ├── ipxe/
│   │   └── scripts/              # Scripts de boot iPXE
│   ├── squid/
│   │   ├── squid.conf            # Configuration Squid
│   │   ├── blocked/              # Listes de blocage
│   │   └── groups/               # Groupes utilisateurs
│   ├── nginx/
│   │   └── nginx.conf            # Configuration Nginx
│   ├── database/
│   │   └── schema.sql            # Schéma MySQL
│   └── ftp/
│       └── vsftpd.conf           # Configuration vsftpd
├── webapp/
│   ├── index.php                 # Application PHP
│   └── templates/                # Templates HTML
├── docker/
│   └── docker-compose.yml        # Composition des services
└── Instruction.md
```

## 3. Installation et Démarrage

### Étape 1: Cloner/Préparer le projet

```bash
cd /home/momo/TP_ServiceRX
```

### Étape 2: Créer les répertoires manquants

```bash
# Répertoires de volumes
mkdir -p docker/volumes/{mysql,named,squid,ftp}

# Permissions
chmod 755 docker/volumes/*
```

### Étape 3: Configurer les adresses réseau

**Note:** Dans un environnement Docker, les IPs de service (192.168.99.x) sont simulées. 
Pour un environnement physique, adapter les configurations réseau.

### Étape 4: Lancer les services

```bash
cd docker
docker-compose up -d

# Vérifier le statut
docker-compose ps

# Voir les logs
docker-compose logs -f
```

## 4. Vérification des Services

### Contrôler que tous les conteneurs sont actifs

```bash
docker-compose ps

# Résultat attendu:
# CONTAINER ID   IMAGE                 STATUS        NAMES
# xxxxx          mysql:8.0             Up 2 minutes  smartcampus-db
# xxxxx          bind9:9.18            Up 2 minutes  smartcampus-dns
# xxxxx          kea:latest            Up 2 minutes  smartcampus-dhcp
# xxxxx          nginx:alpine          Up 2 minutes  smartcampus-ipxe
# xxxxx          nginx:alpine          Up 2 minutes  smartcampus-nginx
# xxxxx          php:8.2-fpm           Up 2 minutes  smartcampus-webapp
# xxxxx          sameersbn/squid       Up 2 minutes  smartcampus-proxy
# xxxxx          fauria/vsftpd         Up 2 minutes  smartcampus-ftp
```

## 5. Tests d'Intégration

### Test 1 : Résolution DNS

```bash
# Depuis le conteneur DNS
docker exec smartcampus-dns nslookup portal.smartcampus.local 192.168.99.20

# Résultat attendu:
# Name:   portal.smartcampus.local
# Address: 192.168.99.30
```

### Test 2 : Accès Base de Données

```bash
docker exec smartcampus-db mysql -u smartcampus_user -psecure_password_123 smartcampus \
  -e "SELECT COUNT(*) as 'Nombre d\'utilisateurs' FROM users;"

# Résultat attendu: 6 utilisateurs
```

### Test 3 : Portail Web

```bash
# Accès au portail
curl -k https://localhost/

# Vérifier les logs Nginx
docker logs smartcampus-nginx
```

### Test 4 : Proxy HTTP

```bash
# Test authentification Squid
curl -x proxy.smartcampus.local:3128 -U student-001:password http://google.com

# Vérifier les logs Squid
docker logs smartcampus-proxy
```

### Test 5 : FTP

```bash
# Test connexion FTP (à adapter selon votre client)
ftp ftp.smartcampus.local

# Identifiants de test:
# Username: student-001
# Password: password (même format de hashage que la DB)
```

## 6. Scénarios de Test

### Scénario 1 : Boot étudiant simulé

```bash
# Simulation d'une demande DHCP
docker exec smartcampus-dhcp kea-shell << EOF
send { "command": "lease4-get", "arguments": {} }
EOF
```

### Scénario 2 : Filtrage proxy pour étudiant

```bash
# Log dans la base de données
docker exec smartcampus-db mysql -u smartcampus_user -psecure_password_123 smartcampus \
  -e "SELECT * FROM proxy_logs WHERE action = 'DENIED' LIMIT 5;"
```

### Scénario 3 : Authentification utilisateur

```bash
# Vérifier qu'un utilisateur peut se connecter
curl -X POST https://localhost/login \
  -d "username=student-001&password=password" \
  -k -v
```

## 7. Administration des Services

### Ajouter un nouvel utilisateur

```bash
docker exec smartcampus-db mysql -u smartcampus_user -psecure_password_123 smartcampus << EOF
INSERT INTO users (username, email, password_hash, role, vlan_id)
VALUES (
  'student-003',
  'etudiant.nouvelle@smartcampus.local',
  '\$2y\$10\$...',  -- Hash bcrypt du password
  'student',
  100
);
EOF
```

### Créer un compte FTP

```bash
docker exec smartcampus-db mysql -u smartcampus_user -psecure_password_123 smartcampus << EOF
INSERT INTO ftp_accounts (user_id, home_dir, permissions, quota_mb)
VALUES (
  3,
  '/ftp/students/student-003',
  'read-write',
  500
);
EOF
```

### Modifier une zone DNS

```bash
# Éditer la zone
nano services/dns/zones/db.smartcampus.local

# Recharger la configuration
docker exec smartcampus-dns rndc reload smartcampus.local
```

## 8. Dépannage

### Les services ne démarrent pas

```bash
# Vérifier les logs
docker-compose logs

# Redémarrer les services
docker-compose restart

# Supprimer les volumes et redémarrer (ATTENTION: données perdues)
docker-compose down -v
docker-compose up -d
```

### Problème de résolution DNS

```bash
# Tester directement
docker exec smartcampus-dns nslookup portal.smartcampus.local

# Vérifier les logs DNS
docker logs smartcampus-dns
```

### Proxy non fonctionnel

```bash
# Vérifier la configuration
docker exec smartcampus-proxy squid -v

# Tester un accès
docker exec smartcampus-proxy curl -v http://google.com
```

## 9. Accès aux Services

| Service | URL/Adresse | Port | Credentials |
|---------|-------------|------|-------------|
| Web Portal | https://portal.smartcampus.local | 443 | student-001 / password |
| Admin Console | https://admin.smartcampus.local | 443 | admin-net / password |
| FTP Server | ftp.smartcampus.local | 21 | student-001 / password |
| DNS | 192.168.99.20 | 53 | N/A |
| DHCP | 192.168.99.10 | 67 | N/A |
| Proxy | proxy.smartcampus.local | 3128 | Authentification requise |
| MySQL | 192.168.99.60 | 3306 | smartcampus_user / secure_password_123 |

## 10. Arrêt des Services

```bash
# Arrêt gracieux
docker-compose down

# Arrêt et suppression des volumes
docker-compose down -v

# Arrêt sans suppression
docker-compose stop
```

## 11. Points Clés d'Intégration

✅ **DHCP → DNS** : Kea fournit les options DNS (pointer vers Bind9)
✅ **DNS → iPXE** : Résolution ipxe.smartcampus.local
✅ **iPXE → Boot** : Scripts de démarrage réseau
✅ **Nginx → Services** : Reverse proxy centralise l'accès
✅ **Proxy → MySQL** : Authentification utilisateur Squid
✅ **FTP → MySQL** : Authentification et ACL FTP
✅ **Web → MySQL** : Portail connecté à la base centralisée

## 12. Logs Importants

```bash
# MySQL
docker logs smartcampus-db

# DNS
docker logs smartcampus-dns

# DHCP
docker logs smartcampus-dhcp

# Nginx
docker logs smartcampus-nginx

# Proxy
docker logs smartcampus-proxy

# FTP
docker logs smartcampus-ftp
```

**Statut**: Déploiement prêt pour laboratoire d'infrastructure réseau
