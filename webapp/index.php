<?php
/**
 * Portal Web SmartCampus
 * Portail d'authentification et gestion utilisateurs
 */

// Configuration
define('DB_HOST', '192.168.99.60');
define('DB_USER', 'smartcampus_user');
define('DB_PASS', 'secure_password_123');
define('DB_NAME', 'smartcampus');

// Connexion à la base de données
try {
    $pdo = new PDO(
        "mysql:host=" . DB_HOST . ";dbname=" . DB_NAME . ";charset=utf8mb4",
        DB_USER,
        DB_PASS,
        [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]
    );
} catch (PDOException $e) {
    die("Database Connection Error: " . $e->getMessage());
}

// Démarrer session
session_start();

// Routes
$request = explode('/', trim($_SERVER['PATH_INFO'] ?? '', '/'));
$page = $request[0] ?? 'home';

switch ($page) {
    case 'login':
        handleLogin();
        break;
    case 'logout':
        session_destroy();
        redirect('/');
        break;
    case 'dashboard':
        requireAuth();
        showDashboard();
        break;
    case 'ftp':
        requireAuth();
        showFTPAccess();
        break;
    case 'profile':
        requireAuth();
        showProfile();
        break;
    default:
        showHome();
}

function handleLogin() {
    global $pdo;
    
    if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
        renderPage('login', ['page' => 'login']);
        return;
    }
    
    $username = $_POST['username'] ?? '';
    $password = $_POST['password'] ?? '';
    
    if (empty($username) || empty($password)) {
        renderPage('login', [
            'page' => 'login',
            'error' => 'Username and password required'
        ]);
        return;
    }
    
    // Vérifier utilisateur
    $stmt = $pdo->prepare("
        SELECT id, username, email, role, password_hash 
        FROM users 
        WHERE username = ? AND status = 'active'
    ");
    $stmt->execute([$username]);
    $user = $stmt->fetch();
    
    if ($user && password_verify($password, $user['password_hash'])) {
        $_SESSION['user_id'] = $user['id'];
        $_SESSION['username'] = $user['username'];
        $_SESSION['role'] = $user['role'];
        $_SESSION['email'] = $user['email'];
        redirect('/dashboard');
    } else {
        renderPage('login', [
            'page' => 'login',
            'error' => 'Invalid credentials'
        ]);
    }
}

function showHome() {
    if (isset($_SESSION['user_id'])) {
        redirect('/dashboard');
    }
    renderPage('home', ['page' => 'home']);
}

function showDashboard() {
    global $pdo;
    
    $stmt = $pdo->prepare("
        SELECT u.*, v.vlan_name 
        FROM users u 
        LEFT JOIN vlans v ON u.vlan_id = v.vlan_id 
        WHERE u.id = ?
    ");
    $stmt->execute([$_SESSION['user_id']]);
    $user = $stmt->fetch();
    
    $ftp = null;
    if ($_SESSION['role'] !== 'admin-net' && $_SESSION['role'] !== 'admin-infra') {
        $stmt = $pdo->prepare("
            SELECT * FROM ftp_accounts WHERE user_id = ?
        ");
        $stmt->execute([$_SESSION['user_id']]);
        $ftp = $stmt->fetch();
    }
    
    renderPage('dashboard', [
        'page' => 'dashboard',
        'user' => $user,
        'ftp' => $ftp
    ]);
}

function showFTPAccess() {
    global $pdo;
    
    $stmt = $pdo->prepare("
        SELECT * FROM ftp_accounts WHERE user_id = ?
    ");
    $stmt->execute([$_SESSION['user_id']]);
    $ftp = $stmt->fetch();
    
    if (!$ftp) {
        $_GET['error'] = 'No FTP account configured';
    }
    
    renderPage('ftp', [
        'page' => 'ftp',
        'ftp' => $ftp
    ]);
}

function showProfile() {
    global $pdo;
    
    $stmt = $pdo->prepare("
        SELECT * FROM users WHERE id = ?
    ");
    $stmt->execute([$_SESSION['user_id']]);
    $user = $stmt->fetch();
    
    renderPage('profile', [
        'page' => 'profile',
        'user' => $user
    ]);
}

function requireAuth() {
    if (!isset($_SESSION['user_id'])) {
        redirect('/login');
    }
}

function renderPage($template, $data = []) {
    extract($data);
    include __DIR__ . "/templates/$template.php";
}

function redirect($path) {
    header("Location: $path");
    exit;
}

?>
