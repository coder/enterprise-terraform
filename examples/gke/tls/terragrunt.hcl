terraform {
  source = "../../../terraform//tls"
}

include {
  path = find_in_parent_folders()
}

dependency "gke" {
  config_path = "../gke"
  skip_outputs = true
}
