variable "vpc_id" {
  type        = string
  description = "id of the vpc to deploy the prefect agent into"
}

variable "private_subnet_ids" {
  type        = list(string)
  description = "ids of the subnets to assign to the autoscaling group"
}