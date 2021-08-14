terraform {
  source = "github.com/cdr/enterprise-terraform//modules/helm"
}

include {
  path = find_in_parent_folders()
}

dependency "gke" {
  config_path = "../gke"
  skip_outputs = true
}

dependency "cloud_sql" {
  config_path = "../cloudsql"

  mock_outputs_allowed_terraform_commands = ["validate", "plan", "destroy"]
  mock_outputs = {
    sql_password = "hunter2"
    sql_host = "sql.coder.com"
    sql_user = "coder"
    sql_database = "coder"
  }
}

dependency "ns" {
  config_path = "../namespace"
  skip_outputs = true
}

dependency "tls" {
  config_path = "../tls"

  mock_outputs_allowed_terraform_commands = ["validate", "plan", "destroy"]
  mock_outputs = {
    address = "1.1.1.1"
    tls_secret_name = "coder-certs"
  }
}

inputs = {
  sql_password = dependency.cloud_sql.outputs.sql_password
  sql_host = dependency.cloud_sql.outputs.sql_host
  sql_user = dependency.cloud_sql.outputs.sql_user
  sql_database = dependency.cloud_sql.outputs.sql_database
  load_balancer_ip = dependency.tls.outputs.address
  tls_secret_name = dependency.tls.outputs.tls_secret_name
}
