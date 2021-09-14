terraform {
  source = "github.com/cdr/enterprise-terraform//modules/gcp/gke?ref=v0.1.0"
}

include {
  path = find_in_parent_folders()
}
