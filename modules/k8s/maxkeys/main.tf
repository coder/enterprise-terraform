terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.8"
    }
  }
}

provider "kubernetes" {
  cluster_ca_certificate = var.k8s_auth.cluster_ca_certificate
  host                   = var.k8s_auth.host
  token                  = var.k8s_auth.token
}

resource "kubernetes_daemonset" "startup_script" {
  metadata {
    name      = "startup-script"
    namespace = var.kubernetes_namespace
  }

  spec {
    selector {
      match_labels = {
        "com.coder.service" = "startup-script"
      }
    }

    template {
      metadata {
        labels = {
          "com.coder.service" = "startup-script"
        }
      }

      spec {
        container {
          name    = "startup-script"
          image   = "ubuntu"
          command = ["/bin/bash"]
          args = [
            "-c",
            <<BASH
            sysctl -w \
              kernel.keys.maxkeys=100000003 \
              kernel.keys.maxbytes=100000003 \
              fs.inotify.max_user_watches=100000003 \
            && echo done \
            && sleep infinity
            BASH
          ]
          image_pull_policy = "Always"

          security_context {
            privileged = true
          }
        }

        host_pid = true
      }
    }
  }
}

variable "k8s_auth" {
  type = object({
    cluster_ca_certificate = string
    host                   = string
    token                  = string
  })
}

variable "kubernetes_namespace" {
  default = "coder"
}
