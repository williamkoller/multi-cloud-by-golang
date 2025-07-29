variable "project_id" {
  description = "ID do projeto GCP"
  type        = string
}

variable "credentials_file" {
  description = "Caminho para o JSON da conta de serviço"
  type        = string
}

variable "bucket_name" {
  description = "Nome do bucket a ser importado"
  type        = string
}

# Variáveis para Lifecycle Policies
variable "enable_lifecycle_policies" {
  description = "Habilita policies de lifecycle para otimização de custos"
  type        = bool
  default     = true
}

variable "lifecycle_ia_transition_days" {
  description = "Dias para transição para Infrequent Access/Nearline"
  type        = number
  default     = 30
}

variable "lifecycle_glacier_transition_days" {
  description = "Dias para transição para Glacier/Coldline"
  type        = number
  default     = 90
}

variable "lifecycle_deep_archive_transition_days" {
  description = "Dias para transição para Deep Archive/Archive"
  type        = number
  default     = 365
}

variable "lifecycle_expiration_days" {
  description = "Dias para expiração automática de objetos (0 = desabilitado)"
  type        = number
  default     = 0
}

variable "lifecycle_noncurrent_version_expiration_days" {
  description = "Dias para expiração de versões não atuais"
  type        = number
  default     = 30
}

variable "lifecycle_multipart_upload_days" {
  description = "Dias para limpeza de uploads multipart incompletos"
  type        = number
  default     = 7
}

variable "environment" {
  description = "Ambiente de deployment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

# ========================================
# Variáveis para Configuração CORS
# ========================================

variable "enable_cors" {
  description = "Habilita configuração de CORS nos buckets"
  type        = bool
  default     = true
}

variable "cors_allowed_origins" {
  description = "Lista de origins permitidas para CORS (* para todos em dev)"
  type        = list(string)
  default     = ["*"]
}

variable "cors_allowed_methods" {
  description = "Métodos HTTP permitidos para CORS"
  type        = list(string)
  default     = ["GET", "POST", "PUT", "DELETE", "HEAD"]
}

variable "cors_allowed_headers" {
  description = "Headers permitidos nas requisições CORS"
  type        = list(string)
  default     = [
    "Authorization",
    "Content-Type",
    "Content-Length",
    "Content-MD5",
    "Cache-Control",
    "X-Amz-Date",
    "X-Amz-Security-Token",
    "X-Amz-User-Agent",
    "x-amz-content-sha256"
  ]
}

variable "cors_exposed_headers" {
  description = "Headers expostos nas respostas CORS"
  type        = list(string)
  default     = [
    "ETag",
    "Content-Length",
    "Content-Type",
    "x-amz-request-id",
    "x-amz-id-2"
  ]
}

variable "cors_max_age_seconds" {
  description = "Tempo de cache para preflight requests em segundos"
  type        = number
  default     = 3600
}

variable "cors_allow_credentials" {
  description = "Permite envio de cookies e headers de autenticação"
  type        = bool
  default     = false
}

# Configurações específicas por ambiente
variable "cors_development_config" {
  description = "Configuração CORS específica para desenvolvimento"
  type = object({
    origins     = list(string)
    methods     = list(string)
    credentials = bool
  })
  default = {
    origins     = ["*"]
    methods     = ["GET", "POST", "PUT", "DELETE", "HEAD", "OPTIONS"]
    credentials = false
  }
}

variable "cors_production_config" {
  description = "Configuração CORS específica para produção"
  type = object({
    origins     = list(string)
    methods     = list(string)
    credentials = bool
  })
  default = {
    origins     = []  # Deve ser especificado explicitamente
    methods     = ["GET", "HEAD"]
    credentials = true
  }
}
