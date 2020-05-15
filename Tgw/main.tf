##############################################
### Module description
#
# Creates transit gateway and associated connectivity
# Transit gateway, direct connect gateway (connectivity to on-prem)
#
##############################################

##############################################
### Input variables
##############################################

variable "vpc_id" {}
variable "priv_a_subnet_id" {}
variable "priv_b_subnet_id" {}
variable "team" {}
variable "environment" {}


##############################################
### Start: TGW config
##############################################

#Create transit gateway
resource "aws_ec2_transit_gateway" "transit_tgw" {
  amazon_side_asn = var.tgw_amazon_asn
  auto_accept_shared_attachments = "disable"
  tags = {Name = join("",list("tgw-", var.team))}
}

#Create direct connect gateway and setup BGP peering to on-prem equipment across private direct connect
resource "aws_dx_gateway" "transit_dxgw" {
  count = var.deploy_dx ? 1 : 0
  name            = join("",list("dxgw-", var.team))
  amazon_side_asn = var.dxgw_amazon_asn
}
resource "aws_dx_transit_virtual_interface" "transit_vif" {
  count = var.deploy_dx ? 1 : 0
  connection_id = var.aws_dxcon
  dx_gateway_id  = aws_dx_gateway.transit_dxgw.*.id[count.index]
  name           = join("",list("dxgw-tvif-", var.team))
  vlan           = var.dxgw_tvif_vlan
  address_family = "ipv4"
  bgp_asn        = var.dxgw_tvif_BgpAsn
  bgp_auth_key  = var.dxgw_tvif_BgpAuth
  customer_address = var.dxgw_tvif_BgpCustAdd
  amazon_address = var.dxgw_tvif_BgpAmazonAdd
}

resource "aws_dx_gateway_association" "dgw_tgw_assoc" {
  count = var.deploy_dx ? 1 : 0
  depends_on = [aws_ec2_transit_gateway.transit_tgw,aws_dx_gateway.transit_dxgw]
  dx_gateway_id         = aws_dx_gateway.transit_dxgw.*.id[count.index]
  associated_gateway_id = aws_ec2_transit_gateway.transit_tgw.id
  allowed_prefixes = var.dxgw_prefixes
}

#Attach network-transit VPC to TGW
resource "aws_ec2_transit_gateway_vpc_attachment" "vpc_att_transit" {
  depends_on = [aws_ec2_transit_gateway.transit_tgw]
  subnet_ids         = [var.priv_a_subnet_id, var.priv_b_subnet_id]
  transit_gateway_id = aws_ec2_transit_gateway.transit_tgw.id
  vpc_id             = var.vpc_id
  tags = {Name = join("",list("Private-Subnets-", var.team))}
}

#Setup resource share (RAM) and associate transit gateway with accounts specified in tgw_accounts variable.
resource "aws_ram_resource_share" "ram_transit" {
  name                      = join("",list("ram-", var.team, "-share"))
  allow_external_principals = true

  tags = {
    environment = var.environment
    team = var.team
    Name = join("",list("DCGW-", var.team))
  }
}
resource "aws_ram_principal_association" "ram_pa" {
  for_each = var.tgw_accounts
  principal          = each.value.AccNum
  resource_share_arn = aws_ram_resource_share.ram_transit.arn
}
resource "aws_ram_resource_association" "ram_ra" {
  resource_arn       = aws_ec2_transit_gateway.transit_tgw.arn
  resource_share_arn = aws_ram_resource_share.ram_transit.arn
}