data "databricks_current_user" "me" {
  provider = databricks.workspace
  depends_on = [ databricks_mws_workspaces.this ]
}

data "aws_availability_zones" "available" {}
