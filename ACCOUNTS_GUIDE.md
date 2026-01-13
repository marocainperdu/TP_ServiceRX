# GUIDE DES ACCÈS ET COMPTES DE TEST

## 📊 Résumé des Services

| Service | Adresse | Port | Statut |
|---------|---------|------|--------|
| **Portal Web** | https://portal.smartcampus.local | 443 | 🟢 Production |
| **Admin Console** | https://admin.smartcampus.local | 443 | 🟢 Production |
| **API Backend** | https://api.smartcampus.local | 443 | 🟢 Production |
| **FTP Server** | ftp.smartcampus.local | 21 | 🟢 Production |
| **DNS (Bind9)** | 192.168.99.20 | 53 | 🟢 Production |
| **DHCP (Kea)** | 192.168.99.10 | 67/68 | 🟢 Production |
| **Proxy HTTP (Squid)** | proxy.smartcampus.local | 3128 | 🟢 Production |
| **MySQL Database** | db.smartcampus.local | 3306 | 🟢 Production |

## 👥 Comptes de Test

### Administrateurs Réseau

| Compte | Email | Role | Accès | Proxy |
|--------|-------|------|-------|-------|
| **admin-net** | admin-net@smartcampus.local | Admin Réseau | ✅ Tous services | ✅ Illimité |
| **admin-infra** | admin-infra@smartcampus.local | Admin Infrastructure | ✅ Tous services | ✅ Illimité |

**Utilité**: Gestion complète réseau, modification DNS, DHCP, monitoring services  
**Restrictions**: Aucune

### Enseignants

| Compte | Email | Role | Accès | Proxy |
|--------|-------|------|-------|-------|
| **teacher-001** | prof.dupont@smartcampus.local | Teacher | ✅ Web, Portal, FTP | ✅ Complet |

**Utilité**: Accès ressources pédagogiques, upload fichiers, gestion classes  
**Restrictions**: Aucune filtrage web, FTP lecture/écriture

### Étudiants

| Compte | Email | Role | Accès | Proxy |
|--------|-------|------|-------|-------|
| **student-001** | etudiant.martin@smartcampus.local | Student | ✅ Portal, FTP-RO | 🚫 Filtré |
| **student-002** | etudiant.bernard@smartcampus.local | Student | ✅ Portal, FTP-RO | 🚫 Filtré |

**Utilité**: Accès ressources éducation, dépôt fichiers  
**Restrictions**:
- YouTube, Facebook, Instagram, TikTok, Netflix → **BLOQUÉS**
- Streaming (m3u8, mp4, mkv) → **BLOQUÉS**
- P2P / Torrent → **BLOQUÉS**
- Accès web limité à 20% en dehors heures (08:00-18:00)
- FTP lecture seule

### Invités

| Compte | Email | Role | Accès | Proxy |
|--------|-------|------|-------|-------|
| **guest-001** | visitor@example.com | Guest | ✅ Portal public | 🚫 Très restrictif |

**Utilité**: Visite temporaire campus  
**Restrictions**:
- Whitelist stricte: Google, Wikipedia, GitHub, Stack Exchange, universités partenaires
- FTP : pas accès
- Proxy : authentification obligatoire

## 🔐 Mots de Passe par Défaut

**IMPORTANT**: En production, utiliser des mots de passe sécurisés!

```
Tous les comptes:
Password: password

Hash bcrypt (demo):
$2y$10$PxRXjKO6qFX/xWZ2X0X0x.cXKKPJtqSjKKKKKKKKKKKKKKKKKK
```

### Générer un Hash bcrypt pour production

```bash
# Utiliser PHP
php -r 'echo password_hash("mon_mot_de_passe_secure", PASSWORD_BCRYPT);'

# Ou Python
python3 -c 'import bcrypt; print(bcrypt.hashpw(b"password", bcrypt.gensalt()).decode())'
```

## 🌐 Accès aux Services

### 1. Portal Web (Authentification Utilisateur)

```
URL: https://portal.smartcampus.local
Méthode: HTTPS (self-signed en démo)
Authentification: Formulaire (MySQL)
Accès: Tous les rôles
```

**Fonctionnalités**:
- ✅ Login / Logout
- ✅ Dashboard utilisateur
- ✅ Affichage profil
- ✅ Accès FTP
- ✅ Configuration proxy

### 2. Admin Console

```
URL: https://admin.smartcampus.local
Restriction IP: 192.168.99.0/24 uniquement
Authentification: Formulaire MySQL
Accès: admin-net, admin-infra
```

**Fonctionnalités**:
- 🔧 Gestion services
- 🔧 Monitoring infrastructure
- 🔧 Modification zones DNS
- 🔧 Gestion utilisateurs
- 🔧 Logs audit
- 🔧 Statut DHCP

### 3. FTP Server

```
Serveur: ftp.smartcampus.local:21
Authentification: MySQL (PAM + vsftpd)
Mode: Passive (ports 10000-10100)
Protocoles: FTP standard, FTPS (optionnel)
```

**Clients recommandés**:
- FileZilla
- WinSCP
- Commande Linux: `ftp ftp.smartcampus.local`

**Répertoires**:
- `/students/` - Lectures étudiants (RO)
- `/teachers/` - Ressources enseignants (RW)
- `/shared/` - Fichiers publics (RO)
- `/home/<user>/` - Répertoire personnel

### 4. Proxy HTTP (Squid)

