<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>SmartCampus Portal - Home</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); min-height: 100vh; display: flex; align-items: center; justify-content: center; }
        .container { background: white; padding: 40px; border-radius: 10px; box-shadow: 0 10px 40px rgba(0,0,0,0.2); max-width: 600px; width: 90%; }
        h1 { color: #333; margin-bottom: 20px; text-align: center; }
        p { color: #666; margin-bottom: 20px; text-align: center; }
        .btn { display: inline-block; background: #667eea; color: white; padding: 12px 30px; border-radius: 5px; text-decoration: none; margin: 10px 5px; }
        .btn:hover { background: #764ba2; }
        .features { margin-top: 30px; }
        .feature { padding: 15px; background: #f8f9fa; margin: 10px 0; border-radius: 5px; }
        .feature h3 { color: #667eea; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🎓 SmartCampus Portal</h1>
        <p>Infrastructure réseau intelligente pour l'université TelecomTech</p>
        
        <div style="text-align: center;">
            <a href="/login" class="btn">Se connecter</a>
        </div>
        
        <div class="features">
            <div class="feature">
                <h3>🔐 Authentification Sécurisée</h3>
                <p>Accès contrôlé par rôle utilisateur</p>
            </div>
            <div class="feature">
                <h3>📁 Gestion FTP</h3>
                <p>Dépôt centralisé de fichiers sécurisé</p>
            </div>
            <div class="feature">
                <h3>🌐 Proxy Intelligent</h3>
                <p>Accès internet filtré par profil</p>
            </div>
            <div class="feature">
                <h3>🖥️ Infrastructure Réseau</h3>
                <p>DHCP, DNS, iPXE - Boot automatisé</p>
            </div>
        </div>
    </div>
</body>
</html>
