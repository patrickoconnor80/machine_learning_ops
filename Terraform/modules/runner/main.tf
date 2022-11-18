# Create a role for the Task Execution Runner
resource "aws_iam_role" "runner_task_execution" {
  name = "${var.env_name}-runner-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
    ]
  })

}

# Create a policy for the Task Execution Runner
resource "aws_iam_policy" "runner_task_execution" {
  name        = "${var.env_name}-runner-task-execution-policy"
  description = "Access to HG Insights role, S3 r7bi buckets, ECS ECR/Log actions KMS, Secrets Manager, Parameter Store"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid      = "AssumeTheHGInsightsRoleToGetDataFromA3rdParty"
        Effect   = "Allow"
        Action   = "sts:AssumeRole"
        Resource = "arn:aws:iam::998468983355:role/delivery-role-0df6f8eb-c58f-4f5a-b04d-192ac2b671b5"
      },
      {
        Sid    = "RunECSTasks"
        Effect = "Allow"
        Action = [
          "ecs:RunTask"
        ],
        Resource = aws_ecs_task_definition.runner.arn
      },
      {
        Sid      = "DescribeTasksInTheECSCluster"
        Effect   = "Allow"
        Action   = "ecs:DescribeTasks"
        Resource = "${aws_ecs_cluster.runner.arn}/*"
      },
      {
        Sid    = "TS3OutputForEachTask"
        Effect = "Allow"
        Action = [
          "s3:Get*",
          "s3:List*",
          "s3:PutObject*",
          "s3:Create*",
          "s3:PutObjectAcl"
        ]
        Resource = [
          "arn:aws:s3:::r7bi-hginsights-automated",
          "arn:aws:s3:::r7bi-hginsights-automated/*",
          "arn:aws:s3:::r7bi-s3-bucket",
          "arn:aws:s3:::r7bi-s3-bucket/*",
          "arn:aws:s3:::r7bi-snowflake-prod-daily-backup",
          "arn:aws:s3:::r7bi-snowflake-prod-daily-backup/*",
          "arn:aws:s3:::r7bi-cloudability-bucket",
          "arn:aws:s3:::r7bi-cloudability-bucket/*",
          "arn:aws:s3:::r7bi-bi-advanced-analytics",
          "arn:aws:s3:::r7bi-bi-advanced-analytics/*"
        ]
      },
      {
        Sid    = "ECRContainerCreationAndLogging"
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      },
      {
        Sid      = "MasterKeyProtectsECSClusterAndCodebuildAndCodepipelineAndS3bucket"
        Effect   = "Allow"
        Action   = "kms:Decrypt"
        Resource = aws_kms_key.runner.arn
      },
      {
        Sid    = "AccessSecretsManagerSnowflakeCredentials"
        Effect = "Allow"
        Action = [
          "secretsmanager:Describe*",
          "secretsmanager:Get*",
          "secretsmanager:List*"
        ]
        Resource = [
          "arn:aws:secretsmanager:us-east-1:206541664368:secret:SNOWFLAKEAIRFLOWUSERNAME-u96oIT",
          "arn:aws:secretsmanager:us-east-1:206541664368:secret:SNOWFLAKEAIRFLOWUSERPASSWORD-B0Loyn",
          "arn:aws:secretsmanager:us-east-1:206541664368:secret:SNOWFLAKEAIRFLOWUSERACCOUNT-oAT178",
          "arn:aws:secretsmanager:us-east-1:206541664368:secret:CLOUDABILITY_API_KEY-gd5dRb",
          "arn:aws:secretsmanager:us-east-1:206541664368:secret:NETSUITECLIENTKEY-u9s61Y",
          "arn:aws:secretsmanager:us-east-1:206541664368:secret:NETSUITECLIENTSECRET-LzHuPQ",
          "arn:aws:secretsmanager:us-east-1:206541664368:secret:NETSUITEOWNERKEY-e5wUrn",
          "arn:aws:secretsmanager:us-east-1:206541664368:secret:NETSUITEOWNERSECRET-UwCZ4l",
          "arn:aws:secretsmanager:us-east-1:206541664368:secret:NETSUITEACCOUNTKEY-givovk",
          "arn:aws:secretsmanager:us-east-1:206541664368:secret:ALLOCADIAUSERNAME-hyetvy",
          "arn:aws:secretsmanager:us-east-1:206541664368:secret:ALLOCADIAPASSWORD-PNxEDM",
          "arn:aws:secretsmanager:us-east-1:206541664368:secret:ALLOCADIAINSTANCE-z0Bcnr",
          "arn:aws:secretsmanager:us-east-1:206541664368:secret:SOLARWINDSAPIKEY-6UxFsM",
          "arn:aws:secretsmanager:us-east-1:206541664368:secret:ADAPTIVEINSIGHTSLOGIN-j5WPKF",
          "arn:aws:secretsmanager:us-east-1:206541664368:secret:ADAPTIVEINSIGHTSPASSWORD-EYRZnd",
          "arn:aws:secretsmanager:us-east-1:206541664368:secret:SALESFORCEUSERNAME-o6SS86",
          "arn:aws:secretsmanager:us-east-1:206541664368:secret:SALESFORCEPASSWORD-gxL6ur",
          "arn:aws:secretsmanager:us-east-1:206541664368:secret:SALESFORCEORGANIZATION-VXmFLw",
          "arn:aws:secretsmanager:us-east-1:206541664368:secret:SALESFORCESECURITYTOKEN-8ZPUnZ"
        ]
      }
    ]
  })

}

