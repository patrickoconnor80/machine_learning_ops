resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.image_name}-TaskExecutionRole"
 
  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}

resource "aws_iam_role" "ecs_task_role" {
  name = "${var.image_name}-TaskRole"
 
  assume_role_policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Action": "sts:AssumeRole",
     "Principal": {
       "Service": "ecs-tasks.amazonaws.com"
     },
     "Effect": "Allow",
     "Sid": ""
   }
 ]
}
EOF
}

resource "aws_iam_policy" "prefect_ecs_task" {
  name        = "prefect-task-execution-policy"
  description = "Access to HG Insights role, S3 r7bi buckets, ECS ECR/Log actions KMS, Secrets Manager, Parameter Store"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AccessSecretsManagerSnowflakeCredentials"
        Effect = "Allow"
        Action = [
          "secretsmanager:Describe*",
          "secretsmanager:Get*",
          "secretsmanager:List*"
        ]
        Resource = [
          "arn:aws:secretsmanager:us-east-1:948065143262:secret:PREFECT_API_KEY-qsOajt",
          "arn:aws:secretsmanager:us-east-1:948065143262:secret:PREFECT_API_URL-XEPLCZ"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "prefect" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.prefect_ecs_task.arn
}

resource "aws_ecs_cluster" "prefect" {
  name = "prefect-cluster"
}
 
resource "aws_iam_role_policy_attachment" "ecs-task-execution-role-policy-attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "task_s3" {
  role       = "${aws_iam_role.ecs_task_role.name}"
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

resource "aws_ecr_repository" "ecr" {
  name                 = "mlops"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }

}

resource "aws_s3_bucket" "prefect" {
  bucket = "prefect-orion-storage-8"
}

resource "aws_cloudwatch_log_group" "prefect" {
  name = "mlops"
}

resource "aws_ecs_service" "prefect" {
  name                = "prefect-ecs-service"
  cluster             = aws_ecs_cluster.prefect.id
  task_definition     = aws_ecs_task_definition.prefect.arn
  desired_count       = 1
  scheduling_strategy = "REPLICA"
  launch_type         = "FARGATE"
  platform_version    = "LATEST"
  network_configuration {
    subnets          = var.private_subnet_ids
    assign_public_ip = false
  }
}

resource "aws_ecs_task_definition" "prefect" {
    family                   = "${var.image_name}-TaskDefinition"
    task_role_arn            = "arn:aws:iam::${var.aws_account_id}:role/${var.image_name}-TaskRole"
    execution_role_arn       = "arn:aws:iam::${var.aws_account_id}:role/${var.image_name}-TaskExecutionRole"
    network_mode             = "awsvpc"
    cpu                      = "${var.cpu}"
    memory                   = "${var.memory}"
    requires_compatibilities = ["FARGATE"]
    container_definitions    = jsonencode([
        {
          image = "${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${var.image_name}:latest",
          name = "flow"
          essential = true
          cpu = "${var.cpu}"
          entryPoint = ["bash", "-c"],
          command = ["prefect", "agent", "start", "-q", "mlops"]
          secrets = [
            {
              name : "PREFECT_API_KEY"
              valueFrom : "arn:aws:secretsmanager:us-east-1:948065143262:secret:PREFECT_API_KEY-qsOajt"
            },
            {
              name : "PREFECT_API_URL"
              valueFrom : "arn:aws:secretsmanager:us-east-1:948065143262:secret:PREFECT_API_URL-XEPLCZ"
            }
          ],
          environment = [
            {
              name : "PREFECT_LOGGING_LEVEL"
              value : "INFO"
            },
            {
              name : "AWS_RETRY_MODE"
              value : "adaptive"
            },
            {
              name : "AWS_MAX_ATTEMPTS"
              value : "10"
            }
          ],
          logConfiguration = {
            logDriver = "awslogs"
            options = {
              awslogs-group         = "mlops",
              awslogs-region        = "us-east-1",
              awslogs-stream-prefix = "mlops"
            }
          }
        }
    ])
}