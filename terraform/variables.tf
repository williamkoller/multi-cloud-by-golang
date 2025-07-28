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
