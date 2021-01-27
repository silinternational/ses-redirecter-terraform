variable "app_env" {
  type = string
}

variable "app_name" {
  type = string
}

variable "aws_region" {
  default = "us-east-1"
}

variable "aws_access_key" {
}

variable "aws_secret_key" {
}

variable "email_recipient" {
  description = "email address to which all emails will be forwarded"
  type = string
}

variable "email_sender" {
  description = "email address from which the emails are forwarded"
  type = string
}

variable "function_name" {
  description = "Don't include the file type (e.g. *.py)"
  default = "ses-redirecter-lambda"
}

variable "function_base64sha256" {
  description = "$ terraform console ...  > base64sha256(\"ses-redirecter-lambda-function.py.zip\")"
  type = string
}

variable "function_bucket_name" {
  description = "name of the s3 bucket which holds the lambda function zip file (must already exist)"
  type = string
  default = "gtis-ses-redirecter-lambda"
}

variable "function_file_name" {
  description = "name of the file (but not the file type) which holds the lambda function (must already exist)"
  default = "ses-redirecter-lambda"
}

variable "function_zip_name" {
  description = "name of the zip file which holds the lambda function (must already exist)"
  default = "ses-redirecter-lambda.py.zip"
}

variable "memory_size" {
  default = "128"
}

variable "s3_email_bucket" {
  description = "must pass AWS rules on bucket names"
  type = string
}

variable "s3_email_prefix" {
  description = "the 'path' of the s3 bucket which will hold the incoming emails"
  default = "emails"
}

variable "ses_domain" {
  description = "example: ses.our.org"
}

variable "timeout" {
  default = "120"
}

variable "use_cloudflare_dns" {
  default     = 0
  description = "1 = use cloudflare dns, 0 = do not use cloudflare dns"
}