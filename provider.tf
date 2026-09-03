terraform {
  required_version = "~> 1.16.0"

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.24.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "6.62.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.9.0"
    }
  }
  cloud {
    organization = "zachtech"

    workspaces {
      name = "zachtech-infra"
    }
  }
}

provider "cloudflare" {
}

provider "aws" {
  region = "eu-west-2"
}

provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}