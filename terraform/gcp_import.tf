provider "google" {
  project     = var.project_id
  credentials = file(var.credentials_file)
}

resource "google_storage_bucket" "import_bucket" {
  name = "bucket-golang-sdk"
  location = "US"
}
