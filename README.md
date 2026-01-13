# 🎓 SmartCampus - Mini-Projet Infrastructure Réseau

## 📋 Vue d'Ensemble

**SmartCampus Infrastructure Réseau** est un projet complet d'infrastructure réseau pour une université moderne, intégrant tous les services critiques d'une entreprise actuelle.

### Services Intégrés
✅ **Kea DHCP** - Distribution d'IP automatisée avec PXE  
✅ **Bind9 DNS** - Résolution de noms centralisée  
✅ **iPXE** - Boot réseau automatisé  
✅ **Nginx** - Reverse proxy et virtualhosting  
✅ **Squid** - Proxy HTTP filtrant par rôle  
✅ **MySQL/MariaDB** - Base de données centralisée  
✅ **vsftpd** - Serveur FTP avec contrôle d'accès  

## 🏛️ Contexte

**Problématique Métier**: L'université TelecomTech accueille 5000 étudiants et 1500 employés. L'infrastructure réseau doit supporter:
- Déploiement automatisé de milliers de postes de travail
- Accès internet contrôlé et filtré par profil utilisateur
- Services internes centralisés (portail, FTP, dépôt fichiers)
- Gestion intelligente du parc réseau

## 🏗️ Architecture

```
                        INTERNET
                            |
                    [Nginx Reverse Proxy]
                            |
        ┌───────────┬───────┴───────┬───────────┐
        |           |               |           |
    [Portal]    [Admin]          [API]    [Proxy Squid]
        |           |               |           |
        └───────────┴───────┬───────┴───────────┘
                            |
                    [MySQL/MariaDB]
                            |
        ┌───────┬────────┬───────┬────────────┐
        |       |        |       |            |
    [Kea DHCP][Bind9] [iPXE] [vsftpd]  [Services]

Infrastructure Réseau Intelligence:
- DHCP → DNS → iPXE (chaîne de boot)
- Authentification centralisée (MySQL)
- Filtrage proxy par rôle utilisateur
```

## 🚀 Démarrage Rapide

### Prérequis
- Docker 20.10+ 
- Docker Compose 2.0+
- 4 GB RAM minimum
- 10 GB espace disque

### Installation

```bash
cd /home/momo/TP_ServiceRX
cd docker
docker-compose up -d

# Vérifier le statut
docker-compose ps
```

### Accès aux Services

| Service | URL | Login |
|---------|-----|-------|
| 🌐 Portal | https://portal.smartcampus.local | student-001 |
| 🔧 Admin | https://admin.smartcampus.local | admin-net |
| 📁 FTP | ftp.smartcampus.local:21 | student-001 |

**Password par défaut**: `password` (à adapter selon hashage en prod)

## 📁 Structure du Projet

```
TP_ServiceRX/
├── docs/
│   ├── ARCHITECTURE.md          # 📚 Documentation complète
│   └── DEPLOYMENT.md            # 🚀 Guide de déploiement
├── services/
│   ├── dhcp/                    # Kea DHCP
│   ├── dns/                     # Bind9
│   ├── ipxe/                    # Scripts de boot
│   ├── squid/                   # Proxy HTTP
│   ├── nginx/                   # Reverse Proxy
│   ├── database/                # Schéma MySQL
│   └── ftp/                     # vsftpd
├── webapp/
│   ├── index.php                # Application PHP
│   └── templates/               # Interfaces HTML
├── docker/
│   └── docker-compose.yml       # 🐳 Orchestration
└── Instruction.md
```

## 🎯 Cas d'Usage Réels

### 1️⃣ Boot Étudiant Automatisé

```
PC étudiant → Demande DHCP → Kea répond (IP + Options PXE)
           → Charge iPXE → Résout ipxe.smartcampus.local (Bind9)
           → Récupère script boot → Installation Linux automatisée
           → Inscription DNS dynamique
```

### 2️⃣ Accès Web Filtré

```
Étudiant → Ouvre navigateur → Proxy Squid (3128)
        → Authentification MySQL → Vérification rôle
        → YouTube bloqué? → Accès refusé
        → Google OK? → Cache optimisé
        → Log → Inscrit dans proxy_logs
```

### 3️⃣ Administration Centralisée

```
Admin → Portal (Nginx/HTTPS) → Console Admin
     → Modifie zones DNS (Bind9)
     → Ajoute utilisateurs (MySQL)
     → Gère VLANs (Kea DHCP)
     → Monitoring services (Dashboard)
```

## 👥 Rôles et Accès

| Rôle | Accès | Filtrage |
|------|-------|----------|
| **Admin Réseau** | Tous services | Aucun |
| **Enseignant** | Web complet, FTP L/W | Pas de limite proxy |
| **Étudiant** | Web filtré, FTP L-O | Streaming/P2P bloqué |
| **Invité** | Web public | Whitelist stricte |

## 🔄 Flux d'Intégration Clé

### Intégration DHCP ↔ DNS ↔ iPXE

