# Input variable definitions

variable "prefix" {
  description = "Prefix to attach to resources"
  type        = string
  default     = "xpresso"
}

variable "vpc_id" {
  description = "Id of the VPC we should be createing the Security Groups for"
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