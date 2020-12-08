# ses-redirecter-terraform
Terraform workspace to create an AWS SES-S3-Lambda email redirecter environment.

Inspired by [this](https://aws.amazon.com/blogs/messaging-and-targeting/forward-incoming-email-to-an-external-destination/)

Ensure the python code for the lambda exists as a zip file in "${var.function_bucket_name}/${var.function_zip_name}""
