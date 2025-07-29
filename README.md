# 🚀 Multi-Cloud Infrastructure with Golang + Terraform

Este projeto demonstra como usar **Golang como motor principal** para provisionar infraestrutura (buckets S3 e Google Cloud Storage), enquanto o **Terraform é usado apenas como complemento opcional** para importar recursos existentes e aplicar configurações avançadas como versionamento e tags.

---

## ✨ Funcionalidades

- ✅ **Criação e deleção de buckets S3** na AWS usando AWS SDK v2
- ✅ **Criação e deleção de buckets** no Google Cloud Storage usando Cloud Storage SDK
- ✅ **CLI moderna** usando [Cobra](https://github.com/spf13/cobra) com flags intuitivas
- ✅ **Configuração via variáveis de ambiente** com suporte a `.env`
- ✅ **Execução paralela** com goroutines para operações simultâneas
- ✅ **Terraform complementar** para importação e configurações avançadas
- 🔐 **Sem dependência de state Terraform** para operações básicas

---

## 📁 Estrutura do Projeto

```
multi-cloud-by-golang/
├── cmd/
│   └── root.go              # Configuração da CLI e comandos
├── internal/
│   ├── aws.go               # Lógica AWS S3
│   └── gcp.go               # Lógica Google Cloud Storage
├── terraform/
│   ├── aws_import.tf        # Configurações AWS para importação
│   ├── gcp_import.tf        # Configurações GCP para importação
│   └── variables.tf         # Variáveis do Terraform
├── main.go                  # Entry point da aplicação
├── go.mod                   # Dependências Go
├── go.sum                   # Checksums das dependências
└── .env                     # Configurações do ambiente (criar)
```

---

## ⚙️ Pré-requisitos

- **Go 1.24.5** ou superior
- **AWS CLI configurado** (`aws configure` ou variáveis de ambiente)
- **Conta de serviço GCP** com role `roles/storage.admin`
- **Terraform** (opcional, apenas para importação e configurações avançadas)

---

## 🔐 Configuração de Ambiente

### Arquivo `.env` (criar na raiz do projeto)

```env
# Configurações GCP
GCP_PROJECT_ID=seu-projeto-gcp-id
GCP_CREDENTIAL_FILE=caminho/para/gcp-service-account.json
```

### Configuração AWS

Configure suas credenciais AWS via:

```bash
# Usando AWS CLI
aws configure

# Ou via variáveis de ambiente
export AWS_ACCESS_KEY_ID=sua-access-key
export AWS_SECRET_ACCESS_KEY=sua-secret-key
export AWS_DEFAULT_REGION=us-east-1
```

---

## 🚀 Instalação e Uso

### 1. Clonar e instalar dependências

```bash
git clone https://github.com/williamkoller/multi-cloud-by-golang.git
cd multi-cloud-by-golang
go mod tidy
```

### 2. Configurar ambiente

```bash
# Criar arquivo .env com suas configurações
cp .env.example .env  # (criar o arquivo com as variáveis necessárias)
```

### 3. Usar a CLI

#### Criar buckets

```bash
# AWS + GCP simultaneamente
go run main.go --aws --gcp --create --bucketname meu-bucket-multicloud

# Apenas AWS
go run main.go --aws --create --bucketname meu-bucket-aws

# Apenas GCP
go run main.go --gcp --create --bucketname meu-bucket-gcp
```

#### Deletar buckets

```bash
# AWS + GCP simultaneamente
go run main.go --aws --gcp --delete --bucketname meu-bucket-multicloud

# Apenas AWS
go run main.go --aws --delete --bucketname meu-bucket-aws

# Apenas GCP
go run main.go --gcp --delete --bucketname meu-bucket-gcp
```

### 4. Build do executável

```bash
# Build para sistema atual
go build -o multicloud .

# Usar o executável
./multicloud --aws --gcp --create --bucketname meu-bucket
```

---

## 🛠️ Terraform (Configurações Avançadas)

### Importar buckets existentes criados via Go

```bash
cd terraform

# Inicializar Terraform
terraform init

# Criar arquivo terraform.tfvars
cat > terraform.tfvars << EOF
project_id = "seu-projeto-gcp-id"
credentials_file = "caminho/para/gcp-service-account.json"
bucket_name = "bucket-golang-sdk"
EOF

# Importar bucket AWS
terraform import aws_s3_bucket.import_s3 bucket-golang-sdk

# Importar bucket GCP
terraform import google_storage_bucket.import_bucket bucket-golang-sdk

# Aplicar configurações avançadas (versionamento, tags, etc.)
terraform plan
terraform apply
```

---

## 💰 Lifecycle Policies - Otimização de Custos

### Configuração de Lifecycle Policies

As lifecycle policies foram implementadas para **redução automática de custos** através de transições inteligentes entre classes de armazenamento e limpeza de dados desnecessários.

#### Benefícios das Lifecycle Policies

- 🎯 **Economia de até 80%** nos custos de storage
- 🔄 **Transições automáticas** entre classes de armazenamento
- 🧹 **Limpeza automática** de versões antigas e uploads incompletos
- ⚡ **Configuração flexível** por ambiente (dev, staging, prod)

### Configurações Padrão

#### AWS S3 - Transições

| Tempo    | Classe de Storage      | Economia Estimada |
| -------- | ---------------------- | ----------------- |
| 30 dias  | STANDARD → STANDARD_IA | ~50%              |
| 90 dias  | STANDARD_IA → GLACIER  | ~75%              |
| 365 dias | GLACIER → DEEP_ARCHIVE | ~80%              |

#### GCP Cloud Storage - Transições

| Tempo    | Classe de Storage   | Economia Estimada |
| -------- | ------------------- | ----------------- |
| 30 dias  | STANDARD → NEARLINE | ~50%              |
| 90 dias  | NEARLINE → COLDLINE | ~70%              |
| 365 dias | COLDLINE → ARCHIVE  | ~75%              |

### Regras Especiais Implementadas

#### 🗂️ Arquivos Temporários

```
Pasta: temp/
Ação: Exclusão automática após 7 dias
Objetivo: Limpeza de arquivos temporários
```

#### 📋 Logs

```
Pasta: logs/
Transições:
- STANDARD → IA/NEARLINE (1 dia)
- IA/NEARLINE → GLACIER/COLDLINE (30 dias)
- Exclusão após 90 dias
```

#### 🔄 Versões Antigas

```
Ação: Exclusão de versões não atuais após 30 dias
Objetivo: Evitar acúmulo desnecessário de versões
```

#### 📤 Uploads Multipart

```
Ação: Limpeza de uploads incompletos após 7 dias
Objetivo: Evitar cobrança por uploads abandonados
```

### Personalização por Ambiente

#### Desenvolvimento

```hcl
# terraform.tfvars
environment = "dev"
lifecycle_ia_transition_days = 7
lifecycle_glacier_transition_days = 30
lifecycle_expiration_days = 90
```

#### Produção

```hcl
# terraform.tfvars
environment = "prod"
lifecycle_ia_transition_days = 30
lifecycle_glacier_transition_days = 90
lifecycle_deep_archive_transition_days = 365
lifecycle_expiration_days = 0  # Nunca expira
```

### Configuração e Deploy

#### 1. Configurar variáveis

```bash
# Copiar arquivo de exemplo
cp terraform/terraform.tfvars.example terraform/terraform.tfvars

# Editar configurações
nano terraform/terraform.tfvars
```

#### 2. Aplicar lifecycle policies

```bash
cd terraform

# Revisar mudanças
terraform plan

# Aplicar configurações
terraform apply

# Verificar outputs
terraform output lifecycle_configuration
terraform output estimated_savings_info
```

#### 3. Monitorar economia

```bash
# Ver configuração atual
terraform output lifecycle_configuration

# Ver estimativa de economia
terraform output estimated_savings_info
```

### Variáveis de Configuração

| Variável                                       | Padrão | Descrição                                |
| ---------------------------------------------- | ------ | ---------------------------------------- |
| `enable_lifecycle_policies`                    | `true` | Habilita/desabilita todas as policies    |
| `lifecycle_ia_transition_days`                 | `30`   | Dias para transição IA/Nearline          |
| `lifecycle_glacier_transition_days`            | `90`   | Dias para transição Glacier/Coldline     |
| `lifecycle_deep_archive_transition_days`       | `365`  | Dias para transição Deep Archive/Archive |
| `lifecycle_expiration_days`                    | `0`    | Dias para expiração (0 = desabilitado)   |
| `lifecycle_noncurrent_version_expiration_days` | `30`   | Expiração de versões antigas             |
| `lifecycle_multipart_upload_days`              | `7`    | Limpeza de uploads incompletos           |

### Monitoramento e Alertas

#### CloudWatch (AWS)

```bash
# Métricas importantes
- BucketSizeBytes
- NumberOfObjects
- StorageClassAnalysis
```

#### Cloud Monitoring (GCP)

```bash
# Métricas importantes
- storage.googleapis.com/storage/object_count
- storage.googleapis.com/storage/total_bytes
```

### 🔧 Script de Validação

Um script automatizado está disponível para validar todas as configurações:

```bash
# Executar validação completa
cd terraform
./validate_lifecycle.sh
```

#### O que o script verifica:

- ✅ Instalação do Terraform
- ✅ Existência do arquivo terraform.tfvars
- ✅ Sintaxe dos arquivos Terraform
- ✅ Configurações de lifecycle policies
- ✅ Ordem correta das transições
- ✅ Geração do plano de execução
- 📊 Estimativa de economia de custos

### Recursos Terraform Incluídos

#### AWS (`terraform/aws_import.tf`)

- Bucket S3 com tags personalizadas
- Versionamento habilitado
- Criptografia server-side (AES256)
- Bloqueio de acesso público
- Região configurável

#### GCP (`terraform/gcp_import.tf`)

- Bucket Cloud Storage
- Versionamento habilitado
- Labels organizacionais
- Localização configurável
- Integração com variáveis

#### Lifecycle Policies (`terraform/lifecycle_policies.tf`)

- **Transições automáticas de storage classes** para redução de custos
- **Limpeza de versões antigas** e uploads multipart incompletos
- **Regras específicas** para arquivos temporários e logs
- **Configuração flexível** via variáveis de ambiente

---

## 📦 Dependências Principais

```go
// Dependências diretas (go.mod)
cloud.google.com/go/storage v1.56.0         // Google Cloud Storage SDK
github.com/aws/aws-sdk-go-v2 v1.36.6        // AWS SDK v2
github.com/aws/aws-sdk-go-v2/config v1.29.18 // AWS Config
github.com/aws/aws-sdk-go-v2/service/s3 v1.84.1 // AWS S3 Service
github.com/joho/godotenv v1.5.1             // Carregamento de .env
github.com/spf13/cobra v1.9.1               // CLI framework
google.golang.org/api v0.243.0              // Google APIs
```

---

## 💡 Arquitetura e Filosofia

### Principais Conceitos

- 🎯 **Go como motor principal**: Toda lógica de criação/deleção é nativa Go
- ⚡ **Execução paralela**: Operações simultâneas com goroutines
- 🔌 **Terraform complementar**: Usado apenas para importação e configurações avançadas
- 🏗️ **Clean Architecture**: Separação clara entre CLI, lógica de negócio e provedores
- 🔒 **Sem state obrigatório**: Funciona independentemente do Terraform state

### Fluxo de Trabalho

1. **Criação**: Go SDK → Bucket criado diretamente nos provedores
2. **Importação** (opcional): Terraform import → State management
3. **Configurações avançadas** (opcional): Terraform apply → Versionamento, tags, policies

---

## 🔍 Troubleshooting

### Erros Comuns

**AWS Credentials não encontradas:**

```bash
# Verificar configuração
aws sts get-caller-identity

# Configurar se necessário
aws configure
```

**GCP Credentials inválidas:**

```bash
# Verificar arquivo de credenciais
gcloud auth list

# Ativar conta de serviço
gcloud auth activate-service-account --key-file=path/to/service-account.json
```

**Bucket já existe:**

```
Nomes de buckets devem ser globalmente únicos. Use nomes únicos como:
meu-projeto-dev-$(date +%s)
```

---

## 👨‍💻 Autor

**William Koller**  
Backend Engineer | Cloud Architect | Golang | AWS | Multi-Cloud Solutions

- GitHub: [@williamkoller](https://github.com/williamkoller)
- LinkedIn: [William Koller](https://linkedin.com/in/williamkoller)

