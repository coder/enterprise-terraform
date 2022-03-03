terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.12"
    }
  }
}

provider "google" {
  project = var.google_project_id
  region  = var.gke_cluster_region
}

resource "random_string" "static_ip_suffix" {
  length  = 8
  special = false
  number  = false
  upper   = false
  lower   = true
}

resource "google_compute_address" "static" {
  name = "${var.static_ip_prefix}-${random_string.static_ip_suffix.result}"
}

variable "google_project_id" {}
variable "gke_cluster_region" {}
variable "static_ip_prefix" {
  default = "coder-static-ip"
}

output "address" {
  value = resource.google_compute_address.static.address
}
