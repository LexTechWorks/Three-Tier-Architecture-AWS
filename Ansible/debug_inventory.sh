#!/bin/bash
# Script para debug do inventário Ansible

echo "🔍 Ansible Inventory Debug Script"
echo "=================================="

# Função para log colorido
log_info() { echo -e "\033[34m[INFO]\033[0m $1"; }
log_success() { echo -e "\033[32m[SUCCESS]\033[0m $1"; }
log_warning() { echo -e "\033[33m[WARNING]\033[0m $1"; }
log_error() { echo -e "\033[31m[ERROR]\033[0m $1"; }

# 1. Verifica se está no diretório correto
if [ ! -f "ansible.cfg" ]; then
    log_error "ansible.cfg não encontrado. Execute no diretório do Ansible."
    exit 1
fi

log_info "Diretório atual: $(pwd)"

# 2. Verifica dependências
log_info "Verificando dependências..."

if command -v ansible &> /dev/null; then
    log_success "Ansible: $(ansible --version | head -1)"
else
    log_error "Ansible não encontrado"
fi

if command -v aws &> /dev/null; then
    log_success "AWS CLI: $(aws --version)"
else
    log_warning "AWS CLI não encontrado"
fi

if python3 -c "import boto3" 2>/dev/null; then
    log_success "Boto3: Disponível"
else
    log_error "Boto3 não encontrado"
fi

# 3. Testa credenciais AWS
log_info "Testando credenciais AWS..."
if aws sts get-caller-identity &> /dev/null; then
    ACCOUNT=$(aws sts get-caller-identity --query Account --output text)
    log_success "AWS configurado - Account: $ACCOUNT"
else
    log_warning "AWS não configurado ou sem permissões"
fi

# 4. Testa inventário dinâmico
log_info "Testando inventário dinâmico..."
if ansible-inventory --list > /tmp/inventory.json 2>&1; then
    log_success "Inventário dinâmico funcionando"
    
    # Conta hosts por grupo
    BASTION_COUNT=$(jq -r '.["role_bastion"]["hosts"]? // [] | length' /tmp/inventory.json)
    APP_COUNT=$(jq -r '.["role_application"]["hosts"]? // [] | length' /tmp/inventory.json)
    
    log_info "Hosts encontrados:"
    log_info "  - Bastion: $BASTION_COUNT"
    log_info "  - Application: $APP_COUNT"
    
    # Lista todos os hosts
    echo ""
    log_info "Lista completa de hosts:"
    jq -r '._meta.hostvars | keys[]' /tmp/inventory.json | while read host; do
        IP=$(jq -r "._meta.hostvars[\"$host\"].ansible_host" /tmp/inventory.json)
        USER=$(jq -r "._meta.hostvars[\"$host\"].ansible_user" /tmp/inventory.json)
        echo "  - $host: $USER@$IP"
    done
    
else
    log_error "Erro no inventário dinâmico:"
    cat /tmp/inventory.json
fi

# 5. Testa conectividade SSH
log_info "Testando conectividade SSH..."

# Primeiro testa Bastion
BASTION_HOSTS=$(jq -r '.["role_bastion"]["hosts"][]? // empty' /tmp/inventory.json 2>/dev/null)
for host in $BASTION_HOSTS; do
    BASTION_IP=$(jq -r "._meta.hostvars[\"$host\"].ansible_host" /tmp/inventory.json)
    log_info "Testando Bastion: $BASTION_IP"
    
    if timeout 10 ansible $host -m ping &> /dev/null; then
        log_success "Bastion acessível: $host"
    else
        log_error "Bastion inacessível: $host"
    fi
done

# Depois testa instâncias de aplicação
APP_HOSTS=$(jq -r '.["role_application"]["hosts"][]? // empty' /tmp/inventory.json 2>/dev/null)
for host in $APP_HOSTS; do
    APP_IP=$(jq -r "._meta.hostvars[\"$host\"].ansible_host" /tmp/inventory.json)
    log_info "Testando App: $APP_IP"
    
    if timeout 15 ansible $host -m ping &> /dev/null; then
        log_success "App acessível: $host"
    else
        log_warning "App inacessível: $host (normal se acabou de subir)"
    fi
done

# 6. Verifica chaves SSH
log_info "Verificando chaves SSH..."
if [ -f ~/.ssh/id_rsa ]; then
    log_success "Chave privada encontrada: ~/.ssh/id_rsa"
    
    # Verifica permissões
    PERMS=$(stat -c %a ~/.ssh/id_rsa)
    if [ "$PERMS" = "600" ]; then
        log_success "Permissões corretas: $PERMS"
    else
        log_warning "Permissões incorretas: $PERMS (deve ser 600)"
        log_info "Corrigindo: chmod 600 ~/.ssh/id_rsa"
        chmod 600 ~/.ssh/id_rsa
    fi
else
    log_error "Chave privada não encontrada: ~/.ssh/id_rsa"
fi

# 7. Testa execução de comando simples
log_info "Testando execução de comando..."
if ansible all -m command -a "whoami" &> /tmp/command_test.log; then
    log_success "Comando executado com sucesso"
    cat /tmp/command_test.log
else
    log_error "Erro na execução de comando:"
    cat /tmp/command_test.log
fi

# 8. Resumo final
echo ""
log_info "=== RESUMO ==="
log_info "Use os comandos abaixo para debug manual:"
echo "  ansible-inventory --list | jq ."
echo "  ansible all -m ping -v"
echo "  ansible all -m setup | grep ansible_default_ipv4"
echo "  ansible-playbook test-connectivity.yml"

# Limpeza
rm -f /tmp/inventory.json /tmp/command_test.log
