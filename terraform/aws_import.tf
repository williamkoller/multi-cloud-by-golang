provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "import_s3" {
  bucket = var.bucket_name

  tags = {
    CriadoPor     = "Golang"
    Ambiente      = var.environment
    ManagedBy     = "Terraform"
    HasLifecycle  = var.enable_lifecycle_policies ? "true" : "false"
    HasCORS       = var.enable_cors ? "true" : "false"
    Project       = "MultiCloud"
    Purpose       = "Storage"
  }
}

resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.import_s3.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Configuração de public access block para segurança
resource "aws_s3_bucket_public_access_block" "import_s3_pab" {
  bucket = aws_s3_bucket.import_s3.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Server-side encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "import_s3_encryption" {
  bucket = aws_s3_bucket.import_s3.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}