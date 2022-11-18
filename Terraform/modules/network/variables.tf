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

variable "availability_zones" {
  description = "Availabilty zones"
  type        = list(string)
  default     = []
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDRs"
  type        = list(string)
  default     = []
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs"
  type        = list(string)
  default     = []
}
