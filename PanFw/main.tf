##############################################
### Module description
##############################################

# Deploys two Palo Alto firewalls, one in each availability zone
# Mgmt interface = priv_a_subnet
# Trust interface = priv_a_subnet
# Untrust interface = priv_a_subnet

##############################################
### Input variables
##############################################

variable "vpc_id" {}
variable "priv_a_subnet_id" {}
variable "priv_b_subnet_id" {}
variable "dmz_a_subnet_id" {}
variable "dmz_b_subnet_id" {}
variable "tgw_id" {}
variable "vpc_att_transit_id" {}
variable "priv_aza_routeTable_id" {}
variable "priv_azb_routeTable_id" {}
variable "priva_id" {}
variable "privb_id" {}
variable "team" {}
variable "igw_id" {}
variable "priv_a_subnet_defaultRoute_bool" {}
variable "priv_b_subnet_defaultRoute_bool" {}
variable "environment" {}

##############################################
### IAM
##############################################

resource "aws_iam_role" "FwBootstrapRole" {
  name = "FwBootstrapRole"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
      "Service": "ec2.amazonaws.com"
    },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "FwBootstrapRolePolicy" {
  name = "FwBootstrapRolePolicy"
  role = aws_iam_role.FwBootstrapRole.id

  policy = <<EOF
{
  "Version" : "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "s3:ListBucket",
      "Resource": "arn:aws:s3:::${var.S3Bucket_aza}"
    },
    {
    "Effect": "Allow",
    "Action": "s3:GetObject",
    "Resource": "arn:aws:s3:::${var.S3Bucket_aza}/*"
    },
    {
      "Effect": "Allow",
      "Action": "s3:ListBucket",
      "Resource": "arn:aws:s3:::${var.S3Bucket_azb}"
    },
    {
    "Effect": "Allow",
    "Action": "s3:GetObject",
    "Resource": "arn:aws:s3:::${var.S3Bucket_azb}/*"
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "FwBootstrapInstProfile" {
  name  = "FwBootstrapInstProfile"
  role = aws_iam_role.FwBootstrapRole.name
  path = "/"
}

#Security group applied to both trust and untust interfaces
resource "aws_security_group" "sec_pan_allowAll" {
  name        = "sec_pan_allowAll"
  description = "PAN firewalled interface - allow all security group"
  vpc_id = var.vpc_id

  ingress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port       = "0"
    to_port         = "0"
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}
#Security group applied to management interface
resource "aws_security_group" "sec_pan_mgmt" {
  name        = "sec_pan_mgmt"
  description = "PAN Mgmt interface"
  vpc_id = var.vpc_id

  ingress {
    from_port   = "443"
    to_port     = "443"
    protocol    = "6"
    cidr_blocks = ["172.16.0.0/12"]
  }
    ingress {
    from_port   = "80"
    to_port     = "80"
    protocol    = "6"
    cidr_blocks = ["172.16.0.0/12"]
  }
    ingress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "1"
    cidr_blocks = ["172.16.0.0/12"]
  }
    ingress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "6"
    cidr_blocks = ["172.16.0.0/12"]
  }
  egress {
    from_port       = "0"
    to_port         = "0"
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

########################################
### Start: PAN Firewall AZA
########################################

resource "aws_network_interface" "FwMgmtNic_aza" {
  subnet_id       = var.priv_a_subnet_id
  security_groups = [aws_security_group.sec_pan_mgmt.id]
  source_dest_check = false
  tags = {Name = "Fw-Mgmt-AZA"}
}

resource "aws_network_interface" "FwPublicNic_aza" {
  subnet_id       = var.dmz_a_subnet_id
  security_groups = [aws_security_group.sec_pan_allowAll.id]
  source_dest_check = false
  tags = {Name = "Fw-Public-AZA"}
}

resource "aws_network_interface" "FwPrivNic_aza" {
  subnet_id       = var.priv_a_subnet_id
  security_groups = [aws_security_group.sec_pan_allowAll.id]
  source_dest_check = false  
  tags = {Name = "Fw-Private-AZA"}
}

resource "aws_eip" "publicEIP_aza" {
  vpc   = true
  tags = {Name = "FwPublicIP AZA"}
}

resource "aws_eip_association" "fw_eip_publicAssoc_aza" {
  network_interface_id   = aws_network_interface.FwPublicNic_aza.id
  allocation_id = aws_eip.publicEIP_aza.id
}

resource "aws_instance" "FwInstance_aza" {
  depends_on = [
    var.priva_id,
    aws_eip_association.fw_eip_publicAssoc_aza,
    aws_iam_instance_profile.FwBootstrapInstProfile,
    aws_network_interface.FwPublicNic_aza,
    aws_network_interface.FwMgmtNic_aza,
    aws_network_interface.FwPrivNic_aza,
    aws_eip.publicEIP_aza,
    var.vpc_att_transit_id
    ]
  disable_api_termination = false
  iam_instance_profile = aws_iam_instance_profile.FwBootstrapInstProfile.name
  instance_initiated_shutdown_behavior = "stop"
  ebs_optimized = true
  ami = var.pan_ami_aza
  instance_type = var.FwInstanceSize_aza

  ebs_block_device {
    device_name = "/dev/xvda"
    volume_type = "gp2"
    delete_on_termination = true
    volume_size = 60
  }

  key_name = var.ServerKeyName
  monitoring = false

  network_interface {
    device_index = 1
    network_interface_id = aws_network_interface.FwMgmtNic_aza.id
  }

  network_interface {
    device_index = 2
    network_interface_id = aws_network_interface.FwPublicNic_aza.id
  }

  network_interface {
    device_index = 2
    network_interface_id = aws_network_interface.FwPrivNic_aza.id
  }
    lifecycle {
    ignore_changes = [ebs_block_device]
    }

  user_data = base64encode(join("", list("vmseries-bootstrap-aws-s3bucket=", var.S3Bucket_aza)))
  tags = {Name = "aws-aza-pa"}
}
data "aws_network_interface" "FwMgmtNic_aza" {
  id = aws_network_interface.FwMgmtNic_aza.id
}

########################################
### Start: PAN Firewall AZB
########################################

resource "aws_network_interface" "FwMgmtNic_azb" {
  subnet_id       = var.priv_b_subnet_id
  security_groups = [aws_security_group.sec_pan_mgmt.id]
  source_dest_check = false
  tags = {Name = "Fw-Mgmt-AZB"}
}

resource "aws_network_interface" "FwPublicNic_azb" {
  subnet_id       = var.dmz_b_subnet_id
  security_groups = [aws_security_group.sec_pan_allowAll.id]
  source_dest_check = false
  tags = {Name = "Fw-Public-AZB"}
}

resource "aws_network_interface" "FwPrivNic_azb" {
  subnet_id       = var.priv_b_subnet_id
  security_groups = [aws_security_group.sec_pan_allowAll.id]
  source_dest_check = false  
  tags = {Name = "Fw-Private-AZB"}
}

resource "aws_eip" "publicEIP_azb" {
  vpc   = true
  tags = {Name = "FwPublicIP AZB"}
}

resource "aws_eip_association" "fw_eip_publicAssoc_azb" {
  network_interface_id   = aws_network_interface.FwPublicNic_azb.id
  allocation_id = aws_eip.publicEIP_azb.id
}

resource "aws_instance" "FwInstance_azb" {
  depends_on = [
    var.privb_id,
    aws_eip_association.fw_eip_publicAssoc_azb,
    aws_iam_instance_profile.FwBootstrapInstProfile,
    aws_network_interface.FwPublicNic_azb,
    aws_network_interface.FwMgmtNic_azb,
    aws_network_interface.FwPrivNic_azb,
    aws_eip.publicEIP_azb,
    var.vpc_att_transit_id
    ]
  disable_api_termination = false
  iam_instance_profile = aws_iam_instance_profile.FwBootstrapInstProfile.name
  instance_initiated_shutdown_behavior = "stop"
  ebs_optimized = true
  ami = var.pan_ami_azb
  instance_type = var.FwInstanceSize_azb

  ebs_block_device {
    device_name = "/dev/xvda"
    volume_type = "gp2"
    delete_on_termination = true
    volume_size = 60
  }

  key_name = var.ServerKeyName
  monitoring = false

  network_interface {
    device_index = 1
    network_interface_id = aws_network_interface.FwMgmtNic_azb.id
  }

  network_interface {
    device_index = 0
    network_interface_id = aws_network_interface.FwPublicNic_azb.id
  }

  network_interface {
    device_index = 2
    network_interface_id = aws_network_interface.FwPrivNic_azb.id
  }
    lifecycle {
    ignore_changes = [ebs_block_device]
    }

  user_data = base64encode(join("", list("vmseries-bootstrap-aws-s3bucket=", var.S3Bucket_azb)))
  tags = {Name = "aws-azb-pa"}
}
data "aws_network_interface" "FwMgmtNic_azb" {
  id = aws_network_interface.FwMgmtNic_azb.id
}

####################################################################################
### End: Firewall Deployment
####################################################################################

# If variable is set to route default traffic to the firewall ENI these route tables are associated with the Priv subnets.
resource "aws_route_table" "priv_a_routeTable" {
  count = var.priv_a_subnet_defaultRoute_bool ? 0 : 1
  vpc_id = var.vpc_id
    route{
      cidr_block = "0.0.0.0/0"
      network_interface_id = aws_network_interface.FwPrivNic_aza.id
    }
  route {
    cidr_block = "10.0.0.0/8"
    gateway_id = var.tgw_id
  }
  route {
    cidr_block = "172.16.0.0/12"
    gateway_id = var.tgw_id
  }
  route {
    cidr_block = "192.168.0.0/16"
    gateway_id = var.tgw_id
  }
  tags = { Name = "Private-AZA-RouteTable"}
}
resource "aws_route_table_association" "priva" {
  count = var.priv_a_subnet_defaultRoute_bool ? 0 : 1
  subnet_id         = var.priv_a_subnet_id
  route_table_id    = aws_route_table.priv_a_routeTable.*.id[count.index]
}

resource "aws_route_table" "priv_azb_routeTable" {
  count = var.priv_b_subnet_defaultRoute_bool ? 0 : 1
  vpc_id = var.vpc_id
    route{
      cidr_block = "0.0.0.0/0"
      network_interface_id = aws_network_interface.FwPrivNic_azb.id
    }
  route {
    cidr_block = "10.0.0.0/8"
    gateway_id = var.tgw_id
  }
  route {
    cidr_block = "172.16.0.0/12"
    gateway_id = var.tgw_id
  }
  route {
    cidr_block = "192.168.0.0/16"
    gateway_id = var.tgw_id
  }
  tags = { Name = "Private-AZB-RouteTable"}
}
resource "aws_route_table_association" "privb" {
  count = var.priv_b_subnet_defaultRoute_bool ? 0 : 1
  subnet_id         = var.priv_b_subnet_id
  route_table_id    = aws_route_table.priv_azb_routeTable.*.id[count.index]
}

resource "aws_route_table" "dmz_aza_routeTable" {
  count = var.priv_a_subnet_defaultRoute_bool ? 0 : 1
  vpc_id = var.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.igw_id
  }
  tags = { Name = "DMZ-AZA-RouteTable"}
}
resource "aws_route_table_association" "dmza" {
  count = var.priv_a_subnet_defaultRoute_bool ? 0 : 1
  subnet_id      = var.dmz_a_subnet_id
  route_table_id = aws_route_table.dmz_aza_routeTable.*.id[count.index]
}

resource "aws_route_table" "dmz_azb_routeTable" {
  count = var.priv_b_subnet_defaultRoute_bool ? 0 : 1
  vpc_id = var.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.igw_id
  }
  tags = { Name = "DMZ-AZB-RouteTable"}
}
resource "aws_route_table_association" "dmzb" {
  count = var.priv_b_subnet_defaultRoute_bool ? 0 : 1
  subnet_id      = var.dmz_b_subnet_id
  route_table_id = aws_route_table.dmz_azb_routeTable.*.id[count.index]
}
#Attach network-transit VPC to TGW (VPN)

