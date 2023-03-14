/**
 * E2 pattern with AWS Private Link
 * 
 * This reference architecture can be described as the following diagram:
 * ![architecture](./aws-e2-private-link-backend.png)
 */
 terraform {
  required_providers {
    databricks = { source = "databricks/databricks" }
    aws = { source  = "hashicorp/aws" }
  }
}

provider "aws" {
  region = var.region
  profile = var.profile
}

// initialize provider in "MWS" mode to provision new workspace
provider "databricks" {
  alias    = "mws"
  host     = "https://accounts.cloud.databricks.com/"
  username = var.databricks_account_username
  password = var.databricks_account_password
}
// initialize provider at workspace level, to create UC resources
provider "databricks" {
  alias    = "workspace"
  host     = databricks_mws_workspaces.this.workspace_url
  username = var.databricks_account_username
  password = var.databricks_account_password
}
