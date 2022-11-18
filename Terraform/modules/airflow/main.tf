# Create a role for Airflow
resource "aws_iam_role" "airflow" {
  name = "${var.env_name}-airflow-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = [
            "airflow-env.amazonaws.com",
            "airflow.amazonaws.com",
          ]
        }
      },
    ]
  })

}

# Create a policy for the Codepipeline Airflow
resource "aws_iam_role_policy" "airflow" {
  name = "${var.env_name}-airflow-execution-policy"
  role = aws_iam_role.airflow.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid      = "PublishesEnvironmentHealthMetricsToAmazonCloudWatch"
        Effect   = "Allow",
        Action   = "airflow:PublishMetrics",
        Resource = aws_mwaa_environment.airflow.arn
      },
      {
        Effect = "Deny"
        Action = "s3:ListAllMyBuckets",
        Resource = [
          "${aws_s3_bucket.dags.arn}",
          "${aws_s3_bucket.dags.arn}/*"
        ],
      },
      {
        Sid    = "AllowOnlyReadAccessToAirflowRepository"
        Effect = "Allow",
        Action = [
          "s3:GetObject*",
          "s3:GetBucket*",
          "s3:List*",
          "s3:GetAccountPublicAccessBlock"
        ],
        Resource = [
          "${aws_s3_bucket.dags.arn}",
          "${aws_s3_bucket.dags.arn}/*"
        ]
      },
      {
        Sid    = "AllowReadAndWriteForAirflowTasksToWriteToS3"
        Effect = "Allow",
        Action = [
          "s3:GetObject*",
          "s3:PutObject*",
          "s3:HeadObject"
        ],
        Resource = [
          "arn:aws:s3:::r7bi-s3-bucket/gainsight/*",
          "arn:aws:s3:::r7bi-s3-bucket/airflow_metadata_db/*",
          "arn:aws:s3:::r7bi-bi-advanced-analytics",
          "arn:aws:s3:::r7bi-bi-advanced-analytics/*"
        ]
      },
      {
        Sid    = "AllowAirflowToWriteLogsToS3"
        Effect = "Allow",
        Action = [
          "logs:CreateLogStream",
          "logs:CreateLogGroup",
          "logs:PutLogEvents",
          "logs:GetLogEvents",
          "logs:GetLogRecord",
          "logs:GetLogGroupFields",
          "logs:GetQueryResults",
          "logs:DescribeLogGroups",
        ],
        Resource = [
          "arn:aws:logs:us-east-1:206541664368:log-group:airflow-${aws_mwaa_environment.airflow.name}-*"
        ]
      },
      {
        Sid      = "AllowAirflowToCreateMetricsInCloudwarch"
        Effect   = "Allow",
        Action   = "cloudwatch:*",
        Resource = "*"
      },
      {
        Sid    = "AllowAirflowToUseSQSAsQueue"
        Effect = "Allow",
        Action = [
          "sqs:ChangeMessageVisibility",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:GetQueueUrl",
          "sqs:ReceiveMessage",
          "sqs:SendMessage"
        ],
        Resource = "arn:aws:sqs:us-east-1:*:airflow-celery-*"
      },
      {
        Sid    = "AllowSQSToUseAWSManagedKMSKeysToEncryptAirflow"
        Effect = "Allow",
        Action = [
          "kms:Decrypt",
          "kms:DescribeKey",
          "kms:GenerateDataKey*",
          "kms:Encrypt"
        ],
        NotResource = "arn:aws:kms:*:206541664368:key/*",
        Condition = {
          StringLike = {
            "kms:ViaService" = [
              "sqs.us-east-1.amazonaws.com"
            ]
          }
        }
      },
      {
        Sid    = "AllowsAirflowToAccessAirflowSecretsForBackendDB"
        Effect = "Allow",
        Action = [
          "secretsmanager:GetResourcePolicy",
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret",
          "secretsmanager:ListSecretVersionIds",
          "secretsmanager:ListSecrets"
        ],
        Resource = "arn:aws:secretsmanager:us-east-1:206541664368:secret:airflow/*",
      },
      {
        Sid    = "AllowAirflowToRunECSTasks"
        Effect = "Allow",
        Action = "ecs:RunTask",
        Resource = [
          "arn:aws:ecs:us-east-1:206541664368:task-definition/dev-runner-ecs-task-definition",
          "arn:aws:ecs:us-east-1:206541664368:task-definition/prod-runner-ecs-task-definition"
        ]
      },
      {
        Sid    = "AllowAirflowToDescribeECSClusters"
        Effect = "Allow",
        Action = "ecs:DescribeTasks",
        Resource = [
          "arn:aws:ecs:us-east-1:206541664368:task/dev-runner-ecs-cluster/*",
          "arn:aws:ecs:us-east-1:206541664368:task/prod-runner-ecs-cluster/*"
        ]
      },
      {
        Sid    = "AllowAirflowAccessToExecuteECSTasks"
        Effect = "Allow",
        Action = "iam:PassRole",
        Resource = [
          "arn:aws:iam::206541664368:role/dev-runner-task-execution-role",
          "arn:aws:iam::206541664368:role/prod-runner-task-execution-role"
        ]
      },
      {
        Sid    = "AllowAirflowToGetLogsFromECS"
        Effect = "Allow"
        Action = "logs:GetLogEvents",
        Resource = [
          "arn:aws:logs:us-east-1:206541664368:log-group:prod-runner-log:log-stream:prod-runner-log/prod-runner-container/*",
          "arn:aws:logs:us-east-1:206541664368:log-group:dev-runner-log:log-stream:dev-runner-log/dev-runner-container/*"
        ]
      },
      {
        Sid      = "AllowAirflowToChangeTheAMOFlagParameterStoreValue"
        Effect   = "Allow"
        Action   = "ssm:PutParameter",
        Resource = "arn:aws:ssm:us-east-1:206541664368:parameter/AMO_EXECUTION_FLAG"
      }
    ]
  })
}