#Attach the Task Execution Runner policy to the Task Execution Runner role
resource "aws_iam_role_policy_attachment" "runner_task_execution" {
  role       = aws_iam_role.runner_task_execution.name
  policy_arn = aws_iam_policy.runner_task_execution.arn
}


# Create a role for the Codepipeline Runner
resource "aws_iam_role" "runner_codepipeline" {
  name = "${var.env_name}-runner-codepipeline-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "codepipeline.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

}

# Create a policy for the Codepipeline Runner
resource "aws_iam_role_policy" "runner_codepipeline" {
  name = "${var.env_name}-runner-codepipeline-policy"
  #description = "Access to CodeCommit, CodeDeploy, codestart-connections, ecs, s3,"
  role = aws_iam_role.runner_codepipeline.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = "iam:PassRole"
        Resource = "*"
        Effect   = "Allow"
        Condition = {
          StringEqualsIfExists = {
            "iam:PassedToService" = [
              "cloudformation.amazonaws.com",
              "elasticbeanstalk.amazonaws.com",
              "ec2.amazonaws.com",
              "ecs-tasks.amazonaws.com"
            ]
          }
        }
      },
      {
        Sid = "GithubWebhook"
        Action = [
          "codecommit:CancelUploadArchive",
          "codecommit:GetBranch",
          "codecommit:GetCommit",
          "codecommit:GetUploadArchiveStatus",
          "codecommit:UploadArchive"
        ]
        Resource = "*"
        Effect   = "Allow"
      },
      {
        Sid = "DeployContainer"
        Action = [
          "codedeploy:CreateDeployment",
          "codedeploy:GetApplication",
          "codedeploy:GetApplicationRevision",
          "codedeploy:GetDeployment",
          "codedeploy:GetDeploymentConfig",
          "codedeploy:RegisterApplicationRevision"
        ]
        Resource = "*"
        Effect   = "Allow"
      },
      {
        Sid      = "CodestarConnectionToRapid7Github"
        Action   = "codestar-connections:UseConnection"
        Resource = "*"
        Effect   = "Allow"
      },
      {
        Sid      = "AllECS"
        Action   = "ecs:*"
        Resource = "*"
        Effect   = "Allow"
      },
      {
        Sid = "CodepiplineLogs"
        Action = [
          "s3:Get*",
          "s3:List*",
          "s3:PutObject*",
          "s3:Create*",
          "s3:PutObjectAcl"
        ]
        Resource = [
          "${aws_s3_bucket.runner.arn}",
          "${aws_s3_bucket.runner.arn}/*"
        ]
        Effect = "Allow"
      },
      {
        Sid      = "MasterKeyProtectsECSClusterAndCodebuildAndCodepipelineAndS3Bucket"
        Effect   = "Allow",
        Action   = "kms:*",
        Resource = aws_kms_key.runner.arn
      },
      {
        Sid = "Codebuild"
        Action = [
          "codebuild:BatchGetBuilds",
          "codebuild:StartBuild"
        ],
        Resource = "*",
        Effect   = "Allow"
      },
      {
        Sid    = "ECRImages"
        Effect = "Allow",
        Action = [
          "ecr:DescribeImages"
        ]
        Resource = "*"
      },
      {
        Sid    = "SecretsManagerDockerPassword"
        Effect = "Allow",
        Action = [
          "secretsmanager:Describe*",
          "secretsmanager:Get*",
          "secretsmanager:List*"
        ]
        Resource = [
          "arn:aws:secretsmanager:us-east-1:206541664368:secret:DOCKERPASSWORD-wSUe1i"
        ]
      }
    ]
  })
}

data "aws_iam_policy_document" "kms" {
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::206541664368:root"]
    }
    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }
}


resource "aws_kms_key" "runner" {
  description             = "${var.env_name}-runner-kms"
  deletion_window_in_days = 7
  policy                  = data.aws_iam_policy_document.kms.json
}


