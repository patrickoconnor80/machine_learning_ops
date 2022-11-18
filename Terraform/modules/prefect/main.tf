module "prefect" {
  source  = "aws-ia/agent-ec2/prefect"
  version = "1.0.2"


  deploy_network = false
  vpc_id         = var.vpc_id
  subnet_ids     = var.private_subnet_ids

}

resource "aws_s3_bucket" "prefect" {
  bucket_prefix = "prefect-block"

}