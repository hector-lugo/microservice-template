resource "aws_sns_topic" "lifecycle_hooks_sns_topic" {
  display_name = format("%s_lifecycle_hooks_sns_topic", var.prefix)

  tags = merge(
  {
    "Name" = format("%s_lifecycle_hooks_sns_topic", var.prefix)
  },
  var.tags
  )
}

resource "aws_sns_topic_subscription" "lifecycle_hooks_sns_topic_subscription" {
  protocol = "lambda"
  topic_arn = aws_sns_topic.lifecycle_hooks_sns_topic.arn
  endpoint = aws_lambda_function.lambda_lifecycle_handler.arn
}

resource "aws_autoscaling_lifecycle_hook" "instance_terminating_hook" {
  name = format("%s_instance_terminating_hook", var.prefix)
  autoscaling_group_name = var.ecs_cluster_asg_name
  lifecycle_transition = "autoscaling:EC2_INSTANCE_TERMINATING"
  notification_target_arn = aws_sns_topic.lifecycle_hooks_sns_topic.arn
  heartbeat_timeout = "900"
  default_result = "ABANDON"

  role_arn = aws_iam_role.autoscaling_notification_role.arn

  depends_on = [
    aws_sns_topic.lifecycle_hooks_sns_topic]
}

resource "aws_iam_role" "autoscaling_notification_role" {
  assume_role_policy = file("./iam_policies/autoscaling_notification_assume_role_policy_document.json")

  tags = merge(
  {
    "Name" = format("%s_autoscaling_notification_role", var.prefix)
  },
  var.tags
  )
}

data "aws_iam_policy" "iam_mng_policy_autoscaling_notification_access" {
  arn = "arn:aws:iam::aws:policy/service-role/AutoScalingNotificationAccessRoley"
}

resource "aws_iam_role_policy_attachment" "iam_mng_policy_autoscaling_notification_access_attachement" {
  role = aws_iam_role.autoscaling_notification_role.name
  policy_arn = data.aws_iam_policy.iam_mng_policy_autoscaling_notification_access.arn
}

resource "aws_iam_role" "lambda_excecution_role" {
  assume_role_policy = file("./iam_policies/lambda_excecution_assume_role_policy_document.json")

  tags = merge(
  {
    "Name" = format("%s_lambda_excecution_role", var.prefix)
  },
  var.tags
  )
}

resource "aws_iam_policy" "iam_policy_lifecycle_hooks_lambda" {
  policy = file("./iam_policies/iam_policy_lifecycle_hooks_lambda.json")

  tags = merge(
    {
      "Name" = format("%s_iam_policy_lifecycle_hooks_lambda", var.prefix)
    },
    var.tags
  )
}

resource "aws_iam_role_policy_attachment" "iam_policy_lifecycle_hooks_lambda_policy_attachement" {
  role = aws_iam_role.lambda_excecution_role.name
  policy_arn = aws_iam_policy.iam_policy_lifecycle_hooks_lambda.arn
}

resource "aws_iam_role_policy_attachment" "iam_mng_policy__lambda_autoscaling_notification_access_attachement" {
  role = aws_iam_role.lambda_excecution_role.name
  policy_arn = data.aws_iam_policy.iam_mng_policy_autoscaling_notification_access.arn
}

resource "aws_lambda_permission" "lambda_invoke_permission" {
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_lifecycle_handler.function_name
  principal = "sns.amazonaws.com"
  source_arn = aws_sns_topic.lifecycle_hooks_sns_topic.arn
}

resource "aws_lambda_function" "lambda_lifecycle_handler" {
  function_name = format("%s_lambda_lifecycle_handler", var.prefix)
  handler = "index.lambda_handler"
  role = aws_iam_role.lambda_excecution_role.arn
  runtime = "python3.6"
  timeout = 10

  filename = "lambda_lifecycle_handler.zip"
  source_code_hash = filebase64sha256("lambda_lifecycle_handler.py.zip")

  environment {
    variables = {
      foo = "bar"
    }
  }

  tags = merge(
  {
    "Name" = format("%s_lifecycle_hooks_sns_topic", var.prefix)
  },
  var.tags
  )
}