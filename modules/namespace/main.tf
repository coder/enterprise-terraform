terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = ">= 2.3"
    }
  }
}

module "gke_auth" {
  source       = "terraform-google-modules/kubernetes-engine/google//modules/auth"
  version      = "16.0.1"
  project_id   = var.google_project_id
  cluster_name = var.gke_cluster_name
  location     = var.gke_cluster_zone
}

provider "kubernetes" {
  cluster_ca_certificate = module.gke_auth.cluster_ca_certificate
  host                   = module.gke_auth.host
  token                  = module.gke_auth.token
}

resource "kubernetes_namespace" "coder" {
  metadata {
    name = var.kubernetes_namespace
  }
}

variable "google_project_id" {}
variable "kubernetes_namespace" {}
variable "gke_cluster_name" {}
variable "gke_cluster_zone" {}
