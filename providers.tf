provider "aws" {
  version    = "~> 3.20"
  region     = var.aws_region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}

provider "http" {
  version = "~> 2.0"
}