#!/bin/bash
# Application Setup Script

# Atualiza o sistema
yum update -y

# Instala o Apache e outras ferramentas
yum install -y httpd wget curl

# Configura página web básica
cat > /var/www/html/index.html << EOF
<!DOCTYPE html>
<html>
<head>
    <title>Application Server</title>
</head>
<body>
    <h1>Welcome to Application Server</h1>
    <p>Instance ID: $(curl -s http://169.254.169.254/latest/meta-data/instance-id)</p>
    <p>Availability Zone: $(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)</p>
</body>
</html>
EOF

# Inicia e habilita o Apache
systemctl start httpd
systemctl enable httpd

# Configura CloudWatch Logs
yum install -y awslogs
systemctl start awslogsd
systemctl enable awslogsd

# Configura health check
cat > /var/www/html/health << EOF
OK
EOF

# Adiciona tags nos logs
echo "Instance ID: $(curl -s http://169.254.169.254/latest/meta-data/instance-id)" >> /var/log/cloud-init-output.log