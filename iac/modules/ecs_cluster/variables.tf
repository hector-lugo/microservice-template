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

variable "cluster_size" {
  description = "How many ECS hosts should be deployed"
  type = number
  default = 2
}

variable "instance_type" {
  description = "Which instance type should be used to build the ECS cluster"
  type = string
  default = "t2.micro"
}

variable "cluster_sg" {
  description = "Select the Security Group to use for the ECS cluster hosts"
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