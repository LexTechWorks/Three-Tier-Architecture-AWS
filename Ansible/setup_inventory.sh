#!/bin/bash
# Script para configurar automaticamente o inventário do Ansible
# Executa no Bastion Host para detectar e configurar acesso às instâncias privadas

set -e

echo "🔧 Configurando inventário do Ansible..."

# Função para log
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

# Verifica se está executando no Bastion
if [ ! -f /home/ubuntu/.ssh/id_rsa ]; then
    log "❌ Chave SSH não encontrada. Execute este script no Bastion."
    exit 1
fi

# Instala dependências se necessário
log "📦 Verificando dependências..."
if ! command -v aws &> /dev/null; then
    log "Instalando AWS CLI..."
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    sudo ./aws/install
    rm -rf aws awscliv2.zip
fi

if ! pip3 list | grep -q boto3; then
    log "Instalando boto3..."
    pip3 install boto3 botocore
fi

if ! ansible-galaxy collection list | grep -q amazon.aws; then
    log "Instalando coleção AWS para Ansible..."
    ansible-galaxy collection install amazon.aws
fi

# Obtém metadados da instância atual (Bastion)
log "🔍 Detectando configuração da instância..."
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/region)
BASTION_PRIVATE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
BASTION_PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)

log "📊 Informações detectadas:"
log "  Instance ID: $INSTANCE_ID"
log "  Region: $REGION"
log "  Bastion Private IP: $BASTION_PRIVATE_IP"
log "  Bastion Public IP: $BASTION_PUBLIC_IP"

# Configura AWS CLI se necessário
if ! aws sts get-caller-identity &> /dev/null; then
    log "⚠️ AWS CLI não configurado. Usando IAM Role da instância."
fi

# Cria inventário dinâmico personalizado
log "📝 Criando inventário dinâmico..."
cat > ~/ansible/aws_ec2_auto.yml << EOF
plugin: amazon.aws.aws_ec2
regions:
  - $REGION

filters:
  tag:Environment: prod
  instance-state-name: running

keyed_groups:
  - key: tags.Environment
    prefix: env
  - key: tags.Type
    prefix: role
  - key: tags.Tier
    prefix: tier

hostnames:
  - private-ip-address

compose:
  ansible_host: private_ip_address
  ansible_user: |
    {%- if tags.Type == 'bastion' -%}
    ubuntu
    {%- else -%}
    ec2-user
    {%- endif -%}
  ansible_ssh_common_args: |
    {%- if tags.Type == 'bastion' -%}
    -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null
    {%- else -%}
    -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ProxyCommand="ssh -W %h:%p -q ubuntu@$BASTION_PRIVATE_IP"
    {%- endif -%}

cache: true
cache_plugin: memory
cache_timeout: 300
EOF

# Atualiza ansible.cfg
log "⚙️ Configurando ansible.cfg..."
cat > ~/ansible/ansible.cfg << EOF
[defaults]
inventory = ./aws_ec2_auto.yml
remote_user = ec2-user
host_key_checking = False
timeout = 30
private_key_file = ~/.ssh/id_rsa
forks = 10
stdout_callback = yaml
gathering = smart
log_path = ./ansible.log

[ssh_connection]
ssh_args = -o ControlMaster=auto -o ControlPersist=60s
pipelining = True
timeout = 10
retries = 3
EOF

# Testa o inventário
log "🧪 Testando inventário..."
cd ~/ansible

if ansible-inventory --list > /dev/null 2>&1; then
    log "✅ Inventário dinâmico funcionando!"
    
    log "📋 Hosts detectados:"
    ansible-inventory --list | jq -r '.["tier_application"]["hosts"][]?' 2>/dev/null || echo "  Nenhum host de aplicação encontrado ainda"
    
    # Testa conectividade
    log "🔗 Testando conectividade..."
    if ansible all -m ping --ssh-common-args='-o ConnectTimeout=10' > /dev/null 2>&1; then
        log "✅ Conectividade OK!"
    else
        log "⚠️ Alguns hosts podem não estar acessíveis ainda. Isso é normal se as instâncias acabaram de ser criadas."
    fi
else
    log "❌ Erro no inventário dinâmico. Criando inventário estático..."
    
    # Busca instâncias manualmente
    APP_IPS=$(aws ec2 describe-instances \
        --region $REGION \
        --filters "Name=tag:Type,Values=application" "Name=instance-state-name,Values=running" \
        --query 'Reservations[].Instances[].PrivateIpAddress' \
        --output text)
    
    # Cria inventário estático
    cat > ~/ansible/hosts_static.ini << EOF
[bastion]
bastion_host ansible_host=$BASTION_PRIVATE_IP ansible_user=ubuntu

[application]
EOF
    
    counter=1
    for ip in $APP_IPS; do
        echo "app-server-$counter ansible_host=$ip ansible_user=ec2-user" >> ~/ansible/hosts_static.ini
        ((counter++))
    done
    
    cat >> ~/ansible/hosts_static.ini << EOF

[private_servers:children]
application

[private_servers:vars]
ansible_ssh_common_args=-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ProxyCommand="ssh -W %h:%p -q ubuntu@$BASTION_PRIVATE_IP"
ansible_ssh_private_key_file=~/.ssh/id_rsa

[all:vars]
ansible_python_interpreter=/usr/bin/python3
EOF
    
    # Atualiza ansible.cfg para usar inventário estático
    sed -i 's|inventory = ./aws_ec2_auto.yml|inventory = ./hosts_static.ini|' ~/ansible/ansible.cfg
    
    log "✅ Inventário estático criado!"
fi

log "🎉 Configuração concluída!"
log "📁 Arquivos criados em ~/ansible/"
log "🔧 Para testar: cd ~/ansible && ansible all -m ping"
