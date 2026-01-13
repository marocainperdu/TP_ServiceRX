```
╔═══════════════════════════════════════════════════════════════════════════╗
║                    SMARTCAMPUS INFRASTRUCTURE MAP                          ║
║                   Services Integration Diagram                             ║
╚═══════════════════════════════════════════════════════════════════════════╝

                    ┌─────────────────────────────────┐
                    │      EXTERNAL NETWORK           │
                    │      (Internet / ISP)            │
                    └──────────────┬──────────────────┘
                                   │
                    ┌──────────────▼──────────────────┐
                    │   NGINX REVERSE PROXY           │
                    │  [192.168.99.30:443]            │
                    │  - SSL/TLS Termination          │
                    │  - Virtual Hosts                │
                    │  - Load Balancing               │
                    └──────────┬──────────┬───────────┘
                               │          │
                ┌──────────────┼──────────┼──────────────┐
                │              │          │              │
        ┌───────▼────┐  ┌──────▼─┐  ┌────▼──────┐  ┌──▼─────────┐
        │   PORTAL   │  │ ADMIN  │  │    API    │  │  SQUID     │
        │  [8080]    │  │[8081]  │  │  [5000]   │  │  [3128]    │
        │   Web App  │  │Console │  │ Backend   │  │  Proxy     │
        │     PHP    │  │        │  │           │  │   HTTP     │
        └───────┬────┘  └──────┬─┘  └────┬──────┘  └──┬─────────┘
                │              │         │           │
                └──────────────┼─────────┼───────────┘
                               │         │
                        ┌──────▼─────────▼──────────┐
                        │  MYSQL/MARIADB            │
                        │ [192.168.99.60:3306]      │
                        │                            │
                        │  ┌─────────────────────┐   │
                        │  │ users               │   │
                        │  │ - auth + roles      │   │
                        │  ├─────────────────────┤   │
                        │  │ vlans               │   │
                        │  │ - 192.168.99/100/101│   │
                        │  ├─────────────────────┤   │
                        │  │ ftp_accounts        │   │
                        │  │ - permissions       │   │
                        │  ├─────────────────────┤   │
                        │  │ proxy_logs          │   │
                        │  │ - access tracking   │   │
                        │  ├─────────────────────┤   │
                        │  │ dhcp_leases         │   │
                        │  │ - IP assignments    │   │
                        │  └─────────────────────┘   │
                        └────────────┬────────────────┘
                                     │
                    ┌────────────────┼────────────────┐
                    │                │                │
        ┌───────────▼────────┐  ┌────▼───────────┐  ┌▼──────────────┐
        │   VSFTPD FTP       │  │  BIND9 DNS     │  │  KEA DHCP     │
        │ [192.168.99.50:21] │  │ [192.168.99.20]│  │ [192.168.99.10]
        │                    │  │    :53         │  │    :67/68     │
        │ - Authentification │  │                │  │               │
        │ - PAM + MySQL      │  │ Zones:         │  │ VLANs:        │
        │ - Chroot jail      │  │ - smartcampus  │  │ - 192.168.99  │
        │ - Passive mode     │  │   .local       │  │ - 192.168.100 │
        │ - Directories:     │  │ - Reverse 99/  │  │ - 192.168.101 │
        │   /students/       │  │   100/101      │  │               │
        │   /teachers/       │  │                │  │ Reservations: │
        │   /shared/         │  │ Records:       │  │ - services    │
        │                    │  │ - A records    │  │ - dhcp        │
        │ Logs:              │  │ - PTR records  │  │ - dns         │
        │ - vsftpd.log       │  │ - CNAME        │  │ - nginx       │
        │ - Auth tracking    │  │                │  │ - proxy       │
        └──────┬─────────────┘  └────┬───────────┘  └▼──────────────┘
               │                     │                 │
               │                     └─────────┬───────┘
               │                               │
               │        ┌──────────────────────┼──────────────┐
               │        │                      │              │
        ┌──────▼────────▼───────────┐  ┌───────▼──────┐  ┌───▼──────┐
        │      IPXE BOOT SERVER     │  │   NETWORK    │  │ CLIENTS  │
        │   [192.168.99.10:69/8080] │  │  GATEWAY     │  │          │
        │                           │  │              │  │ Students │
        │ - Menu script (menu.ipxe) │  │ - Admin GW   │  │ Teachers │
        │ - Student boot (Debian)   │  │   192.168... │  │ Admins   │
        │ - Admin boot (Ubuntu)     │  │ - Student GW │  │ Guests   │
        │                           │  │ - Lab GW     │  │          │
        │ - HTTP bootstrap          │  │              │  │ 1000+    │
        │ - NFS root filesystem     │  │              │  │ users    │
        │                           │  │              │  │          │
        │ Resolves via Bind9:       │  │              │  └──┬───────┘
        │ ipxe.smartcampus.local ──────────────────────────┘
        │ → 192.168.99.10           │  │              │
        └───────────────────────────┘  └──────────────┘


╔═══════════════════════════════════════════════════════════════════════════╗
║                        INTEGRATION FLOWS                                    ║
╚═══════════════════════════════════════════════════════════════════════════╝

FLOW 1: Boot Étudiant (PXE Chain)
═════════════════════════════════════════════════════════════════════════════

PC Client (new boot)
    ↓ [1] DHCPDISCOVER
    ├─→ Kea DHCP [192.168.99.10:67]
    │       ├─ Assign IP: 192.168.100.50
    │       ├─ DNS Server: 192.168.99.20 (Option 6)
    │       ├─ TFTP Server: 192.168.99.10 (Option 66)
    │       ├─ Boot File: ipxe.efi (Option 67)
    │       └─ Create Lease in MySQL
    │
    ↓ [2] Boot via TFTP
    ├─→ iPXE Server [192.168.99.10:69]
    │       ├─ Resolve ipxe.smartcampus.local
    │       └─→ Bind9 DNS [192.168.99.20:53]
    │            └─ Return: 192.168.99.10
    │
    ↓ [3] Load Menu
    ├─→ iPXE HTTP [192.168.99.10:8080]
    │       ├─ GET /scripts/menu.ipxe
    │       └─ Display Boot Options
    │
    ↓ [4] Boot Linux
    ├─→ iPXE [auto-select or manual]
    │       ├─ Load Kernel + Initrd
    │       ├─ NFS root from 192.168.99.10
    │       └─ Boot OS
    │
    ↓ [5] Register DNS
    ├─→ Dynamic DNS Update
    │       └─→ Bind9 [192.168.99.20]
    │            ├─ Create A record
    │            └─ Create PTR record

Result: PC fully operational with assigned IP, DNS resolution, OS running


FLOW 2: Authentication Web & Portal Access
═════════════════════════════════════════════════════════════════════════════

User → Browser
    ↓ Opens: https://portal.smartcampus.local
    ├─→ Nginx Reverse Proxy [192.168.99.30:443]
    │       ├─ TLS Termination
    │       ├─ Route to PHP Backend [127.0.0.1:8080]
    │       └─ GET / (home page)
    │
    ↓ [1] User clicks Login
    ├─→ Nginx → PHP [index.php, /login route]
    │       └─ Display login.php template
    │
    ↓ [2] User submits credentials (student-001:password)
    ├─→ Nginx → PHP index.php
    │       │
    │       ├─→ Query: SELECT * FROM users WHERE username = 'student-001'
    │       │   
    │       ├─→ MySQL [192.168.99.60:3306]
    │       │       ├─ Fetch user record
    │       │       ├─ password_hash verified (bcrypt)
    │       │       └─ Return user data + role
    │       │
    │       ├─ Create Session: $_SESSION['user_id'] = 4
    │       ├─ Redirect to /dashboard
    │       └─ Set-Cookie: PHPSESSID=...
    │
    ↓ [3] Dashboard Load
    ├─→ Nginx → PHP /dashboard
    │       │
    │       ├─→ Query: SELECT * FROM users WHERE id = 4
    │       ├─→ Query: SELECT * FROM ftp_accounts WHERE user_id = 4
    │       │
    │       ├─→ MySQL returns user info
    │       │
    │       └─ Render dashboard.php with user data
    │
    ↓ Display Dashboard
    └─ Show: Name, Role, VLAN, FTP access, Services

Result: User authenticated, dashboard shown, can access services


FLOW 3: Proxy HTTP Filtering (Student Access)
═════════════════════════════════════════════════════════════════════════════

Student (on VLAN 100) → Ouvre YouTube
    ↓ Browser HTTP request (YouTube.com)
    ├─→ Proxy configured: proxy.smartcampus.local:3128
    │
    ├─→ Squid Proxy [192.168.99.40:3128]
    │       │
    │       ├─ [1] Require authentication
    │       │       └─ Prompt: Enter username/password
    │       │
    │       ├─ [2] Username: student-001 / Password: password
    │       │       │
    │       │       ├─→ MySQL Query: SELECT role FROM users 
    │       │       │                 WHERE username = 'student-001'
    │       │       │
    │       │       ├─→ MySQL [192.168.99.60]
    │       │       │       └─ Return: role = 'student'
    │       │       │
    │       │       └─ Set: acl students = authenticated
    │       │
    │       ├─ [3] URL Check: youtube.com
    │       │       │
    │       │       ├─ Check ACL: student_blocked_sites
    │       │       │   (Blacklist contains .youtube.com)
    │       │       │
    │       │       ├─ Match FOUND → ACCESS DENIED
    │       │       │
    │       │       ├─→ MySQL INSERT:
    │       │       │   proxy_logs (user_id=4, dest_domain='youtube.com',
    │       │       │               action='DENIED', request_time=NOW())
    │       │       │
    │       │       └─ Return 403 Forbidden
    │
    └─ Browser shows: Access Denied

Now try GitHub.com (allowed):
    ├─→ Proxy checks: github.com not in blacklist
    ├─ Check time: 14:00 (during work hours)
    ├─ Allow access
    ├─→ Check cache: Not found
    ├─→ Fetch from Internet via ISP
    ├─ Cache response (CSS, JS, images)
    ├─→ MySQL INSERT: proxy_logs (..., action='ALLOWED')
    └─ Return content to browser

Result: YouTube blocked, GitHub allowed & cached, logs recorded


FLOW 4: FTP Access with MySQL Authentication
═════════════════════════════════════════════════════════════════════════════

User: student-001 → Opens FTP Client
    ├─ Host: ftp.smartcampus.local
    ├─ Port: 21
    ├─ Username: student-001
    ├─ Password: password
    │
    ├─→ vsftpd [192.168.99.50:21]
    │       │
    │       ├─ [1] PAM Authentication Module
    │       │       │
    │       │       ├─→ pam_mysql calls:
    │       │       │   MySQL [192.168.99.60:3306]
    │       │       │
    │       │       ├─ Query: SELECT password_hash FROM users
    │       │       │          WHERE username = 'student-001'
    │       │       │
    │       │       ├─ Verify password_hash (bcrypt)
    │       │       ├─ If match: PAM returns SUCCESS
    │       │       │
    │       │       └─→ Also check ftp_accounts table:
    │       │           SELECT * FROM ftp_accounts 
    │       │           WHERE user_id = 4
    │       │
    │       ├─ [2] Get FTP Permissions
    │       │       │
    │       │       ├─ home_dir: /ftp/students/student-001
    │       │       ├─ permissions: 'read-only'
    │       │       ├─ quota_mb: 500
    │       │       │
    │       │       └─ Chroot to: /ftp/students/student-001
    │       │
    │       └─ [3] Setup FTP Session
    │           ├─ Passive mode: ports 10000-10100
    │           ├─ User can LIST/RETR (read-only)
    │           ├─ User cannot STOR/DELE (no write)
    │           └─ Log connection to syslog
    │
    ├─ Client lists directory: /students/
    ├─ Client downloads: assignment.pdf
    └─ Session closed

Result: User authenticated via MySQL, constrained to read-only, quota enforced


FLOW 5: DNS Resolution Chain
═════════════════════════════════════════════════════════════════════════════

Client (any VLAN) → Needs to resolve: portal.smartcampus.local
    │
    ├─→ Configure: nameserver 192.168.99.20
    │
    ├─→ DNS Query [192.168.99.20:53]
    │       │
    │       ├─→ Bind9 receives query
    │       │
    │       ├─ Zone: smartcampus.local
    │       │   File: /etc/bind/zones/db.smartcampus.local
    │       │
    │       ├─ Record lookup:
    │       │   portal.smartcampus.local IN A 192.168.99.30
    │       │
    │       └─ Return: 192.168.99.30
    │
    ├─ Client connects to: 192.168.99.30
    │
    └─ Nginx Reverse Proxy receives connection

Also works:
    - Reverse lookup: 192.168.99.30 → portal.smartcampus.local
    - Any subdomain: api.*, admin.*, ftp.*, proxy.*, etc.
    - External forwarding: google.com → Google's DNS (8.8.8.8)

Result: All internal names resolve, external queries forwarded


═══════════════════════════════════════════════════════════════════════════════
                           SECURITY LAYERS
═══════════════════════════════════════════════════════════════════════════════

Layer 1: Network Isolation
    └─ Docker network: 192.168.99.0/24 (isolated from host)

Layer 2: TLS/SSL
    └─ Nginx: HTTPS on port 443 (self-signed certs for demo)

Layer 3: Authentication
    ├─ MySQL: bcrypt password hashing
    ├─ PAM: FTP authentication via MySQL
    └─ HTTP Session: PHP sessions with secure cookies

Layer 4: Authorization (ACL)
    ├─ Squid: Role-based ACL (student, teacher, admin, guest)
    ├─ FTP: Chroot jail, permissions (RO/RW)
    └─ Admin: IP restriction (192.168.99.0/24)

Layer 5: Filtering
    ├─ Squid: Blacklist (YouTube, Netflix, streaming)
    ├─ Squid: Whitelist (guests only)
    └─ Squid: P2P/Torrent blocking

Layer 6: Logging & Audit
    ├─ proxy_logs: All web accesses recorded
    ├─ admin_audit_log: Admin actions tracked
    ├─ DNS query.log: DNS resolutions logged
    ├─ Nginx access.log: HTTP requests
    └─ vsftpd.log: FTP connections


═══════════════════════════════════════════════════════════════════════════════
                        SERVICE DEPENDENCIES
═══════════════════════════════════════════════════════════════════════════════

MySQL [Foundation]
    ↑
    └─ All services depend on MySQL for:
       - Users & authentication
       - Logs & records
       - Configuration data

DNS [Infrastructure]
    ├─ Used by: DHCP, iPXE, Nginx, Squid, FTP
    └─ Provides: Name resolution

DHCP [Infrastructure]
    ├─ Feeds: Client IPs + DNS server info
    ├─ Integrates with: Kea + Bind9 + MySQL
    └─ Required by: Network clients

iPXE [Boot]
    ├─ Depends on: DHCP + DNS
    └─ Used by: Bare metal server deployment

Nginx [Frontend]
    ├─ Depends on: PHP app + MySQL
    └─ Required by: Portal, Admin Console, API

Squid [Filtering]
    ├─ Depends on: MySQL (auth), DNS (forwarding)
    └─ Required by: Students, Teachers (web access)

FTP [Storage]
    ├─ Depends on: MySQL (auth), PAM
    └─ Required by: All users (file access)

PHP App [Application]
    ├─ Depends on: MySQL
    └─ Required by: Nginx (backend)


═══════════════════════════════════════════════════════════════════════════════
```

**Status**: ✅ Complete Integration Map  
**Last Updated**: Janvier 2026  
**Purpose**: Visualize SmartCampus Infrastructure Services & Data Flows
