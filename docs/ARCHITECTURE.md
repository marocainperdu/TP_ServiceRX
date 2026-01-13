# Architecture Smart Campus - Projet Infrastructure Réseau

## 1. Objectif du Projet

### Problématique Métier
**Smart Campus TelecomTech University** : Université moderne de 5000 étudiants + 1500 employés nécessitant une infrastructure réseau automatisée, sécurisée et scalable. Les besoins incluent :

- Déploiement automatisé de postes de travail (students, staff, labs)
- Accès à internet contrôlé et filtré par profil utilisateur
- Services internes centralisés (portail, dépôt fichiers, partage documents)
- Gestion intelligente des baux DHCP et configuration réseau
- Authentification et autorisation d'accès granulaires

### Cas d'Usage Réels
1. **Démarrage réseau d'un PC étudiant** → Boot via iPXE → Installation automatisée via PXE → Accès services
2. **Accès internet sécurisé** → Proxy filtrant par rôle (étudiant vs admin) → Cache optimisé
3. **Portail utilisateur** → Gestion comptes, accès FTP, telechargement ressources → BD centralisée
4. **Administration réseau** → Console d'administration des services → Monitoring intégré

---

## 2. Architecture Réseau et Schéma d'Intégration

### Schéma Logique Global

```
┌─────────────────────────────────────────────────────────────┐
│                    INTERNET / EXTERNAL                       │
└────────────────────────┬────────────────────────────────────┘
                         │
                    ┌────▼──────┐
                    │  Nginx     │  ← Reverse Proxy (Port 80/443)
                    │ (Entrée)   │     Virtualhost balancing
                    └────┬───────┘
                         │
        ┌────────────────┼────────────────┐
        │                │                │
   ┌────▼────┐    ┌──────▼──────┐   ┌────▼─────┐
   │  Squid   │    │  Webapp     │   │  Admin   │
   │ Proxy    │    │  Portal     │   │ Console  │
   │ HTTP     │    │  (PHP/Node) │   │          │
   └────┬────┘    └──────┬──────┘   └────┬─────┘
        │                │                │
        └────────────────┼────────────────┘
                         │
                    ┌────▼──────────┐
                    │  MySQL/MariaDB│  ← Backend Centralisé
                    │  (Port 3306)  │    Users, FTP, Logs
                    └───────────────┘

        [Domaine : smartcampus.local]

┌──────────────────────────────────────────────┐
│         COUCHE INFRASTRUCTURE RÉSEAU          │
├──────────────────────────────────────────────┤
│                                               │
│  ┌─────────────┐      ┌─────────────┐       │
│  │  Bind9 DNS  │      │ Kea DHCP    │       │
│  │ (Port 53)   │◄────►│ (Port 67)   │       │
│  │             │      │ Options PXE │       │
│  └─────────────┘      └──────┬──────┘       │
│         △                     │              │
│         │          ┌──────────┴──────┐      │
│         │          │                 │      │
│  ┌──────┴──────┐   │      iPXE       │      │
│  │   Résolveur │   │   Boot Scripts  │      │
│  │ smartcampus │   │ (tftp/http)     │      │
│  │   .local    │   │                 │      │
│  │ dns.kea.... │   └─────────────────┘      │
│  │ ftp.kea...  │                            │
│  │ proxy.kea...│                            │
│  │ db.kea...   │                            │
│  └─────────────┘                            │
│                                               │
└──────────────────────────────────────────────┘
         │                │
         └────────┬───────┘
                  │
         ┌────────▼────────┐
         │   Postes Clients │
         │  (Students/Labs) │
         │  Demande DHCP → │
         │  Reçoit IP      │
         │  + Options PXE  │
         └─────────────────┘


┌──────────────────────────────────────────────┐
│      COUCHE SERVICES UTILISATEUR              │
├──────────────────────────────────────────────┤
│                                               │
│  ┌──────────────┐      ┌─────────────────┐  │
│  │  vsftpd FTP  │      │  FTP Clients    │  │
│  │ (Port 21)    │◄────►│ Students/Staff  │  │
│  │ Chroot Auth  │      │                 │  │
│  └──────────────┘      └─────────────────┘  │
│         │                                    │
│         │ (Authentification vers DB)        │
│         └────────────────────────────────────┤
│                                               │
└──────────────────────────────────────────────┘
```

---

## 3. Rôles et Accès Réseau