```
Proxy: proxy.smartcampus.local:3128
Authentification: MySQL obligatoire
Port: 3128 (standard Squid)
```

**Configuration navigateur**:

**Linux/Mac**:
```bash
export http_proxy=http://proxy.smartcampus.local:3128
export https_proxy=http://proxy.smartcampus.local:3128
```

**Windows**:
```
Settings → Internet Options → Connections → LAN Settings
Proxy Server: proxy.smartcampus.local:3128
```

**Navigateur (Firefox)**:
```
Preferences → Network Settings
Manual proxy configuration:
HTTP Proxy: proxy.smartcampus.local (Port 3128)
HTTPS Proxy: proxy.smartcampus.local (Port 3128)
```

### 5. DNS Server

```
Serveur: 192.168.99.20
Port: 53 (UDP/TCP)
Zone: smartcampus.local
```

**Configuration DNS client**:
```bash
# Linux/Mac
echo "nameserver 192.168.99.20" >> /etc/resolv.conf

# Test
nslookup portal.smartcampus.local 192.168.99.20
dig portal.smartcampus.local @192.168.99.20
```

### 6. DHCP Server

```
Serveur: 192.168.99.10
Port: 67/68 (UDP)
Pools:
  - Admin: 192.168.99.100-200
  - Students: 192.168.100.50-200
  - Labs: 192.168.101.50-200
```

**Options PXE distribuées**:
- DNS: 192.168.99.20
- TFTP: 192.168.99.10 (iPXE)
- Boot Filename: ipxe.efi

## 📝 Scénarios de Test Recommandés

### Scénario 1 : Test Authentification

1. Ouvrir https://portal.smartcampus.local
2. Se connecter avec `student-001` / `password`
3. Vérifier accès Dashboard
4. Vérifier affichage FTP
5. Se déconnecter

**Résultat attendu**: Authentification OK, données utilisateur affichées

### Scénario 2 : Test Filtrage Proxy (Étudiant)

1. Configurer proxy: `proxy.smartcampus.local:3128`
2. Se connecter en proxy avec `student-001` / `password`
3. Essayer accès YouTube → **BLOQUÉ**
4. Essayer accès Google → **OK** (en cache après 1ère visite)
5. Vérifier logs: `docker logs smartcampus-proxy`

**Résultat attendu**: YouTube refusé, Google autorisé, logs écrits

### Scénario 3 : Test FTP

1. Ouvrir client FTP (FileZilla, WinSCP)
2. Connexion: `ftp.smartcampus.local:21`
3. Username: `student-001`, Password: `password`
4. Lister répertoires
5. Télécharger un fichier test

**Résultat attendu**: Connexion OK, fichiers accessibles en lecture

### Scénario 4 : Test Admin

1. Ouvrir https://admin.smartcampus.local
2. Se connecter avec `admin-net` / `password`
3. Accéder au dashboard admin
4. Vérifier statut services
5. Consulter logs d'audit

**Résultat attendu**: Console admin accessible, services listés, historique visible

### Scénario 5 : Test DNS Inverse

```bash
# Depuis un client
nslookup 192.168.99.20 192.168.99.20
# Attendu: dns.smartcampus.local

nslookup 192.168.99.30 192.168.99.20
# Attendu: portal.smartcampus.local
```

## 🔍 Vérifications de Sécurité

- [ ] Certificats SSL auto-signés générés
- [ ] Mots de passe dans variable d'environnement (pas hardcodés)
- [ ] Logs audit activés (admin_audit_log)
- [ ] Proxy authentification obligatoire
- [ ] FTP en mode chroot (sécurisé)
- [ ] Réseau Docker isolé (192.168.99.0/24)

## 📱 Ports Ouverts en Local

```bash
# Depuis l'hôte Docker
localhost:80     → Nginx (HTTP redirect HTTPS)
localhost:443    → Nginx reverse proxy (HTTPS)
localhost:53     → DNS (UDP)
localhost:67     → DHCP (UDP)
localhost:69     → TFTP/iPXE (UDP)
localhost:21     → FTP (TCP)
localhost:3128   → Squid Proxy (TCP)
localhost:3306   → MySQL (TCP)
```

## 🐛 Dépannage Rapide

### Je ne peux pas me connecter au portal

```bash
# Vérifier que MySQL est actif
docker exec smartcampus-db mysqladmin ping

# Vérifier que l'utilisateur existe
docker exec smartcampus-db mysql -u smartcampus_user -psecure_password_123 smartcampus \
  -e "SELECT * FROM users WHERE username='student-001';"

# Vérifier les logs Nginx
docker logs smartcampus-nginx
```

### Le proxy bloque tout

```bash
# Vérifier authentification Squid
docker exec smartcampus-proxy tail -f /var/log/squid/access.log

# Tester authentification MySQL
docker exec smartcampus-db mysql -u smartcampus_user -psecure_password_123 smartcampus \
  -e "SELECT * FROM users WHERE role='student';"
```

### FTP ne répond pas

```bash
# Vérifier vsftpd
docker logs smartcampus-ftp

# Vérifier comptes FTP
docker exec smartcampus-db mysql -u smartcampus_user -psecure_password_123 smartcampus \
  -e "SELECT * FROM ftp_accounts;"

# Tester connexion
ftp ftp.smartcampus.local
```

---

**Version**: 1.0  
**Dernière mise à jour**: Janvier 2026  
**Environnement**: Docker (Local Development)
