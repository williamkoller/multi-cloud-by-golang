# 🚀 Projeto MultiCloud com Golang + Terraform (Complementar)

Este projeto demonstra como usar **Golang como motor principal** para provisionar infraestrutura (buckets), enquanto o **Terraform é usado apenas como complemento opcional** — por exemplo, para importar recursos existentes e aplicar observabilidade ou versionamento.

---

## ✨ O que está incluso

- ✅ Criação e deleção de bucket S3 na AWS usando Go SDK
- ✅ Criação e deleção de bucket no GCP usando Go SDK
- ✅ CLI usando [Cobra](https://github.com/spf13/cobra) com suporte a flags
- ✅ Configuração por `.env` (GCP)
- ✅ Execução paralela com goroutines
- 🛠️ Terraform como complemento (importação apenas)
- 🔐 Sem logs nem dependência de Terraform para criação

---

## 📁 Estrutura

```
multicloud/
├── cmd/                  # Comando CLI (create/delete)
├── internal/             # Lógica de provisionamento (AWS, GCP)
├── main.go               # Entry point
├── .env                  # Configuração do ambiente
├── go.mod                # Dependências Go
└── terraform/            # Importação opcional via Terraform
    ├── aws_import.tf
    └── gcp_import.tf
```

---

## ⚙️ Pré-requisitos

- Go 1.24.5
- AWS CLI configurado (`aws configure`)
- Conta de serviço GCP com `roles/storage.admin`
- Terraform instalado (opcional para importação)

---

## 🔐 Variáveis de ambiente (`.env`)

```env
GCP_PROJECT_ID=seu-projeto-gcp-id
GCP_CREDENTIAL_FILE=gcp-sa.json
```

---

## ▶️ Como usar

### Instalar dependências

```bash
go mod tidy
```

### Criar buckets

```bash
# AWS + GCP
go run main.go --aws --gcp --create --bucketname meu-bucket

# Apenas AWS
go run main.go --aws --create --bucketname bucket-aws

# Apenas GCP
go run main.go --gcp --create --bucketname bucket-gcp
```

### Deletar buckets

```bash
# AWS + GCP
go run main.go --aws --gcp --delete --bucketname meu-bucket

# Apenas AWS
go run main.go --aws --delete --bucketname bucket-aws

# Apenas GCP
go run main.go --gcp --delete --bucketname bucket-gcp
```

---

## 📦 Terraform (Importação opcional)

### Exemplo `terraform/aws_import.tf`

```hcl
provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "importado" {
  bucket = "meu-bucket"
}
```

### Exemplo `terraform/gcp_import.tf`

```hcl
provider "google" {
  project = "seu-projeto-gcp-id"
}

resource "google_storage_bucket" "importado" {
  name     = "meu-bucket"
  location = "US"
}
```

### Importar buckets

```bash
cd terraform
terraform init

# Importar AWS
terraform import aws_s3_bucket.importado meu-bucket

# Importar GCP
terraform import google_storage_bucket.importado meu-bucket
```

### Adicionar configurações via Terraform (opcional)

```hcl
resource "google_storage_bucket" "importado" {
  name     = "meu-bucket"
  location = "US"

  versioning {
    enabled = true
  }

  labels = {
    CriadoPor = "Golang"
    Ambiente  = "Multicloud"
  }
}
```

---

## 💡 Filosofia

- ✅ **Golang cria e deleta**
- ✅ **Terraform apenas complementa (se/quando necessário)**
- 🔁 Código Go é o motor principal
- 📦 Sem estado Terraform obrigatório

---

## 🧠 Autor

William Koller  
Backend Engineer | Arquitetura | Golang | AWS | MultiCloud

---
