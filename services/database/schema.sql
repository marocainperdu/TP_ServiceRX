-- Schéma MySQL SmartCampus
-- Base de données centralisée pour infrastructure réseau

CREATE DATABASE IF NOT EXISTS smartcampus CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE smartcampus;

-- Table des utilisateurs (Authentification centralisée)
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role ENUM('admin-net', 'admin-infra', 'teacher', 'student', 'guest', 'service') DEFAULT 'student',
    vlan_id INT NOT NULL,
    status ENUM('active', 'suspended', 'inactive') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_username (username),
    INDEX idx_role (role),
    INDEX idx_vlan (vlan_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table des VLAN
CREATE TABLE vlans (
    vlan_id INT PRIMARY KEY,
    vlan_name VARCHAR(50) NOT NULL,
    network_address VARCHAR(18) NOT NULL,
    gateway VARCHAR(15) NOT NULL,
    description TEXT,
    INDEX idx_name (vlan_name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table des comptes FTP
CREATE TABLE ftp_accounts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    home_dir VARCHAR(255) NOT NULL,
    permissions ENUM('read-only', 'read-write', 'admin') DEFAULT 'read-only',
    quota_mb INT DEFAULT 1000,
    enabled BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user (user_id),
    UNIQUE KEY unique_ftp (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table des baux DHCP
CREATE TABLE dhcp_leases (
    id INT AUTO_INCREMENT PRIMARY KEY,
    mac_address VARCHAR(17) NOT NULL UNIQUE,
    ip_address VARCHAR(15),
    hostname VARCHAR(255),
    user_id INT,
    lease_start DATETIME,
    lease_end DATETIME,
    vlan_id INT NOT NULL,
    status ENUM('active', 'expired', 'released') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (vlan_id) REFERENCES vlans(vlan_id),
    INDEX idx_mac (mac_address),
    INDEX idx_ip (ip_address),
    INDEX idx_user (user_id),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table des logs proxy
CREATE TABLE proxy_logs (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    src_ip VARCHAR(15) NOT NULL,
    dest_domain VARCHAR(255) NOT NULL,
    url_path TEXT,
    http_status INT,
    bytes_sent INT,
    bytes_received INT,
    request_time DATETIME NOT NULL,
    action ENUM('ALLOWED', 'DENIED', 'BLOCKED') DEFAULT 'ALLOWED',
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL,
    INDEX idx_user (user_id),
    INDEX idx_time (request_time),
    INDEX idx_domain (dest_domain),
    INDEX idx_action (action)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table des enregistrements DNS dynamiques
CREATE TABLE dns_records (
    id INT AUTO_INCREMENT PRIMARY KEY,
    hostname VARCHAR(255) NOT NULL,
    zone VARCHAR(100) NOT NULL,
    type ENUM('A', 'AAAA', 'MX', 'NS', 'CNAME', 'TXT', 'PTR') NOT NULL,
    value VARCHAR(255) NOT NULL,
    ttl INT DEFAULT 300,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY unique_record (hostname, zone, type),
    INDEX idx_zone (zone),
    INDEX idx_type (type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table de statut des services
CREATE TABLE services_status (
    id INT AUTO_INCREMENT PRIMARY KEY,
    service_name VARCHAR(50) NOT NULL UNIQUE,
    status ENUM('running', 'stopped', 'error', 'maintenance') DEFAULT 'stopped',
    ip_address VARCHAR(15),
    port INT,
    last_check DATETIME,
    last_status_change DATETIME,
    error_message TEXT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Table d'audit des actions administrateur
CREATE TABLE admin_audit_log (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    admin_id INT NOT NULL,
    action VARCHAR(100) NOT NULL,
    target_entity VARCHAR(100),
    target_id INT,
    old_value TEXT,
    new_value TEXT,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (admin_id) REFERENCES users(id),
    INDEX idx_admin (admin_id),
    INDEX idx_timestamp (timestamp)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insertion des VLAN
INSERT INTO vlans (vlan_id, vlan_name, network_address, gateway, description) VALUES
(99, 'Administration', '192.168.99.0/24', '192.168.99.1', 'VLAN Administration Infrastructure'),
(100, 'Students', '192.168.100.0/24', '192.168.100.1', 'VLAN Étudiants'),
(101, 'Labs', '192.168.101.0/24', '192.168.101.1', 'VLAN Laboratoires');

-- Insertion des utilisateurs de test
INSERT INTO users (username, email, password_hash, role, vlan_id) VALUES
('admin-net', 'admin-net@smartcampus.local', '$2y$10$PxRXjKO6qFX/xWZ2X0X0x.cXKKPJtqSjKKKKKKKKKKKKKKKKKK', 'admin-net', 99),
('admin-infra', 'admin-infra@smartcampus.local', '$2y$10$PxRXjKO6qFX/xWZ2X0X0x.cXKKPJtqSjKKKKKKKKKKKKKKKKKK', 'admin-infra', 99),
('teacher-001', 'prof.dupont@smartcampus.local', '$2y$10$GvJ5Y6Y6Y6Y6Y6Y6Y6Y6Y6Y6Y6Y6Y6Y6Y6Y6Y6Y6Y6Y6Y6Y6Y', 'teacher', 100),
('student-001', 'etudiant.martin@smartcampus.local', '$2y$10$8y8y8y8y8y8y8y8y8y8y8y8y8y8y8y8y8y8y8y8y8y8y8y8y8', 'student', 100),
('student-002', 'etudiant.bernard@smartcampus.local', '$2y$10$8y8y8y8y8y8y8y8y8y8y8y8y8y8y8y8y8y8y8y8y8y8y8y8y8', 'student', 100),
('guest-001', 'visitor@example.com', '$2y$10$VvVvVvVvVvVvVvVvVvVvVvVvVvVvVvVvVvVvVvVvVvVvVvVv', 'guest', 100);

-- Insertion des services
INSERT INTO services_status (service_name, ip_address, port) VALUES
('Kea DHCP', '192.168.99.10', 67),
('Bind9 DNS', '192.168.99.20', 53),
('iPXE Server', '192.168.99.10', 69),
('Nginx Reverse Proxy', '192.168.99.30', 443),
('Squid Proxy', '192.168.99.40', 3128),
('MySQL Database', '192.168.99.60', 3306),
('vsftpd FTP', '192.168.99.50', 21);

-- Insertion des comptes FTP
INSERT INTO ftp_accounts (user_id, home_dir, permissions, quota_mb) VALUES
(4, '/ftp/students/student-001', 'read-only', 500),
(5, '/ftp/students/student-002', 'read-only', 500),
(3, '/ftp/teachers/teacher-001', 'read-write', 2000);
