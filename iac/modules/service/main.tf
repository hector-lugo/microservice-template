resource "aws_ecs_service" "ecs_service" {
  name = format("%s_ecs_service", var.prefix)
  cluster = var.esc_cluster
  iam_role = aws_iam_role.service_role.name
  desired_count = var.desired_count
  task_definition = aws_ecs_task_definition.ecs_service_task_definition.arn

  load_balancer {
    container_name = "demo-service"
    container_port = 80
    target_group_arn = var.load_balancer_target_group_arn
  }

  depends_on = [aws_iam_role.service_role]
}

data "aws_region" "current" {}

data "template_file" "demo_service_task_definition" {
  template = file("${path.module}/task_definitions/demo_service.json")
  vars = {
    cloudwatch_logs_group = aws_cloudwatch_log_group.log_group.name
    aws_region = data.aws_region.current.id
    ecs_image = var.ecs_image
  }
}

resource "aws_ecs_task_definition" "ecs_service_task_definition" {
  family = "demo-service"
  container_definitions = data.template_file.demo_service_task_definition.rendered

  tags = merge(
    {
      "Name" = format("%s_demo_service_task_definition", var.prefix)
    },
    var.tags
  )
}

resource "aws_cloudwatch_log_group" "log_group" {
  name = format("%s_log_group", var.prefix)
  retention_in_days = 14

  tags = merge(
    {
      "Name" = format("%s_log_group", var.prefix)
    },
    var.tags
  )
}

resource "aws_iam_role" "service_role" {
  assume_role_policy = file("${path.module}/iam_policies/ecs_service_assume_role_policy_document.json")
  path = "/"

  tags = merge(
    {
      "Name" = format("%s_service_role", var.prefix)
    },
    var.tags
  )
}

resource "aws_iam_policy" "iam_policy_ecs_service_policy" {
  name = format("%s_ecs_service_policy", var.prefix)
  policy = file("${path.module}/iam_policies/ecs_service_policy.json")
}

resource "aws_iam_role_policy_attachment" "iam_policy_ecs_service_policy_attachement" {
  role = aws_iam_role.service_role.name
  policy_arn = aws_iam_policy.iam_policy_ecs_service_policy.arn
}