package internal

import (
	"context"
	"fmt"
	"strings"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/s3"
)

func CreateS3(bucket string) {
	cfg, err := config.LoadDefaultConfig(context.TODO())

	if err != nil {
		fmt.Printf("❌ Erro ao carregar configurações AWS: %v\n", err)
		fmt.Println("💡 Configure suas credenciais AWS:")
		fmt.Println("   • aws configure")
		fmt.Println("   • ou exporte as variáveis:")
		fmt.Println("     export AWS_ACCESS_KEY_ID=sua-access-key")
		fmt.Println("     export AWS_SECRET_ACCESS_KEY=sua-secret-key")
		fmt.Println("     export AWS_DEFAULT_REGION=us-east-1")
		return
	}

	// Verificar se região está configurada
	if cfg.Region == "" {
		fmt.Println("❌ Região AWS não configurada!")
		fmt.Println("💡 Configure a região:")
		fmt.Println("   • aws configure set region us-east-1")
		fmt.Println("   • ou export AWS_DEFAULT_REGION=us-east-1")
		return
	}

	client := s3.NewFromConfig(cfg)

	_, err = client.CreateBucket(context.TODO(), &s3.CreateBucketInput{
		Bucket: aws.String(bucket),
	})

	if err != nil {
		errorMsg := err.Error()

		if strings.Contains(errorMsg, "resolve auth scheme") || strings.Contains(errorMsg, "credential") {
			fmt.Printf("❌ Erro de credenciais AWS: %v\n", err)
			fmt.Println("💡 Configure suas credenciais AWS:")
			fmt.Println("   • aws configure")
			fmt.Println("   • ou verifique suas variáveis de ambiente:")
			fmt.Println("     AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_DEFAULT_REGION")
		} else if strings.Contains(errorMsg, "Invalid region") || strings.Contains(errorMsg, "DNS name") {
			fmt.Printf("❌ Região AWS inválida: %v\n", err)
			fmt.Println("💡 Configure uma região válida:")
			fmt.Println("   • aws configure set region us-east-1")
			fmt.Println("   • ou export AWS_DEFAULT_REGION=us-east-1")
		} else if strings.Contains(errorMsg, "BucketAlreadyExists") {
			fmt.Printf("❌ Bucket '%s' já existe ou nome não disponível\n", bucket)
			fmt.Println("💡 Use um nome único para o bucket")
		} else {
			fmt.Printf("❌ Erro ao criar bucket S3: %v\n", err)
		}
		return
	}

	fmt.Println("✅ S3 Bucket criado:", bucket)
}

func DeleteS3(bucket string) {
	cfg, err := config.LoadDefaultConfig(context.TODO())

	if err != nil {
		fmt.Printf("❌ Erro ao carregar configurações AWS: %v\n", err)
		fmt.Println("💡 Configure suas credenciais AWS primeiro")
		return
	}

	if cfg.Region == "" {
		fmt.Println("❌ Região AWS não configurada!")
		fmt.Println("💡 Configure: export AWS_DEFAULT_REGION=us-east-1")
		return
	}

	client := s3.NewFromConfig(cfg)

	_, err = client.DeleteBucket(context.TODO(), &s3.DeleteBucketInput{
		Bucket: aws.String(bucket),
	})

	if err != nil {
		errorMsg := err.Error()

		if strings.Contains(errorMsg, "NoSuchBucket") {
			fmt.Printf("❌ Bucket '%s' não encontrado\n", bucket)
		} else if strings.Contains(errorMsg, "BucketNotEmpty") {
			fmt.Printf("❌ Bucket '%s' não está vazio. Remova todos os objetos primeiro\n", bucket)
		} else {
			fmt.Printf("❌ Erro ao deletar bucket: %v\n", err)
		}
		return
	}

	fmt.Println("🗑️ Bucket AWS deletado:", bucket)
}
