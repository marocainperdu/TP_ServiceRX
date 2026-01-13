<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - SmartCampus</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #f5f5f5; }
        .navbar { background: #333; color: white; padding: 15px 20px; }
        .navbar a { color: white; text-decoration: none; margin-right: 20px; }
        .navbar a:hover { color: #667eea; }
        .container { max-width: 1000px; margin: 30px auto; padding: 0 20px; }
        .card { background: white; padding: 20px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); margin-bottom: 20px; }
        h2 { color: #333; margin-bottom: 15px; }
        .info { display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 20px; }
        .info-box { background: #f8f9fa; padding: 15px; border-radius: 5px; border-left: 4px solid #667eea; }
        .info-box label { color: #666; font-weight: 500; display: block; }
        .info-box value { color: #333; font-size: 16px; display: block; margin-top: 5px; }
        .btn { display: inline-block; background: #667eea; color: white; padding: 10px 20px; border-radius: 5px; text-decoration: none; margin-right: 10px; }
        .btn:hover { background: #764ba2; }
        .btn-secondary { background: #6c757d; }
        .btn-secondary:hover { background: #5a6268; }
        .alert { padding: 15px; border-radius: 5px; margin-bottom: 20px; }
        .alert-info { background: #e7f3ff; color: #004085; border: 1px solid #b3d9ff; }
        .alert-warning { background: #fff3cd; color: #856404; border: 1px solid #ffeaa7; }
    </style>
</head>
<body>
    <div class="navbar">
        <strong>SmartCampus Infrastructure</strong>
        <a href="/profile">My Profile</a>
        <a href="/ftp">FTP Access</a>
        <a href="/logout">Logout</a>
    </div>
    
    <div class="container">
        <div class="card">
            <h2>Welcome, <?php echo htmlspecialchars($user['username']); ?>! 👋</h2>
            
            <div class="alert alert-info">
                Role: <strong><?php echo htmlspecialchars($user['role']); ?></strong> | 
                VLAN: <strong><?php echo htmlspecialchars($user['vlan_name']); ?></strong>
            </div>
        </div>
        
        <div class="card">
            <h2>📊 User Information</h2>
            <div class="info">
                <div class="info-box">
                    <label>Username</label>
                    <value><?php echo htmlspecialchars($user['username']); ?></value>
                </div>
                <div class="info-box">
                    <label>Email</label>
                    <value><?php echo htmlspecialchars($user['email']); ?></value>
                </div>
                <div class="info-box">
                    <label>VLAN</label>
                    <value><?php echo htmlspecialchars($user['vlan_name']); ?></value>
                </div>
                <div class="info-box">
                    <label>Status</label>
                    <value><span style="color: green;">✓ Active</span></value>
                </div>
            </div>
        </div>
        
        <div class="card">
            <h2>🌐 Available Services</h2>
            <div class="info">
                <div class="info-box">
                    <label>📁 FTP Server</label>
                    <value>ftp.smartcampus.local</value>
                    <?php if ($ftp): ?>
                        <a href="/ftp" class="btn">Access FTP</a>
                    <?php else: ?>
                        <p style="color: #999; font-size: 12px;">No FTP account configured</p>
                    <?php endif; ?>
                </div>
                <div class="info-box">
                    <label>🌐 Web Portal</label>
                    <value>portal.smartcampus.local</value>
                </div>
                <div class="info-box">
                    <label>⚙️ Infrastructure Status</label>
                    <value>All Services Running ✓</value>
                </div>
                <?php if (in_array($user['role'], ['admin-net', 'admin-infra'])): ?>
                <div class="info-box">
                    <label>🔧 Admin Console</label>
                    <value>admin.smartcampus.local</value>
                    <a href="https://admin.smartcampus.local" class="btn">Access Admin</a>
                </div>
                <?php endif; ?>
            </div>
        </div>
        
        <div class="card">
            <h2>🔒 Network Configuration</h2>
            <div class="alert alert-warning">
                <p><strong>Proxy Settings:</strong> Configure your browser proxy to <code>proxy.smartcampus.local:3128</code></p>
                <p style="margin-top: 10px;"><strong>DNS:</strong> <code>192.168.99.20</code></p>
                <p style="margin-top: 10px;"><strong>Domain:</strong> <code>smartcampus.local</code></p>
            </div>
        </div>
    </div>
</body>
</html>
