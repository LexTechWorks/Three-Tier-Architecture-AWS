#!/bin/bash
# Bastion Host Setup Script - Ubuntu
# Configura o Bastion com Ansible para gerenciar a infraestrutura

set -e

# Variável do ambiente (será substituída via Terraform)
ENVIRONMENT="${ENVIRONMENT}"

echo "🚀 Iniciando configuração do Bastion Host..."

# Atualiza o sistema
echo "📦 Atualizando sistema..."
sudo apt update -y && sudo apt upgrade -y

# Instala ferramentas essenciais
echo "🔧 Instalando ferramentas essenciais..."
sudo apt install -y \
    htop \
    wget \
    curl \
    tcpdump \
    unzip \
    git \
    python3 \
    python3-pip \
    python3-venv \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release

# Instala AWS CLI v2
echo "☁️ Instalando AWS CLI..."
if ! command -v aws &> /dev/null; then
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
    rm -rf aws awscliv2.zip
fi

# Instala Ansible via apt (compatível com Ubuntu 22.04+)
echo "🤖 Instalando Ansible..."
sudo apt update
sudo apt install -y ansible python3-boto3 python3-botocore

# Instala pip para coleções específicas se necessário
sudo apt install -y python3-pip python3-full

# Instala coleções do Ansible
echo "📚 Instalando coleções do Ansible..."
ansible-galaxy collection install amazon.aws community.general

# Cria estrutura do Ansible para o usuário ubuntu
echo "📁 Configurando estrutura do Ansible..."
mkdir -p /home/ubuntu/ansible/{playbooks,inventory,roles,group_vars,host_vars,files,templates}
mkdir -p /home/ubuntu/.ansible/collections
mkdir -p /home/ubuntu/.ssh

# Configura permissões SSH
chmod 700 /home/ubuntu/.ssh
chown -R ubuntu:ubuntu /home/ubuntu/

# Cria configuração básica do Ansible
cat > /home/ubuntu/ansible/ansible.cfg << EOF
[defaults]
inventory = ./inventory/aws_ec2.yml
remote_user = ec2-user
host_key_checking = False
timeout = 30
private_key_file = ~/.ssh/id_rsa
forks = 10
stdout_callback = yaml
gathering = smart
fact_caching = memory
fact_caching_timeout = 3600

[ssh_connection]
ssh_args = -o ControlMaster=auto -o ControlPersist=60s -o StrictHostKeyChecking=no
pipelining = True
timeout = 10
retries = 3
EOF

# Cria inventário dinâmico AWS
cat > /home/ubuntu/ansible/inventory/aws_ec2.yml << EOF
plugin: amazon.aws.aws_ec2
regions:
  - us-east-1

filters:
  tag:Environment: ${ENVIRONMENT}
  tag:Project: ansible-integration
  instance-state-name: running

keyed_groups:
  - key: tags.Environment
    prefix: env
  - key: tags.Role
    prefix: role
  - key: tags.Type
    prefix: type
  - key: tags.Tier
    prefix: tier

hostnames:
  - private-ip-address

compose:
  ansible_host: private_ip_address
  ansible_user: |
    {%- if tags.Role == 'bastion' -%}
    ubuntu
    {%- else -%}
    ec2-user
    {%- endif -%}

cache: true
cache_plugin: memory
cache_timeout: 300
EOF

# Script utilitário para testar conectividade
cat > /home/ubuntu/ansible/test-connectivity.sh << 'EOF'
#!/bin/bash
echo "🔍 Testando inventário dinâmico..."
ansible-inventory --list

echo ""
echo "🏓 Testando conectividade..."
ansible all -m ping --ssh-common-args='-o ConnectTimeout=10'

echo ""
echo "📊 Mostrando grupos disponíveis..."
ansible-inventory --graph
EOF

chmod +x /home/ubuntu/ansible/test-connectivity.sh

# Cria script de setup automático
cat > /home/ubuntu/ansible/setup.sh << 'EOF'
#!/bin/bash
echo "🔧 Configurando chaves SSH..."

# Aguarda a chave ser copiada pelo Jenkins
while [ ! -f ~/.ssh/id_rsa ]; do
    echo "⏳ Aguardando chave SSH ser copiada..."
    sleep 5
done

chmod 600 ~/.ssh/id_rsa

echo "✅ Configuração concluída!"
echo "🧪 Para testar: ./test-connectivity.sh"
EOF

chmod +x /home/ubuntu/ansible/setup.sh

# Configura AWS CLI para usar IAM Role
mkdir -p /home/ubuntu/.aws
cat > /home/ubuntu/.aws/config << EOF
[default]
region = us-east-1
output = json
EOF

# Ajusta permissões
chown -R ubuntu:ubuntu /home/ubuntu/

# Cria banner de aviso no SSH
sudo tee /etc/ssh/banner > /dev/null << EOF
*******************************************
*     Bastion Host - Acesso Restrito     *
*         Ambiente: ${ENVIRONMENT}        *
*     Ansible Control Node Configurado   *
*******************************************
EOF

# Configurações de segurança no SSH
sudo sed -i 's|#Banner none|Banner /etc/ssh/banner|' /etc/ssh/sshd_config
sudo sed -i 's|#LogLevel INFO|LogLevel VERBOSE|' /etc/ssh/sshd_config
sudo sed -i 's|#MaxAuthTries 6|MaxAuthTries 3|' /etc/ssh/sshd_config

# Restart SSH service
sudo systemctl restart ssh

# Mensagem final
echo "✅ Configuração do Bastion finalizada com sucesso!"
echo "📁 Ansible configurado em: /home/ubuntu/ansible/"
echo "🔧 Scripts disponíveis:"
echo "   - test-connectivity.sh: Testa inventário e conectividade"
echo "   - setup.sh: Configura chaves SSH"