data "databricks_current_user" "me" {
  depends_on = [ databricks_mws_workspaces.this ]
}

data "aws_availability_zones" "available" {}
