resource "aws_s3_bucket" "default" {
  bucket_prefix = var.unique_name

  tags = merge(
    {
      Name = "${var.unique_name}-default-artifact-root"
    },
  )
}

resource "aws_iam_role_policy" "default_bucket" {
  name_prefix = "access_to_default_bucket"
  role        = aws_iam_role.ecs_task.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:HeadBucket",
        ]
        Resource = concat(
          aws_s3_bucket.default.*.arn,
          var.artifact_buckets_mlflow_will_read,
        )
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucketMultipartUploads",
          "s3:GetBucketTagging",
          "s3:GetObjectVersionTagging",
          "s3:ReplicateTags",
          "s3:PutObjectVersionTagging",
          "s3:ListMultipartUploadParts",
          "s3:PutObject",
          "s3:GetObject",
          "s3:GetObjectAcl",
          "s3:GetObject",
          "s3:AbortMultipartUpload",
          "s3:PutBucketTagging",
          "s3:GetObjectVersionAcl",
          "s3:GetObjectTagging",
          "s3:PutObjectTagging",
          "s3:GetObjectVersion",
        ]
        Resource = [
          for bucket in concat(aws_s3_bucket.default.*.arn, var.artifact_buckets_mlflow_will_read) :
          "${bucket}/*"
        ]
      },
    ]
  })
}
