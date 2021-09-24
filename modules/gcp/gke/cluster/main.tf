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

  networking_mode = "VPC_NATIVE"
  ip_allocation_policy {}
  # Enables GKE Dataplane v2. This forces Network Policy to be enabled.
  datapath_provider = "ADVANCED_DATAPATH"

  release_channel {
    channel = "REGULAR"
  }

  addons_config {
    horizontal_pod_autoscaling {
      disabled = false
    }

    # TODO: options for enabling istio
    # istio_config {
    #   disabled = false
    #   auth     = "AUTH_NONE"
    # }
  }

  # Enables GKE Workload Identity. This is used for Cloud SQL Proxy
  # authentication.
  workload_identity_config {
    identity_namespace = "${var.google_project_id}.svc.id.goog"
  }
}

resource "google_container_node_pool" "coder_node_pool" {
  name       = "coder-node-pool"
  location   = google_container_cluster.primary.location
  cluster    = google_container_cluster.primary.name
  node_count = var.gke_cluster_node_count
  initial_node_count = var.gke_cluster_initial_node_count

  # Once the cluster is created with an initial node count of 2, ignore all
  # subsequent changes. We want the autoscaler to control it.
  lifecycle {
    ignore_changes = [
      initial_node_count
    ]
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  dynamic "autoscaling" {
    for_each = var.gke_cluster_autoscaling != null ? [var.gke_cluster_autoscaling] : []
    content {
      min_node_count = autoscaling.value.min_node_count
      max_node_count = autoscaling.value.max_node_count
    }
  }

  node_config {
    preemptible  = var.gke_cluster_preemptible
    machine_type = var.gke_cluster_machine_type
    image_type   = "UBUNTU_CONTAINERD"
    disk_size_gb = 100
    disk_type    = "pd-ssd"
    metadata = {
      disable-legacy-endpoints = true
    }
  }
}

variable "google_project_id" {}
variable "gke_cluster_name" {}
variable "gke_cluster_region" {}
variable "gke_cluster_zone" {}
variable "gke_cluster_machine_type" {}

variable "gke_cluster_node_count" {
  type = number
  default = null
}

variable "gke_cluster_initial_node_count" {
  type = number
  default = null
}

variable "gke_cluster_preemptible" {
  type = bool
  default = false
}

variable "gke_cluster_autoscaling" {
  type = object({
    min_node_count = number
    max_node_count = number
  })
  default = null
}
