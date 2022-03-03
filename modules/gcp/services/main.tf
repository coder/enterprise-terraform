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
}

resource "google_project_service" "services" {
  for_each = toset(var.google_services)
  project = var.google_project_id
  service = each.key

  disable_dependent_services = false
  disable_on_destroy = false
}

variable "google_project_id" {}
variable "google_services" {
  type = list(string)
  default = []
}

variable "google_services_disable_dependent_services" {
  default = false
}

variable "google_services_disable_disable_on_destroy" {
  default = false
}
