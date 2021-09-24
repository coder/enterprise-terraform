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
}

resource "google_project_service" "sql_admin" {
  project = var.google_project_id
  service = "sqladmin.googleapis.com"


  disable_dependent_services = false
  disable_on_destroy = false
}

variable "google_project_id" {}