### Profils d'Utilisateurs
| Rôle | Identifiant | Accès | Filtrage |
|------|------------|--------|----------|
| **Admin Réseau** | `admin-net` | Tous services, console d'admin | Aucun |
| **Admin Infra** | `admin-infra` | Kea, DNS, iPXE, monitoring | Aucun |
| **Étudiant** | `student-*` | Web, proxy (sites éducatifs), FTP (lecture) | Proxy filtrant : pas de streaming, P2P bloqué |
| **Enseignant** | `teacher-*` | Web, proxy (complet), FTP (lecture+écriture) | Accès Squid sans limite |
| **Service** | `service-*` | Communication interne services | Firewall: réseau local uniquement |
| **Invité** | `guest-*` | Web portail public uniquement | Proxy extrêmement restrictif |

### Architecture de Sécurité
```
Entrée Utilisateur → Nginx (SSL/TLS) → Authentification BD
                                       ↓
                          Check Rôle dans MySQL
                                       ↓
Redirect → Web App / Squid Proxy / FTP ← ACL par rôle
                                       ↓
           Services Internes (DNS/DHCP/iPXE)
```

---

## 4. Services Détail & Interactions

### A. **Kea DHCP** (Cœur du Réseau)
**Fonction** : Distribution automatisée des configurations réseau

**Caractéristiques**
- Pool IP étudiant: `192.168.100.50 - 192.168.100.150` (VLAN étudiant)
- Pool IP admin: `192.168.99.50 - 192.168.99.100` (VLAN admin)
- Pool réservé lab: `192.168.101.50 - 192.168.101.200` (VLAN lab)
- **Options DHCP**
  - Option 66 (TFTP Server) → `192.168.99.10` (iPXE)
  - Option 67 (Boot Filename) → `ipxe.efi` / `undionly.kpxe`
  - Option 6 (DNS Server) → `192.168.99.20` (Bind9)

**Fichier config** : `services/dhcp/kea-dhcp4.conf`

---

### B. **Bind9 DNS** (Résolution Centralisée)
**Fonction** : Résolution de noms dans le domaine `smartcampus.local`

**Zones configurées**
- Zone directe: `smartcampus.local` (A records)
- Zone inverse: `99.168.192.in-addr.arpa` (PTR records)

**Records critiques**
```
dns.smartcampus.local       → 192.168.99.20   (Bind9)
dhcp.smartcampus.local      → 192.168.99.10   (Kea)
ipxe.smartcampus.local      → 192.168.99.10   (iPXE/TFTP)
portal.smartcampus.local    → 192.168.99.30   (Nginx)
proxy.smartcampus.local     → 192.168.99.40   (Squid)
ftp.smartcampus.local       → 192.168.99.50   (vsftpd)
db.smartcampus.local        → 192.168.99.60   (MySQL)
admin.smartcampus.local     → 192.168.99.30   (Admin Console via Nginx)
```

**Fichiers config** : `services/dns/zones/`

---

### C. **iPXE** (Démarrage Réseau Automatisé)
**Fonction** : Boot sans disque dur → Configuration centralisée

**Flux**
1. PC client : BIOS demande DHCP
2. Kea répond : IP + Option 66/67 (TFTP → iPXE)
3. Client charge iPXE bootloader
4. iPXE contact Bind9 pour résoudre `ipxe.smartcampus.local`
5. Récupère script iPXE depuis HTTP
6. Lance installation ou boot système

**Scripts iPXE** : `services/ipxe/scripts/`
- `menu.ipxe` → Menu de choix (Linux Lab, Windows Install, etc.)
- `student-boot.ipxe` → Boot OS étudiant
- `admin-boot.ipxe` → Boot OS admin

---

### D. **Squid Proxy HTTP** (Contrôle d'Accès Web)
**Fonction** : Proxy filtrant avec cache + ACL par rôle

**Politiques**
- **Étudiant** → Blacklist : streaming (YouTube), réseaux sociaux, P2P
- **Enseignant** → Whitelist positive ou accès complet
- **Invité** → Whitelist stricte (Google, universités partenaires)

**Cache** : Optimisation bande passante
- Images, CSS, JS mis en cache 7 jours
- HLS/DASH bloqué

**Port** : 3128 (requiert auth MySQL)

---

### E. **Nginx Reverse Proxy** (Accès aux Services)
**Fonction** : Single entry point SSL/TLS, virtualhosting

**Vhosts configurés**
```
portal.smartcampus.local      → 127.0.0.1:8080  (Webapp Portal)
admin.smartcampus.local       → 127.0.0.1:8081  (Admin Console)
api.smartcampus.local         → 127.0.0.1:5000  (Backend API)
```

**Certificats** : Self-signed (domaine interne)

**Load Balancing** : Possible sur plusieurs backends

---

