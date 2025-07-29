# ========================================
# AWS S3 Lifecycle Policies
# ========================================

resource "aws_s3_bucket_lifecycle_configuration" "import_s3_lifecycle" {
  count  = var.enable_lifecycle_policies ? 1 : 0
  bucket = aws_s3_bucket.import_s3.id

  rule {
    id     = "multicloud_lifecycle_rule"
    status = "Enabled"

    # Transições para classes de armazenamento mais baratas
    transition {
      days          = var.lifecycle_ia_transition_days
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = var.lifecycle_glacier_transition_days
      storage_class = "GLACIER"
    }

    transition {
      days          = var.lifecycle_deep_archive_transition_days
      storage_class = "DEEP_ARCHIVE"
    }

    # Expiração de objetos (se configurado)
    dynamic "expiration" {
      for_each = var.lifecycle_expiration_days > 0 ? [1] : []
      content {
        days = var.lifecycle_expiration_days
      }
    }

    # Limpeza de versões não atuais
    noncurrent_version_expiration {
      noncurrent_days = var.lifecycle_noncurrent_version_expiration_days
    }

    # Transições para versões não atuais
    noncurrent_version_transition {
      noncurrent_days = var.lifecycle_ia_transition_days
      storage_class   = "STANDARD_IA"
    }

    noncurrent_version_transition {
      noncurrent_days = var.lifecycle_glacier_transition_days
      storage_class   = "GLACIER"
    }

    # Limpeza de uploads multipart incompletos
    abort_incomplete_multipart_upload {
      days_after_initiation = var.lifecycle_multipart_upload_days
    }

    # Filtro para aplicar a todos os objetos
    filter {}
  }

  # Regra específica para logs e temporários
  rule {
    id     = "cleanup_temp_files"
    status = "Enabled"

    filter {
      prefix = "temp/"
    }

    expiration {
      days = 7
    }
  }

  # Regra para logs com retenção mais longa
  rule {
    id     = "logs_lifecycle"
    status = "Enabled"

    filter {
      prefix = "logs/"
    }

    transition {
      days          = 1
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 30
      storage_class = "GLACIER"
    }

    expiration {
      days = 90
    }
  }

  depends_on = [aws_s3_bucket_versioning.versioning_example]
}

# ========================================
# GCP Cloud Storage Lifecycle Policies
# ========================================

resource "google_storage_bucket" "import_bucket" {
  name     = var.bucket_name
  location = "US"

  # Lifecycle configuration
  dynamic "lifecycle_rule" {
    for_each = var.enable_lifecycle_policies ? [1] : []
    content {
      condition {
        age = var.lifecycle_ia_transition_days
      }
      action {
        type          = "SetStorageClass"
        storage_class = "NEARLINE"
      }
    }
  }

  dynamic "lifecycle_rule" {
    for_each = var.enable_lifecycle_policies ? [1] : []
    content {
      condition {
        age = var.lifecycle_glacier_transition_days
      }
      action {
        type          = "SetStorageClass"
        storage_class = "COLDLINE"
      }
    }
  }

  dynamic "lifecycle_rule" {
    for_each = var.enable_lifecycle_policies ? [1] : []
    content {
      condition {
        age = var.lifecycle_deep_archive_transition_days
      }
      action {
        type          = "SetStorageClass"
        storage_class = "ARCHIVE"
      }
    }
  }

  # Expiração de objetos (se configurado)
  dynamic "lifecycle_rule" {
    for_each = var.enable_lifecycle_policies && var.lifecycle_expiration_days > 0 ? [1] : []
    content {
      condition {
        age = var.lifecycle_expiration_days
      }
      action {
        type = "Delete"
      }
    }
  }

  # Limpeza de uploads multipart incompletos
  dynamic "lifecycle_rule" {
    for_each = var.enable_lifecycle_policies ? [1] : []
    content {
      condition {
        age = var.lifecycle_multipart_upload_days
      }
      action {
        type = "AbortIncompleteMultipartUpload"
      }
    }
  }

  # Regra específica para arquivos temporários
  lifecycle_rule {
    condition {
      age                   = 7
      matches_prefix        = ["temp/"]
    }
    action {
      type = "Delete"
    }
  }

  # Regra para logs
  lifecycle_rule {
    condition {
      age            = 1
      matches_prefix = ["logs/"]
    }
    action {
      type          = "SetStorageClass"
      storage_class = "NEARLINE"
    }
  }

  lifecycle_rule {
    condition {
      age            = 30
      matches_prefix = ["logs/"]
    }
    action {
      type          = "SetStorageClass"
      storage_class = "COLDLINE"
    }
  }

  lifecycle_rule {
    condition {
      age            = 90
      matches_prefix = ["logs/"]
    }
    action {
      type = "Delete"
    }
  }

  # Versionamento (se habilitado)
  versioning {
    enabled = true
  }

  # Labels para organização
  labels = {
    environment   = var.environment
    managed_by    = "terraform"
    created_by    = "golang-sdk"
    has_lifecycle = "true"
  }
} 