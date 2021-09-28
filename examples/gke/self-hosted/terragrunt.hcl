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

  # GCP Services options

  # Enables specific GCP services that are disabled by default. To get a full
  # list, see: `gcloud services list --available`.
  google_services = [
    "sqladmin.googleapis.com", # Necessary, do not remove!
  ]
  # If true, services that are enabled and which depend on this service should
  # also be disabled when this service is destroyed. If false or unset, an
  # error will be generated if any enabled services depend on this service when
  # destroying it.
  google_services_disable_dependent_services = false
  # If true, disable the service when the terraform resource is destroyed. May
  # be useful in the event that a project is long-lived but the infrastructure
  # running in that project changes frequently.
  google_services_disable_disable_on_destroy = false

  # Cloud SQL options

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

  #
  # GKE options
  #

  # The name of the GKE cluster that will be created.
  gke_cluster_name = ""
  gke_cluster_region = local.region
  gke_cluster_zone = local.zone
  # The machine type of the nodes.
  gke_cluster_machine_type = "e2-standard-4"
  # Whether the cluster should be preemptible. For test deployments, this can
  # help save costs during evaluation, but nodes can be recreated at any time.
  gke_cluster_preemptible = false

  #
  # GKE Autoscaling options
  #
  # One of two options must be enabled:
  #
  # 1.  gke_cluster_node_count
  #
  #     Disables autoscaling and manually controls the
  #     node count.
  #
  # 2.  gke_cluster_initial_node_count + gke_cluster_autoscaling
  #
  #     Enables autoscaling. The cluster starts with
  #     gke_cluster_initial_node_count nodes.
  #
  # Only 1 or 2 should be enabled at once. If both are enabled, the cluster
  # will reset to gke_cluster_node_count nodes every time the Terraform is
  # applied.

  # For clusters without autoscaling, use gke_cluster_node_count to manually
  # specify the number of nodes in the cluster.
  # gke_cluster_node_count = 2

  # The initial number of nodes the cluster will be created with. Changing this
  # value after cluster creation has no effect. It should be used in
  # conjunction with gke_cluster_autoscaling to control the number of nodes
  # before autoscaling takes over.
  # gke_cluster_initial_node_count = 2
  #
  # Controls the node limits for GKE autoscaling. Should be used in conjunction
  # with gke_cluster_initial_node_count.
  # gke_cluster_autoscaling = {
  #   min_node_count = 2
  #   max_node_count = 8
  # }

  #
  # Helm options
  #

  # The kubernetes namespace Coder will be deployed in.
  kubernetes_namespace = ""
  # The release name of the helm chart. This shouldn't need to be changed.
  helm_release_name = "coder"
  # The chart name. This shouldn't need to be changed.
  helm_chart = "coder"
  # The version of Coder to deploy.
  helm_chart_version = "1.22.0"
  # The password used to login to the admin user.
  admin_password = ""

  # The Cloud DNS zone which your hostname will be created in. It must be
  # created outside of this Terraform module.
  dns_zone_name = ""
  # The hostname for accessing Coder.
  hostname = "my-deployment.coder.com"
}