resource "aws_security_group" "runner" {
  name        = "${var.env_name}-runner-security-group"
  description = "Allow inbound access from Airflow Worker. No limit on outbound access"
  vpc_id      = var.vpc_id

  ingress = [
    {
      description      = "Allow access from Airflow Worker"
      from_port        = 8793
      to_port          = 8793
      protocol         = "tcp"
      cidr_blocks      = var.private_subnet_cidrs
      ipv6_cidr_blocks = null
      prefix_list_ids  = null
      #TODO - Change cidr_blocks to null and attach the security group for the Airflow Worker
      #At the time of writing this, Airflow and ECS were on separate VPCs
      security_groups = null
      self            = null
    }
  ]

  egress = [
    {
      description      = "No limit on outbound access"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      prefix_list_ids  = null
      security_groups  = null
      self             = null
    }
  ]

}

resource "aws_cloudwatch_log_group" "runner" {
  name = "${var.env_name}-runner-log"
}

resource "aws_ecs_cluster" "runner" {
  name = "${var.env_name}-runner-ecs-cluster"

  configuration {
    execute_command_configuration {
      kms_key_id = aws_kms_key.runner.arn
      logging    = "OVERRIDE"

      log_configuration {
        cloud_watch_encryption_enabled = true
        cloud_watch_log_group_name     = aws_cloudwatch_log_group.runner.name
      }
    }
  }

}

resource "aws_ecs_task_definition" "runner" {
  family             = "${var.env_name}-runner-ecs-task-definition"
  execution_role_arn = aws_iam_role.runner_task_execution.arn
  task_role_arn      = aws_iam_role.runner_task_execution.arn
  cpu                = 2048
  memory             = 4096
  container_definitions = jsonencode([
    {
      name      = "${var.env_name}-runner-container"
      image     = "206541664368.dkr.ecr.us-east-1.amazonaws.com/${var.env_name}-runner-ecr:latest"
      essential = true
      cpu       = 0
      secrets = [
        {
          name : "SNOWFLAKEAIRFLOWUSERNAME"
          valueFrom : "arn:aws:secretsmanager:us-east-1:206541664368:secret:SNOWFLAKEAIRFLOWUSERNAME-u96oIT"
        },
        {
          name : "SNOWFLAKEAIRFLOWUSERPASSWORD"
          valueFrom : "arn:aws:secretsmanager:us-east-1:206541664368:secret:SNOWFLAKEAIRFLOWUSERPASSWORD-B0Loyn"
        },
        {
          name : "SNOWFLAKEAIRFLOWUSERACCOUNT"
          valueFrom : "arn:aws:secretsmanager:us-east-1:206541664368:secret:SNOWFLAKEAIRFLOWUSERACCOUNT-oAT178"
        },
        {
          name : "CLOUDABILITY_API_KEY"
          valueFrom : "arn:aws:secretsmanager:us-east-1:206541664368:secret:CLOUDABILITY_API_KEY-gd5dRb"
        },
        {
          name : "NETSUITEACCOUNTKEY"
          valueFrom : "arn:aws:secretsmanager:us-east-1:206541664368:secret:NETSUITEACCOUNTKEY-givovk"
        },
        {
          name : "NETSUITEOWNERSECRET"
          valueFrom : "arn:aws:secretsmanager:us-east-1:206541664368:secret:NETSUITEOWNERSECRET-UwCZ4l"
        },
        {
          name : "NETSUITEOWNERKEY"
          valueFrom : "arn:aws:secretsmanager:us-east-1:206541664368:secret:NETSUITEOWNERKEY-e5wUrn"
        },
        {
          name : "NETSUITECLIENTSECRET"
          valueFrom : "arn:aws:secretsmanager:us-east-1:206541664368:secret:NETSUITECLIENTSECRET-LzHuPQ"
        },
        {
          name : "NETSUITECLIENTKEY"
          valueFrom : "arn:aws:secretsmanager:us-east-1:206541664368:secret:NETSUITECLIENTKEY-u9s61Y"
        },
        {
          name : "SOLARWINDSAPIKEY"
          valueFrom : "arn:aws:secretsmanager:us-east-1:206541664368:secret:SOLARWINDSAPIKEY-6UxFsM"
        },
        {
          name : "ALLOCADIAUSERNAME"
          valueFrom : "arn:aws:secretsmanager:us-east-1:206541664368:secret:ALLOCADIAUSERNAME-hyetvy"
        },
        {
          name : "ALLOCADIAPASSWORD"
          valueFrom : "arn:aws:secretsmanager:us-east-1:206541664368:secret:ALLOCADIAPASSWORD-PNxEDM"
        },
        {
          name : "ADAPTIVEINSIGHTSLOGIN"
          valueFrom : "arn:aws:secretsmanager:us-east-1:206541664368:secret:ADAPTIVEINSIGHTSLOGIN-j5WPKF"
        },
        {
          name : "ADAPTIVEINSIGHTSPASSWORD"
          valueFrom : "arn:aws:secretsmanager:us-east-1:206541664368:secret:ADAPTIVEINSIGHTSPASSWORD-EYRZnd"
        },
        {
          name : "SALESFORCEUSERNAME"
          valueFrom : "arn:aws:secretsmanager:us-east-1:206541664368:secret:SALESFORCEUSERNAME-o6SS86"
        },
        {
          name : "SALESFORCEPASSWORD"
          valueFrom : "arn:aws:secretsmanager:us-east-1:206541664368:secret:SALESFORCEPASSWORD-gxL6ur"
        },
        {
          name : "SALESFORCEORGANIZATION"
          valueFrom : "arn:aws:secretsmanager:us-east-1:206541664368:secret:SALESFORCEORGANIZATION-VXmFLw"
        },
        {
          name : "SALESFORCESECURITYTOKEN"
          valueFrom : "arn:aws:secretsmanager:us-east-1:206541664368:secret:SALESFORCESECURITYTOKEN-8ZPUnZ"
        }
      ],
      environment = [
        {
          name : "TASK"
          value : "snowflake_dynamic_views"
        }
      ]
      portMappings = [
        {
          protocol      = "tcp"
          containerPort = 8793
          hostPort      = 8793
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.runner.name,
          awslogs-region        = "us-east-1",
          awslogs-stream-prefix = aws_cloudwatch_log_group.runner.name
        }
      }
    }
  ])
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
}

