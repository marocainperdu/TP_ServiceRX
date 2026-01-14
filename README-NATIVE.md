# 🏫 Campus Platform - Installation Native (Sans Docker)

Installation complète de tous les services directement sur une VM Ubuntu/Debian.

## 📋 Prérequis

- **VM Ubuntu 20.04/22.04/24.04** ou **Debian 11/12**
- **Minimum 2 Go RAM, 20 Go disque**
- **Accès root (sudo)**
- **Connexion Internet** (pour l'installation initiale)

## 🚀 Installation automatique

```bash
# 1. Télécharger le script
cd /home/momo/TP_ServiceRX

# 2. Rendre exécutable
chmod +x install-native.sh check-services.sh start-services.sh stop-services.sh

# 3. Lancer l'installation (en tant que root)
sudo ./install-native.sh
```

Le script installe et configure automatiquement :
- ✅ **Bind9** - Serveur DNS
- ✅ **ISC DHCP** - Serveur DHCP
- ✅ **Nginx** - Serveur Web
- ✅ **MariaDB** - Base de données
- ✅ **Squid** - Proxy cache HTTP
- ✅ **vsftpd** - Serveur FTP
- ✅ **TFTP** - Boot PXE réseau

## 🔧 Configuration post-installation

### 1. Configurer l'adresse IP statique

```bash
# Éditer la configuration réseau
sudo nano /etc/netplan/00-installer-config.yaml
```

Exemple de configuration :
```yaml
network:
  version: 2
  ethernets:
    eth0:  # ou ens33, enp0s3, etc.
      addresses:
        - 10.20.0.1/16
      nameservers:
        addresses: [127.0.0.1, 8.8.8.8]
      routes:
        - to: default
          via: 10.20.0.254  # Votre passerelle
```

Appliquer :
```bash
sudo netplan apply
```

### 2. Démarrer le serveur DHCP

```bash
sudo systemctl start isc-dhcp-server
sudo systemctl status isc-dhcp-server
```

### 3. Vérifier tous les services

```bash
./check-services.sh
```

## 📊 Gestion des services

### Démarrer tous les services
```bash
./start-services.sh
```

### Arrêter tous les services
```bash
./stop-services.sh
```

### Vérifier l'état
```bash
./check-services.sh
```

### Gérer un service individuellement
```bash
# Démarrer
sudo systemctl start bind9

# Arrêter
sudo systemctl stop bind9

# Redémarrer
sudo systemctl restart bind9

# Voir les logs
sudo journalctl -u bind9 -f
```

## 🌐 Services et ports

| Service | Port | Accès | Identifiants |
|---------|------|-------|--------------|
| **Web (Nginx)** | 80 | http://10.20.0.1 | - |
| **DNS (Bind9)** | 53 | 10.20.0.10 | - |
| **DHCP** | 67 | Automatique | - |
| **Proxy (Squid)** | 3128 | 10.20.0.1:3128 | - |
| **FTP (vsftpd)** | 21, 21100-21110 | ftp://10.20.0.1 | campus/campus123 |
| **MariaDB** | 3306 | localhost | campus_user/campus_pass |
| **TFTP/PXE** | 69 | Réseau | - |

## 🔍 Dépannage

### DNS ne résout pas

```bash
# Vérifier la configuration
sudo named-checkconf

# Vérifier les zones
sudo named-checkzone campus.local /etc/bind/zones/db.campus.local

# Redémarrer
sudo systemctl restart bind9

# Logs
sudo journalctl -u bind9 -n 50
```

### DHCP ne démarre pas

```bash
# Vérifier la config
sudo dhcpd -t -cf /etc/dhcp/dhcpd.conf

# Vérifier l'interface
ip addr show

# Logs
sudo journalctl -u isc-dhcp-server -n 50
```

### Nginx erreur

```bash
# Tester la config
sudo nginx -t

# Redémarrer
sudo systemctl restart nginx

# Logs
sudo tail -f /var/log/nginx/error.log
```

### Squid ne démarre pas

```bash
# Initialiser le cache
sudo squid -z

# Vérifier la config
sudo squid -k parse

# Redémarrer
sudo systemctl restart squid
```

## 📁 Emplacements des fichiers

### Configurations
- **Bind9** : `/etc/bind/`
- **DHCP** : `/etc/dhcp/dhcpd.conf`
- **Nginx** : `/etc/nginx/sites-available/campus`
- **Squid** : `/etc/squid/squid.conf`
- **vsftpd** : `/etc/vsftpd.conf`
- **TFTP** : `/var/lib/tftpboot/`

### Données
- **Site web** : `/var/www/campus/`
- **FTP** : `/home/campus/ftp/`
- **Logs** : `/var/log/`

## 🔐 Sécurité

### Changer les mots de passe

```bash
# FTP
sudo passwd campus

# MariaDB
sudo mysql -e "ALTER USER 'campus_user'@'localhost' IDENTIFIED BY 'NOUVEAU_MOT_DE_PASSE';"
```

### Firewall (optionnel)

```bash
# Installer UFW
sudo apt install ufw

# Autoriser les services
sudo ufw allow 53/tcp
sudo ufw allow 53/udp
sudo ufw allow 67/udp
sudo ufw allow 80/tcp
sudo ufw allow 21/tcp
sudo ufw allow 3128/tcp
sudo ufw allow 69/udp
sudo ufw allow 21100:21110/tcp

# Activer
sudo ufw enable
```

## 📝 Personnalisation

### Changer le domaine

Éditer `/etc/bind/zones/db.campus.local` et modifier les références à `campus.local`.

### Modifier la plage DHCP

Éditer `/etc/dhcp/dhcpd.conf` :
```bash
sudo nano /etc/dhcp/dhcpd.conf
# Modifier: range 10.20.100.0 10.20.200.254;
sudo systemctl restart isc-dhcp-server
```

### Personnaliser la page web

```bash
sudo nano /var/www/campus/index.html
sudo systemctl reload nginx
```

## 🎓 Utilisation pédagogique

### Scénario 1 : Lab réseau complet
Les étudiants se connectent au réseau campus et obtiennent automatiquement :
- Une adresse IP (DHCP)
- Configuration DNS
- Accès au proxy pour navigation optimisée

### Scénario 2 : Installation OS via PXE
1. Placer les images ISO dans `/var/lib/tftpboot/`
2. Configurer le menu PXE
3. Démarrer les postes en mode réseau

### Scénario 3 : Exercices SQL
Connexion à MariaDB :
```bash
mysql -u campus_user -pcampus_pass campus_users
```

## 📚 Commandes utiles

```bash
# Voir tous les services
systemctl list-units --type=service --state=running | grep -E "bind9|dhcp|nginx|maria|squid|ftp|tftp"

# Ports ouverts
sudo netstat -tuln

# Processus
ps aux | grep -E "named|dhcpd|nginx|mysql|squid|vsftpd"

# Espace disque
df -h

# Mémoire
free -h

# Backup configuration
sudo tar -czf campus-backup-$(date +%Y%m%d).tar.gz /etc/bind /etc/dhcp /etc/nginx /var/www/campus
```

## ✅ Checklist de déploiement

- [ ] Installation terminée sans erreur
- [ ] IP statique configurée
- [ ] DNS résout campus.local
- [ ] DHCP attribue des adresses
- [ ] Site web accessible
- [ ] Proxy Squid fonctionne
- [ ] FTP accessible
- [ ] MariaDB répond
- [ ] Firewall configuré (si nécessaire)
- [ ] Sauvegardes en place

## 🆘 Support

En cas de problème :
1. Vérifier les logs : `sudo journalctl -xe`
2. Exécuter : `./check-services.sh`
3. Consulter `/var/log/syslog`

---

**Installation native Campus Platform** - Tous services sans Docker 🚀
