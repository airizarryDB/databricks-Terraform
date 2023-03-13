variable "databricks_account_username" {}
variable "databricks_account_password" {}

variable "account_console_id" {
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

variable "private_dns_enabled" {
  default = true
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
}

locals {
  description = "Prefix used for root bucket name"
  prefix = "test" // Must be changed
}


