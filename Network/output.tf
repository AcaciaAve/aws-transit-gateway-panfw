#############################################################
###     Output Variables
#############################################################

output "vpc_id" {
    value = aws_vpc.vpc_transit.id
    description = "New vpc id"
}
output "priv_a_subnet_id" {
    value = aws_subnet.priv_a_subnet.id
    description = "Private AZA subnet id"
}
output "priv_b_subnet_id" {
    value = aws_subnet.priv_b_subnet.id
    description = "Private AZB subnet id"
}
output "dmz_a_subnet_id" {
    value = aws_subnet.dmz_a_subnet.id
    description = "DMZ AZA subnet id"
}
output "dmz_b_subnet_id" {
    value = aws_subnet.dmz_b_subnet.id
    description = "Priv AZB subnet id"
}
output "nat_gateway_id" {
    value = aws_nat_gateway.nat_gateway.*.id
    description = "NAT gateway id"
}
output "priv_aza_routeTable_id" {
    value = [aws_route_table.priv_aza_routeTable]
    description = "Private AZA route table id"
}
output "priv_azb_routeTable_id" {
    value = [aws_route_table.priv_azb_routeTable]
    description = "Private AZB route table id"
}
output "priva_id" {
    value = [aws_route_table_association.priva]
    description = "Private A route table association id"
}
output "privb_id" {
    value = [aws_route_table_association.privb]
    description = "Private B route table association id"
}
output "team" {
    value = var.team
    description = "Name of the team owning the solution or general identifier. Used in tags and object naming."
}
output "environment" {
    value = var.environment
    description = "Environment type (Production/Staging) Used in tags and object naming. Identifying string specifying solution importance."
}
output "priv_a_subnet_defaultRoute_bool" {
    description = "true/false: Bool used to specify where default route points in private subnet"
    value = var.priv_a_subnet_defaultRoute
}
output "priv_b_subnet_defaultRoute_bool" {
    description = "true/false: Bool used to specify where default route points in private subnet"
    value = var.priv_b_subnet_defaultRoute
}
output "igw_id" {
  description = "Internet gateway ID"
  value = aws_internet_gateway.igw.id
}