#!/bin/bash
# Script para deploy manual do Ansible (executa no Bastion Host)
# Use este script se precisar fazer deploy manual sem o Jenkins

set -e

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para log colorido
log() {
    echo -e "${GREEN}[$(date '+%Y-%m-%d %H:%M:%S')] $1${NC}"
}

warn() {
    echo -e "${YELLOW}[$(date '+%Y-%m-%d %H:%M:%S')] ⚠️  $1${NC}"
}

error() {
    echo -e "${RED}[$(date '+%Y-%m-%d %H:%M:%S')] ❌ $1${NC}"
}

info() {
    echo -e "${BLUE}[$(date '+%Y-%m-%d %H:%M:%S')] ℹ️  $1${NC}"
}

# Banner
echo -e "${BLUE}"
cat << 'EOF'
╔══════════════════════════════════════════════════════════╗
║                   🚀 Deploy Manual                      ║
║              Ansible + Terraform Integration            ║
╚══════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# Verifica se está no diretório correto
if [ ! -f "ansible.cfg" ]; then
    error "Execute este script no diretório ~/ansible/"
    exit 1
fi

# Verifica se a chave SSH existe
if [ ! -f ~/.ssh/id_rsa ]; then
    error "Chave SSH não encontrada em ~/.ssh/id_rsa"
    echo "Execute primeiro: ./setup.sh"
    exit 1
fi

log "Iniciando processo de deploy..."

# 1. Testa inventário dinâmico
log "🔍 Testando inventário dinâmico..."
if ansible-inventory --list > /dev/null 2>&1; then
    info "✅ Inventário dinâmico funcionando"
    
    # Mostra resumo dos hosts
    echo ""
    info "📋 Hosts detectados:"
    ansible-inventory --graph
    echo ""
else
    warn "❌ Inventário dinâmico falhou, tentando inventário estático..."
    
    # Verifica se existe inventário estático
    if [ ! -f "hosts_static.ini" ]; then
        error "Nenhum inventário disponível. Execute o script setup_inventory.sh primeiro."
        exit 1
    fi
    
    # Atualiza ansible.cfg para usar inventário estático
    sed -i 's|inventory = ./aws_ec2.yml|inventory = ./hosts_static.ini|' ansible.cfg
    info "✅ Usando inventário estático"
fi

# 2. Testa conectividade
log "🏓 Testando conectividade com os hosts..."
if ansible all -m ping --ssh-common-args='-o ConnectTimeout=10' > /dev/null 2>&1; then
    info "✅ Conectividade OK com todos os hosts"
else
    warn "⚠️ Alguns hosts podem não estar acessíveis"
    echo ""
    info "Tentando conexão individual por grupo..."
    
    # Testa cada grupo individualmente
    for group in bastion application; do
        if ansible $group -m ping --ssh-common-args='-o ConnectTimeout=10' > /dev/null 2>&1; then
            info "✅ Grupo '$group' acessível"
        else
            warn "❌ Grupo '$group' não acessível"
        fi
    done
    echo ""
fi

# 3. Pergunta qual playbook executar
echo ""
info "📚 Playbooks disponíveis:"
echo "  1) test-connectivity.yml - Testa conectividade e coleta informações"
echo "  2) playbook-nginx.yml - Instala e configura Nginx"
echo "  3) deploy-docker.yml - Deploy de container Docker"
echo ""

read -p "Escolha o playbook (1-3): " choice

case $choice in
    1)
        PLAYBOOK="test-connectivity.yml"
        DESCRIPTION="Teste de conectividade"
        ;;
    2)
        PLAYBOOK="playbook-nginx.yml"
        DESCRIPTION="Configuração do Nginx"
        ;;
    3)
        PLAYBOOK="deploy-docker.yml"
        DESCRIPTION="Deploy Docker"
        read -p "Imagem Docker (padrão: nginx:latest): " docker_image
        read -p "Tag (padrão: latest): " docker_tag
        EXTRA_VARS="--extra-vars \"docker_image=${docker_image:-nginx:latest} docker_tag=${docker_tag:-latest}\""
        ;;
    *)
        error "Opção inválida"
        exit 1
        ;;
esac

# 4. Executa o playbook
log "🚀 Executando: $DESCRIPTION"
echo ""

# Comando base do ansible-playbook
ANSIBLE_CMD="ansible-playbook $PLAYBOOK --ssh-common-args='-o StrictHostKeyChecking=no' -v"

# Adiciona extra vars se necessário
if [ ! -z "$EXTRA_VARS" ]; then
    ANSIBLE_CMD="$ANSIBLE_CMD $EXTRA_VARS"
fi

# Executa o comando
eval $ANSIBLE_CMD

# 5. Resultado
if [ $? -eq 0 ]; then
    echo ""
    log "🎉 Deploy concluído com sucesso!"
    
    # Se foi deploy de aplicação, mostra informações úteis
    if [[ "$PLAYBOOK" == *"nginx"* ]] || [[ "$PLAYBOOK" == *"docker"* ]]; then
        echo ""
        info "🔗 Informações úteis:"
        echo "   • Para testar a aplicação via ALB, use o DNS do Load Balancer"
        echo "   • Para verificar logs: ssh para as instâncias e rode 'sudo tail -f /var/log/nginx/error.log'"
        echo "   • Para verificar status: curl http://<instance-ip>/health"
    fi
    
    echo ""
    info "📊 Para monitorar:"
    echo "   • AWS Console: https://console.aws.amazon.com/"
    echo "   • Logs do Ansible: ./ansible.log"
    echo ""
    
else
    echo ""
    error "❌ Deploy falhou!"
    echo ""
    info "🔍 Para debugar:"
    echo "   • Verifique os logs acima"
    echo "   • Teste conectividade: ansible all -m ping"
    echo "   • Verifique inventário: ansible-inventory --list"
    echo "   • Execute em modo verbose: ansible-playbook $PLAYBOOK -vvv"
    echo ""
    exit 1
fi
