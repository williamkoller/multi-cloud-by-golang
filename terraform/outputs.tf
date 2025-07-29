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