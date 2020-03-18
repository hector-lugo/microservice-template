output "load_balancer" {
  description = "A reference to the Application Load Balancer"
  value = aws_alb.load_balancer.id
}

output "load_balancer_arn" {
  description = "A reference to the Application Load Balancer arn"
  value = aws_alb.load_balancer.arn
}

output "load_balancer_dns" {
  description = "The DNS of the ALB"
  value = aws_alb.load_balancer.dns_name
}

output "load_balancer_listener" {
  description = "A reference to a port 80 listener"
  value = aws_alb_listener.load_balancer_listener.id
}

output "load_balancer_listener_arn" {
  description = "ARN of a port 80 listener"
  value = aws_alb_listener.load_balancer_listener.arn
}

output "load_balancer_target_group_arn" {
  description = "ARN of the target group for the load balancer"
  value = aws_alb_target_group.load_balancer_tg.arn
}