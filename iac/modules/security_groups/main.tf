resource "aws_security_group" "ecs_host_sg" {
  name = format("%s_ecs_host_sg", var.prefix)
  description = "Access to the ECS hosts and the tasks/containers that run on them"

  vpc_id = var.vpc_id

  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    security_groups = [aws_security_group.load_balancer_sg.id]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  tags = merge(
    {
      "Name" = format("%s_ecs_host_sg", var.prefix)
    },
    var.tags
  )
}

resource "aws_security_group" "load_balancer_sg" {
  name = format("%s_load_balancer_sg", var.prefix)
  description = "Access to the load balancer that sits in front of ECS"

  vpc_id = var.vpc_id

  ingress {
    from_port = 80
    protocol = "tcp"
    to_port = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 443
    protocol = "tcp"
    to_port = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  tags = merge(
    {
      "Name" = format("%s_load_balancer_sg", var.prefix)
    },
    var.tags
  )
}

resource "aws_security_group" "database_sg" {
  name   = format("%s_database_security_group", var.prefix)
  description = "Access to the database from the microservice"

  vpc_id = var.vpc_id

  ingress {
    from_port = 3306
    protocol = "tcp"
    to_port = 3306
    security_groups = [aws_security_group.ecs_host_sg.id]
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [
      "0.0.0.0/0",
    ]
  }

  tags = merge(
  {
    "Name" = format("%s_database_sg", var.prefix)
  },
  var.tags
  )
}