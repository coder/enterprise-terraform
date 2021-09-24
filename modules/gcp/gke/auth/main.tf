provider "google" {
  project = var.google_project_id
  zone    = var.gke_cluster_zone
}

module "gke_auth" {
  source       = "terraform-google-modules/kubernetes-engine/google//modules/auth"
  version      = "16.0.1"
  project_id   = var.google_project_id
  cluster_name = var.gke_cluster_name
  location     = var.gke_cluster_zone
}

variable "google_project_id" {}
variable "gke_cluster_name" {}
variable "gke_cluster_zone" {}

output "cluster_ca_certificate" {
  value = module.gke_auth.cluster_ca_certificate
  sensitive = true
}

output "host" {
  value = module.gke_auth.host
  sensitive = true
}

output "token" {
  value = module.gke_auth.token
  sensitive = true
}
