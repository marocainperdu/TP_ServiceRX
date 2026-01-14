-- Initialisation de la base de données pour le campus

-- Base de données pour les utilisateurs du campus
CREATE DATABASE IF NOT EXISTS campus_users CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Accorder tous les privilèges
GRANT ALL PRIVILEGES ON campus_users.* TO 'campus_user'@'%';

FLUSH PRIVILEGES;

-- Créer table simple pour gérer les utilisateurs
USE campus_users;

CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    full_name VARCHAR(100),
    role ENUM('student', 'teacher', 'admin') DEFAULT 'student',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_login TIMESTAMP NULL,
    active BOOLEAN DEFAULT TRUE
);

-- Insérer quelques utilisateurs de test
INSERT INTO users (username, email, full_name, role) VALUES
('admin', 'admin@campus.local', 'Administrateur Campus', 'admin'),
('prof1', 'prof1@campus.local', 'Professeur Martin', 'teacher'),
('etudiant1', 'etudiant1@campus.local', 'Étudiant Dupont', 'student');
