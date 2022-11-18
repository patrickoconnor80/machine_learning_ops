# module "bastion" {
#   source = "../modules/bastion"

#   env_name                  = var.env_name
#   vpc_id                    = module.network.vpc_id
#   public_subnet_ids         = module.network.public_subnet_ids
#   airflow_security_group_id = module.airflow.security_group_id

# }
