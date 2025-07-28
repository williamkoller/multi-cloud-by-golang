package internal

import (
	"context"
	"fmt"
	"os"

	"cloud.google.com/go/storage"
	"google.golang.org/api/option"
)

func CreateGCP(bucket string) {
	projectID := os.Getenv("GCP_PROJECT_ID")
	credentials := os.Getenv("GCP_CREDENTIAL_FILE")

	client, _ := storage.NewClient(context.Background(), option.WithCredentialsFile(credentials))

	client.Bucket(bucket).Create(context.Background(), projectID, &storage.BucketAttrs{
		Location: "US",
	})

	fmt.Println("✅ Bucket GCP criado:", bucket)
}

func DeleteGCP(bucket string) {
	credentials := os.Getenv("GCP_CREDENTIAL_FILE")

	client, _ := storage.NewClient(context.Background(), option.WithCredentialsFile(credentials))
	err := client.Bucket(bucket).Delete(context.Background())
	if err != nil {
		fmt.Println("Erro ao deletar bucket GCP:", err)
		return
	}
	fmt.Println("🗑️ Bucket GCP deletado:", bucket)
}
