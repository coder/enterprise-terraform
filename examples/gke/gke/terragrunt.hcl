terraform {
  source = "../../../terraform//gke"
}

include {
  path = find_in_parent_folders()
}
