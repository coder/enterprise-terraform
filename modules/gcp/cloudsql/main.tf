terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = ">= 3.77"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.3"
    }
  }
}

provider "google" {
  project = var.google_project_id
  region  = var.cloud_sql_instance_region
}

resource "random_string" "service_account_suffix" {
  length = 8
  special = false
  number = false
  upper = false
  lower = true
}

locals {
  service_account_id = "coder-cloud-sql-${random_string.service_account_suffix.result}"
}

resource "google_service_account" "service_account" {
  account_id   = local.service_account_id
  display_name = "Service account used for Coder CloudSQL access in namespace ${var.kubernetes_namespace}"
}

module "gke_workload_identity" {
  source              = "terraform-google-modules/kubernetes-engine/google//modules/workload-identity"
  use_existing_gcp_sa = true
  name                = google_service_account.service_account.account_id
  project_id          = var.google_project_id
  namespace           = var.kubernetes_namespace
  roles               = ["roles/cloudsql.instanceUser", "roles/cloudsql.client"]
}

resource "google_sql_database_instance" "master" {
  name             = var.cloud_sql_instance_name
  database_version = var.cloud_sql_instance_version
  region           = var.cloud_sql_instance_region
  deletion_protection = var.cloud_sql_deletion_prevention

  settings {
    tier = var.cloud_sql_instance_tier

    database_flags {
      name  = "cloudsql.iam_authentication"
      value = "on"
    }
  }
}

resource "random_password" "sql_password" {
  length  = var.cloud_sql_password_length
  special = true
}

# TODO(@coadler): the provider for this is bugged somehow, and always fails
# when applied. It's not currently necessary.
# resource "google_sql_user" "coder_iam_user" {
#   name     = trimsuffix(google_service_account.service_account.email, ".gserviceaccount.com")
#   instance = google_sql_database_instance.master.name
#   type     = "CLOUD_IAM_SERVICE_ACCOUNT"
# }

resource "google_sql_user" "coder_user" {
  name     = "coder"
  instance = google_sql_database_instance.master.name
  password = random_password.sql_password.result
}

resource "google_sql_database" "database" {
  name     = "coder"
  instance = google_sql_database_instance.master.name
}

variable "google_project_id" {}
variable "kubernetes_namespace" {}
variable "gke_cluster_name" {}
variable "gke_cluster_zone" {}
variable "cloud_sql_instance_name" {}
variable "cloud_sql_instance_tier" {}
variable "cloud_sql_instance_region" {}
variable "cloud_sql_instance_version" {}
variable "cloud_sql_password_length" {
  type    = number
  default = 24
}

variable "cloud_sql_deletion_prevention" {
  type    = bool
  default = true
}

output "instance_name" {
  value = google_sql_database_instance.master.name
}

output "sql_user" {
  value = google_sql_user.coder_user.name
}

output "sql_password" {
  value     = random_password.sql_password.result
  sensitive = true
}

output "sql_database" {
  value = google_sql_database.database.name
}
