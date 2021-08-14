terraform {
  source = "github.com/cdr/enterprise-terraform//modules/gcp/gke"
}

include {
  path = find_in_parent_folders()
}
