package main

import (
	"github.com/joho/godotenv"
	"github.com/williamkoller/multi-cloud-by-golang/cmd"
)

func main() {
	_ = godotenv.Load()
	cmd.Execute()
}
