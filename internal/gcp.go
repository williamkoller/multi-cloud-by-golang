package internal

import (
	"context"
	"fmt"
	"os"
	"strings"

	"cloud.google.com/go/storage"
	"google.golang.org/api/option"
)

func CreateGCP(bucket string) {
	projectID := os.Getenv("GCP_PROJECT_ID")
	credentials := os.Getenv("GCP_CREDENTIAL_FILE")

	if projectID == "" {
		fmt.Println("❌ GCP_PROJECT_ID não configurado!")
		fmt.Println("💡 Configure no arquivo .env:")
		fmt.Println("   GCP_PROJECT_ID=seu-projeto-gcp-id")
		return
	}

	if credentials == "" {
		fmt.Println("❌ GCP_CREDENTIAL_FILE não configurado!")
		fmt.Println("💡 Configure no arquivo .env:")
		fmt.Println("   GCP_CREDENTIAL_FILE=caminho/para/service-account.json")
		return
	}

	// Verificar se arquivo de credenciais existe
	if _, err := os.Stat(credentials); os.IsNotExist(err) {
		fmt.Printf("❌ Arquivo de credenciais não encontrado: %s\n", credentials)
		fmt.Println("💡 Verifique o caminho no arquivo .env")
		return
	}

	client, err := storage.NewClient(context.Background(), option.WithCredentialsFile(credentials))
	if err != nil {
		errorMsg := err.Error()

		if strings.Contains(errorMsg, "credential") || strings.Contains(errorMsg, "authentication") {
			fmt.Printf("❌ Erro de credenciais GCP: %v\n", err)
			fmt.Println("💡 Verifique:")
			fmt.Println("   • Arquivo JSON da conta de serviço existe")
			fmt.Println("   • Conta de serviço tem permissões Storage Admin")
			fmt.Println("   • Variável GCP_CREDENTIAL_FILE está correta")
		} else {
			fmt.Printf("❌ Erro ao conectar com GCP: %v\n", err)
		}
		return
	}
	defer client.Close()

	err = client.Bucket(bucket).Create(context.Background(), projectID, &storage.BucketAttrs{
		Location: "US",
	})

	if err != nil {
		errorMsg := err.Error()

		if strings.Contains(errorMsg, "already exists") || strings.Contains(errorMsg, "conflict") {
			fmt.Printf("❌ Bucket '%s' já existe ou nome não disponível\n", bucket)
			fmt.Println("💡 Use um nome único para o bucket")
		} else if strings.Contains(errorMsg, "permission") || strings.Contains(errorMsg, "forbidden") {
			fmt.Printf("❌ Sem permissão para criar bucket: %v\n", err)
			fmt.Println("💡 Verifique se a conta de serviço tem role 'Storage Admin'")
		} else if strings.Contains(errorMsg, "project") {
			fmt.Printf("❌ Projeto GCP inválido: %v\n", err)
			fmt.Println("💡 Verifique a variável GCP_PROJECT_ID")
		} else {
			fmt.Printf("❌ Erro ao criar bucket GCP: %v\n", err)
		}
		return
	}

	fmt.Println("✅ Bucket GCP criado:", bucket)
}

func DeleteGCP(bucket string) {
	projectID := os.Getenv("GCP_PROJECT_ID")
	credentials := os.Getenv("GCP_CREDENTIAL_FILE")

	if projectID == "" || credentials == "" {
		fmt.Println("❌ Variáveis GCP não configuradas!")
		fmt.Println("💡 Configure no arquivo .env:")
		fmt.Println("   GCP_PROJECT_ID=seu-projeto-gcp-id")
		fmt.Println("   GCP_CREDENTIAL_FILE=caminho/para/service-account.json")
		return
	}

	client, err := storage.NewClient(context.Background(), option.WithCredentialsFile(credentials))
	if err != nil {
		fmt.Printf("❌ Erro ao conectar com GCP: %v\n", err)
		return
	}
	defer client.Close()

	err = client.Bucket(bucket).Delete(context.Background())
	if err != nil {
		errorMsg := err.Error()

		if strings.Contains(errorMsg, "not found") || strings.Contains(errorMsg, "404") {
			fmt.Printf("❌ Bucket '%s' não encontrado\n", bucket)
		} else if strings.Contains(errorMsg, "not empty") || strings.Contains(errorMsg, "conflict") {
			fmt.Printf("❌ Bucket '%s' não está vazio. Remova todos os objetos primeiro\n", bucket)
		} else {
			fmt.Printf("❌ Erro ao deletar bucket GCP: %v\n", err)
		}
		return
	}

	fmt.Println("🗑️ Bucket GCP deletado:", bucket)
}
