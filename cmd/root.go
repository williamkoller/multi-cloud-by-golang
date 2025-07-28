package cmd

import (
	"fmt"
	"os"
	"sync"

	"github.com/joho/godotenv"
	"github.com/spf13/cobra"
	"github.com/williamkoller/multi-cloud-by-golang/internal"
)

var (
	useAWS     bool
	useGCP     bool
	doCreate   bool
	doDelete   bool
	bucketName string
)

var rootCmd = &cobra.Command{
	Use:   "multicloud",
	Short: "Infra MultiCloud via Go SDK",
	Run: func(cmd *cobra.Command, args []string) {
		_ = godotenv.Load()

		if doCreate && doDelete {
			fmt.Println("❌ Use apenas um dos modos: --create ou --delete.")
			os.Exit(1)
		}

		if !doCreate && !doDelete {
			fmt.Println("⚠️  Use --create ou --delete para executar a ação.")
			os.Exit(1)
		}

		if bucketName == "" {
			fmt.Println("⚠️  --bucketname é obrigatório.")
			os.Exit(1)
		}

		var wg sync.WaitGroup

		if doCreate {
			if useAWS {
				wg.Add(1)
				go func() {
					defer wg.Done()
					internal.CreateS3(bucketName)
				}()
			}
			if useGCP {
				wg.Add(1)
				go func() {
					defer wg.Done()
					internal.CreateGCP(bucketName)
				}()
			}
		}

		if doDelete {
			if useAWS {
				wg.Add(1)
				go func() {
					defer wg.Done()
					internal.DeleteS3(bucketName)
				}()
			}
			if useGCP {
				wg.Add(1)
				go func() {
					defer wg.Done()
					internal.DeleteGCP(bucketName)
				}()
			}
		}

		wg.Wait()
		fmt.Println("✅ Operação finalizada.")
	},
}

func Execute() {
	rootCmd.Flags().BoolVar(&useAWS, "aws", false, "Operar bucket na AWS")
	rootCmd.Flags().BoolVar(&useGCP, "gcp", false, "Operar bucket na GCP")
	rootCmd.Flags().BoolVar(&doCreate, "create", false, "Criar o bucket")
	rootCmd.Flags().BoolVar(&doDelete, "delete", false, "Deletar o bucket")
	rootCmd.Flags().StringVar(&bucketName, "bucketname", "", "Nome do bucket")

	if err := rootCmd.Execute(); err != nil {
		os.Exit(1)
	}
}