resource "aws_vpn_connection" "vpn_fw1_aza" {
  customer_gateway_id = aws_customer_gateway.cgw_aza.id
  transit_gateway_id  = var.tgw_id
  type                = aws_customer_gateway.cgw_aza.type
  tunnel1_inside_cidr = "169.254.250.4/30"
  tunnel2_inside_cidr = "169.254.250.8/30"
  tunnel1_preshared_key = var.tunnel1_preshared_key_aza
  tunnel2_preshared_key = var.tunnel2_preshared_key_aza
  tags = {Name = join("",list("vpn-aza-", var.team))}
}
resource "aws_vpn_connection" "vpn_fw1_azb" {
  customer_gateway_id = aws_customer_gateway.cgw_azb.id
  transit_gateway_id  = var.tgw_id
  type                = aws_customer_gateway.cgw_azb.type
  tunnel1_inside_cidr = "169.254.250.12/30"
  tunnel2_inside_cidr = "169.254.250.16/30"
  tunnel1_preshared_key = var.tunnel1_preshared_key_azb
  tunnel2_preshared_key = var.tunnel2_preshared_key_azb
  tags = {Name = join("",list("vpn-azb-", var.team))}
}

resource "aws_customer_gateway" "cgw_aza" {
  bgp_asn    = 65512
  type       = "ipsec.1"
  ip_address = aws_eip.publicEIP_aza.public_ip
  tags = {Name = join("",list("cgw-aza-", var.team))}
}
resource "aws_customer_gateway" "cgw_azb" {
  bgp_asn    = 65512
  type       = "ipsec.1"
  ip_address = aws_eip.publicEIP_azb.public_ip
  tags = {Name = join("",list("cgw-azb-", var.team))}
}

