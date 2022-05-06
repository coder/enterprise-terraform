terraform {
  source = "github.com/cdr/enterprise-terraform//modules/gcp/tls?ref=v0.4.0"
}

include {
  path = find_in_parent_folders()
}

dependency "gke" {
  config_path = "../gke"
  skip_outputs = true
}
