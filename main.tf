data "aws_caller_identity" "current" {}

data "template_file" "s3_bucket_policy" {
  template = file("${path.module}/s3-bucket-iam-policy.json")

  vars = {
    s3_email_bucket = var.s3_email_bucket
    aws_account_id  = data.aws_caller_identity.current.account_id
  }
}

data "template_file" "lambda_policy" {
  template = file("${path.module}/lambda-iam-policy.json")

  vars = {
    s3_email_bucket = var.s3_email_bucket
    aws_account_id  = data.aws_caller_identity.current.account_id
    aws_region  = var.aws_region
  }
}

resource "aws_s3_bucket" "s3_email_bucket" {
  bucket = var.s3_email_bucket
  acl    = "private"

  tags = {
    Name        = var.app_name
    Environment = var.app_env
  }

  policy = data.template_file.s3_bucket_policy.rendered
}

resource "aws_iam_policy" "lambda" {
  name        = "app-${var.app_name}-${var.app_env}-lambda"
  description = "Write to logs, read s3 objects and send ses emails"

  policy = data.template_file.lambda_policy.rendered
}

resource "aws_iam_role" "lambda" {
  name               = "${var.app_name}-${var.app_env}-lambda-role"
  description        = "Write to logs, read s3 objects and send ses emails"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "lambda.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_iam_policy_attachment" {
    role = aws_iam_role.lambda.name
    policy_arn = aws_iam_policy.lambda.arn
}

resource "aws_lambda_function" "ses_redirecter" {
  s3_bucket        = var.function_bucket_name
  s3_key           = var.function_zip_name
  source_code_hash = var.function_base64sha256
  function_name    = var.function_name
  handler          = "${var.function_file_name}.lambda_handler"
  memory_size      = var.memory_size
  role             = aws_iam_role.lambda.arn
  runtime          = "python3.7"
  timeout          = var.timeout

  environment {
    variables = {
      MailRecipient = var.email_recipient
      MailSender    = var.email_sender
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

data "aws_route53_zone" "selected" {
  name  = "${var.domain}."
  count = 1
}

resource "aws_ses_domain_identity" "domain" {
  domain = var.ses_domain
}

resource "aws_route53_record" "mx" {
  zone_id = data.aws_route53_zone.selected[0].zone_id
  name    = var.ses_domain
  type    = "MX"
  ttl     = "600"
  records = ["10 inbound-smtp.${var.aws_region}.amazonaws.com"]

  count = 1
}

resource "aws_route53_record" "verification" {
  zone_id = data.aws_route53_zone.selected[0].zone_id
  name    = "_amazonses.${var.ses_domain}"
  type    = "TXT"
  ttl     = "600"
  records = [aws_ses_domain_identity.domain.verification_token]

  count = 1
}

data "template_file" "instructions" {
  template = file("${path.module}/instructions.md")

  vars = {
    aws_region = var.aws_region
    s3_email_bucket = var.s3_email_bucket
    s3_email_prefix = var.s3_email_prefix
    function_name = var.function_name
  }

}