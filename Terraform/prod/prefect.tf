module "prefect" {
  source = "../modules/prefect"

  aws_region = "us-east-1"
  aws_account_id = "948065143262"
  image_name = "mlops"
  cpu = 2048
  memory = 4096
  private_subnet_ids = module.network.private_subnet_ids

}
