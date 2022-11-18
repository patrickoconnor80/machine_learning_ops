variable "env_name" {
  description = "Environment used as a prefix to all resource names(i.e. prod, dev)"
  type        = string
  default     = "prod"
}

variable "github_branch" {
  description = "Github branch to use for Production"
  type        = string
  default     = "master"
}

variable "s3_bucket_prefix" {
  description = "Standard S3 bucket prefix"
  type        = string
  default     = "r7bi"
}

variable "snowflake_warehouse" {
  description = "Snowflake Warehouse"
  type        = string
  default     = "ETL_WH"
}

variable "cidr_blocks" {
  description = "Identifying the ingress traffic to the runner ecs cluster"
  type        = string
  default     = "10.0.0.0/16"
}

variable "private_subnet_cidrs" {
  description = "Private subnets CIDRs"
  type        = list(string)
  default     = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "public_subnet_cidrs" {
  description = "Public subnets CIDRs that allow the runner to interact with AWS services(ECR, SSM etc.)"
  type        = list(string)
  default     = ["10.0.128.0/24", "10.0.129.0/24"]
}
