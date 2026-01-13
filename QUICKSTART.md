# ⚡ QuickStart - SmartCampus en 5 minutes

## Prérequis

✅ Docker 20.10+  
✅ Docker Compose 2.0+  
✅ 4 GB RAM libre  
✅ 10 GB espace disque  

## Étape 1: Préparation (1 minute)

```bash
cd /home/momo/TP_ServiceRX
make init
```

## Étape 2: Démarrage Services (2 minutes)

```bash
make up
```

Attendez que tous les services soient **Up** :

```bash
make status
```

Expected:
```
smartcampus-db       ✓ Up 2 minutes
smartcampus-dns      ✓ Up 2 minutes
smartcampus-dhcp     ✓ Up 2 minutes
smartcampus-nginx    ✓ Up 2 minutes
smartcampus-proxy    ✓ Up 2 minutes
smartcampus-ftp      ✓ Up 2 minutes
smartcampus-webapp   ✓ Up 2 minutes
```

## Étape 3: Tests (1 minute)

```bash
make test
```

Vous devriez voir:
```
✓ Réussis : 25
✗ Échoués : 0
```

## Étape 4: Accès Services (1 minute)

### 🌐 Portal Web
```
https://portal.smartcampus.local
Login: student-001 / password
```

### 🔧 Admin Console
```
https://admin.smartcampus.local
Login: admin-net / password
```

### 📁 FTP Server
```
ftp://ftp.smartcampus.local:21
Login: student-001 / password
```

### 📊 Proxy HTTP
```
proxy.smartcampus.local:3128
Login: student-001 / password
```

---

## 🎯 Commandes Utiles

```bash
# Afficher les logs
make logs

# Arrêter les services
make down

# Redémarrer les services
make restart

# Accès shell MySQL
make shell-db

# Accès shell DNS
make shell-dns

# Recharger configuration DNS
make dns-reload

# Sauvegarde base de données
make db-backup

# Afficher aide complète
make help
```

---

## 🐛 Dépannage Rapide

**Les services ne démarre pas?**
```bash
make down
make clean
make init
make up
```

**Logs trop longs?**
```bash
make logs | head -20   # Voir les 20 premières lignes
```

**Besoin d'accès MySQL?**
```bash
make shell-db
mysql> SELECT * FROM users;
```

---

## 🎓 Comprendre l'Architecture

Consultez: [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)

Pour comptes de test détaillés: [ACCOUNTS_GUIDE.md](ACCOUNTS_GUIDE.md)

Pour déploiement complet: [docs/DEPLOYMENT.md](docs/DEPLOYMENT.md)

---

**C'est parti!** 🚀
