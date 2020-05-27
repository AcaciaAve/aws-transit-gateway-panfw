

# Set to true if you want to crate an ingress application load balancer for public http/https traffic inbound to the firewalls.
variable "deploy_ingress_elb" {
    description = "Deploy ALB for load balancing of inbound services"
    type = bool
    default = true
}
# Create a key pair (AWS console --> EC2 -->  Key Pairs)
variable "ServerKeyName" {
    description = "The AWS key pair used to connect to the firewall instance after creation"
    default = "key-pair-name"
}
#General variables, enter the required string for each value.
variable "FwInstanceSize_aza" {
    description = "EC2 instance side to use for VM-Series firewall"
    default = "m4.xlarge"
}
variable "pan_ami_aza" {
    description = "Firewall AMI base image version"
    default = "ami-00d61562"
}
variable "FwInstanceSize_azb" {
    description = "EC2 instance side to use for VM-Series firewall"
    default = "m4.xlarge"
}
variable "pan_ami_azb" {
    description = "Firewall AMI base image version"
    default = "ami-00d61562"
}
variable "S3Bucket_aza" {
    description = "S3 bucket setup to bootstrap"
    default = "s3-bucket-name-aza"
}
variable "S3Bucket_azb" {
    description = "S3 bucket setup to bootstrap"
    default = "s3-bucket-name-azb"
}
variable "tunnel1_preshared_key_aza" {
    description = "Tunnel preshared-key for IPsec VPN between TGW and firewalls."
    default = "PleaseChange"
}
variable "tunnel2_preshared_key_aza" {
    description = "Tunnel preshared-key for IPsec VPN between TGW and firewalls."
    default = "PleaseChange"
}
variable "tunnel1_preshared_key_azb" {
    description = "Tunnel preshared-key for IPsec VPN between TGW and firewalls."
    default = "PleaseChange"
}
variable "tunnel2_preshared_key_azb" {
    description = "Tunnel preshared-key for IPsec VPN between TGW and firewalls."
    default = "PleaseChange"
}