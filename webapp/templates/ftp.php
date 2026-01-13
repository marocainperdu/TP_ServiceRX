<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>FTP Access - SmartCampus</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #f5f5f5; }
        .navbar { background: #333; color: white; padding: 15px 20px; }
        .navbar a { color: white; text-decoration: none; margin-right: 20px; }
        .container { max-width: 800px; margin: 30px auto; padding: 0 20px; }
        .card { background: white; padding: 20px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        h2 { color: #333; margin-bottom: 20px; }
        .info-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; }
        .info-box { background: #f8f9fa; padding: 15px; border-radius: 5px; border-left: 4px solid #667eea; }
        .info-box label { color: #666; font-weight: 500; }
        .info-box value { color: #333; display: block; margin-top: 8px; font-weight: bold; }
        .alert { padding: 15px; border-radius: 5px; margin-bottom: 20px; }
        .alert-success { background: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        .alert-warning { background: #fff3cd; color: #856404; border: 1px solid #ffeaa7; }
        .alert-error { background: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }
        .btn { display: inline-block; background: #667eea; color: white; padding: 10px 20px; border-radius: 5px; text-decoration: none; }
        .btn:hover { background: #764ba2; }
        code { background: #f4f4f4; padding: 2px 6px; border-radius: 3px; font-family: monospace; }
    </style>
</head>
<body>
    <div class="navbar">
        <strong>SmartCampus Infrastructure</strong>
        <a href="/dashboard">Dashboard</a>
        <a href="/profile">Profile</a>
        <a href="/logout">Logout</a>
    </div>
    
    <div class="container">
        <div class="card">
            <h2>📁 FTP Access Configuration</h2>
            
            <?php if (!empty($_GET['error'])): ?>
                <div class="alert alert-error"><?php echo htmlspecialchars($_GET['error']); ?></div>
            <?php elseif (!$ftp): ?>
                <div class="alert alert-warning">
                    No FTP account has been configured for your user. Contact an administrator to request access.
                </div>
            <?php else: ?>
                <div class="alert alert-success">
                    ✓ FTP Account is active and ready to use
                </div>
                
                <div class="info-grid">
                    <div class="info-box">
                        <label>📍 Server Address</label>
                        <value>ftp.smartcampus.local</value>
                    </div>
                    <div class="info-box">
                        <label>👤 Username</label>
                        <value><?php echo htmlspecialchars($ftp['user_id']); ?></value>
                    </div>
                    <div class="info-box">
                        <label>🔑 Password</label>
                        <value>(Same as portal login)</value>
                    </div>
                    <div class="info-box">
                        <label>🗂️ Home Directory</label>
                        <value><?php echo htmlspecialchars($ftp['home_dir']); ?></value>
                    </div>
                    <div class="info-box">
                        <label>🔒 Permissions</label>
                        <value><?php echo htmlspecialchars($ftp['permissions']); ?></value>
                    </div>
                    <div class="info-box">
                        <label>💾 Quota</label>
                        <value><?php echo $ftp['quota_mb']; ?> MB</value>
                    </div>
                </div>
                
                <div style="margin-top: 30px; padding-top: 20px; border-top: 1px solid #eee;">
                    <h3>📝 Connection Instructions</h3>
                    
                    <h4 style="margin-top: 20px;">Linux/Mac (Command Line):</h4>
                    <code style="display: block; padding: 10px; background: #f4f4f4; border-radius: 5px; overflow-x: auto;">
                        ftp ftp.smartcampus.local
                    </code>
                    
                    <h4 style="margin-top: 20px;">Windows (File Explorer):</h4>
                    <p>Open file explorer, paste: <code>ftp://ftp.smartcampus.local</code></p>
                    
                    <h4 style="margin-top: 20px;">FTP Client (FileZilla, WinSCP):</h4>
                    <ul style="margin-left: 20px; margin-top: 10px;">
                        <li>Host: ftp.smartcampus.local</li>
                        <li>Protocol: FTP</li>
                        <li>Username: (Your SmartCampus username)</li>
                        <li>Password: (Your SmartCampus password)</li>
                        <li>Port: 21</li>
                    </ul>
                </div>
            <?php endif; ?>
            
            <div style="margin-top: 30px;">
                <a href="/dashboard" class="btn">← Back to Dashboard</a>
            </div>
        </div>
    </div>
</body>
</html>
