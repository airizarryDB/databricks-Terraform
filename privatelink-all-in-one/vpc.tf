module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.4.0"

  name                  = var.project_name
  cidr                  = var.cidr_block_private
  secondary_cidr_blocks = [var.cidr_block_public, var.vpce_subnet_cidr]
  azs                   = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1]]
  tags                  = var.tags

  enable_dns_hostnames          = true
  enable_nat_gateway            = true
  single_nat_gateway            = true
  one_nat_gateway_per_az        = false
  create_igw                    = true
  manage_default_security_group = true

  public_subnets = [
    cidrsubnet(var.cidr_block_public, 0, 0)
  ]
  private_subnets = [
    cidrsubnet(var.cidr_block_private, 1, 0),
    cidrsubnet(var.cidr_block_private, 1, 1),
    cidrsubnet(var.vpce_subnet_cidr  , 0, 0)
  ]

  default_security_group_egress = [
    {
      description = "Outbound all internal TCP and UDP"
      self        = true
    },
    {
      description = "Databricks infrastructure, cloud data sources, and library repositories"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      description = "FIPS encryption Secure Cluster Connectivity"
      from_port   = 2443
      to_port     = 2443
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      description = "Metastore"
      from_port   = 3306
      to_port     = 3306
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      description = "Secure Cluster Connectivity"
      from_port   = 6666
      to_port     = 6666
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      description = "CP Services"
      from_port   = 8443
      to_port     = 8451
      protocol    = "tcp"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  default_security_group_ingress = [
    {
      description = "Inbound all internal TCP and UDP"
      self        = true
    }
  ]
}

module "endpoints" {
  source             = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version            = "5.4.0"
  vpc_id             = module.vpc.vpc_id
  security_group_ids = [module.vpc.default_security_group_id]
  endpoints = {
     s3 = {
       service         = "s3"
       service_type    = "Gateway"
       route_table_ids = flatten([module.vpc.private_route_table_ids, module.vpc.public_route_table_ids])
       tags = {
         Name = "${var.project_name}-s3-vpc-endpoint"
       }
     },
    sts = {
      service             = "sts"
      vpc_endpoint_type   = "Interface"
      security_group_ids  = [module.vpc.default_security_group_id]
      subnet_ids          = [module.vpc.private_subnets[2]]
      private_dns_enabled = true
      tags = {
        Name = "${var.project_name}-sts-vpc-endpoint"
      }
    },
    kinesis-streams = {
      service             = "kinesis-streams"
      vpc_endpoint_type   = "Interface"
      security_group_ids  = [module.vpc.default_security_group_id]
      subnet_ids          = [module.vpc.private_subnets[2]]
      private_dns_enabled = true
      tags = {
        Name = "${var.project_name}-kinesis-vpc-endpoint"
      }
    },
    backend-rest = {
      service_name        = var.backend_rest[var.region]
      vpc_endpoint_type   = "Interface"
      security_group_ids  = [module.vpc.default_security_group_id]
      subnet_ids          = [module.vpc.private_subnets[2]]
      private_dns_enabled = true
      tags = {
        Name = "${var.project_name}-backend-rest-vpc-endpoint"
      }
    },
    relay = {
      service_name        = var.relay[var.region]
      vpc_endpoint_type   = "Interface"
      security_group_ids  = [module.vpc.default_security_group_id]
      subnet_ids          = [module.vpc.private_subnets[2]]
      private_dns_enabled = true
      tags = {
        Name = "${var.project_name}-scc-relay-vpc-endpoint"
      }
    }
  }
  tags       = var.tags
  depends_on = [module.vpc]
}
