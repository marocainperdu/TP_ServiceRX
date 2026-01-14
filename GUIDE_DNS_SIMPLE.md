# ???? Guide DNS pour Campus Platform

## ??? Solution rapide (SANS Bind9)

Puisque Bind9 a des probl??mes, voici la solution la plus simple et efficace pour un campus :

### M??thode 1 : /etc/hosts sur chaque machine (SIMPLE)

**Linux/Mac :**
```bash
echo "10.20.0.30  campus.local pxe.campus.local" | sudo tee -a /etc/hosts
echo "10.20.0.20  ftp.campus.local" | sudo tee -a /etc/hosts

# Tester
ping campus.local
```

**Windows (cmd en admin) :**
```cmd
echo 10.20.0.30  campus.local pxe.campus.local >> C:\Windows\System32\drivers\etc\hosts
echo 10.20.0.20  ftp.campus.local >> C:\Windows\System32\drivers\etc\hosts

# Tester
ping campus.local
```

---

### M??thode 2 : Avec un DNS forwarder simple (RECOMMAND??)

Vous pouvez utiliser **dnsmasq** au lieu de Bind9 (beaucoup plus simple) :

**Sur votre serveur campus :**
```bash
# 1. Installer dnsmasq
sudo apt install dnsmasq -y

# 2. Configurer
sudo nano /etc/dnsmasq.conf

# Ajouter ces lignes :
# address=/campus.local/10.20.0.30
# address=/pxe.campus.local/10.20.0.30
# address=/ftp.campus.local/10.20.0.20
# listen-address=0.0.0.0
# port=53

# 3. Red??marrer
sudo systemctl restart dnsmasq
```

**Sur chaque machine du campus :**
```bash
# Param??tres r??seau ??? DNS ??? Ajouter 10.20.0.30 (ou l'IP du serveur)

# Puis tester
nslookup campus.local 10.20.0.30
```

---

### M??thode 3 : Avec Docker (si vous voulez garder tout en Docker)

Cr??er un conteneur dnsmasq simple :

```yaml
dnsmasq:
  image: jpillora/dnsmasq:latest
  container_name: campus-dnsmasq
  ports:
    - "53:53/udp"
    - "53:53/tcp"
  volumes:
    - ./dnsmasq.conf:/etc/dnsmasq.conf:ro
  cap_add:
    - NET_ADMIN
```

Configuration `dnsmasq.conf` :
```
address=/campus.local/10.20.0.30
address=/pxe.campus.local/10.20.0.30
address=/ftp.campus.local/10.20.0.20
address=/local/10.20.0.1
```

---

## ??? R??sum?? - Ce qui fonctionne maintenant

??? **Nginx Reverse Proxy** ??? http://localhost (ou direct par IP 10.20.0.30)
??? **MariaDB** ??? Accessible pour applications
??? **FTP** ??? ftp://10.20.0.20 (campus/campus123)
??? **iPXE** ??? http://localhost:8080
??? **Squid Proxy** ??? localhost:3128

### Comment acc??der depuis une autre machine

**Actuellement** (r??solution par IP) :
```bash
# Navigation directe
http://10.20.0.30      # Portail principal
http://10.20.0.30:8080 # iPXE Boot
ftp://10.20.0.20       # FTP serveur
```

**Pour avoir les noms de domaine** (campus.local) :
```bash
# Option 1 : Ajouter dans /etc/hosts
10.20.0.30  campus.local pxe.campus.local
10.20.0.20  ftp.campus.local

# Option 2 : Configurer DNS sur la machine
nameserver 10.20.0.30  # Remplacer par votre serveur
```

---

## ???? Test rapide

Depuis une autre machine :
```bash
# Acc??s direct
curl http://10.20.0.30

# Ou avec hostname (apr??s config /etc/hosts)
curl http://campus.local
```

