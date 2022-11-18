module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "3.7.0"

  cidr = var.cidr_blocks
  name = "${var.env_name}-vpc"

  azs             = var.availability_zones
  private_subnets = var.private_subnet_cidrs
  public_subnets  = var.public_subnet_cidrs

  enable_nat_gateway     = true
  single_nat_gateway     = true
  one_nat_gateway_per_az = false

  enable_vpn_gateway = false

  enable_dns_hostnames = true
  enable_dns_support   = true
}
