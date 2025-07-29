provider "google" {
  project     = var.project_id
  credentials = file(var.credentials_file)
}

# Nota: O bucket google_storage_bucket.import_bucket 
# agora está definido em lifecycle_policies.tf com 
# configurações completas de lifecycle
