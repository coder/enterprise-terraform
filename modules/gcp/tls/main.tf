terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.12"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.8"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.4"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.13"
    }
  }
}

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

provider "kubectl" {
  cluster_ca_certificate = module.gke_auth.cluster_ca_certificate
  host                   = module.gke_auth.host
  token                  = module.gke_auth.token
}

resource "random_string" "service_account_suffix" {
  length  = 8
  special = false
  number  = false
  upper   = false
  lower   = true
}

resource "random_string" "static_ip_suffix" {
  length  = 8
  special = false
  number  = false
  upper   = false
  lower   = true
}

locals {
  kubernetes_namespace = "cert-manager"
  service_account_id   = "coder-cert-manager-${random_string.service_account_suffix.result}"
}

resource "kubernetes_namespace" "cert_manager" {
  metadata {
    name = local.kubernetes_namespace
  }
}

resource "google_service_account" "service_account" {
  account_id   = local.service_account_id
  display_name = "Service account used for Cert Manager to manager Coder TLS certificates."
}

module "gke_workload_identity" {
  source                          = "terraform-google-modules/kubernetes-engine/google//modules/workload-identity"
  use_existing_gcp_sa             = true
  automount_service_account_token = true
  name                            = google_service_account.service_account.account_id
  project_id                      = var.google_project_id
  namespace                       = local.kubernetes_namespace
  roles                           = ["roles/dns.admin"]

  depends_on = [
    resource.kubernetes_namespace.cert_manager,
  ]
}

resource "google_compute_address" "static" {
  name = "coder-static-ip-${random_string.static_ip_suffix.result}"
}

data "google_dns_managed_zone" "coder_dns_zone" {
  name = var.dns_zone_name
}

resource "google_dns_record_set" "main_dns" {
  managed_zone = data.google_dns_managed_zone.coder_dns_zone.name
  name         = "${var.hostname}."
  type         = "A"
  rrdatas      = [resource.google_compute_address.static.address]
  ttl          = 300
}

resource "google_dns_record_set" "devurl_dns" {
  managed_zone = data.google_dns_managed_zone.coder_dns_zone.name
  name         = "*.${var.hostname}."
  type         = "A"
  rrdatas      = [resource.google_compute_address.static.address]
  ttl          = 300
}

resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "1.5.0"

  set {
    name  = "installCRDs"
    value = true
  }

  set {
    name  = "serviceAccount.create"
    value = false
  }

  set {
    name  = "serviceAccount.name"
    value = local.service_account_id
  }

  set {
    name  = "cainjector.serviceAccount.create"
    value = false
  }

  set {
    name  = "cainjector.serviceAccount.name"
    value = local.service_account_id
  }

  set {
    name  = "webhook.serviceAccount.create"
    value = false
  }

  set {
    name  = "webhook.serviceAccount.name"
    value = local.service_account_id
  }

  namespace = local.kubernetes_namespace
  atomic    = true
  wait      = true

  depends_on = [
    resource.kubernetes_namespace.cert_manager,
    module.gke_workload_identity,
  ]
}

resource "kubectl_manifest" "issuer" {
    yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: coder-issuer
spec:
  acme:
    privateKeySecretRef:
      name: gclouddnsissuersecret
    server: https://acme-v02.api.letsencrypt.org/directory
    solvers:
    - dns01:
        cloudDNS:
          project: ${var.google_project_id}
YAML

  depends_on = [
    helm_release.cert_manager,
  ]
}

resource "kubectl_manifest" "certificate" {
    yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: coder-certs
  namespace: ${var.kubernetes_namespace}
spec:
  commonName: "*.${var.hostname}"
  dnsNames:
    - "${var.hostname}"
    - "*.${var.hostname}"
  issuerRef:
    kind: ClusterIssuer
    name: coder-issuer
  secretName: coder-certs
YAML

  depends_on = [
    helm_release.cert_manager,
  ]
}

variable "google_project_id" {}
variable "kubernetes_namespace" {}
variable "gke_cluster_name" {}
variable "gke_cluster_zone" {}

variable "dns_zone_name" {}
variable "hostname" {}

output "address" {
  value = resource.google_compute_address.static.address
}

output "tls_secret_name" {
  value = "coder-certs"
}