# Create a role for the Codepipeline Airflow
resource "aws_iam_role" "airflow_codepipeline" {
  name = "${var.env_name}-airflow-codepipeline-role"

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

# Create a policy for the Codepipeline Airflow
resource "aws_iam_role_policy" "airflow_codepipeline" {
  name = "${var.env_name}-airflow-codepipeline-policy"
  role = aws_iam_role.airflow_codepipeline.id
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
        Sid = "CodepiplineLogs"
        Action = [
          "s3:Get*",
          "s3:List*",
          "s3:PutObject*",
          "s3:Create*",
          "s3:PutObjectAcl"
        ]
        Resource = [
          "${aws_s3_bucket.codepipeline.arn}",
          "${aws_s3_bucket.codepipeline.arn}/*"
        ]
        Effect = "Allow"
      },
      {
        Sid      = "MasterKeyProtectsCodebuildAndCodepipelineAndS3Bucket"
        Effect   = "Allow",
        Action   = "kms:*",
        Resource = aws_kms_key.airflow.arn
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
        Effect = "Allow",
        Action = [
          "s3:Get*",
          "s3:PutObject*",
          "s3:Create*",
          "s3:GetBucket*",
          "s3:List*"
        ],
        Resource = [
          "${aws_s3_bucket.dags.arn}",
          "${aws_s3_bucket.dags.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_s3_bucket" "dags" {
  bucket = "${var.s3_bucket_prefix}-${var.env_name}-airflow"
  acl    = "private"
}

resource "aws_s3_bucket_public_access_block" "dags" {
  bucket = aws_s3_bucket.dags.id

  block_public_acls   = true
  block_public_policy = true
}

data "aws_iam_policy_document" "kms" {
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::206541664368:root"]
    }
    principals {
      type = "Service"
      identifiers = [
        "logs.us-east-1.amazonaws.com",
        "codepipeline.amazonaws.com"
      ]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }
}


resource "aws_kms_key" "airflow" {
  description             = "${var.env_name}-airflow-kms"
  deletion_window_in_days = 7
  policy                  = data.aws_iam_policy_document.kms.json
}

resource "aws_mwaa_environment" "airflow" {
  environment_class     = "mw1.small"
  source_bucket_arn     = aws_s3_bucket.dags.arn
  dag_s3_path           = "dags/"
  requirements_s3_path  = "requirements.txt"
  execution_role_arn    = aws_iam_role.airflow.arn
  name                  = "${var.env_name}-airflow-mwaa"
  min_workers           = 5
  webserver_access_mode = "PUBLIC_ONLY"
  airflow_configuration_options = {
    "operators.allow_illegal_arguments" = "True"
    "scheduler.catchup_by_default"      = "False"

    # Use Secrets Manager as backend
    "secrets.backend"        = "airflow.providers.amazon.aws.secrets.secrets_manager.SecretsManagerBackend"
    "secrets.backend_kwargs" = "{\"connections_prefix\" : \"airflow/connections\", \"variables_prefix\" : \"airflow/variables\"}"

    # Update Airflow webserve title
    "webserver.instance_name" = var.env_name

    # Set environment variables through custom configurations
    "env_var.environment"           = var.env_name
    "env_var.cluster"               = var.runner_cluster_name
    "env_var.task_definition"       = var.runner_task_definition
    "env_var.name"                  = "${var.env_name}-runner-container"
    "env_var.securitygroups"        = var.runner_security_group_id
    "env_var.subnets"               = jsonencode(var.private_subnet_ids)
    "env_var.awslogs_group"         = var.runner_log_group
    "env_var.awslogs_stream_prefix" = "${var.runner_log_stream_prefix}/${var.env_name}-runner-container"
    "env_var.snowflake_warehouse"   = var.snowflake_warehouse

    #test
    #"env_var.container_name" = "${jsonencode(var.runner_container_name)}"
  }

  network_configuration {
    security_group_ids = [aws_security_group.airflow.id]
    subnet_ids         = var.private_subnet_ids
  }

  logging_configuration {
    dag_processing_logs {
      enabled   = true
      log_level = "INFO"
    }
    scheduler_logs {
      enabled   = true
      log_level = "INFO"
    }
    task_logs {
      enabled   = true
      log_level = "INFO"
    }
    webserver_logs {
      enabled   = true
      log_level = "INFO"
    }
    worker_logs {
      enabled   = true
      log_level = "INFO"
    }
  }

}


resource "aws_security_group" "airflow" {
  name        = "${var.env_name}-airflow-security-group"
  description = "Allow all inbound access to all instances within the MWAA environment. No limit on outbound access"
  vpc_id      = var.vpc_id

  ingress = [
    {
      description      = "Allow access from all MWAA resources"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = null
      ipv6_cidr_blocks = null
      prefix_list_ids  = null
      security_groups  = null
      self             = true
    } #,
    # {
    #   description      = "Allow access from Bastion"
    #   from_port        = 0
    #   to_port          = 0
    #   protocol         = "-1"
    #   cidr_blocks      = null
    #   ipv6_cidr_blocks = null
    #   prefix_list_ids  = null
    #   security_groups  = [var.bastion_security_group_id]
    #   self             = false
    # }
  ]

  egress = [
    {
      description      = "No limit on outbound access"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = null
      prefix_list_ids  = null
      security_groups  = null
      self             = null
    }
  ]

}

resource "aws_codebuild_project" "airflow" {
  name           = "${var.env_name}-airflow-codebuild"
  build_timeout  = 75
  service_role   = "arn:aws:iam::206541664368:role/AWSCodebuildExecutionRole"
  badge_enabled  = false
  queued_timeout = 480
  encryption_key = aws_kms_key.airflow.arn
  artifacts {
    type                = "CODEPIPELINE"
    name                = "${var.env_name}-airflow-codepipeline"
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

resource "aws_s3_bucket" "codepipeline" {
  bucket = "${var.s3_bucket_prefix}-${var.env_name}-airflow-codepipeline"
  acl    = "private"
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.airflow.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

resource "aws_codepipeline" "airflow" {
  name     = "${var.env_name}-airflow-codepipeline"
  role_arn = aws_iam_role.airflow_codepipeline.arn

  artifact_store {
    location = aws_s3_bucket.codepipeline.bucket
    type     = "S3"

    encryption_key {
      id   = aws_kms_key.airflow.arn
      type = "KMS"
    }
  }

  stage {
    name = "Source"

    action {
      name             = "Airflow"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["SourceArtifact_Airflow"]

      configuration = {
        ConnectionArn        = "arn:aws:codestar-connections:us-east-1:206541664368:connection/7523bfa3-db55-466c-8c33-b4da6706db38"
        FullRepositoryId     = "rapid7/Airflow_Repository"
        BranchName           = var.github_branch
        OutputArtifactFormat = "CODE_ZIP"
      }
    }

    action {
      name             = "Snowflake_Data_Warehouse"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["SourceArtifact_Snowflake"]

      configuration = {
        ConnectionArn        = "arn:aws:codestar-connections:us-east-1:206541664368:connection/7523bfa3-db55-466c-8c33-b4da6706db38"
        FullRepositoryId     = "rapid7/Snowflake_Data_Warehouse"
        BranchName           = "master"
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
      input_artifacts  = ["SourceArtifact_Airflow", "SourceArtifact_Snowflake"]
      output_artifacts = ["BuildArtifact"]
      version          = "1"
      configuration = {
        ProjectName   = aws_codebuild_project.airflow.arn
        PrimarySource = "SourceArtifact_Airflow"
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "DeployS3"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "S3"
      input_artifacts = ["BuildArtifact"]
      version         = "1"
      run_order       = 1
      region          = "us-east-1"
      namespace       = "DeployVariables"

      configuration = {
        BucketName = aws_s3_bucket.dags.bucket
        Extract    = "true"
      }
    }
  }
}
