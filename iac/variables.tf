# Input variable definitions

variable "deployment_type" {
  description = "The type of deployment"
  type        = string
  default     = "ecs"
}

variable "ecs_image" {
  description = "The image to be used for the cluster"
  type        = string
  default     = "httpd"
}