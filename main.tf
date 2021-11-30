/*
  NOTE: The following page was used for a guide in the creation of this Terraform creation.
  https://www.maxivanov.io/deploy-aws-lambda-to-vpc-with-terraform/
*/

provider "aws" {
  profile = "default"
  region  = var.region
}

resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "${var.project}-${var.dept}-${var.facing-internal-or-external}-${var.env}-vpc",
    dept = "${var.dept}"
  }
}


########################################
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# PUBLIC SUBNET
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
########################################
resource "aws_subnet" "subnet_public" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.subnet_public_cidr_block
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.project}-${var.dept}-${var.facing-internal-or-external}-${var.env}-subnet-public",
    dept = "${var.dept}"
  }
}

########################################
# Internet Gateway
########################################
resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.project}-${var.dept}-${var.facing-internal-or-external}-${var.env}-internet-gateway",
    dept = "${var.dept}"
  }
}

########################################
# PUBLIC Route Table
########################################
resource "aws_route_table" "route_table_public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }

  tags = {
    Name = "${var.project}-${var.dept}-${var.facing-internal-or-external}-${var.env}-route-table-public",
    dept = "${var.dept}"
  }
}

#---------------------------------------
# Route Table Association
#---------------------------------------
resource "aws_route_table_association" "route_table_association_public" {
  subnet_id      = aws_subnet.subnet_public.id
  route_table_id = aws_route_table.route_table_public.id
}

########################################
# Elastic IP
########################################
resource "aws_eip" "eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.internet_gateway]
  tags = {
    Name = "${var.project}-${var.dept}-${var.facing-internal-or-external}-${var.env}-eip",
    dept = "${var.dept}"
  }
}

########################################
# NAT Gateway
########################################
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.subnet_public.id

  tags = {
    Name = "${var.project}-${var.dept}-${var.facing-internal-or-external}-${var.env}-nat-gateway",
    dept = "${var.dept}"
  }
}

########################################
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# PRIVATE SUBNET
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
########################################
resource "aws_subnet" "subnet_private" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = var.subnet_private_cidr_block
  map_public_ip_on_launch = false
  tags = {
    Name = "${var.project}-${var.dept}-${var.facing-internal-or-external}-${var.env}-subnet-private",
    dept = "${var.dept}"
  }
}

########################################
# PRIVATE Route Table
########################################
resource "aws_route_table" "route_table_private" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    Name = "${var.project}-${var.dept}-${var.facing-internal-or-external}-${var.env}-route-table-private",
    dept = "${var.dept}"
  }
}

resource "aws_route_table_association" "route_table_association_private" {
  subnet_id      = aws_subnet.subnet_private.id
  route_table_id = aws_route_table.route_table_private.id
}

########################################
# NACL 
########################################
resource "aws_default_network_acl" "default_network_acl" {
  default_network_acl_id = aws_vpc.vpc.default_network_acl_id
  subnet_ids             = [aws_subnet.subnet_public.id, aws_subnet.subnet_private.id]

  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = {
    Name = "${var.project}-${var.dept}-${var.facing-internal-or-external}-${var.env}-default-network-acl",
    dept = "${var.dept}"
  }
}

########################################
# PRIVATE Route Table
########################################
resource "aws_default_security_group" "default_security_group" {
  vpc_id = aws_vpc.vpc.id

  ingress {
    protocol  = -1
    self      = true
    from_port = 0
    to_port   = 0
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    # cidr_blocks = ["127.0.0.1/32"]
  }

  tags = {
    Name = "${var.project}-${var.dept}-${var.facing-internal-or-external}-${var.env}-default-security-group",
    dept = "${var.dept}"
  }
}