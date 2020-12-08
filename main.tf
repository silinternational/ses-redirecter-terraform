data "aws_caller_identity" "current" {}

data "http" "function-checksum" {
  url = "https://${var.function_bucket_name}.s3.amazonaws.com/${var.function_zip_name}.sum"
}

resource "aws_s3_bucket" "s3_email_bucket" {
  bucket = var.s3_email_bucket
  acl    = "private"

  tags = {
    Name        = var.app_name
    Environment = var.app_env
  }

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
        {
            "Sid": "AllowSESPuts",
            "Effect": "Allow",
            "Principal": {
                "Service": "ses.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::${var.s3_email_bucket}/*",
            "Condition": {
                "StringEquals": {
                    "aws:Referer": data.aws_caller_identity.current.account_id
                }
            }
        }
  ]
}
EOF
}

resource "aws_iam_role" "iam_for_lambda" {
  name        = "${var.app_name}-${var.app_env}-lambda-function-role"
  description = "Write to logs, read s3 objects and send ses emails"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Sid": "VisualEditor0",
        "Effect": "Allow",
        "Action": [
            "logs:CreateLogStream",
            "logs:CreateLogGroup",
            "logs:PutLogEvents"
        ],
        "Resource": "*"
    },
    {
        "Sid": "VisualEditor1",
        "Effect": "Allow",
        "Action": [
            "s3:GetObject",
            "ses:SendRawEmail"
        ],
        "Resource": [
            "arn:aws:s3:::${var.s3_email_bucket}/*",
            "${data.aws_caller_identity.current.arn}/*"
        ]
    }
  ]
}
EOF

}

resource "aws_lambda_function" "ses_redirecter" {
  s3_bucket        = var.function_bucket_name
  s3_key           = var.function_zip_name
  source_code_hash = data.http.function-checksum.body
  function_name    = var.function_name
  handler          = "lambda_handler"
  memory_size      = var.memory_size
  role             = aws_iam_role.iam_for_lambda.arn
  runtime          = "python3.7"
  timeout          = var.timeout

  environment {
    variables = {
      MailRecipient = var.email_recipient
      MailS3Bucket  = var.s3_email_bucket
      MailS3Prefix  = var.s3_email_prefix
      Region        = var.aws_region
    }
  }

  tags = {
    app_name = var.app_name
    app_env  = var.app_env
  }
}

