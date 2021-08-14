terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = ">= 2.3"
    }

    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.2"
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

provider "helm" {
  kubernetes {
    cluster_ca_certificate = module.gke_auth.cluster_ca_certificate
    host                   = module.gke_auth.host
    token                  = module.gke_auth.token
  }
}

locals {
  database_password_secret_name = "coderd-postgres-pass"
}

resource "kubernetes_secret" "coderd_admin_password" {
  metadata {
    name      = var.admin_password_secret_name
    namespace = var.kubernetes_namespace
  }

  type = "Opaque"

  data = {
    password = var.admin_password
  }
}

resource "kubernetes_secret" "coderd_sql_password" {
  metadata {
    name      = local.database_password_secret_name
    namespace = var.kubernetes_namespace
  }

  type = "Opaque"

  data = {
    password = var.sql_password
  }
}

resource "helm_release" "coder" {
  name       = var.helm_release_name
  repository = "https://helm.coder.com"
  chart      = var.helm_chart
  version    = var.helm_chart_version

  timeout = 120

  values = var.helm_values

  set {
    name  = "coderd.superAdmin.passwordSecret.name"
    value = var.admin_password_secret_name
  }

  set {
    name  = "postgres.default.enable"
    value = false
  }

  set {
    name  = "postgres.host"
    value = var.sql_host
  }

  set {
    name  = "postgres.port"
    value = "5432"
  }

  set {
    name  = "postgres.sslMode"
    value = "disable"
  }

  set {
    name  = "postgres.database"
    value = var.sql_database
  }

  set {
    name  = "postgres.user"
    value = var.sql_user
  }

  set {
    name  = "postgres.passwordSecret"
    value = local.database_password_secret_name
  }

  set {
    name  = "coderd.serviceSpec.type"
    value = "LoadBalancer"
  }

  set {
    name  = "coderd.serviceSpec.loadBalancerIP"
    value = var.load_balancer_ip
  }

  set {
    name  = "coderd.devurlsHost"
    value = "*.${var.hostname}"
  }

  set {
    name  = "coderd.tls.devurlsHostSecretName"
    value = "${var.tls_secret_name}"
  }

  set {
    name  = "coderd.tls.hostSecretName"
    value = "${var.tls_secret_name}"
  }

  namespace = var.kubernetes_namespace
  atomic    = true
  wait      = true

  depends_on = [
    kubernetes_secret.coderd_admin_password,
    kubernetes_secret.coderd_sql_password,
  ]
}

variable "admin_password_secret_name" {
  default = "coder-admin-password"
}

variable "google_project_id" {}
variable "kubernetes_namespace" {}
variable "gke_cluster_name" {}
variable "gke_cluster_zone" {}

variable "admin_password" {}
variable "sql_host" {}
variable "sql_user" {}
variable "sql_database" {}
variable "sql_password" {}

variable "helm_release_name" {}
variable "helm_chart" {}
variable "helm_chart_version" {}
variable "helm_values" {
  type = list(string)
  default = []
}

variable "hostname" {}
variable "load_balancer_ip" {}
variable "tls_secret_name" {}
