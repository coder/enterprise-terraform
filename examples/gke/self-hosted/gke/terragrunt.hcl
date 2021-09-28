terraform {
  source = "github.com/cdr/enterprise-terraform//modules/gcp/gke/cluster?ref=v0.3.0"
}

include {
  path = find_in_parent_folders()
}
