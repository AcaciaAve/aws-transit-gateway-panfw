# Define VPC CIDR. 
#Format: (192.168.1.0/24)
variable "vpc_cidr" {default = "172.22.28.0/22"}

#Variables used in tags and descriptions. 
#Format: Any string value
variable "team" {
    default = "infrastructure"
    description = "Team name used in tags and descriptions"
}
variable "environment" {
    default = "testing"
    description = "Environment description Staging/Production used in tags and descriptions"
}
/*
**Important:** 
The Palo Alto firewalls management interface must have reachability to the internet before bootstrapping is able to complete. The firewall will install init-cfg.txt giving a very limited amount of initial configuration however bootstrap.xml occurs 
after licensing so the management interface must be connected to a subnet/route table with accessibility to the internet by using a NAT gateway or assigning a public IP address in a DMZ subnet to the management interface.
This will impact you if you use a private Direct Connect and intend to access the firewall via a private IP address and/or intend to configure the firewall from Panorama. If this is the case you will need to use a multi-step process for bootstrapping:

1. Deploy the firewall management interface into an internal subnet with a default route via a NAT gateway (Set the below variables to "false")
2. After bootstrapping occurs (following the initial deployment), modify the default route in the internal route table to point towards the transit gateway. (Set the below variables to "true")
   The NAT gateway is no longer required so will be removed by setting the below variable to true.

**Instructions:** 
Set to true: Private subnet will use nat gateway for default route and internet traffic. The private subnet route table default route points to nat instance.
Set to false: Private subnet will use the transit gateway for its next hop then route to the firewall for internet access.
*/
variable "priv_a_subnet_defaultRoute" {
    description = "true = nat gateway, modifies Private subnet route table"
    type        = bool
    default     = true
}
variable "priv_b_subnet_defaultRoute" {
    description = "true = nat gateway, modifies Private subnet route table"
    type        = bool
    default     = true
}

### Describe the four subnets, modify the SubCidr, SubAz and SubDesc
#        "priv_a_subnet" = {
#            SubName = "priv_a_subnet",         ()
#            SubCidr = "172.22.28.0/24",        (CIDR for subnet, division of VPC CIDR)
#            SubAz = "ap-southeast-2a",         (Subnet availability zone) 
#            SubDesc = "Private-A-Subnet        (Description to be displayed on resource")
#        }
variable "subnets" {
    default = {
        "priv_a_subnet" = {
            SubCidr = "172.22.28.0/24",
            SubAz = "ap-southeast-2a",
            SubDesc = "Private-AZA-Subnet"
        }
        "priv_b_subnet" = {
            SubCidr = "172.22.29.0/24",
            SubAz = "ap-southeast-2b"
            SubDesc = "Private-AZB-Subnet"
        }
        "dmz_a_subnet" = {
            SubCidr = "172.22.30.0/24",
            SubAz = "ap-southeast-2a"
            SubDesc = "DMZ-AZA-Subnet"
        }
        "dmz_b_subnet" = {
            SubCidr = "172.22.31.0/24",
            SubAz = "ap-southeast-2b"
            SubDesc = "DMZ-AZB-Subnet"
        }
    }
}