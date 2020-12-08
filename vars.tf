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
  type = string
}

variable "function_name" {
  default = "ses-redirecter-lambda"
}

variable "function_bucket_name" {
  type = string
}

variable "function_zip_name" {
  default = "ses-redirecter-lambda.zip"
}

variable "memory_size" {
  default = "128"
}

variable "s3_email_bucket" {
  type = string
}

variable "s3_email_prefix" {
  default = "emails"
}

variable "timeout" {
  default = "120"
}
