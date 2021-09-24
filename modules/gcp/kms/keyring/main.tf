terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 3.77"
    }
  }
}

provider "google" {
  project = var.google_project_id
  region  = var.google_region
}

resource "google_kms_key_ring" "key_ring" {
  project  = var.google_project_id
  name     = var.kms_key_ring_name
  location = var.google_region
}

resource "google_kms_crypto_key" "crypto_key" {
  name     = var.kms_crypto_key_name
  key_ring = google_kms_key_ring.key_ring.self_link

  purpose = "ENCRYPT_DECRYPT"
  rotation_period = "7776000s" # 90 days

  version_template {
    algorithm = "GOOGLE_SYMMETRIC_ENCRYPTION"
    protection_level = "SOFTWARE"
  }
}

variable "google_project_id" {}
variable "google_region" {}
variable "kms_key_ring_name" {}
variable "kms_crypto_key_name" {}

output "key_ring_self_link" {
  value = google_kms_key_ring.key_ring.self_link
}

output "crypto_key_self_link" {
  value = google_kms_crypto_key.crypto_key.self_link
}
