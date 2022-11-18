data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_secretsmanager_secret" "db_password" {
  arn = var.database_password_secret_arn
}

data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = data.aws_secretsmanager_secret.db_password.id
}

resource "aws_iam_role_policy" "db_secrets" {
  name = "${var.unique_name}-read-db-pass-secret"
  role = aws_iam_role.ecs_task.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetResourcePolicy",
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecretVersionIds",
        ]
        Resource = [
          data.aws_secretsmanager_secret_version.db_password.arn,
        ]
      },
    ]
  })
}

resource "aws_db_subnet_group" "rds" {
  name       = "${var.unique_name}-rds"
  subnet_ids = var.database_subnet_ids
}

resource "aws_security_group" "rds" {
  name   = "${var.unique_name}-rds"
  vpc_id = var.vpc_id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_service.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_rds_cluster" "backend_store" {
  cluster_identifier_prefix = var.unique_name
  engine                    = "aurora-mysql"
  engine_version            = "5.7.mysql_aurora.2.08.3"
  engine_mode               = "serverless"
  port                      = 3306
  db_subnet_group_name      = aws_db_subnet_group.rds.name
  vpc_security_group_ids    = [aws_security_group.rds.id]
  availability_zones        = var.availability_zones
  master_username           = "ecs_task"
  database_name             = "mlflow"
  skip_final_snapshot       = true
  final_snapshot_identifier = var.unique_name
  master_password           = data.aws_secretsmanager_secret_version.db_password.secret_string
  backup_retention_period   = 14

  scaling_configuration {
    auto_pause               = true
    max_capacity             = var.database_max_capacity
    min_capacity             = var.database_min_capacity
    seconds_until_auto_pause = 300
    timeout_action           = "ForceApplyCapacityChange"
  }

}
