data "aws_ssm_parameter" "database_name" {
  name = format("/%s/database/name", var.prefix)
}

data "aws_ssm_parameter" "database_username" {
  name = format("/%s/database/username", var.prefix)
}

data "aws_ssm_parameter" "database_password" {
  name = format("/%s/database/password", var.prefix)
}

resource "aws_db_subnet_group" "subnet_group" {
  name = format("%s_database_subnet_group", var.prefix)
  subnet_ids = var.subnets_ids
}

resource "aws_db_instance" "database_instance" {
  identifier = format("%s-database", var.prefix)
  allocated_storage           = 20
  storage_type                = "gp2"
  engine                      = "mysql"
  engine_version              = "5.7"
  instance_class              = var.instance_type
  name                        = data.aws_ssm_parameter.database_name.value
  username                    = data.aws_ssm_parameter.database_username.value
  password                    = data.aws_ssm_parameter.database_password.value
  parameter_group_name        = "default.mysql5.7"
  db_subnet_group_name        = aws_db_subnet_group.subnet_group.name
  vpc_security_group_ids      = [var.database_sg]
  final_snapshot_identifier = format("%s-database-backup", var.prefix)
}

resource "aws_ssm_parameter" "database_address" {
  name = format("/%s/database/host", var.prefix)
  type = "String"
  value = aws_db_instance.database_instance.address
}

resource "aws_ssm_parameter" "database_port" {
  name = format("/%s/database/port", var.prefix)
  type = "String"
  value = aws_db_instance.database_instance.port
}