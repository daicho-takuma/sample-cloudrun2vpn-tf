#########################
# VPC
#########################
resource "aws_vpc" "vpc" {
  cidr_block                       = local.aws_network_config.vpc_cidr
  instance_tenancy                 = "default"
  enable_dns_support               = true
  enable_dns_hostnames             = true
  assign_generated_ipv6_cidr_block = false
  tags = {
    Name = "${local.env}-${local.project}-vpc"
  }
}

resource "aws_default_route_table" "default_rt" {
  default_route_table_id = aws_vpc.vpc.default_route_table_id
  tags = {
    Name = "${local.env}-${local.project}-default-route"
  }
}

resource "aws_default_network_acl" "default_acl" {
  default_network_acl_id = aws_vpc.vpc.default_network_acl_id
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
    Name = "${local.env}-${local.project}-default-acl"
  }
  lifecycle {
    ignore_changes = [subnet_ids]
  }
}

#########################
# Public Network
#########################
resource "aws_subnet" "public" {
  for_each          = local.aws_network_config.public_subnet
  availability_zone = each.value.az
  # availability_zone_id
  cidr_block = each.value.cidr
  # ipv6_cidr_block
  map_public_ip_on_launch = true
  # outpost_arn
  # assign_ipv6_address_on_creation
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = each.key
  }
}

# ----------------------
# Internet Gateway
# ----------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${local.env}-${local.project}-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${local.env}-${local.project}-public-route"
  }
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_route" "public_igw" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public" {
  for_each       = local.aws_network_config.public_subnet
  subnet_id      = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.public.id
}

#########################
# Private Network
#########################
resource "aws_subnet" "private" {
  for_each          = local.aws_network_config.private_subnet
  availability_zone = each.value.az
  # availability_zone_id
  cidr_block = each.value.cidr
  # ipv6_cidr_block
  map_public_ip_on_launch = false
  # outpost_arn
  # assign_ipv6_address_on_creation
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = each.key
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name = "${local.env}-${local.project}-private-route"
  }
  #propagating_vgws = []
}

resource "aws_route_table_association" "private" {
  for_each       = local.aws_network_config.private_subnet
  subnet_id      = aws_subnet.private[each.key].id
  route_table_id = aws_route_table.private.id
}
