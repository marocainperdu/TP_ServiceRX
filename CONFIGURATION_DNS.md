# Configuration DNS pour Campus Platform

## 🎯 Objectif
Permettre aux machines du campus d'accéder à `campus.local`, `pxe.campus.local` et `ftp.campus.local` automatiquement.

## 3 méthodes

### Méthode 1 : Configuration manuelle /etc/hosts (SIMPLE)

Pour chaque machine du campus :

**Linux/Mac :**
```bash
sudo nano /etc/hosts

# Ajouter cette ligne :
10.20.0.30  campus.local pxe.campus.local
10.20.0.20  ftp.campus.local
```

**Windows :**
```
C:\Windows\System32\drivers\etc\hosts

# Ajouter :
10.20.0.30  campus.local pxe.campus.local
10.20.0.20  ftp.campus.local
```

✅ Simple | ❌ Pas automatique | ❌ À faire sur chaque machine

---

### Méthode 2 : Configuration DNS manuel (PROFESSIONNEL)

Chaque machine du réseau doit utiliser `10.20.0.10` comme serveur DNS.

#### Sur Linux

**Pour une connexion Ethernet/DHCP :**
```bash
# Via NetworkManager
nmcli conn modify "Wired connection 1" ipv4.dns 10.20.0.10

# Ou éditer directement
sudo nano /etc/netplan/01-netcfg.yaml
```

Ajouter :
```yaml
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: true
      dhcp4-overrides:
        use-dns: false
      nameservers:
        addresses:
          - 10.20.0.10
          - 8.8.8.8
```

Puis :
```bash
sudo netplan apply
```

**Vérifier :**
```bash
nslookup campus.local 10.20.0.10
```

#### Sur Windows

1. **Paramètres** → **Réseau et Internet** → **Modifier les paramètres de l'adaptateur**
2. Clic droit sur votre connexion → **Propriétés**
3. **Protocole TCP/IPv4** → **Propriétés**
4. Sélectionner **Utiliser l'adresse de serveur DNS suivante :**
   - Serveur DNS préféré : `10.20.0.10`
   - Serveur DNS alternatif : `8.8.8.8`
5. **OK** → **OK**

**Vérifier :**
```cmd
nslookup campus.local 10.20.0.10
```

#### Sur Mac

1. **Paramètres Système** → **Réseau**
2. Sélectionner votre connexion → **Advanced**
3. Onglet **DNS**
4. Cliquer **+** et ajouter `10.20.0.10`
5. **OK** → **Appliquer**

**Vérifier :**
```bash
nslookup campus.local 10.20.0.10
```

✅ Professionnel | ✅ Centralisé | ❌ À configurer sur chaque machine

---

### Méthode 3 : Configuration DHCP automatique (IDÉALE pour campus)

**C'est la meilleure solution !** Quand une machine se connecte au réseau, le serveur DHCP lui dit :
- **Ton IP** : 10.20.100.50 (exemple)
- **Ton DNS** : 10.20.0.10
- **Ta passerelle** : 10.20.0.1

#### Configuration actuelle

Le serveur DHCP est configuré dans `/etc/dhcp/dhcpd.conf` :

```conf
# Chaque client reçoit automatiquement le DNS
option domain-name-servers 10.20.0.10, 8.8.8.8;
```

#### Comment ça marche

1. Machine se connecte au réseau
2. Demande une IP au serveur DHCP (10.20.0.20)
3. Reçoit : `IP + DNS + Passerelle`
4. Peut maintenant accéder à `campus.local`

#### Configuration manuelle du DHCP (optional)

Sur la machine cliente, demander une IP DHCP :

**Linux :**
```bash
sudo dhclient eth0
```

**Windows :**
```cmd
ipconfig /release
ipconfig /renew
```

**Mac :**
```bash
sudo ifconfig en0 down
sudo ifconfig en0 up
```

✅ Automatique | ✅ Scalable | ✅ Idéal pour campus | ❌ Nécessite DHCP

---

## 🔧 Dépannage

### Le DNS ne répond pas

```bash
# Vérifier que Bind9 fonctionne
docker-compose logs bind9

# Tester directement le DNS sur port 5353
nslookup campus.local 10.20.0.10:5353

# Depuis un autre host
nslookup campus.local @10.20.0.30
```

### Le DHCP ne distribue pas le DNS

```bash
# Vérifier les logs DHCP
docker-compose logs dhcp

# Vérifier la configuration
cat configs/dhcp/dhcpd.conf
```

### La machine ne reçoit pas d'IP

```bash
# Demander une nouvelle IP
sudo dhclient -v eth0

# Voir l'IP reçue
ip addr show
```

---

## 📋 Résumé des recommandations

| Méthode | Simplicité | Scalabilité | Recommandé pour |
|---------|-----------|-------------|-----------------|
| **hosts** | ⭐⭐⭐ | ⭐ | Tests locaux |
| **DNS manuel** | ⭐⭐ | ⭐⭐⭐ | Réseaux moyens |
| **DHCP** | ⭐⭐ | ⭐⭐⭐⭐⭐ | Campus entier |

**Pour un campus : Utilisez la Méthode 3 (DHCP)** ✅

---

## 🚀 Mise en pratique rapide

1. **Sur le serveur Campus** :
```bash
docker-compose restart dhcp bind9
```

2. **Sur chaque machine du campus** :
```bash
# Linux
sudo dhclient eth0

# Windows (cmd en admin)
ipconfig /renew

# Mac
sudo ifconfig en0 down && sudo ifconfig en0 up
```

3. **Tester** :
```bash
ping campus.local
ping pxe.campus.local
ping ftp.campus.local
```

Voilà ! 🎉
