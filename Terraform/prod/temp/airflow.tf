module "airflow" {
  source = "../modules/airflow"

  env_name                 = var.env_name
  github_branch            = var.github_branch
  s3_bucket_prefix         = var.s3_bucket_prefix
  snowflake_warehouse      = var.snowflake_warehouse
  vpc_id                   = module.network.vpc_id
  private_subnet_ids       = module.network.private_subnet_ids
  runner_security_group_id = module.runner.security_group_id
  runner_cluster_name      = module.runner.cluster_name
  runner_task_definition   = module.runner.task_definition
  runner_container_name    = module.runner.container_name
  runner_log_stream_prefix = module.runner.log_stream_prefix
  runner_log_group         = module.runner.log_group
  # bastion_security_group_id = module.bastion.security_group_id

}
