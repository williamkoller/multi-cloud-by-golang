# ========================================
# CORS Configuration
# Cross-Origin Resource Sharing
# ========================================

# Locals para configuração dinâmica baseada no ambiente
locals {
  # Configuração CORS baseada no ambiente
  cors_config = var.environment == "prod" ? var.cors_production_config : var.cors_development_config
  
  # Origins finais (usa cors_allowed_origins se não especificado no config específico)
  final_origins = length(local.cors_config.origins) > 0 ? local.cors_config.origins : var.cors_allowed_origins
  
  # Headers permitidos com adições específicas do GCP
  gcp_allowed_headers = concat(var.cors_allowed_headers, [
    "x-goog-meta-*",
    "x-goog-resumable"
  ])
  
  # Headers expostos com adições específicas do GCP
  gcp_exposed_headers = concat(var.cors_exposed_headers, [
    "x-goog-hash",
    "x-goog-generation",
    "x-goog-metageneration"
  ])
}

# ========================================
# AWS S3 CORS Configuration
# ========================================

resource "aws_s3_bucket_cors_configuration" "import_s3_cors" {
  count  = var.enable_cors ? 1 : 0
  bucket = aws_s3_bucket.import_s3.id

  # Regra principal para aplicações web
  cors_rule {
    id              = "main-cors-rule"
    allowed_origins = local.final_origins
    allowed_methods = local.cors_config.methods
    allowed_headers = var.cors_allowed_headers
    expose_headers  = var.cors_exposed_headers
    max_age_seconds = var.cors_max_age_seconds
  }

  # Regra específica para uploads diretos
  cors_rule {
    id              = "upload-cors-rule"
    allowed_origins = local.final_origins
    allowed_methods = ["POST", "PUT"]
    allowed_headers = concat(var.cors_allowed_headers, [
      "x-amz-acl",
      "x-amz-server-side-encryption",
      "x-amz-storage-class"
    ])
    expose_headers  = var.cors_exposed_headers
    max_age_seconds = var.cors_max_age_seconds
  }

  # Regra para downloads e visualização
  cors_rule {
    id              = "download-cors-rule"
    allowed_origins = local.final_origins
    allowed_methods = ["GET", "HEAD"]
    allowed_headers = ["Range", "If-Modified-Since", "Cache-Control"]
    expose_headers  = concat(var.cors_exposed_headers, [
      "Accept-Ranges",
      "Content-Range",
      "Last-Modified"
    ])
    max_age_seconds = var.cors_max_age_seconds
  }

  # Regra para preflight OPTIONS (se necessário)
  dynamic "cors_rule" {
    for_each = contains(local.cors_config.methods, "OPTIONS") ? [1] : []
    content {
      id              = "preflight-cors-rule"
      allowed_origins = local.final_origins
      allowed_methods = ["OPTIONS"]
      allowed_headers = ["*"]
      max_age_seconds = var.cors_max_age_seconds
    }
  }

  depends_on = [aws_s3_bucket.import_s3]
}

# ========================================
# AWS S3 Bucket Policy para CORS (opcional)
# ========================================

resource "aws_s3_bucket_policy" "cors_policy" {
  count  = var.enable_cors && var.environment != "dev" ? 1 : 0
  bucket = aws_s3_bucket.import_s3.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowCORSRequests"
        Effect    = "Allow"
        Principal = "*"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = "${aws_s3_bucket.import_s3.arn}/*"
        Condition = {
          StringLike = {
            "aws:Referer" = local.final_origins
          }
        }
      }
    ]
  })

  depends_on = [aws_s3_bucket_public_access_block.import_s3_pab]
}

# ========================================
# GCP Cloud Storage CORS Configuration
# ========================================

# Atualizar o bucket GCP no lifecycle_policies.tf para incluir CORS
# A configuração será integrada diretamente no resource google_storage_bucket 