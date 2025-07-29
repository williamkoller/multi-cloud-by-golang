# ========================================
# AWS S3 Outputs
# ========================================

output "aws_bucket_name" {
  description = "Nome do bucket S3 na AWS"
  value       = aws_s3_bucket.import_s3.bucket
}

output "aws_bucket_arn" {
  description = "ARN do bucket S3 na AWS"
  value       = aws_s3_bucket.import_s3.arn
}

output "aws_bucket_region" {
  description = "Região do bucket S3 na AWS"
  value       = aws_s3_bucket.import_s3.region
}

output "aws_lifecycle_enabled" {
  description = "Status das lifecycle policies no S3"
  value       = var.enable_lifecycle_policies
}

# ========================================
# GCP Cloud Storage Outputs
# ========================================

output "gcp_bucket_name" {
  description = "Nome do bucket no GCP Cloud Storage"
  value       = google_storage_bucket.import_bucket.name
}

output "gcp_bucket_url" {
  description = "URL do bucket no GCP Cloud Storage"
  value       = google_storage_bucket.import_bucket.url
}

output "gcp_bucket_location" {
  description = "Localização do bucket no GCP"
  value       = google_storage_bucket.import_bucket.location
}

output "gcp_lifecycle_enabled" {
  description = "Status das lifecycle policies no GCP"
  value       = var.enable_lifecycle_policies
}

# ========================================
# CORS Outputs
# ========================================

output "cors_enabled" {
  description = "Status da configuração CORS"
  value       = var.enable_cors
}

output "cors_configuration" {
  description = "Configuração CORS atual"
  value = var.enable_cors ? {
    enabled            = var.enable_cors
    allowed_origins    = local.final_origins
    allowed_methods    = local.cors_config.methods
    max_age_seconds    = var.cors_max_age_seconds
    allow_credentials  = var.cors_allow_credentials
    environment_config = local.cors_config
  } : {
    enabled = false
    message = "CORS está desabilitado"
  }
}

# ========================================
# Configurações de Lifecycle
# ========================================

output "lifecycle_configuration" {
  description = "Resumo das configurações de lifecycle"
  value = {
    enabled                    = var.enable_lifecycle_policies
    ia_transition_days        = var.lifecycle_ia_transition_days
    glacier_transition_days   = var.lifecycle_glacier_transition_days
    archive_transition_days   = var.lifecycle_deep_archive_transition_days
    expiration_days          = var.lifecycle_expiration_days
    noncurrent_expiration    = var.lifecycle_noncurrent_version_expiration_days
    multipart_cleanup_days   = var.lifecycle_multipart_upload_days
    environment              = var.environment
  }
}

# ========================================
# Savings Estimation
# ========================================

output "estimated_savings_info" {
  description = "Informações sobre economia estimada com lifecycle policies"
  value = var.enable_lifecycle_policies ? {
    message = "Lifecycle policies ativadas - economia estimada de 20-60% nos custos de storage"
    aws_transitions = [
      "STANDARD -> STANDARD_IA (${var.lifecycle_ia_transition_days} dias): ~50% economia",
      "STANDARD_IA -> GLACIER (${var.lifecycle_glacier_transition_days} dias): ~75% economia", 
      "GLACIER -> DEEP_ARCHIVE (${var.lifecycle_deep_archive_transition_days} dias): ~80% economia"
    ]
    gcp_transitions = [
      "STANDARD -> NEARLINE (${var.lifecycle_ia_transition_days} dias): ~50% economia",
      "NEARLINE -> COLDLINE (${var.lifecycle_glacier_transition_days} dias): ~70% economia",
      "COLDLINE -> ARCHIVE (${var.lifecycle_deep_archive_transition_days} dias): ~75% economia"
    ]
  } : {
    message = "Lifecycle policies desativadas - sem otimização automática de custos"
  }
}

# ========================================
# CORS Usage Examples
# ========================================

output "cors_usage_examples" {
  description = "Exemplos de uso da configuração CORS"
  value = var.enable_cors ? {
    direct_upload_example = {
      description = "Upload direto de arquivos via JavaScript"
      javascript_example = "fetch('${aws_s3_bucket.import_s3.bucket_regional_domain_name}/file.jpg', { method: 'PUT', body: file })"
      note = "Requer assinatura de URL ou configuração de bucket policy adequada"
    }
    cdn_integration = {
      description = "Integração com CDN para servir arquivos"
      cloudfront_origin = aws_s3_bucket.import_s3.bucket_regional_domain_name
      note = "Configure CloudFront com este bucket como origin"
    }
    web_app_access = {
      description = "Acesso direto de aplicações web"
      allowed_origins = local.final_origins
      allowed_methods = local.cors_config.methods
      note = "Aplicações web podem acessar diretamente os buckets"
    }
  } : {
    message = "CORS desabilitado - não há exemplos de uso disponíveis"
  }
}

# ========================================
# Security Information
# ========================================

output "cors_security_info" {
  description = "Informações de segurança sobre a configuração CORS"
  value = var.enable_cors ? {
    environment = var.environment
    security_level = var.environment == "prod" ? "Alta segurança - origins específicas" : "Desenvolvimento - permitir todos (*)"
    recommendations = var.environment == "prod" ? [
      "✅ Origins específicas configuradas",
      "✅ Métodos limitados aos necessários",
      "✅ Credentials habilitadas para autenticação",
      "⚠️  Revise regularmente as origins permitidas"
    ] : [
      "⚠️  Ambiente de desenvolvimento - CORS aberto (*)",
      "⚠️  NÃO use '*' em produção",
      "✅ Configuração adequada para desenvolvimento local",
      "📝 Configure origins específicas antes de ir para produção"
    ]
    origins_count = length(local.final_origins)
    wildcard_used = contains(local.final_origins, "*")
  } : {
    message = "CORS desabilitado - nenhuma informação de segurança disponível"
  }
} 