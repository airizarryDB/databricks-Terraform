data "databricks_current_user" "me" {}

data "aws_availability_zones" "available" {}

data "aws_vpc" "my_vpc" {
  id = var.vpc_id
}