resource "aws_ecs_service" "runner" {
  name                = "${var.env_name}-runner-ecs-service"
  cluster             = aws_ecs_cluster.runner.id
  task_definition     = aws_ecs_task_definition.runner.arn
  desired_count       = 0
  scheduling_strategy = "REPLICA"
  launch_type         = "FARGATE"
  platform_version    = "LATEST"
  network_configuration {
    security_groups  = [aws_security_group.runner.id]
    subnets          = var.private_subnet_ids
    assign_public_ip = false
  }
}


resource "aws_ecr_repository" "runner" {
  name                 = "${var.env_name}-runner-ecr"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }

}


resource "aws_codebuild_project" "runner" {
  name           = "${var.env_name}-runner-codebuild"
  build_timeout  = 75
  service_role   = "arn:aws:iam::206541664368:role/AWSCodebuildExecutionRole"
  badge_enabled  = false
  queued_timeout = 480
  encryption_key = aws_kms_key.runner.arn
  artifacts {
    type                = "CODEPIPELINE"
    name                = "${var.env_name}-runner-codepipeline"
    packaging           = "NONE"
    encryption_disabled = false
  }
  source {
    type         = "CODEPIPELINE"
    buildspec    = "infra/buildspec.yml"
    insecure_ssl = false
  }
  cache {
    type = "NO_CACHE"
  }
  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:4.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    privileged_mode             = true
    environment_variable {
      name  = "DOCKERPASSWORD"
      value = "arn:aws:secretsmanager:us-east-1:206541664368:secret:DOCKERPASSWORD-wSUe1i"
      type  = "SECRETS_MANAGER"
    }
    environment_variable {
      name  = "ENVIRONMENT"
      value = var.env_name
    }
  }
}

resource "aws_s3_bucket" "runner" {
  bucket = "${var.env_name}-runner-codepipeline"
  acl    = "private"
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.runner.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

resource "aws_codepipeline" "runner" {
  name     = "${var.env_name}-runner-codepipeline"
  role_arn = aws_iam_role.runner_codepipeline.arn

  artifact_store {
    location = aws_s3_bucket.runner.bucket
    type     = "S3"

    encryption_key {
      id   = aws_kms_key.runner.arn
      type = "KMS"
    }
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["SourceArtifact"]

      configuration = {
        ConnectionArn        = "arn:aws:codestar-connections:us-east-1:206541664368:connection/7523bfa3-db55-466c-8c33-b4da6706db38"
        FullRepositoryId     = "rapid7/ECS_Data_Engineering_Repository"
        BranchName           = var.github_branch
        OutputArtifactFormat = "CODE_ZIP"
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["SourceArtifact"]
      output_artifacts = ["BuildArtifact"]
      version          = "1"
      configuration = {
        ProjectName = aws_codebuild_project.runner.arn
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "DeployECS"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      input_artifacts = ["BuildArtifact"]
      version         = "1"
      run_order       = 1
      region          = "us-east-1"
      namespace       = "DeployVariables"
      configuration = {
        ClusterName = aws_ecs_cluster.runner.name
        FileName    = "imagedefinitions.json"
        ServiceName = aws_ecs_service.runner.name
      }
    }
  }
}
