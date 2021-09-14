terraform {
  source = "github.com/cdr/enterprise-terraform//modules/gcp/cloudsql?ref=v0.1.0"
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
