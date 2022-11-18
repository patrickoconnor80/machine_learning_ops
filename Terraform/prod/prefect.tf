module "prefect" {
  source = "../modules/prefect"

  vpc_id          = module.network.vpc_id
  private_subnet_ids = module.network.private_subnet_ids

}
