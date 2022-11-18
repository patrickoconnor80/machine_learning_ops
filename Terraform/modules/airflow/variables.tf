variable "github_branch" {
  description = "The branch name codepipeline will use in the github webhook"
  type        = string
  default     = ""
}

variable "env_name" {
  description = "Environment used as a prefix to all resource names(i.e. prod, dev)"
  type        = string
  default     = ""
}

variable "s3_bucket_prefix" {
  description = "Standard S3 bucket prefix"
  type        = string
  default     = ""
}

variable "snowflake_warehouse" {
  description = "Snowflake Warehouse"
  type        = string
  default     = ""
}

variable "vpc_id" {
  description = "VPC id"
  type        = string
  default     = ""
}

variable "private_subnet_ids" {
  description = "Private subnets"
  type        = list(string)
  default     = []
}

variable "bastion_security_group_id" {
  description = "The Security Gropu ID of the Bastion"
  type        = string
  default     = ""
}

variable "runner_security_group_id" {
  description = "The Security Group ID of the Runner"
  type        = string
  default     = ""
}

variable "runner_subnet_ids" {
  description = "The Subnet IDs of the Runner"
  type        = string
  default     = ""
}

variable "runner_cluster_name" {
  description = "The Cluster name of the Runner"
  type        = string
  default     = ""
}

variable "runner_task_definition" {
  description = "The Task Definition name of the Runner"
  type        = string
  default     = ""
}

variable "runner_container_name" {
  description = "The Container name of the Runner"
  type        = string
  default     = ""
}

variable "runner_log_stream_prefix" {
  description = "The Log Stream Prefix of the Runner"
  type        = string
  default     = ""
}

variable "runner_log_group" {
  description = "The Log Group name of the Runner"
  type        = string
  default     = ""
}
