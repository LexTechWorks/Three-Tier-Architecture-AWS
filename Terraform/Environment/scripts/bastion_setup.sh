#!/bin/bash
# Bastion Host Setup Script - Ubuntu

# Variável do ambiente (será substituída via Terraform)
ENVIRONMENT="${ENVIRONMENT}"

# Atualiza o sistema
apt update -y && apt upgrade -y

# Instala ferramentas úteis
apt install -y htop wget curl tcpdump unzip git python3 python3-pip

# Instala Ansible e dependências AWS
pip3 install ansible boto3 botocore
apt install -y ansible-core

# Cria estrutura padrão do Ansible
mkdir -p /etc/ansible
chown -R ubuntu:ubuntu /etc/ansible

# Cria banner de aviso no SSH
cat > /etc/ssh/banner << EOF
*******************************************
*     Bastion Host - Acesso Restrito     *
*         Ambiente: ${ENVIRONMENT}        *
*******************************************
EOF

# Configurações de segurança no SSH
sed -i 's|#Banner none|Banner /etc/ssh/banner|' /etc/ssh/sshd_config
sed -i 's|#LogLevel INFO|LogLevel VERBOSE|' /etc/ssh/sshd_config
sed -i 's|#MaxAuthTries 6|MaxAuthTries 3|' /etc/ssh/sshd_config

# Reinicia o SSH
systemctl restart ssh

# Mensagem final
echo "Configuração do Bastion finalizada com sucesso."