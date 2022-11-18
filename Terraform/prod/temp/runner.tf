module "runner" {
  source = "../modules/runner"

  env_name = var.env_name

  github_branch        = "master"
  cidr_blocks          = var.cidr_blocks
  vpc_id               = module.network.vpc_id
  private_subnet_cidrs = var.private_subnet_cidrs
  private_subnet_ids   = module.network.private_subnet_ids

}
