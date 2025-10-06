provider "aws" {
  region = "us-east-1"
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda_kms_creator_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role" "firehose_role" {
  name = "firehose_to_s3_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = "firehose.amazonaws.com"
        },
        Effect = "Allow",
      }
    ]
  })
}


resource "aws_iam_role_policy" "firehose_policy" {
  role = aws_iam_role.firehose_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:AbortMultipartUpload",
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads",
          "s3:PutObject",
          "s3:PutObjectAcl"
        ],
        Resource = [
          aws_s3_bucket.lambda_logs.arn,
          "${aws_s3_bucket.lambda_logs.arn}/*"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  name = "lambda_kms_creator_policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "kms:CreateKey",
          "kms:CreateAlias",
          "kms:DescribeKey"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy" "firehose_logs_policy" {
  role = aws_iam_role.firehose_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "logs:PutSubscriptionFilter",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      }
    ]
  })
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda"
  output_path = "${path.module}/lambda.zip"
}

resource "aws_lambda_function" "create_kms_key" {
  function_name = "create_kms_key_lambda"
  handler       = "create_kms_key.lambda_handler"
  runtime       = "python3.9"
  role          = aws_iam_role.lambda_role.arn
  filename      = data.archive_file.lambda_zip.output_path
  timeout       = 10
}

resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "lambda_logs" {
  bucket = "lambda-logs-${random_id.suffix.hex}"

  lifecycle {
    prevent_destroy = true
  }
}
resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.create_kms_key.function_name}"
  retention_in_days = 14
}

resource "aws_kinesis_firehose_delivery_stream" "cw_to_s3" {
  name        = "lambda-logs-to-s3"
  destination = "s3"

extended_s3_configuration {
  role_arn           = aws_iam_role.firehose_role.arn
  bucket_arn         = aws_s3_bucket.lambda_logs.arn
  buffering_size     = 5
  compression_format = "GZIP"
}

  depends_on = [aws_s3_bucket.lambda_logs]
}

resource "aws_cloudwatch_log_subscription_filter" "lambda_to_s3" {
  name            = "lambda_to_s3_subscription"
  log_group_name  = aws_cloudwatch_log_group.lambda_log_group.name
  filter_pattern  = ""
  destination_arn = aws_kinesis_firehose_delivery_stream.cw_to_s3.arn
  depends_on      = [aws_lambda_function.create_kms_key]
}

output "lambda_name" {
  value = aws_lambda_function.create_kms_key.function_name
}

output "logs_bucket" {
  value = aws_s3_bucket.lambda_logs.bucket
}
