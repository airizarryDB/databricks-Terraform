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
  description = "pick region: us-east-1, us-west-2"
  validation {
    condition     = contains(["us-east-1", "us-west-2"], var.region)
    error_message = "Valid values for var: region are (us-east-1, us-west-2)."
  }
}

variable "backend_rest" {
  type = map(string)
  default = {
    "us-east-1" = "com.amazonaws.vpce.us-east-1.vpce-svc-09143d1e626de2f04"
    "us-west-2" = "com.amazonaws.vpce.us-west-2.vpce-svc-0129f463fcfbc46c5"
  }
}

variable "relay" {
  type = map(string)
  default = {
    "us-east-1" = "com.amazonaws.vpce.us-east-1.vpce-svc-00018a8c3ff62ffdf"
    "us-west-2" = "com.amazonaws.vpce.us-west-2.vpce-svc-0158114c0c730c3bb"
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

variable "ex_databricks_account_id" {
  type        = string
  description = "This is the Databricks AWS account id (414351767826); used for the bucket policy"
  default     = "414351767826"
}

variable "vpc_id" {
  default = "ID of existing VPC (e.g. \"vpc-01234567890abcdef\")"
}

variable "cidr_block_private" {
  default = "10.0.15.0/24"
}

variable "cidr_block_public" {
  default = "10.0.16.0/24"
}

variable "vpce_subnet_cidr" {
  default = "10.0.17.0/24"
}

variable "project_name" {
  description = "Name that will be used in the workspace URL"
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
