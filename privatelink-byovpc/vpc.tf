resource "aws_security_group" "databricks_sg" {
  name        = "Databricks Workspace/VPC endpoint security group"
  description = "Security group shared with workspace EC2 instances and VPC endpoints"
  vpc_id      = data.aws_vpc.my_vpc.id
  depends_on  = [data.aws_vpc.my_vpc]

  ingress {
    description = "Inbound all internal TCP and UDP"
    self      = true
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
  }

  egress {
    description = "Outbound all internal TCP and UDP"
    self      = true
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
  }

  egress {
    description = "Databricks infrastructure, cloud data sources, and library repositories"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Metastore"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Secure Cluster Connectivity"
    from_port   = 6666
    to_port     = 6666
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "FIPS encryption Secure Cluster Connectivity"
    from_port   = 2443
    to_port     = 2443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
      description = "CP Services"
      from_port   = 8443
      to_port     = 8451
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

  tags = merge(var.tags, {
    Name = "${var.resource_prefix}-${data.aws_vpc.my_vpc.id}-pl-vpce-sg-rules"
  })
}

module "vpc_endpoints" {
  source             = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version            = "3.19.0"
  vpc_id             = data.aws_vpc.my_vpc.id
  security_group_ids = [aws_security_group.databricks_sg.id]
  endpoints = {
     s3 = {
       service         = "s3"
       service_type    = "Gateway"
       route_table_ids = [data.aws_route_table.default.id] #flatten([aws_route_table.subnet.id, aws_route_table.public.id])
       tags = {
         Name = "${var.project_name}-s3-vpc-endpoint"
       }
     },
    sts = {
      service             = "sts"
      vpc_endpoint_type   = "Interface"
      security_group_ids  = [aws_security_group.databricks_sg.id]
      subnet_ids          = [data.aws_subnet.vpce.id]
      private_dns_enabled = true
      tags = {
        Name = "${var.project_name}-sts-vpc-endpoint"
      }
    },
    kinesis-streams = {
      service             = "kinesis-streams"
      vpc_endpoint_type   = "Interface"
      security_group_ids  = [aws_security_group.databricks_sg.id]
      subnet_ids           = [data.aws_subnet.vpce.id]
      private_dns_enabled = true
      tags = {
        Name = "${var.project_name}-kinesis-vpc-endpoint"
      }
    },
    backend-rest = {
      service_name        = var.backend_rest[var.region]
      vpc_endpoint_type   = "Interface"
      security_group_ids  = [aws_security_group.databricks_sg.id]
      subnet_ids          = [data.aws_subnet.vpce.id]
      private_dns_enabled = true
      tags = {
        Name = "${var.project_name}-backend-rest-vpc-endpoint"
      }
    },
    relay = {
      service_name        = var.relay[var.region]
      vpc_endpoint_type   = "Interface"
      security_group_ids  = [aws_security_group.databricks_sg.id]
      subnet_ids          = [data.aws_subnet.vpce.id]
      private_dns_enabled = true
      tags = {
        Name = "${var.project_name}-scc-relay-vpc-endpoint"
      }
    }
  }
  tags       = var.tags
  depends_on = [data.aws_vpc.my_vpc, data.aws_subnet.vpce]
}
