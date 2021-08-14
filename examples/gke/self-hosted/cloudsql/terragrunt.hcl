terraform {
  source = "github.com/cdr/enterprise-terraform//modules/gcp/cloudsql"
}

include {
  path = find_in_parent_folders()
}

dependency "gke" {
  config_path = "../gke"
  skip_outputs = true
}

dependency "ns" {
  config_path = "../namespace"
  skip_outputs = true
}
