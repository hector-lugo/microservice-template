data "aws_region" "current" {}

# Terraform state will be stored in S3
terraform {
  backend "s3" {
    bucket = var.tf_state_bucket
    key    = var.tf_state_object
    region = data.aws_region.current.id
  }
}

module "vpc" {
  source = "./modules/vpc"
}

module "security_groups" {
  source = "./modules/security_groups"
  vpc_id = module.vpc.vpc_id
}

module "load_balancers" {
  source = "./modules/load_balancers"
  vpc_id = module.vpc.vpc_id
  subnets_ids = module.vpc.public_subnets
  security_group_id = module.security_groups.load_balance_sg
}

module "ecs_cluster" {
  source = "./modules/ecs_cluster"
  vpc_id = module.vpc.vpc_id
  subnets_ids = module.vpc.private_subnets
  instance_type = "t2.micro"
  cluster_sg = module.security_groups.ecs_host_sg
  enabled = var.deployment_type == "ecs" ? true : false
}

module "service" {
  source = "./modules/service"
  esc_cluster = module.ecs_cluster.cluster_name
  load_balancer = module.load_balancers.load_balancer_arn
  load_balancer_target_group_arn = module.load_balancers.load_balancer_target_group_arn
  vpc_id = module.vpc.vpc_id
  enabled = var.deployment_type == "ecs" ? true : false
}
