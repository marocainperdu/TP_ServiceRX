<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Profile - SmartCampus</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #f5f5f5; }
        .navbar { background: #333; color: white; padding: 15px 20px; }
        .navbar a { color: white; text-decoration: none; margin-right: 20px; }
        .container { max-width: 800px; margin: 30px auto; padding: 0 20px; }
        .card { background: white; padding: 20px; border-radius: 10px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); margin-bottom: 20px; }
        h2 { color: #333; margin-bottom: 20px; }
        .profile-info { display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 20px; }
        .info-box { background: #f8f9fa; padding: 15px; border-radius: 5px; border-left: 4px solid #667eea; }
        .info-box label { color: #666; font-weight: 500; display: block; }
        .info-box value { color: #333; display: block; margin-top: 8px; font-weight: bold; }
        .btn { display: inline-block; background: #667eea; color: white; padding: 10px 20px; border-radius: 5px; text-decoration: none; }
        .btn:hover { background: #764ba2; }
    </style>
</head>
<body>
    <div class="navbar">
        <strong>SmartCampus Infrastructure</strong>
        <a href="/dashboard">Dashboard</a>
        <a href="/ftp">FTP Access</a>
        <a href="/logout">Logout</a>
    </div>
    
    <div class="container">
        <div class="card">
            <h2>👤 My Profile</h2>
            
            <div class="profile-info">
                <div class="info-box">
                    <label>Username</label>
                    <value><?php echo htmlspecialchars($user['username']); ?></value>
                </div>
                <div class="info-box">
                    <label>Email Address</label>
                    <value><?php echo htmlspecialchars($user['email']); ?></value>
                </div>
                <div class="info-box">
                    <label>User Role</label>
                    <value><?php echo htmlspecialchars($user['role']); ?></value>
                </div>
                <div class="info-box">
                    <label>VLAN ID</label>
                    <value><?php echo $user['vlan_id']; ?></value>
                </div>
                <div class="info-box">
                    <label>Account Status</label>
                    <value style="color: green;">✓ <?php echo htmlspecialchars($user['status']); ?></value>
                </div>
                <div class="info-box">
                    <label>Member Since</label>
                    <value><?php echo htmlspecialchars($user['created_at']); ?></value>
                </div>
            </div>
        </div>
        
        <div class="card">
            <h2>🔐 Security</h2>
            <p>To change your password, please contact the IT Support team at: <strong>it-support@smartcampus.local</strong></p>
            <p style="margin-top: 10px; font-size: 12px; color: #666;">Session active since login. Keep your credentials secure and never share them with others.</p>
        </div>
        
        <div>
            <a href="/dashboard" class="btn">← Back to Dashboard</a>
        </div>
    </div>
</body>
</html>
