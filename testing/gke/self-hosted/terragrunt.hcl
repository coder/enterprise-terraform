locals {
  region = "us-central1"
  zone = "us-central1-a"
  inc = 7
}

inputs = {
  google_project_id = "coder-dev-1"

  cloud_sql_instance_name = "terraform-testing-${local.inc}"
  cloud_sql_instance_tier = "db-custom-2-7680"
  cloud_sql_instance_region = local.region
  cloud_sql_instance_version = "POSTGRES_13"
  cloud_sql_deletion_prevention = false

  gke_cluster_name = "terraform-testing-${local.inc}"
  gke_cluster_region = local.region 
  gke_cluster_zone = local.zone 
  gke_cluster_machine_type = "e2-standard-8"
  gke_cluster_preemptible = false
  gke_cluster_node_count = 1
  # gke_cluster_initial_node_count = 2
  # gke_cluster_autoscaling = {
  #   min_node_count = 2
  #   max_node_count = 8
  # }
  kubernetes_namespace = "coder"

  helm_release_name = "coder"
  helm_chart = "coder"
  helm_chart_version = "1.30.4-rc.1"
  admin_password = "terraform-testing"

  dns_zone_name = "dev"
  hostname = "terraform-testing-${local.inc}.dev.c8s.io"
}
