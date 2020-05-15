output "Panorama_VPN_Config" {
  value = <<EOT
  

________________________________________________________________________________________________________
IPsec VPN configuration details
________________________________________________________________________________________________________

--------------------------------------------------------------------
Firewall #1 - Availability Zone A
--------------------------------------------------------------------
Tunnel 1
Preshared-Key: ${aws_vpn_connection.vpn_fw1_aza.tunnel1_preshared_key}
Peer address: ${aws_vpn_connection.vpn_fw1_aza.tunnel1_address}
Inside cidr: ${aws_vpn_connection.vpn_fw1_aza.tunnel1_inside_cidr}
Firewall/cgw inside address: ${aws_vpn_connection.vpn_fw1_aza.tunnel1_cgw_inside_address}
AWS/vgw inside address: ${aws_vpn_connection.vpn_fw1_aza.tunnel1_vgw_inside_address}
mtu: 1427
BGP ASN (AWS side): ${aws_vpn_connection.vpn_fw1_aza.tunnel1_bgp_asn}
BGP peer address: Use the other address in the /30 tunnel subnet

Tunnel 2
Preshared-Key: ${aws_vpn_connection.vpn_fw1_aza.tunnel2_preshared_key}
Peer address: ${aws_vpn_connection.vpn_fw1_aza.tunnel2_address}
Inside cidr: ${aws_vpn_connection.vpn_fw1_aza.tunnel2_inside_cidr}
Firewall/cgw inside address: ${aws_vpn_connection.vpn_fw1_aza.tunnel2_cgw_inside_address}
AWS/vgw inside address: ${aws_vpn_connection.vpn_fw1_aza.tunnel2_vgw_inside_address}
mtu: 1427
BGP ASN (AWS side): ${aws_vpn_connection.vpn_fw1_aza.tunnel2_bgp_asn}
BGP peer address: Use the other address in the /30 tunnel subnet

--------------------------------------------------------------------
Firewall #2 - Availability Zone B
--------------------------------------------------------------------
Tunnel 1
Preshared-Key: ${aws_vpn_connection.vpn_fw1_azb.tunnel1_preshared_key}
Peer address: ${aws_vpn_connection.vpn_fw1_azb.tunnel1_address}
Inside cidr: ${aws_vpn_connection.vpn_fw1_azb.tunnel1_inside_cidr}
Firewall/cgw inside address: ${aws_vpn_connection.vpn_fw1_azb.tunnel1_cgw_inside_address}
AWS/vgw inside address: ${aws_vpn_connection.vpn_fw1_azb.tunnel1_vgw_inside_address}
mtu: 1427
BGP ASN (AWS side): ${aws_vpn_connection.vpn_fw1_azb.tunnel1_bgp_asn}
BGP peer address: Use the other address in the /30 tunnel subnet 

Tunnel 2
Preshared-Key: ${aws_vpn_connection.vpn_fw1_azb.tunnel2_preshared_key}
Peer address: ${aws_vpn_connection.vpn_fw1_azb.tunnel2_address}
Inside cidr: ${aws_vpn_connection.vpn_fw1_azb.tunnel2_inside_cidr}
Firewall/cgw inside address: ${aws_vpn_connection.vpn_fw1_azb.tunnel2_cgw_inside_address}
AWS/vgw inside address: ${aws_vpn_connection.vpn_fw1_azb.tunnel2_vgw_inside_address}
mtu: 1427
BGP ASN (AWS side): ${aws_vpn_connection.vpn_fw1_azb.tunnel2_bgp_asn}
BGP peer address: Use the other address in the /30 tunnel subnet

________________________________________________________________________________________________________

EOT

}

output "FirewallManagementURL" {
  value = <<EOT
________________________________________________________________________________________________________
Firewall management addresses
________________________________________________________________________________________________________


  AZA Firewall: ${join("", list("https://", "${data.aws_network_interface.FwMgmtNic_aza.private_ip}"))}
  AZB Firewall: ${join("", list("https://", "${data.aws_network_interface.FwMgmtNic_azb.private_ip}"))}

________________________________________________________________________________________________________
EOT
}
