#!/bin/bash

# ========================================
# Script de Validação - Lifecycle Policies
# Multi-Cloud Infrastructure
# ========================================

set -e

echo "🔍 Validando configurações de Lifecycle Policies..."
echo "=============================================="

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para logs coloridos
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Verificar se o Terraform está instalado
check_terraform() {
    log_info "Verificando instalação do Terraform..."
    if command -v terraform &> /dev/null; then
        TERRAFORM_VERSION=$(terraform version -json | jq -r '.terraform_version')
        log_success "Terraform v${TERRAFORM_VERSION} encontrado"
    else
        log_error "Terraform não encontrado. Instale o Terraform primeiro."
        exit 1
    fi
}

# Verificar se o arquivo terraform.tfvars existe
check_tfvars() {
    log_info "Verificando arquivo terraform.tfvars..."
    if [[ -f "terraform.tfvars" ]]; then
        log_success "Arquivo terraform.tfvars encontrado"
    else
        log_warning "Arquivo terraform.tfvars não encontrado"
        log_info "Copiando arquivo de exemplo..."
        cp terraform.tfvars.example terraform.tfvars
        log_warning "Edite o arquivo terraform.tfvars com suas configurações antes de continuar"
        exit 1
    fi
}

# Validar sintaxe do Terraform
validate_terraform() {
    log_info "Validando sintaxe dos arquivos Terraform..."
    if terraform validate; then
        log_success "Sintaxe Terraform válida"
    else
        log_error "Erro na sintaxe dos arquivos Terraform"
        exit 1
    fi
}

# Verificar configurações de lifecycle
check_lifecycle_config() {
    log_info "Verificando configurações de lifecycle..."
    
    # Verificar se lifecycle está habilitado
    LIFECYCLE_ENABLED=$(grep "enable_lifecycle_policies" terraform.tfvars | awk -F'=' '{print $2}' | tr -d ' ')
    if [[ "$LIFECYCLE_ENABLED" == "true" ]]; then
        log_success "Lifecycle policies habilitadas"
    else
        log_warning "Lifecycle policies desabilitadas"
    fi
    
    # Verificar transições
    IA_DAYS=$(grep "lifecycle_ia_transition_days" terraform.tfvars | awk -F'=' '{print $2}' | tr -d ' ')
    GLACIER_DAYS=$(grep "lifecycle_glacier_transition_days" terraform.tfvars | awk -F'=' '{print $2}' | tr -d ' ')
    ARCHIVE_DAYS=$(grep "lifecycle_deep_archive_transition_days" terraform.tfvars | awk -F'=' '{print $2}' | tr -d ' ')
    
    log_info "Configurações de transição:"
    echo "  - IA/Nearline: ${IA_DAYS} dias"
    echo "  - Glacier/Coldline: ${GLACIER_DAYS} dias"
    echo "  - Deep Archive/Archive: ${ARCHIVE_DAYS} dias"
    
    # Validar ordem das transições
    if [[ $IA_DAYS -lt $GLACIER_DAYS && $GLACIER_DAYS -lt $ARCHIVE_DAYS ]]; then
        log_success "Ordem das transições está correta"
    else
        log_error "Ordem das transições está incorreta. IA < Glacier < Archive"
        exit 1
    fi
}

