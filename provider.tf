terraform {
  required_version = "1.15.6"

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "5.12.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "5.100.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.7.2"
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