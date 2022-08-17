terraform {
  source = "../../../..//modules/gcp/gke/cluster"
}

include {
  path = find_in_parent_folders()
}
