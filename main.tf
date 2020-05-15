

provider aws{
  region = "ap-southeast-2"
  profile = "default"
}

module "Network" {
  source = "./Network"
  tgw_id = module.Tgw.tgw_id
}

#Creates transit gateway, direct connect gateway, connects direct connect to transit gateway and advertises subnets back to on-prem
module "Tgw" {
  source = "./Tgw"
  vpc_id = "${module.Network.vpc_id}"
  priv_a_subnet_id = module.Network.priv_a_subnet_id
  priv_b_subnet_id = module.Network.priv_b_subnet_id
  team = module.Network.team
  environment = module.Network.environment
}

#Creates two Palo Alto firewalls (BYOL) and deploys to two availability zones.
module "PanFw" {
  source = "./PanFw"
  vpc_id = "${module.Network.vpc_id}"
  priv_a_subnet_id = module.Network.priv_a_subnet_id
  priv_b_subnet_id = module.Network.priv_b_subnet_id
  dmz_a_subnet_id = module.Network.dmz_a_subnet_id
  dmz_b_subnet_id = module.Network.dmz_b_subnet_id
  tgw_id = module.Tgw.tgw_id
  vpc_att_transit_id = module.Tgw.vpc_att_transit_id
  nat_gateway_id = module.Network.nat_gateway_id
  priv_aza_routeTable_id = module.Network.priv_aza_routeTable_id
  priv_azb_routeTable_id = module.Network.priv_azb_routeTable_id
  priva_id = module.Network.priva_id
  privb_id = module.Network.privb_id
  team = module.Network.team
  igw_id = module.Network.igw_id
  priv_a_subnet_defaultRoute_bool = module.Network.priv_a_subnet_defaultRoute_bool
  priv_b_subnet_defaultRoute_bool = module.Network.priv_a_subnet_defaultRoute_bool
  environment = module.Network.environment
}

# Print VPN configuration values
output "Panorama_VPN_Config" {
  value = module.PanFw.Panorama_VPN_Config
}

# Print firewall management URLs.
output "FirewallManagementURL" {
  value = module.PanFw.FirewallManagementURL
}
