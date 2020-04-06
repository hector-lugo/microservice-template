# Input variable definitions

variable "prefix" {
  description = "Prefix to attach to resources"
  type        = string
  default     = "xpresso"
}

variable "vpc_id" {
  description = "Id of the VPC we should be createing the database in"
  type = string
}

variable "subnets_ids" {
  description = "Choose which subnets the database should be deployed to"
  type = list(string)
}

variable "database_sg" {
  description = "Database security group"
  type = string
}

variable "instance_type" {
  description = "Type of instance to use for the database"
  type = string
  default = "db.t2.micro"
}

variable "project_namespace" {
  description = "Namespace for parameters"
  type = string
  default = "xpresso"
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