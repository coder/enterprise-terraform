terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 4.12"
    }
  }
}

provider "google" {
  project = var.google_project_id
  region  = var.google_region
}

data "google_kms_secret" "secret" {
  crypto_key = var.kms_crypto_key_self_link
  ciphertext = var.ciphertext
}

variable "google_project_id" {}
variable "google_region" {}
variable "kms_crypto_key_self_link" {}
variable "ciphertext" {}

output "plaintext" {
  value = data.google_kms_secret.secret.plaintext
  sensitive = true
}
