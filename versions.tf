
terraform {
  required_version = ">= 0.13"
  required_providers {
    aws = {
      version = "~> 3.12"
      source  = "hashicorp/aws"
    }
    cloudflare = {
      source = "cloudflare/cloudflare"
    }
    http = {
      version = "~> 2.0"
      source  = "hashicorp/http"
    }
    template = {
      source = "hashicorp/template"
    }
  }
}
