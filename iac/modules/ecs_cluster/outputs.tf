output "cluster_name" {
  description = "A reference to the ECS cluster name"
  value = aws_ecs_cluster.ecs_cluster.name
}

output "ecs_service_autoscaling_role_name" {
  description = "A reference to ECS service auto scaling role name"
  value = aws_iam_role.ecs_service_asg_role.name
}

output "ecs_asg_id" {
  description = "A reference to ECS AutoScaling Group id"
  value = aws_autoscaling_group.cluster_asg.id
}