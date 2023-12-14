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
  account_id    = var.databricks_account_id
  client_id     = var.client_id
  client_secret = var.client_secret
}
// initialize provider at workspace level, to create UC resources
provider "databricks" {
  alias    = "workspace"
  host     = databricks_mws_workspaces.this.workspace_url
  account_id    = var.databricks_account_id
  client_id     = var.client_id
  client_secret = var.client_secret
}
