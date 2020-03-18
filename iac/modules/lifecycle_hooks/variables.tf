# Input variable definitions

variable "prefix" {
  description = "Prefix to attach to resources"
  type        = string
  default     = "xpresso"
}

variable "ecs_cluster" {
  description = "Name of ECS Cluster"
  type = string
}

variable "ecs_cluster_asg_name" {
  description = "Name of Auto Scaling Group"
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