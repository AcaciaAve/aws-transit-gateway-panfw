
##############################################
### Start: Direct Connect 
##############################################

# If you want to attach direct connect to the transit gateway and route back to your data centre, set "deploy_dx" to "true"
# If it's set to false non of the other variables in this section will matter.

variable "deploy_dx" {
    type = bool
    default = "true"
}

#dxcon of the direct connect, this will be assigned when you connect a Direct Connect to your account
#AWS console --> Direct Connect --> Connections --> dxcon-xxxxxxx
variable "aws_dxcon" { default = "dxcon-xxxxxxx"}

#BGP information for the BGP peering between the dxgw and on-prem router.
variable "dxgw_amazon_asn" {default = "64512"}
variable "dxgw_tvif_vlan" {default = "900"}
variable "dxgw_tvif_BgpAsn" {default = "64513"}
variable "dxgw_tvif_BgpAuth" {default = "BGP-md5-passowrd"}
variable "dxgw_tvif_BgpCustAdd" {default = "192.168.2.1/30"}
variable "dxgw_tvif_BgpAmazonAdd" {default = "192.168.2.2/30"}

#Prefixes you want to advertise from the dxgw to on-prem router.
#Format "192.168.1.0/24, 192.168.2.0/24"
variable "dxgw_prefixes" {
  type    = set(string)
  default = ["172.22.28.0/22"]
}

##############################################
### End: Direct Connect 
##############################################

#BGP ASN assisgned to the transit gateway.
#Format "64512"
variable "tgw_amazon_asn" {default = "64514"}

### List account you want to create TGW attachments (not including the account/VPC created as part of this network module.)
# Format for each account:
#    "AnythingString" = {
#       "AccNum" = "123456789123",
#       "AccName" = "Any name for your reference ",
#   }
variable "tgw_accounts" {
    default = {
        "111111111111" = {
            "AccNum" = "111111111111",
            "AccName" = "infrastructure-dev ",
        }
        "222222222222" = {
            "AccNum" = "222222222222",
            "AccName" = "infrastructure-prod ",
        }
    }
}