```json
// Kea DHCP répond au client avec:
{
  "ip_address": "192.168.100.50",
  "router": "192.168.100.1",
  "dns_server": "192.168.99.20",    // ← Bind9
  "tftp_server": "192.168.99.10",   // ← iPXE
  "boot_filename": "ipxe.efi"
}

// Client résout ipxe.smartcampus.local via Bind9
A ipxe.smartcampus.local 192.168.99.10

// Récupère script boot depuis iPXE (HTTP/TFTP)
kernel http://192.168.99.10:8080/kernel.ipxe
```

### Intégration Authentification Web ↔ MySQL

```
HTTP POST /login
  ├→ Nginx reverse proxy
  ├→ PHP Application (webapp)
  ├→ Query MySQL: SELECT * FROM users WHERE username = ?
  ├→ Vérification password_hash (bcrypt)
  ├→ Session créée
  └→ Dashboard / Rôle appliqué
```

### Intégration Proxy Squid ↔ MySQL

```
Client HTTP → Squid:3128
  ├→ Vérification auth REQUIRED
  ├→ Query MySQL: SELECT role FROM users WHERE username = ?
  ├→ ACL check : student_blocked_sites
  ├→ URL youtube.com → DENIED (étudiant)
  ├→ URL github.com → ALLOWED + CACHED
  └→ Log inscrit : proxy_logs (user_id, url, timestamp, action)
```

## 📊 Base de Données

### Tables Principales

| Table | Rôle |
|-------|------|
| `users` | Identités + rôles + authentification |
| `vlans` | Configuration VLAN (IP, gateway) |
| `ftp_accounts` | Comptes FTP + permissions |
| `dhcp_leases` | Baux DHCP actifs |
| `proxy_logs` | Logs des accès web |
| `dns_records` | Enregistrements DNS dynamiques |
| `services_status` | État des services |

## 🔒 Sécurité

- **SSL/TLS** : Nginx avec certificats self-signed (production: Let's Encrypt)
- **Authentification centralisée** : MySQL + bcrypt
- **Contrôle d'accès** : ACL par rôle (Squid, FTP, DHCP)
- **Firewall réseau** : Réseau Docker isolé (192.168.99.0/24)
- **Logs d'audit** : admin_audit_log table

## 📈 Monitoring

Consulter les logs des services:

```bash
# Tous les services
docker-compose logs -f

# Service spécifique
docker logs smartcampus-nginx
docker logs smartcampus-db
docker logs smartcampus-proxy
```

Dashboard Admin accessible via : `https://admin.smartcampus.local`

## 🧪 Tests d'Intégration

```bash
# Test DNS
docker exec smartcampus-dns nslookup portal.smartcampus.local

# Test MySQL
docker exec smartcampus-db mysql -u smartcampus_user -psecure_password_123 smartcampus -e "SELECT COUNT(*) FROM users;"

# Test Proxy
curl -x proxy.smartcampus.local:3128 http://google.com

# Test Portal Web
curl -k https://localhost/
```

## 📖 Documentation

- **[ARCHITECTURE.md](docs/ARCHITECTURE.md)** - Architecture détaillée, interactions services, schémas
- **[DEPLOYMENT.md](docs/DEPLOYMENT.md)** - Guide d'installation, dépannage, tests

## 🎓 Apprentissages

Ce projet démontre:
- ✅ Intégration de services réseau critiques
- ✅ Orchestration multi-conteneur (Docker)
- ✅ Architecture haute disponibilité
- ✅ Contrôle d'accès granulaire
- ✅ Logs centralisés et monitoring
- ✅ Infrastructure as Code (IaC)

## 📝 Fichiers Clés

| Fichier | Rôle |
|---------|------|
| `services/dhcp/kea-dhcp4.conf` | Config pools DHCP, options PXE |
| `services/dns/named.conf` | Zones, résolveurs, logging |
| `services/squid/squid.conf` | ACL proxy, filtrage par rôle |
| `services/nginx/nginx.conf` | Virtualhost, SSL, reverse proxy |
| `services/database/schema.sql` | Schéma tables + données test |
| `webapp/index.php` | Portail PHP + authentification |
| `docker/docker-compose.yml` | Orchestration services |

## 🚀 Prochaines Étapes

- [ ] Load balancing Nginx multi-instances
- [ ] Monitoring Prometheus + Grafana
- [ ] Backup/Restore base de données
- [ ] Clustering Kea DHCP haute dispo
- [ ] Intégration LDAP/Active Directory
- [ ] API REST administration complète

## ❓ Support

Pour des questions ou problèmes:
1. Consulter [DEPLOYMENT.md](docs/DEPLOYMENT.md) section "Dépannage"
2. Vérifier les logs: `docker-compose logs`
3. Consulter [ARCHITECTURE.md](docs/ARCHITECTURE.md) pour la compréhension globale

---

**Statut** : ✅ Production Ready (laboratoire)  
**Version** : 1.0  
**Dernière mise à jour** : Janvier 2026  
**Auteur** : Équipe Infrastructure SmartCampus
