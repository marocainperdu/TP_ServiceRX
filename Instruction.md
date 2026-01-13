**Contexte général**
Vous devez concevoir un **mini-projet d’infrastructure réseau** s’inspirant d’une **architecture réaliste d’entreprise moderne / Smart Campus**.
Les services web ne sont pas des applications isolées, mais des **briques d’infrastructure intégrées**, comme dans un environnement professionnel réel.

---

### Exigences obligatoires (non négociables)

👉 **Chaque mini-projet doit impérativement intégrer l’ensemble des services suivants :**

* **Kea DHCP**

  * Configuration PXE / iPXE
  * Gestion centralisée des baux et options réseau

* **DNS avancé – Bind9**

  * Zones directes et inverses
  * Intégration avec DHCP et services internes

* **iPXE**

  * Démarrage réseau automatisé
  * Chaînage avec Kea DHCP et le DNS

* **Proxy HTTP – Squid**

  * Accès web contrôlé
  * Cache et politiques de filtrage

* **Reverse Proxy – Nginx ou Apache**

  * Publication sécurisée des services web
  * Virtual hosts / load balancing si pertinent

* **Base de données – MySQL ou MariaDB**

  * Backend des services web
  * Séparation claire applicatif / données

* **Serveur FTP – vsftpd ou proftpd**

  * Dépôt de fichiers internes
  * Accès contrôlé par rôles

⚠️ **Aucun service ne peut être omis.**
⚠️ Les services doivent être **fonctionnels, interconnectés et cohérents**.

---

### Structure imposée du mini-projet

Chaque mini-projet doit respecter **strictement** la structure suivante :

1. **Objectif du projet**

   * Problématique métier (Smart Campus / entreprise moderne)
   * Cas d’usage réel

2. **Architecture iPXE + DNS + Kea DHCP**

   * Schéma logique
   * Rôle de chaque service dans le boot réseau

3. **Services intégrés**

   * Description de chaque service
   * Interactions entre les services
   * Justification des choix techniques

4. **Rôles et accès**

   * Administrateurs
   * Utilisateurs
   * Services internes / externes

---

### Contraintes pédagogiques

* L’architecture doit être **réaliste et professionnelle**
* La logique doit correspondre à un **SI d’entreprise**
* Les services web sont des **composants d’infrastructure**, pas des projets indépendants
* La cohérence globale est prioritaire sur la complexité

---

### Projet de référence

📌 **Thème imposé :**
**Smart Campus / Entreprise moderne**
