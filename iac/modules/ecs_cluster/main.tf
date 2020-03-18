resource "aws_ecs_cluster" "ecs_cluster" {
  name = format("%s_cluster", var.prefix)

  tags = merge(
    {
      "Name" = format("%s_cluster", var.prefix)
    },
    var.tags
  )
}

resource "aws_autoscaling_group" "cluster_asg" {
  name = format("%s_cluster_asg", var.prefix)

  max_size = var.cluster_size
  min_size = var.cluster_size
  desired_capacity = var.cluster_size

  vpc_zone_identifier = var.subnets_ids

  launch_configuration = aws_launch_configuration.cluster_launch_config.id
}

resource "aws_autoscaling_policy" "cluster_asg_scale_up_policy" {
  adjustment_type        = "ChangeInCapacity"
  autoscaling_group_name = aws_autoscaling_group.cluster_asg.name
  name                   = format("%s_cluster_asg_scale_up_policy", var.prefix)
  policy_type            = "StepScaling"

  step_adjustment {
    scaling_adjustment          = 1
    metric_interval_upper_bound = "25"
  }

  step_adjustment {
    scaling_adjustment          = 2
    metric_interval_lower_bound = "25"
  }

  depends_on = [aws_autoscaling_group.cluster_asg]
}

resource "aws_autoscaling_policy" "cluster_asg_scale_down_policy" {
  name                   =  format("%s_cluster_asg_scale_up_policy", var.prefix)
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.cluster_asg.name

  depends_on = [aws_autoscaling_group.cluster_asg]
}

data "template_file" "ecs_instance_user_data" {
  template = file("${path.module}/scripts/user_data.sh")

  vars = {
    cluster_name = aws_ecs_cluster.ecs_cluster.name
  }
}

data "aws_ami" "amazon_linux_ecs" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-*-amazon-ecs-optimized"]
  }

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }
}

resource "aws_launch_configuration" "cluster_launch_config" {
  name = format("%s_launch_config", var.prefix)

  image_id = data.aws_ami.amazon_linux_ecs.id
  instance_type = var.instance_type

  security_groups = [var.cluster_sg]

  iam_instance_profile = aws_iam_instance_profile.ecs_instance_profile.name

  user_data = data.template_file.ecs_instance_user_data.rendered

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_iam_role" "cluster_iam_role" {
  path = "/"

  assume_role_policy = file("${path.module}/iam_policies/cluster_iam_role_policy_document.json")

  tags = merge(
    {
      "Name" = format("%s_cluster_role", var.prefix)
    },
    var.tags
  )
}

data "aws_iam_policy" "iam_mng_policy_ec2_for_ssm" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM"
}

data "aws_iam_policy" "iam_mng_policy_cloudwatch_agent" {
  arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy_attachment" "iam_mng_policy_ec2_for_ssm_attachement" {
  role       = aws_iam_role.cluster_iam_role.name
  policy_arn = data.aws_iam_policy.iam_mng_policy_ec2_for_ssm.arn
}

resource "aws_iam_role_policy_attachment" "iam_mng_policy_cloudwatch_agent_attachement" {
  role       = aws_iam_role.cluster_iam_role.name
  policy_arn = data.aws_iam_policy.iam_mng_policy_cloudwatch_agent.arn
}

resource "aws_iam_policy" "iam_policy_ecs_service" {
  policy = file("${path.module}/iam_policies/iam_policy_ecs_service.json")
}

resource "aws_iam_role_policy_attachment" "iam_policy_ecs_service_attachement" {
  role       = aws_iam_role.cluster_iam_role.name
  policy_arn = aws_iam_policy.iam_policy_ecs_service.arn
}

resource "aws_iam_instance_profile" "ecs_instance_profile" {
  path = "/"
  role = aws_iam_role.cluster_iam_role.name
}

resource "aws_iam_role" "ecs_service_asg_role" {
  path = "/"
  assume_role_policy = file("${path.module}/iam_policies/ecs_service_asg_role_policy_document.json")

  tags = merge(
    {
      "Name" = format("%s_ecs_service_asg_role", var.prefix)
    },
    var.tags
  )
}

resource "aws_iam_policy" "iam_policy_ecs_service_autoscaling" {
  policy = file("${path.module}/iam_policies/iam_policy_ecs_service_autoscaling.json")
}

resource "aws_iam_role_policy_attachment" "iam_policy_ecs_service_autoscaling_attachement" {
  role       = aws_iam_role.ecs_service_asg_role.name
  policy_arn = aws_iam_policy.iam_policy_ecs_service_autoscaling.arn
}

/*
data "template_file" "cluster_cloudwatch_config_content" {
  template = file("${path.module}/cloudwatch_config/cluster_cloudwatch_config.json")
  vars = {
    cluster_name = aws_ecs_cluster.ecs_cluster.name
  }
}

resource "aws_ssm_parameter" "cluster_cloudwatch_config" {
  name = format("%s_cluster_cloudwatch_config", var.prefix)
  type = "String"
  value = data.template_file.cluster_cloudwatch_config_content
}*/
