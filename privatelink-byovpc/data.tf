data "databricks_current_user" "me" {
  provider = databricks.mws
  depends_on = [ databricks_mws_workspaces.this ]
}

data "aws_availability_zones" "available" {}

data "aws_vpc" "my_vpc" {
  id = var.vpc_id
}

data "aws_subnet" "private1" {
  id = var.private1_subnet_id
}

data "aws_subnet" "private2" {
  id = var.private2_subnet_id
}

data "aws_subnet" "vpce" {
  id = var.vpce_subnet_id
}

data "aws_route_table" "default" {
  id = var.default_route_table_id
}