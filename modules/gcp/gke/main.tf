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
  region  = var.gke_cluster_region
  zone    = var.gke_cluster_zone
}

resource "google_container_cluster" "primary" {
  name     = var.gke_cluster_name
  location = var.gke_cluster_zone

  # We can't create a cluster with no node pool defined, but we want to only
  # use separately managed node pools. So we create the smallest possible
  # default node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  workload_identity_config {
    identity_namespace = "${var.google_project_id}.svc.id.goog"
  }
}

resource "google_container_node_pool" "coder_node_pool" {
  name       = "coder-node-pool"
  location   = google_container_cluster.primary.location
  cluster    = google_container_cluster.primary.name
  node_count = var.gke_cluster_node_count

  node_config {
    preemptible  = var.gke_cluster_preemptible
    machine_type = var.gke_cluster_machine_type
  }

}

variable "google_project_id" {}
variable "gke_cluster_name" {}
variable "gke_cluster_region" {}
variable "gke_cluster_zone" {}
variable "gke_cluster_machine_type" {}
variable "gke_cluster_node_count" {
  type = number
  default = 1
}
variable "gke_cluster_preemptible" {
  type = bool
  default = false
}
