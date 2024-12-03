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
  alias         = "mws"
  host          = var.account_console[var.databricks_gov_shard]
  account_id    = var.databricks_account_id
  client_id     = var.client_id
  client_secret = var.client_secret
}
// initialize provider at workspace level, to create UC resources
provider "databricks" {
  alias         = "workspace"
  host          = databricks_mws_workspaces.this.workspace_url
  account_id    = var.databricks_account_id
  client_id     = var.client_id
  client_secret = var.client_secret
}
