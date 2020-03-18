resource "aws_alb" "load_balancer" {
  name = format("%s-load-balancer", var.prefix)
  subnets = var.subnets_ids
  security_groups = [var.security_group_id]

  tags = merge(
    {
      "Name" = format("%s_load_balancer", var.prefix)
    },
    var.tags
  )
}

resource "aws_alb_listener" "load_balancer_listener" {
  load_balancer_arn = aws_alb.load_balancer.arn
  port = 80
  default_action {
    type = "forward"
    target_group_arn = aws_alb_target_group.load_balancer_tg.arn
  }
}

resource "aws_alb_target_group" "load_balancer_tg" {
  name = format("%s-load-balancer-tg", var.prefix)
  vpc_id = var.vpc_id
  port = 80
  protocol = "HTTP"

  depends_on = [aws_alb.load_balancer]

  tags = merge(
    {
      "Name" = format("%s_load_balancer_tg", var.prefix)
    },
    var.tags
  )
}