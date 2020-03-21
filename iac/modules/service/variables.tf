# Input variable definitions

variable "prefix" {
  description = "Prefix to attach to resources"
  type        = string
  default     = "xpresso"
}

variable "ecs_image" {
  description = "The image to be used for service's task definition"
  type        = string
  default     = "httpd"
}

variable "vpc_id" {
  description = "Id of the VPC we should be createing the load balancers in"
  type = string
}

variable "esc_cluster" {
  description = "Please provide the ECS Cluster ID that this service should run on"
  type = string
}

variable "desired_count" {
  description = "How many instances of this task should we run across our cluster"
  type = number
  default = 2
}

variable "load_balancer" {
  description = "The Application Load Balancer listener to register with"
  type = string
}

variable "load_balancer_target_group_arn" {
  description = "The ARN of the Target Group for the Application Load Balancer"
  type = string
}

variable "service_path" {
  description = "The path to register with the Application Load Balancer"
  type = string
  default = "/ping"
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