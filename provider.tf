terraform {
  required_version = "~> 1.16.0"

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.25.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "6.65.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.9.1"
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