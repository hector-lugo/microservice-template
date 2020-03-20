# Input variable definitions

variable "deployment_type" {
  description = "The type of deployment"
  type        = string
  default     = "ecs"
}

variable "tf_state_bucket" {
  description = "Bucket to use as a backend for terraform"
  type        = string
  default     = "xpresso-terraform"
}

variable "tf_state_object" {
  description = "Object containing the terraform state for the project"
  type        = string
  default     = "microservice_template/terraform.tfstate"
}