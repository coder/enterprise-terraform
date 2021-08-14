locals {
  # Your GCP region.
  region = "us-central1"
  # Your GCP zone.
  zone = "us-central1-a"
}

# Uncomment this to manage Terraform state in GCS instead of locally.
# remote_state {
#   backend = "gcs"
#   generate = {
#     path      = "backend.tf"
#     if_exists = "overwrite"
#   }
#   config = {
#     bucket  = "<your gcs bucket>"
#     prefix = "gke/${path_relative_to_include()}/terraform.tfstate"
#   }
# }

inputs = {
  # The GCP project all resources will be created in.
  google_project_id = "coder-dev-1"

  # The name of the Cloud SQL instance that will be created.
  cloud_sql_instance_name = ""
  # The size of the created Cloud SQL instance.
  cloud_sql_instance_tier = "db-f1-micro"
  cloud_sql_instance_region = local.region
  # The Postgres version used in the Cloud SQL instance. We recommend always
  # choosing the latest verstion.
  cloud_sql_instance_version = "POSTGRES_13"
  # Setting this to true prevents the Cloud SQL instance from being deleted. If
  # you would like to delete your instance, set this to false.
  cloud_sql_deletion_prevention = true

  # The name of the GKE cluster that will be created.
  gke_cluster_name = ""
  gke_cluster_region = local.region 
  gke_cluster_zone = local.zone 
  # The machine type of the nodes.
  gke_cluster_machine_type = "e2-standard-4"
  # Whether the cluster should be preemptible. For test deployments, this can
  # help save costs during evaluation, but nodes can be recreated at any time.
  gke_cluster_preemptible = false
  # The kubernetes namespace Coder will be deployed in.
  kubernetes_namespace = ""

  # The release name of the helm chart. This shouldn't need to be changed.
  helm_release_name = "coder"
  # The chart name. This shouldn't need to be changed.
  helm_chart = "coder"
  # The version of Coder to deploy.
  helm_chart_version = "1.21.0"
  # The password used to login to the admin user.:w
  admin_password = ""

  # The Cloud DNS zone which your hostname will be created in.
  dns_zone_name = ""
  # The hostname for accessing Coder.
  hostname = "my-deployment.coder.com"
}
