#!/bin/bash
set -e

# Update system
yum update -y
yum install -y httpd php php-mysql

# Create simple health check
cat > /var/www/html/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Queens App - 3-Tier Infrastructure</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .container { max-width: 600px; }
        .status { padding: 10px; margin: 10px 0; border-radius: 5px; }
        .healthy { background-color: #d4edda; color: #155724; }
    </style>
</head>
<body>
    <div class="container">
        <h1>Queens App - 3-Tier Infrastructure</h1>
        <div class="status healthy">
            <h2>✓ Web Tier Healthy</h2>
            <p>Environment: ${environment}</p>
            <p>Database Host: ${db_host}</p>
            <p>Database: ${db_name}</p>
        </div>
    </div>
</body>
</html>
EOF

# Start Apache
systemctl start httpd
systemctl enable httpd
