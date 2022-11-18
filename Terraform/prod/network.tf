module "network" {
  source = "../modules/network"

  env_name = var.env_name

  cidr_blocks          = var.cidr_blocks
  availability_zones   = ["us-east-1a", "us-east-1b", "us-east-1d"]
  private_subnet_cidrs = var.private_subnet_cidrs
  public_subnet_cidrs  = var.public_subnet_cidrs

}
