terraform {
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = ">= 2.26.1"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.3"
    }

    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.2"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.11.3"
    }
  }
}

provider "cloudflare" { 
  email   = var.cloudflare_email
  api_token = var.cloudflare_api_token
}

provider "kubernetes" {
  cluster_ca_certificate = var.k8s_auth.cluster_ca_certificate
  host                   = var.k8s_auth.host
  token                  = var.k8s_auth.token
}

provider "helm" {
  kubernetes {
    cluster_ca_certificate = var.k8s_auth.cluster_ca_certificate
    host                   = var.k8s_auth.host
    token                  = var.k8s_auth.token
  }
}

provider "kubectl" {
  cluster_ca_certificate = var.k8s_auth.cluster_ca_certificate
  host                   = var.k8s_auth.host
  token                  = var.k8s_auth.token
}

resource "cloudflare_record" "hostname" {
  zone_id = var.cloudflare_zone_id
  name    = var.hostname
  value   = var.address
  type    = "A"
  ttl     = 3600
}

resource "cloudflare_record" "devurl_hostname" {
  zone_id = var.cloudflare_zone_id
  name    = "*.${var.hostname}"
  value   = var.hostname
  type    = "CNAME"
  ttl     = 3600
}

locals {
  kubernetes_namespace = "cert-manager"
  issuer_name = "coder-issuer"
  tls_secret_name = "coder-certs"
  cloudflare_api_token_secret_name = "cert-manager-cloudflare-api-token"
}

resource "kubernetes_namespace" "cert_manager" {
  metadata {
    name = local.kubernetes_namespace
  }
}

resource "kubernetes_secret" "cloudflare_api_token" {
  metadata {
    name      = local.cloudflare_api_token_secret_name
    namespace = local.kubernetes_namespace
  }

  type = "Opaque"

  data = {
    api-token = var.cloudflare_api_token
  }
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

  namespace = local.kubernetes_namespace
  atomic    = true
  wait      = true

  depends_on = [
    resource.kubernetes_namespace.cert_manager,
  ]
}

resource "kubectl_manifest" "issuer" {
    yaml_body = <<YAML
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: ${local.issuer_name}
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    privateKeySecretRef:
      name: letsencrypt-account-key
    solvers:
    - dns01:
        cloudflare:
          email: ${var.cloudflare_email}
          apiTokenSecretRef:
            name: ${local.cloudflare_api_token_secret_name}
            key: api-token
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
  name: ${local.tls_secret_name}
  namespace: ${var.kubernetes_namespace}
spec:
  commonName: "*.${var.hostname}"
  dnsNames:
    - "${var.hostname}"
    - "*.${var.hostname}"
  issuerRef:
    kind: ClusterIssuer
    name: ${local.issuer_name}
  secretName: ${local.tls_secret_name}
YAML

  depends_on = [
    helm_release.cert_manager,
  ]
}

variable "k8s_auth" {
  type = object({
    cluster_ca_certificate = string
    host = string
    token = string
  })
}

variable "cloudflare_email" {}
variable "cloudflare_zone_id" {}
variable "cloudflare_api_token" {}

variable "kubernetes_namespace" {}

variable "hostname" {}
variable "address" {}

output "tls_secret_name" {
  value = local.tls_secret_name
}
