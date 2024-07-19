variable "client_id" {
  type        = string
  description = "Databricks Account Service Principal Client ID"
}
variable "client_secret" {
  type        = string
  description = "Databricks Account Service Principal Client Secret"
}

variable "databricks_account_id" {
  type        = string
  description = "Databricks Account Console ID"
}

variable "profile" {
  type        = string
  description = "AWS profile name used in conjunction with \"gimme-aws-creds\""
}

variable "region" {
  description = "Databricks only operates in AWS Gov West (us-gov-west-1)"
  default = "us-gov-west-1"
}

variable "databricks_gov_shard" {
  description = "pick shard: civilian, dod"
  validation {
    condition     = contains(["civilian", "dod"], var.databricks_gov_shard)
    error_message = "Valid values for var: databricks_gov_shard are (civilian, dod)."
  }
}

variable "account_console" {
  type = map(string)
  default = {
    "civilian" = "https://accounts.cloud.databricks.us/"
    "dod"      = "https://accounts-dod.cloud.databricks.us/"
  }
}

variable "backend_rest" {
  type = map(string)
  default = {
    "civilian" = "com.amazonaws.vpce.us-gov-west-1.vpce-svc-0f25e28401cbc9418"
    "dod"      = "com.amazonaws.vpce.us-gov-west-1.vpce-svc-05c210a2feea23ad7"
  }
}

variable "relay" {
  type = map(string)
  default = {
    "civilian" = "com.amazonaws.vpce.us-gov-west-1.vpce-svc-05f27abef1a1a3faa"
    "dod"      = "com.amazonaws.vpce.us-gov-west-1.vpce-svc-08fddf710780b2a54"
  }
}

variable "tags" {
  type        = map(string)
  description = "Tags applied to all resources created"
  default = {}
}

locals {
  tags = merge(
    var.tags,
    {
      Owner = data.databricks_current_user.me.user_name
    },
  )
}

variable "databricks_prod_aws_account_id" {
  type = map(string)
  default = {
    "civilian" = "044793339203"
    "dod"      = "170661010020"
  }
}

variable "uc_master_role_id" {
  type = map(string)
  default = {
    "civilian" = "1QRFA8SGY15OJ"
    "dod"      = "1DI6DL6ZP26AS"
  }
}

variable "cidr_block_private" {
  default = "10.1.0.0/16"
}

variable "cidr_block_public" {
  default = "10.2.0.0/24"
}

variable "vpce_subnet_cidr" {
  default = "10.2.1.0/24"
}

variable "project_name" {
  description = "Name that will be used in the workspace URL"
  validation {
    condition     = (can(regex("^[a-zA-Z0-9-]+$", var.resource_prefix)))
    error_message = "Invalid variable name, make sure it is all lower case"
  }
}

variable "resource_prefix" {
  description = "Prefix used for root bucket name"
  validation {
    condition     = (can(regex("^[a-z-]+$", var.resource_prefix)))
    error_message = "Invalid variable name, make sure it is all lower case"
  }
}

variable "ucname" {
  description = "URL compliant name for Unity Catalog Metastore"
  type = string
}

variable "aws_account_id" {
  description = "AWS Account ID"
  type = string
}