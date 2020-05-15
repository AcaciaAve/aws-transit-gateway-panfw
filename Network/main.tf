#############################################################
### Module description
#
# Defines core AWS networking 
# VPC, subnets, route tables, internet gw, nat gw.
#
#############################################################

#############################################################
### Input variables
#############################################################

variable "tgw_id" {}

#############################################################
### Start: Network Configuration
#############################################################

# Create a VPC to launch instances.
resource "aws_vpc" "vpc_transit" {
  cidr_block = var.vpc_cidr
  tags = {Name = join("",list("vpc-", var.team))}
} 

# Create internet gateway.
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc_transit.id
  tags = {Name = join("",list("igw-", var.team))}
}

#Create NAT Gateway and EIP to be used by the NAT gateway.
resource "aws_nat_gateway" "nat_gateway" {
  count = var.priv_a_subnet_defaultRoute ? 1 : 0
  allocation_id = aws_eip.natgw.id
  subnet_id     = aws_subnet.dmz_a_subnet.id
  depends_on = [aws_internet_gateway.igw]
  tags = {Name = join("",list("natgw-", var.team))}
}
resource "aws_eip" "natgw" {
  vpc      = true
  tags = {Name = join("",list("eip-natgw-aza-", var.team))}
}

# Create AWS subnets. Creates two private and two DMZ subnets.
resource "aws_subnet" "priv_a_subnet" {
  vpc_id                  = aws_vpc.vpc_transit.id
  cidr_block              = var.subnets.priv_a_subnet.SubCidr
  availability_zone       = var.subnets.priv_a_subnet.SubAz
  map_public_ip_on_launch = false
  tags = {Name = var.subnets.priv_a_subnet.SubDesc}
}
resource "aws_subnet" "priv_b_subnet" {
  vpc_id                  = aws_vpc.vpc_transit.id
  cidr_block              = var.subnets.priv_b_subnet.SubCidr
  availability_zone       = var.subnets.priv_b_subnet.SubAz
  map_public_ip_on_launch = false
  tags = {Name = var.subnets.priv_b_subnet.SubDesc}
}

resource "aws_subnet" "dmz_a_subnet" {
  vpc_id                  = aws_vpc.vpc_transit.id
  cidr_block              = var.subnets.dmz_a_subnet.SubCidr
  availability_zone       = var.subnets.dmz_a_subnet.SubAz
  map_public_ip_on_launch = false
  tags = {Name = var.subnets.dmz_a_subnet.SubDesc}
}
resource "aws_subnet" "dmz_b_subnet" {
  vpc_id                  = aws_vpc.vpc_transit.id
  cidr_block              = var.subnets.dmz_b_subnet.SubCidr
  availability_zone       = var.subnets.dmz_b_subnet.SubAz
  map_public_ip_on_launch = false
  tags = {Name = var.subnets.dmz_b_subnet.SubDesc}
}

#Create subnet route tables and associations.
resource "aws_route_table" "priv_aza_routeTable" {
  count = var.priv_a_subnet_defaultRoute ? 1 : 0
  vpc_id = aws_vpc.vpc_transit.id
    route{
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_nat_gateway.nat_gateway.*.id[count.index]
    }
  tags = { Name = "Private-AZA-Rtb"}
}
resource "aws_route_table_association" "priva" {
  count = var.priv_a_subnet_defaultRoute ? 1 : 0
  subnet_id         = aws_subnet.priv_a_subnet.id
  route_table_id    = aws_route_table.priv_aza_routeTable.*.id[count.index]
}

resource "aws_route_table" "priv_azb_routeTable" {
  count = var.priv_b_subnet_defaultRoute ? 1 : 0
  vpc_id = aws_vpc.vpc_transit.id
    route{
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_nat_gateway.nat_gateway.*.id[count.index]
    }
  tags = { Name = "Private-AZB-Rtb"}
}
resource "aws_route_table_association" "privb" {
  count = var.priv_a_subnet_defaultRoute ? 1 : 0
  subnet_id         = aws_subnet.priv_b_subnet.id
  route_table_id    = aws_route_table.priv_azb_routeTable.*.id[count.index]
}

resource "aws_route_table" "dmz_aza_routeTable" {
  count = var.priv_a_subnet_defaultRoute ? 1 : 0
  vpc_id = aws_vpc.vpc_transit.id
    route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { Name = "DMZ-AZA-Rtb"}
}
resource "aws_route_table_association" "dmza" {
  count = var.priv_a_subnet_defaultRoute ? 1 : 0
  subnet_id      = aws_subnet.dmz_a_subnet.id
  route_table_id = aws_route_table.dmz_aza_routeTable.*.id[count.index]
}

resource "aws_route_table" "dmz_azb_routeTable" {
  count = var.priv_a_subnet_defaultRoute ? 1 : 0
  vpc_id = aws_vpc.vpc_transit.id
    route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { Name = "DMZ-AZB-Rtb"}
}
resource "aws_route_table_association" "dmzb" {
  count = var.priv_a_subnet_defaultRoute ? 1 : 0
  subnet_id      = aws_subnet.dmz_b_subnet.id
  route_table_id = aws_route_table.dmz_azb_routeTable.*.id[count.index]
}




