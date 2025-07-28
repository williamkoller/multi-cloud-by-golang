provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "import_s3" {
  bucket = "bucket-golang-sdk"

  tags = {
    CriadoPor = "Golang"
    Ambiente = "MultiCloud"
  }
}

resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.import_s3.id
  versioning_configuration {
    status = "Enabled"
  }
}