### F. **MySQL/MariaDB** (Backend Centralisé)
**Fonction** : Stockage unique données utilisateurs, logs, FTP

**Schéma de base**
```sql
Database: smartcampus

Tables:
- users (id, username, password_hash, email, role, VLAN)
- ftp_accounts (user_id, home_dir, permissions)
- dhcp_leases (mac, ip, hostname, user_id, lease_time)
- proxy_logs (user_id, url, timestamp, action)
- services_status (service_name, status, last_check)
```

---

### G. **vsftpd FTP** (Dépôt Centralisé Fichiers)
**Fonction** : Accès fichiers contrôlé par rôle

**Répertoires virtuels**
- `/opt/ftp/students/` → Lecture seule pour étudiants
- `/opt/ftp/teachers/` → Lecture/écriture enseignants
- `/opt/ftp/shared/` → Public lecture
- `/opt/ftp/internal/` → Admin uniquement

**Authentification** : contre MySQL (PAM + pam_mysql)

---

## 5. Flux d'Intégration Complet

### Scenario 1 : Boot Étudiant (Nouveau Poste)
```
1. PC étudiant → Demande DHCP
2. Kea DHCP → IP 192.168.100.X + Option 66/67
3. Client → Résout ipxe.smartcampus.local via Bind9
4. Client → Récupère ipxe.efi depuis TFTP
5. iPXE → Contact Bind9 pour ipxe.smartcampus.local
6. iPXE → Menu choix (Student-Debian pour labs)
7. iPXE → Install Linux via HTTP (nginx)
8. Post-install → Créé compte système + enregistrement DNS
```

### Scenario 2 : Accès Web Filtré (Étudiant)
```
1. Étudiant → Ouvre navigateur
2. Proxy auto-détecté (via Kea DHCP option 252)
3. Navigateur → Requête via Squid (port 3128)
4. Squid → Vérifie auth MySQL + rôle utilisateur
5. URL blacklistée ? → Bloquée (YouTube)
6. URL valide → Récupère depuis cache ou internet
7. Log → Inscrit dans proxy_logs (MySQL)
```

### Scenario 3 : Administration Services
```
1. Admin → Accès portal.smartcampus.local
2. Nginx TLS → Redirige vers Admin Console (port 8081)
3. Admin Console → Connexion MySQL
4. Dashboard → Affiche status Kea, Bind9, Squid, FTP, BD
5. Actions → Modifier zones DNS, ajouter utilisateurs, gestion VLAN
6. Logs → Consultables pour audit
```

---

## 6. Contraintes Réseau & Sécurité

| Composant | Réseau | Firewall | VPN |
|-----------|--------|----------|-----|
| Kea DHCP | 192.168.99.0/24 | Port 67 : Broadcast interne uniquement | N/A |
| Bind9 | 192.168.99.20 | Port 53 : UDP + TCP (transferts de zone) | N/A |
| iPXE | 192.168.99.10 | Port 69 TFTP : LAN uniquement, Port 80 HTTP : LAN | N/A |
| Squid | 192.168.99.40 | Port 3128 : Authentification obligatoire | N/A |
| Nginx | 192.168.99.30 | Port 80/443 : SSL/TLS, Certificate pinning | Optional |
| MySQL | 192.168.99.60 | Port 3306 : Réseau interne uniquement | N/A |
| vsftpd | 192.168.99.50 | Port 21 : Passive mode, authentification MySQL | Optional |

---

## 7. Dépendances et Démarrage Ordonné

```
1. MySQL/MariaDB      (Foundation - toutes les données)
   ↓
2. Bind9 DNS          (Base résolution)
   ↓
3. Kea DHCP           (Déploiement client)
   ↓
4. iPXE TFTP/HTTP     (Boot réseau)
   ↓
5. Nginx Reverse Proxy (Frontend)
   ↓
6. Squid Proxy        (Filtrage web)
   ↓
7. vsftpd FTP         (Partage fichiers)
   ↓
8. Web App Portal     (Services applicatifs)
```

---

## 8. Monitoring et Logs

- **Kea DHCP** : `/var/log/kea/kea.log`
- **Bind9** : `/var/log/bind/query.log`, `/var/log/syslog`
- **Squid** : `/var/log/squid/access.log`
- **Nginx** : `/var/log/nginx/access.log`, `/var/log/nginx/error.log`
- **MySQL** : `/var/log/mysql/error.log`, DB `proxy_logs` table
- **vsftpd** : `/var/log/vsftpd.log` ou syslog
- **Dashboard** : Admin Console (Nginx) → Consulte tous les logs centralisés

---

**Statut** : Prêt pour implémentation