resource "aws_security_group" "sec_elb" {
  count = var.deploy_ingress_elb ? 1 : 0
  name        = "sec_elb"
  description = "Application load balancer security group"
  vpc_id = var.vpc_id

  ingress {
    from_port   = "0"
    to_port     = "443"
    protocol    = "6"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port       = "0"
    to_port         = "0"
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }
}

data "aws_elb_service_account" "main" {}

resource "aws_s3_bucket" "elb_logs" {
  count = var.deploy_ingress_elb ? 1 : 0
  bucket = lower(join("",list(var.team, "-elb-logs")))
  acl    = "private"
  force_destroy = true
  tags = { 
    Name  = "ingress application load balancer logs"
    Environment = var.environment  
  }
  policy = <<EOT
{
  "Id": "Policy",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${lower(join("",list(var.team, "-elb-logs")))}/ingress-elb/*",
      "Principal": {
        "AWS": [
          "${data.aws_elb_service_account.main.arn}"
        ]
      }
    }
  ]
}
EOT
}

resource "aws_lb" "elb_ext" {
  count = var.deploy_ingress_elb ? 1 : 0
  name               = join("",list("elb-", var.team))
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.sec_elb.*.id[count.index]]
  subnets            = [var.dmz_a_subnet_id, var.dmz_b_subnet_id]
  enable_deletion_protection = false
  access_logs {
    bucket  = aws_s3_bucket.elb_logs.*.bucket[count.index]
    prefix  = "ingress-elb"
    enabled = true
  }
  tags = {
    environment = var.environment
  }
}
