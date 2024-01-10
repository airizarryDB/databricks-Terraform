resource "aws_subnet" "private1" {
  vpc_id            = data.aws_vpc.my_vpc.id
  availability_zone = data.aws_availability_zones.available.names[0]
  cidr_block        = cidrsubnet(var.cidr_block_private, 2, 0) #cidrsubnet(data.aws_vpc.selected.cidr_block, 4, 1)
}

resource "aws_subnet" "private2" {
  vpc_id            = data.aws_vpc.my_vpc.id
  availability_zone = data.aws_availability_zones.available.names[1]
  cidr_block        = cidrsubnet(var.cidr_block_private, 2, 1) #cidrsubnet(data.aws_vpc.selected.cidr_block, 4, 1)
}

resource "aws_subnet" "vpce" {
  vpc_id            = data.aws_vpc.my_vpc.id
  availability_zone = data.aws_availability_zones.available.names[0]
  cidr_block        = cidrsubnet(var.vpce_subnet_cidr  , 0, 0) #cidrsubnet(data.aws_vpc.selected.cidr_block, 4, 1)
}

resource "aws_subnet" "public" {
  vpc_id            = data.aws_vpc.my_vpc.id
  availability_zone = data.aws_availability_zones.available.names[0]
  cidr_block        = cidrsubnet(var.cidr_block_public , 0, 0) #cidrsubnet(data.aws_vpc.selected.cidr_block, 4, 1)
}

# Create an IGW
resource "aws_internet_gateway" "vpc_igw" {
  vpc_id = data.aws_vpc.my_vpc.id
}

#Create EIP
resource "aws_eip" "nat_eip" {
  vpc = true
  tags = {
    Name = "${var.resource_prefix}-NAT_EIP"
  }
  depends_on = [aws_internet_gateway.vpc_igw]
}

# Create a NAT GW
resource "aws_nat_gateway" "nat" {
  subnet_id     = aws_subnet.public.id
  allocation_id = aws_eip.nat_eip.id
  tags          = {
    Name = "${var.resource_prefix}-NAT"
  }
  depends_on = [aws_eip.nat_eip, aws_internet_gateway.vpc_igw]
}

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

#Create route table for Databricks Subnets
 resource "aws_route_table" "subnet" {
   vpc_id = data.aws_vpc.my_vpc.id

   tags = merge(var.tags, {
     Name = "${var.resource_prefix}-${data.aws_vpc.my_vpc.id}-pl-subnet-route-tbl"
   })
   route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat.id
  }
   depends_on = [aws_nat_gateway.nat]
 }
 #Create  Dataplane Subnet RT Association
 resource "aws_route_table_association" "dataplane_subnet_1" {
   subnet_id      = aws_subnet.private1.id
   route_table_id = aws_route_table.subnet.id
 }

 #Create  Dataplane Subnet RT Association
 resource "aws_route_table_association" "dataplane_subnet_2" {
   subnet_id      = aws_subnet.private2.id
   route_table_id = aws_route_table.subnet.id
 }

 #Create  Dataplane Subnet RT Association
 resource "aws_route_table_association" "vpce_subnet" {
   subnet_id      = aws_subnet.vpce.id
   route_table_id = aws_route_table.subnet.id
 }

#Create route table for Dataplane Public Subnet
 resource "aws_route_table" "public" {
   vpc_id = data.aws_vpc.my_vpc.id

   tags = merge(var.tags, {
     Name = "${var.resource_prefix}-${data.aws_vpc.my_vpc.id}-pl-local-route-tbl"
   })
   route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.vpc_igw.id
  }
   depends_on = [aws_internet_gateway.vpc_igw]
 }
 #Create  Dataplane VPC Endpoint Subnet
 resource "aws_route_table_association" "dataplane_public_rtb" {
   subnet_id      = aws_subnet.public.id
   route_table_id = aws_route_table.public.id
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
       route_table_ids = flatten([aws_route_table.subnet.id, aws_route_table.public.id])
       tags = {
         Name = "${var.project_name}-s3-vpc-endpoint"
       }
     },
    sts = {
      service             = "sts"
      vpc_endpoint_type   = "Interface"
      security_group_ids  = [aws_security_group.databricks_sg.id]
      subnet_ids          = [aws_subnet.vpce.id]
      private_dns_enabled = true
      tags = {
        Name = "${var.project_name}-sts-vpc-endpoint"
      }
    },
    kinesis-streams = {
      service             = "kinesis-streams"
      vpc_endpoint_type   = "Interface"
      security_group_ids  = [aws_security_group.databricks_sg.id]
      subnet_ids           = [aws_subnet.vpce.id]
      private_dns_enabled = true
      tags = {
        Name = "${var.project_name}-kinesis-vpc-endpoint"
      }
    },
    backend-rest = {
      service_name        = var.backend_rest[var.region]
      vpc_endpoint_type   = "Interface"
      security_group_ids  = [aws_security_group.databricks_sg.id]
      subnet_ids          = [aws_subnet.vpce.id]
      private_dns_enabled = true
      tags = {
        Name = "${var.project_name}-backend-rest-vpc-endpoint"
      }
    },
    relay = {
      service_name        = var.relay[var.region]
      vpc_endpoint_type   = "Interface"
      security_group_ids  = [aws_security_group.databricks_sg.id]
      subnet_ids          = [aws_subnet.vpce.id]
      private_dns_enabled = true
      tags = {
        Name = "${var.project_name}-scc-relay-vpc-endpoint"
      }
    }
  }
  tags       = var.tags
  depends_on = [data.aws_vpc.my_vpc, aws_subnet.vpce]
}
