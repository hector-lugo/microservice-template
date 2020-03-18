output "ecs_host_sg" {
  description = "A reference to the security group for ECS hosts"
  value = aws_security_group.ecs_host_sg.id
}

output "load_balance_sg" {
  description = "A reference to the security group for load balancers"
  value = aws_security_group.load_balancer_sg.id
}