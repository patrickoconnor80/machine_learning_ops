module "mlflow" {
  source  = "../modules/mlflow"

  unique_name                       = "mlflow-${var.env_name}"
  availability_zones = module.network.availability_zones
  vpc_id                            = module.network.vpc_id
  load_balancer_subnet_ids          = module.network.public_subnet_ids
  load_balancer_ingress_cidr_blocks = ["10.0.128.0/22"]
  service_subnet_ids                = module.network.private_subnet_ids
  database_subnet_ids               = module.network.private_subnet_ids
  database_password_secret_arn      = "arn:aws:secretsmanager:us-east-1:948065143262:secret:mlflow-rds-password-Gs6aSZ"
}