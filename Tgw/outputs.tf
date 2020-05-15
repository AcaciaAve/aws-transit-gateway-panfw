##############################################
###     Output Variables
##############################################

output "tgw_id"{
    value = aws_ec2_transit_gateway.transit_tgw.id
    description = "New vpc id"
}
output "vpc_att_transit_id"{
    value = aws_ec2_transit_gateway_vpc_attachment.vpc_att_transit.id
}