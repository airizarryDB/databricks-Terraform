resource "databricks_mws_credentials" "this" {
  provider         = databricks.mws
  account_id       = var.databricks_account_id
  role_arn         = aws_iam_role.cross_account_role.arn
  credentials_name = "${var.resource_prefix}-creds"
  depends_on       = [time_sleep.wait_30_seconds]
}

resource "databricks_mws_storage_configurations" "this" {
  provider                   = databricks.mws
  account_id                 = var.databricks_account_id
  bucket_name                = aws_s3_bucket.root_storage_bucket.bucket
  storage_configuration_name = "${var.resource_prefix}-storage"
}

resource "databricks_mws_vpc_endpoint" "backend_rest_vpce" {
  provider            = databricks.mws
  account_id          = var.databricks_account_id
  aws_vpc_endpoint_id = module.endpoints.endpoints["backend-rest"].id
  vpc_endpoint_name   = "${var.resource_prefix}-vpc-backend-${module.vpc.vpc_id}"
  region              = var.region
  depends_on          = [module.endpoints]
}

resource "databricks_mws_vpc_endpoint" "relay" {
  provider            = databricks.mws
  account_id          = var.databricks_account_id
  aws_vpc_endpoint_id = module.endpoints.endpoints["relay"].id
  vpc_endpoint_name   = "${var.resource_prefix}-vpc-relay-${module.vpc.vpc_id}"
  region              = var.region
  depends_on          = [module.endpoints]
}

resource "databricks_mws_networks" "this" {
  provider           = databricks.mws
  account_id         = var.databricks_account_id
  network_name       = "${var.resource_prefix}-network"
  security_group_ids = [module.vpc.default_security_group_id]
  subnet_ids         = [module.vpc.private_subnets[0], module.vpc.private_subnets[1]]
  vpc_id             = module.vpc.vpc_id
    vpc_endpoints {
    dataplane_relay = [databricks_mws_vpc_endpoint.relay.vpc_endpoint_id]
     rest_api        = [databricks_mws_vpc_endpoint.backend_rest_vpce.vpc_endpoint_id]
   }
  depends_on = [module.vpc, module.endpoints, databricks_mws_vpc_endpoint.relay, databricks_mws_vpc_endpoint.backend_rest_vpce]
}

resource "databricks_mws_private_access_settings" "pas" {
  provider                     = databricks.mws
  account_id                   = var.databricks_account_id
  private_access_settings_name = "${var.region} public"
  region                       = var.region
  public_access_enabled        = true
}

resource "databricks_mws_workspaces" "this" {
  provider        = databricks.mws
  account_id      = var.databricks_account_id
  aws_region      = var.region
  workspace_name  = var.project_name
  deployment_name = var.project_name

  credentials_id             = databricks_mws_credentials.this.credentials_id
  storage_configuration_id   = databricks_mws_storage_configurations.this.storage_configuration_id
  network_id                 = databricks_mws_networks.this.network_id
  private_access_settings_id = databricks_mws_private_access_settings.pas.private_access_settings_id
  pricing_tier               = "ENTERPRISE"
  depends_on                 = [databricks_mws_networks.this, databricks_mws_credentials.this,
    databricks_mws_storage_configurations.this, databricks_mws_private_access_settings.pas]
}
