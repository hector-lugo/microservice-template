# Input variable definitions

variable "prefix" {
  description = "Prefix to attach to resources"
  type        = string
  default     = "xpresso"
}

variable "vpc_id" {
  description = "Id of the VPC we should be createing the load balancers in"
  type = string
}

variable "subnets_ids" {
  description = "Choose which subnets the Application Load Balancer should be deployed to"
  type = list(string)
}

variable "security_group_id" {
  description = "Select the Security Group to apply to the Application Load Balancer"
  type = string
}

variable "tags" {
  description = "Tags to apply to resources created"
  type        = map(string)
  default     = {
    Terraform   = "true"
    Environment = "dev"
    Project = "xpresso"
  }
}