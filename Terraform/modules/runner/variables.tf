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

variable "cidr_blocks" {
  description = "Identifying the ingress traffic to the runner ecs cluster"
  type        = string
  default     = ""
}

variable "vpc_id" {
  description = "VPC id"
  type        = string
  default     = ""
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs"
  type        = list(string)
  default     = []
}

variable "private_subnet_ids" {
  description = "Private subnet IDs"
  type        = list(string)
  default     = []
}