# Verificar configurações de CORS
check_cors_config() {
    log_info "Verificando configurações de CORS..."
    
    # Verificar se CORS está habilitado
    CORS_ENABLED=$(grep "enable_cors" terraform.tfvars | awk -F'=' '{print $2}' | tr -d ' ')
    if [[ "$CORS_ENABLED" == "true" ]]; then
        log_success "CORS habilitado"
    else
        log_warning "CORS desabilitado"
        return
    fi
    
    # Verificar ambiente
    ENVIRONMENT=$(grep "environment" terraform.tfvars | awk -F'=' '{print $2}' | tr -d ' "')
    log_info "Ambiente detectado: ${ENVIRONMENT}"
    
    # Verificar origins
    ORIGINS_LINE=$(grep "cors_allowed_origins" terraform.tfvars)
    if echo "$ORIGINS_LINE" | grep -q '\*'; then
        if [[ "$ENVIRONMENT" == "prod" ]]; then
            log_error "CORS com wildcard (*) detectado em ambiente de produção!"
            log_error "Configure origins específicas para produção"
            exit 1
        else
            log_warning "CORS com wildcard (*) - adequado apenas para desenvolvimento"
        fi
    else
        log_success "Origins específicas configuradas"
    fi
    
    # Verificar métodos
    METHODS_LINE=$(grep "cors_allowed_methods" terraform.tfvars)
    if echo "$METHODS_LINE" | grep -q "DELETE"; then
        if [[ "$ENVIRONMENT" == "prod" ]]; then
            log_warning "Método DELETE habilitado em produção - verifique se é necessário"
        fi
    fi
    
    # Verificar credenciais
    CREDENTIALS=$(grep "cors_allow_credentials" terraform.tfvars | awk -F'=' '{print $2}' | tr -d ' ')
    if [[ "$CREDENTIALS" == "true" && "$ORIGINS_LINE" =~ "*" ]]; then
        log_error "CORS com credentials=true e origins=* não é permitido!"
        exit 1
    fi
    
    log_info "Configuração CORS validada com sucesso"
}

# Verificar estimativa de economia
show_savings_estimate() {
    log_info "Estimativa de economia com lifecycle policies:"
    echo ""
    echo "📊 AWS S3:"
    echo "  - STANDARD → STANDARD_IA (${IA_DAYS} dias): ~50% economia"
    echo "  - STANDARD_IA → GLACIER (${GLACIER_DAYS} dias): ~75% economia"
    echo "  - GLACIER → DEEP_ARCHIVE (${ARCHIVE_DAYS} dias): ~80% economia"
    echo ""
    echo "📊 GCP Cloud Storage:"
    echo "  - STANDARD → NEARLINE (${IA_DAYS} dias): ~50% economia"
    echo "  - NEARLINE → COLDLINE (${GLACIER_DAYS} dias): ~70% economia"
    echo "  - COLDLINE → ARCHIVE (${ARCHIVE_DAYS} dias): ~75% economia"
    echo ""
    log_success "Economia total estimada: 20-80% nos custos de storage"
}

# Gerar plano Terraform
generate_plan() {
    log_info "Gerando plano Terraform..."
    if terraform plan -out=lifecycle.tfplan; then
        log_success "Plano Terraform gerado com sucesso"
        log_info "Para aplicar as mudanças, execute:"
        echo "  terraform apply lifecycle.tfplan"
    else
        log_error "Erro ao gerar plano Terraform"
        exit 1
    fi
}

# Função principal
main() {
    echo ""
    log_info "Iniciando validação das configurações de lifecycle..."
    echo ""
    
    check_terraform
    echo ""
    
    check_tfvars
    echo ""
    
    # Inicializar Terraform se necessário
    if [[ ! -d ".terraform" ]]; then
        log_info "Inicializando Terraform..."
        terraform init
        echo ""
    fi
    
    validate_terraform
    echo ""
    
    check_lifecycle_config
    echo ""
    
    check_cors_config
    echo ""
    
    show_savings_estimate
    echo ""
    
    generate_plan
    echo ""
    
    log_success "Validação concluída com sucesso! 🎉"
    echo ""
    log_info "Próximos passos:"
    echo "1. Revisar o plano: terraform show lifecycle.tfplan"
    echo "2. Aplicar mudanças: terraform apply lifecycle.tfplan"
    echo "3. Verificar outputs:"
    echo "   - terraform output lifecycle_configuration"
    echo "   - terraform output cors_configuration"
    echo "   - terraform output cors_usage_examples"
    echo "   - terraform output cors_security_info"
}

# Verificar se está no diretório correto
if [[ ! -f "lifecycle_policies.tf" ]]; then
    log_error "Execute este script no diretório terraform/"
    exit 1
fi

# Executar função principal
main 