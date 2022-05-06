terraform {
  source = "github.com/cdr/enterprise-terraform//modules/gcp/services?ref=v0.4.0"
}

include {
  path = find_in_parent_folders()
}
