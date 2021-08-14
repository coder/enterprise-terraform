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

locals {
  cloud_sql_proxy_img = "gcr.io/cloudsql-docker/gce-proxy:1.23.1"
  cloud_sql_proxy_deployment_name = "cloud-sql-proxy"
  cloud_sql_proxy_connection_string = "${var.google_project_id}:${var.cloud_sql_instance_region}:${var.cloud_sql_instance_name}"
}

resource "kubernetes_deployment" "cloud_sql_proxy" {
  metadata {
    name      = local.cloud_sql_proxy_deployment_name
    namespace = var.kubernetes_namespace
  }

  spec {
    selector {
      match_labels = {
        app = local.cloud_sql_proxy_deployment_name
      }
    }

    template {
      metadata {
        labels = {
          app = local.cloud_sql_proxy_deployment_name
        }
      }

      spec {
        container {
          name  = local.cloud_sql_proxy_deployment_name
          image = local.cloud_sql_proxy_img
          command = [
            "/cloud_sql_proxy",
            "-instances=${local.cloud_sql_proxy_connection_string}=tcp:0.0.0.0:5432",
          ]

          port {
            name           = "tcp-5432"
            container_port = 5432
          }

          security_context {
            run_as_non_root = true
          }
        }

        service_account_name = local.service_account_id
      }
    }
  }

  depends_on = [
    google_sql_database_instance.master,
  ]
}

resource "kubernetes_service" "cloud_sql_proxy_service" {
  metadata {
    name      = local.cloud_sql_proxy_deployment_name
    namespace = var.kubernetes_namespace
  }

  spec {
    port {
      protocol    = "TCP"
      port        = 5432
      target_port = "5432"
    }

    selector = {
      app = local.cloud_sql_proxy_deployment_name
    }
  }
  depends_on = [
    kubernetes_deployment.cloud_sql_proxy,
  ]
}

output "sql_host" {
  value = "${local.cloud_sql_proxy_deployment_name}.${var.kubernetes_namespace}.svc.cluster.local"
}
