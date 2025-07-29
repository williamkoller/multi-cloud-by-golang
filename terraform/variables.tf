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
