#!/bin/bash
# Bastion Host Setup Script

# Atualiza o sistema
yum update -y

# Instala ferramentas úteis
yum install -y htop wget curl tcpdump

# Configura o banner SSH
cat > /etc/ssh/banner << EOF
*******************************************
*     Bastion Host - Acesso Restrito     *
*         Ambiente: ${environment}        *
*******************************************
EOF

# Fortalece a configuração SSH
sed -i 's/#Banner none/Banner \/etc\/ssh\/banner/' /etc/ssh/sshd_config
sed -i 's/#LogLevel INFO/LogLevel VERBOSE/' /etc/ssh/sshd_config
sed -i 's/#MaxAuthTries 6/MaxAuthTries 3/' /etc/ssh/sshd_config

# Reinicia o serviço SSH
systemctl restart sshd

# Configura CloudWatch Logs
yum install -y awslogs
systemctl start awslogsd
systemctl enable awslogsd