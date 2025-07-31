# Projeto DevOps: Infraestrutura Automatizada com Terraform, Jenkins e Ansible

Este projeto provisiona uma infraestrutura automatizada na AWS utilizando práticas de DevOps modernas, com foco em alta disponibilidade, segurança e modularização.

## 🔧 Tecnologias Utilizadas

- **Terraform** – Provisionamento da infraestrutura (VPC, Subnets, EC2, Load Balancer, Auto Scaling)
- **Jenkins** – Orquestração da pipeline CI/CD
- **Ansible** – Configuração automática das instâncias EC2 (instalação do Nginx e ajustes adicionais)

## 🏗️ Arquitetura - Tier 3 (3 Camadas)

- **Camada 1 – Bastion**:
  - Instância em **subnet pública** com acesso SSH restrito por IP
  - Utilizada como ponto de acesso seguro à infraestrutura
- **Camada 2 – Aplicação**:
  - EC2s em **subnets privadas**, configuradas com Nginx via Ansible
  - Recebem tráfego interno do Load Balancer
- **Camada 3 – Banco de Dados (Opcional)**:
  - Subnets privadas reservadas para RDS (não utilizadas no momento)
- **ALB**:
  - Load Balancer público com HTTPS via certificado ACM
  - Redirecionamento HTTP → HTTPS
- **NAT Gateway**:
  - Permite que instâncias privadas acessem a internet com segurança

## 📦 Módulos Terraform

- `VPC` – Cria a VPC, subnets públicas/privadas, NAT, rotas e SGs
- `LB` – Provisiona o Application Load Balancer com HTTPS
- `ASG` – Gerencia grupos de Auto Scaling para bastion e aplicação
- `Outputs` – Exporta informações úteis como DNS do ALB e subnets

## 🤖 Automação com Jenkins e Ansible

- Jenkins pipeline executa:
  1. `terraform init && terraform apply`
  2. Playbook Ansible com SSH na instância da aplicação
- Ansible realiza:
  - Instalação do Nginx
  - Criação do `index.html` customizado
  - Configurações de firewall/local

## 🚀 Como usar

1. Clone o repositório:
```bash
git clone https://github.com/JoaumGabrielSS/projeto-devops.git
cd projeto-devops
